package com.jf.playlet.controller;

import cn.hutool.core.util.StrUtil;
import com.alibaba.fastjson2.JSONObject;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.jf.playlet.admin.service.ConcurrencyLimitService;
import com.jf.playlet.common.dto.ConcurrencyCheckResult;
import com.jf.playlet.common.dto.CreateVideoRequest;
import com.jf.playlet.common.dto.PageResult;
import com.jf.playlet.common.dto.TaskQueryRequest;
import com.jf.playlet.common.security.SecurityUtils;
import com.jf.playlet.common.security.StpKit;
import com.jf.playlet.common.security.annotation.SaUserCheckLogin;
import com.jf.playlet.common.util.Result;
import com.jf.playlet.entity.VideoGenerationTask;
import com.jf.playlet.mapper.VideoGenerationTaskMapper;
import com.jf.playlet.service.CosService;
import com.jf.playlet.service.PointsDeductService;
import com.jf.playlet.service.SoraService;
import com.jf.playlet.service.VideoTaskCacheService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.annotation.Resource;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/video")
@Tag(name = "视频生成接口")
@SaUserCheckLogin
public class VideoGenerationController {

    @Resource
    private SoraService soraService;

    @Resource
    private VideoGenerationTaskMapper videoGenerationTaskMapper;

    @Resource
    private CosService cosService;

    @Resource
    private VideoTaskCacheService videoTaskCacheService;

    @Resource
    private PointsDeductService pointsDeductService;

    @Resource
    private ConcurrencyLimitService concurrencyLimitService;


    @PostMapping("/create")
    @Operation(summary = "创建视频生成任务")
    public Result<?> createVideo(@Valid @RequestBody CreateVideoRequest request) {
        Long userId = StpKit.USER.getLoginIdAsLong();
        Long siteId = SecurityUtils.getRequiredAppLoginUserSiteId();

        // 并发检查（按用户统计）- 使用原子操作获取槽位
        ConcurrencyCheckResult concurrencyResult = concurrencyLimitService.checkVideoConcurrency(userId);
        if (!concurrencyResult.isAllowed()) {
            return Result.error(concurrencyResult.getMessage(), 429);
        }

        // 检查算力是否充足（根据视频时长）
        if (!pointsDeductService.checkBalanceForVideo(userId, request.getDuration())) {
            // 算力不足，释放并发槽位
            concurrencyLimitService.releaseVideoSlot(userId);
            Integer requiredPoints = pointsDeductService.getRequiredPointsForVideo(userId, request.getDuration());
            return Result.error("算力不足，需要" + requiredPoints + "算力", 400);
        }

        try {
            // 调用Sora API创建视频生成任务
            JSONObject response = soraService.createVideoTask(
                    siteId,
                    request.getModel(),
                    request.getPrompt(),
                    request.getAspectRatio(),
                    request.getDuration(),
                    request.getImageUrls(),
                    request.getChannel()
            );

            // API调用失败处理
            if (response == null || StrUtil.isBlank(soraService.extractTaskId(response))) {
                String errorMsg = response != null ? soraService.extractErrorMessage(response) : "API请求失败";
                log.warn("视频API调用失败: userId={}, error={}", userId, errorMsg);
                concurrencyLimitService.releaseVideoSlot(userId);
                return Result.error(errorMsg, 400);
            }

            String taskId = soraService.extractTaskId(response);

            // 保存任务到数据库
            VideoGenerationTask task = buildTask(userId, siteId, request, taskId);

            int result = videoGenerationTaskMapper.insert(task);
            if (result <= 0) {
                log.error("保存任务失败: user_id={}", userId);
                // 保存失败，释放并发槽位
                concurrencyLimitService.releaseVideoSlot(userId);
                return Result.error("保存任务失败", 500);
            }

            // 扣除算力
            try {
                pointsDeductService.deductForVideoGeneration(userId, task.getId(), request.getDuration());
            } catch (Exception e) {
                log.error("扣除算力失败: {}", e.getMessage());
                // 算力扣除失败，删除任务
                videoGenerationTaskMapper.deleteById(task.getId());
                // 释放并发槽位
                concurrencyLimitService.releaseVideoSlot(userId);
                return Result.error("扣除算力失败: " + e.getMessage(), 400);
            }

            log.info("视频生成任务保存成功: id={}, task_id={}, projectId={}", task.getId(), taskId, task.getProjectId());

            // 保存任务到Redis缓存（3分钟过期）
            videoTaskCacheService.saveTask(task);

            return Result.success(buildResponseData(task), "任务创建成功");

        } catch (Exception e) {
            log.error("创建视频生成任务失败: {}", e.getMessage(), e);
            // 异常时释放并发槽位
            concurrencyLimitService.releaseVideoSlot(userId);
            return Result.error("创建任务失败: " + e.getMessage(), 500);
        }
    }

    @GetMapping("/task/{id}")
    @Operation(summary = "查询视频生成任务状态")
    public Result<?> getTask(@PathVariable Long id) {
        Long userId = StpKit.USER.getLoginIdAsLong();

        try {
            // 先从Redis缓存获取
            VideoGenerationTask task = videoTaskCacheService.getTask(id);

            if (task != null) {
                // 验证任务归属
                if (!task.getUserId().equals(userId)) {
                    return Result.error("无权访问此任务", 403);
                }

                log.info("从Redis缓存获取任务: id={}, status={}", id, task.getStatus());

                // 构建返回数据
                Map<String, Object> data = new HashMap<>();
                data.put("id", task.getId());
                data.put("taskId", task.getTaskId());
                data.put("model", task.getModel());
                data.put("prompt", task.getPrompt());
                data.put("imageUrls", task.getImageUrls());
                data.put("aspectRatio", task.getAspectRatio());
                data.put("duration", task.getDuration());
                data.put("characters", task.getCharacters());
                data.put("status", task.getStatus());
                data.put("progress", task.getProgress());
                data.put("resultUrl", task.getResultUrl());
                data.put("errorMessage", task.getErrorMessage());
                data.put("createdAt", task.getCreatedAt());
                data.put("updatedAt", task.getUpdatedAt());
                data.put("completedAt", task.getCompletedAt());

                return Result.success(data);
            }

            // Redis中没有，从数据库查询
            task = videoGenerationTaskMapper.selectById(id);

            if (task == null) {
                return Result.error("任务不存在", 404);
            }

            if (!task.getUserId().equals(userId)) {
                return Result.error("无权访问此任务", 403);
            }

            log.info("从数据库获取任务: id={}, status={}", id, task.getStatus());

            // 如果任务状态不是已完成或错误，主动查询一次三方接口
            if (!VideoGenerationTask.Status.SUCCEEDED.equals(task.getStatus())
                    && !VideoGenerationTask.Status.ERROR.equals(task.getStatus())
                    && StrUtil.isNotBlank(task.getTaskId())) {

                log.info("任务未完成，主动查询三方接口: id={}, taskId={}, status={}",
                        task.getId(), task.getTaskId(), task.getStatus());

                try {
                    JSONObject response = soraService.queryTaskStatus(task.getSiteId(), task.getTaskId());

                    if (response == null) {
                        log.warn("查询三方接口失败: id={}", task.getId());
                        task.setStatus(VideoGenerationTask.Status.ERROR);
                        task.setErrorMessage("查询三方接口失败");
                        task.setCompletedAt(LocalDateTime.now());
                        concurrencyLimitService.releaseVideoSlot(task.getUserId());
                    } else if (soraService.isTaskCompleted(response)) {
                        // 任务完成
                        String videoUrl = soraService.extractResultUrl(response);

                        if (StrUtil.isNotBlank(videoUrl)) {
                            log.info("任务已完成，开始下载并上传视频: id={}, url={}",
                                    task.getId(), videoUrl);

                            // 同步下载并上传视频
                            String cosUrl = downloadAndUploadVideo(task.getSiteId(), videoUrl);

                            if (StrUtil.isNotBlank(cosUrl)) {
                                task.setStatus(VideoGenerationTask.Status.SUCCEEDED);
                                task.setResultUrl(cosUrl);
                                task.setProgress(100);
                                task.setCompletedAt(LocalDateTime.now());
                                log.info("视频处理成功: id={}, cosUrl={}", task.getId(), cosUrl);

                                // 释放并发槽位
                                concurrencyLimitService.releaseVideoSlot(task.getUserId());
                            } else {
                                log.warn("视频下载或上传失败: id={}", task.getId());
                                task.setStatus(VideoGenerationTask.Status.ERROR);
                                task.setErrorMessage("视频下载或上传失败");
                                task.setCompletedAt(LocalDateTime.now());
                                concurrencyLimitService.releaseVideoSlot(task.getUserId());
                            }
                        } else {
                            log.warn("无法获取视频URL: id={}", task.getId());
                            task.setStatus(VideoGenerationTask.Status.ERROR);
                            task.setErrorMessage("无法获取视频URL");
                            task.setCompletedAt(LocalDateTime.now());
                            concurrencyLimitService.releaseVideoSlot(task.getUserId());
                        }

                    } else if (soraService.isTaskFailed(response)) {
                        String errorMsg = soraService.extractErrorMessage(response);
                        log.warn("第三方返回任务失败: id={}, error={}", task.getId(), errorMsg);
                        task.setStatus(VideoGenerationTask.Status.ERROR);
                        task.setErrorMessage(errorMsg);
                        task.setCompletedAt(LocalDateTime.now());
                        concurrencyLimitService.releaseVideoSlot(task.getUserId());

                    } else {
                        // 任务仍在处理中，更新进度
                        Integer progress = soraService.extractProgress(response);
                        if (progress != null && !progress.equals(task.getProgress())) {
                            task.setProgress(progress);
                        }
                        if (!VideoGenerationTask.Status.RUNNING.equals(task.getStatus())) {
                            task.setStatus(VideoGenerationTask.Status.RUNNING);
                        }
                    }

                    // 保存更新到数据库
                    videoGenerationTaskMapper.updateById(task);

                    // 保存到Redis缓存
                    videoTaskCacheService.saveTask(task);

                } catch (Exception e) {
                    log.error("主动查询任务状态失败: id={}, error={}", task.getId(), e.getMessage(), e);
                    task.setStatus(VideoGenerationTask.Status.ERROR);
                    task.setErrorMessage("查询任务状态失败: " + e.getMessage());
                    task.setCompletedAt(LocalDateTime.now());
                    videoGenerationTaskMapper.updateById(task);
                    videoTaskCacheService.saveTask(task);
                    concurrencyLimitService.releaseVideoSlot(task.getUserId());
                }
            }

            Map<String, Object> data = new HashMap<>();
            data.put("id", task.getId());
            data.put("taskId", task.getTaskId());
            data.put("model", task.getModel());
            data.put("prompt", task.getPrompt());
            data.put("imageUrls", task.getImageUrls());
            data.put("aspectRatio", task.getAspectRatio());
            data.put("duration", task.getDuration());
            data.put("characters", task.getCharacters());
            data.put("status", task.getStatus());
            data.put("progress", task.getProgress());
            data.put("resultUrl", task.getResultUrl());
            data.put("errorMessage", task.getErrorMessage());
            data.put("createdAt", task.getCreatedAt());
            data.put("updatedAt", task.getUpdatedAt());
            data.put("completedAt", task.getCompletedAt());

            return Result.success(data);

        } catch (Exception e) {
            log.error("查询任务失败: {}", e.getMessage(), e);
            return Result.error("查询失败: " + e.getMessage(), 500);
        }
    }

    @GetMapping("/tasks")
    @Operation(summary = "获取视频生成任务列表")
    public Result<?> getTasks(@Valid TaskQueryRequest request) {
        request.validateAndCorrect();

        Long userId = StpKit.USER.getLoginIdAsLong();

        try {
            LambdaQueryWrapper<VideoGenerationTask> queryWrapper = new LambdaQueryWrapper<>();
            queryWrapper.eq(VideoGenerationTask::getUserId, userId);

            if (StrUtil.isNotBlank(request.getStatus())) {
                queryWrapper.eq(VideoGenerationTask::getStatus, request.getStatus());
            }

            // 支持按项目ID筛选
            if (request.getProjectId() != null) {
                queryWrapper.eq(VideoGenerationTask::getProjectId, request.getProjectId());
            }

            queryWrapper.orderByDesc(VideoGenerationTask::getCreatedAt);

            Page<VideoGenerationTask> pageParam = new Page<>(request.getPage(), request.getPageSize());
            IPage<VideoGenerationTask> pageResult = videoGenerationTaskMapper.selectPage(pageParam, queryWrapper);

            return Result.success(PageResult.of(pageResult));

        } catch (Exception e) {
            log.error("查询任务列表失败: {}", e.getMessage(), e);
            return Result.error("查询失败: " + e.getMessage(), 500);
        }
    }

    @DeleteMapping("/task/{id}")
    @Operation(summary = "删除视频生成任务")
    public Result<?> deleteTask(@PathVariable Long id) {
        Long userId = StpKit.USER.getLoginIdAsLong();

        try {
            VideoGenerationTask task = videoGenerationTaskMapper.selectById(id);

            if (task == null) {
                return Result.error("任务不存在", 404);
            }

            if (!task.getUserId().equals(userId)) {
                return Result.error("无权删除此任务", 403);
            }

            videoGenerationTaskMapper.deleteById(id);

            return Result.success(null, "删除成功");

        } catch (Exception e) {
            log.error("删除任务失败: {}", e.getMessage(), e);
            return Result.error("删除失败: " + e.getMessage(), 500);
        }
    }

    private VideoGenerationTask buildTask(Long userId, Long siteId, CreateVideoRequest request, String taskId) {
        VideoGenerationTask task = new VideoGenerationTask();
        task.setUserId(userId);
        task.setSiteId(siteId);
        task.setProjectId(request.getProjectId());
        task.setScriptId(request.getScriptId());
        task.setTaskId(taskId);
        task.setModel(request.getModel());
        task.setPrompt(request.getPrompt());
        task.setAspectRatio(request.getAspectRatio());
        task.setDuration(request.getDuration());
        task.setImageUrls(request.getImageUrls());
        task.setCharacters(request.getCharacters());
        task.setStatus(VideoGenerationTask.Status.PENDING);
        task.setProgress(0);
        return task;
    }

    private Map<String, Object> buildResponseData(VideoGenerationTask task) {
        Map<String, Object> data = new HashMap<>();
        data.put("id", task.getId());
        data.put("taskId", task.getTaskId());
        data.put("status", task.getStatus());
        data.put("progress", task.getProgress());
        data.put("createdAt", task.getCreatedAt());
        return data;
    }

    /**
     * 下载视频并上传到COS
     *
     * @param siteId   站点ID
     * @param videoUrl 第三方视频URL
     * @return COS URL
     */
    private String downloadAndUploadVideo(Long siteId, String videoUrl) {
        try {
            log.info("开始下载视频: {}", videoUrl);

            // 下载视频
            byte[] videoBytes = downloadVideo(videoUrl);

            if (videoBytes == null || videoBytes.length == 0) {
                log.error("视频下载失败");
                return null;
            }

            log.info("视频下载成功，大小: {} MB", videoBytes.length / (1024 * 1024));

            // 从URL中提取文件名
            String fileName = extractFileName(videoUrl);

            // 上传到COS
            log.info("开始上传视频到COS");
            String cosUrl = cosService.uploadFile(siteId, videoBytes, fileName);
            log.info("视频上传成功: {}", cosUrl);

            return cosUrl;

        } catch (Exception e) {
            log.error("下载并上传视频失败: {}", e.getMessage(), e);
            return null;
        }
    }

    /**
     * 下载视频
     *
     * @param videoUrl 视频URL
     * @return 视频字节数组
     */
    private byte[] downloadVideo(String videoUrl) {
        InputStream inputStream = null;
        HttpURLConnection connection = null;

        try {
            URL url = new URL(videoUrl);
            connection = (HttpURLConnection) url.openConnection();
            connection.setConnectTimeout(30000); // 30秒连接超时
            connection.setReadTimeout(300000);   // 5分钟读取超时
            connection.setRequestMethod("GET");
            connection.connect();

            int responseCode = connection.getResponseCode();
            if (responseCode != HttpURLConnection.HTTP_OK) {
                log.error("下载视频失败，HTTP状态码: {}", responseCode);
                return null;
            }

            inputStream = connection.getInputStream();
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            byte[] buffer = new byte[8192];
            int bytesRead;
            long totalBytesRead = 0;

            while ((bytesRead = inputStream.read(buffer)) != -1) {
                outputStream.write(buffer, 0, bytesRead);
                totalBytesRead += bytesRead;

                // 每10MB输出一次进度日志
                if (totalBytesRead % (10 * 1024 * 1024) == 0) {
                    log.info("已下载: {} MB", totalBytesRead / (1024 * 1024));
                }
            }

            return outputStream.toByteArray();

        } catch (Exception e) {
            log.error("下载视频异常: {}", e.getMessage(), e);
            return null;
        } finally {
            try {
                if (inputStream != null) {
                    inputStream.close();
                }
                if (connection != null) {
                    connection.disconnect();
                }
            } catch (Exception e) {
                log.error("关闭连接异常: {}", e.getMessage());
            }
        }
    }

    /**
     * 从URL中提取文件名
     *
     * @param videoUrl 视频URL
     * @return 文件名
     */
    private String extractFileName(String videoUrl) {
        try {
            String path = new URL(videoUrl).getPath();
            String fileName = path.substring(path.lastIndexOf('/') + 1);

            // 如果文件名为空或没有扩展名，使用默认值
            if (fileName.isEmpty() || !fileName.contains(".")) {
                return "video.mp4";
            }

            // 移除URL参数（如果有）
            int queryIndex = fileName.indexOf('?');
            if (queryIndex > 0) {
                fileName = fileName.substring(0, queryIndex);
            }

            return fileName;
        } catch (Exception e) {
            log.warn("提取文件名失败，使用默认值: video.mp4");
            return "video.mp4";
        }
    }
}
