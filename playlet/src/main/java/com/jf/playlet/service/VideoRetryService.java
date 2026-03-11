// package com.jf.playlet.service;
//
// import cn.hutool.core.util.StrUtil;
// import com.alibaba.fastjson2.JSONObject;
// import com.jf.playlet.admin.service.ConcurrencyLimitService;
// import com.jf.playlet.common.util.RedisUtil;
// import com.jf.playlet.entity.VideoGenerationTask;
// import com.jf.playlet.entity.VideoResource;
// import com.jf.playlet.mapper.VideoGenerationTaskMapper;
// import com.jf.playlet.mapper.VideoResourceMapper;
// import jakarta.annotation.Resource;
// import lombok.extern.slf4j.Slf4j;
// import org.springframework.scheduling.annotation.Scheduled;
// import org.springframework.stereotype.Service;
//
// import java.io.ByteArrayOutputStream;
// import java.io.InputStream;
// import java.net.HttpURLConnection;
// import java.net.URL;
// import java.time.LocalDateTime;
// import java.util.List;
//
// @Slf4j
// @Service
// public class VideoRetryService {
//
//     private static final String QUEUE_KEY = "video:retry:queue";
//     private static final String CIRCUIT_KEY = "video:retry:circuit_open";
//     private static final String CALLBACK_QUEUE_KEY = "video:callback:retry:queue";
//
//     @Resource
//     private SoraService soraService;
//
//     @Resource
//     private VideoGenerationTaskMapper videoGenerationTaskMapper;
//
//     @Resource
//     private VideoTaskCacheService videoTaskCacheService;
//
//     @Resource
//     private CosService cosService;
//
//     @Resource
//     private VideoResourceMapper videoResourceMapper;
//
//     @Resource
//     private ConcurrencyLimitService concurrencyLimitService;
//
//     @Resource
//     private VideoErrorJudgeService videoErrorJudgeService;
//
//     // 检查熔断是否开启
//     public boolean isCircuitOpen() {
//         return "1".equals(RedisUtil.getStr(CIRCUIT_KEY));
//     }
//
//     // 开启熔断
//     public void openCircuit() {
//         RedisUtil.set(CIRCUIT_KEY, "1");
//         log.warn("视频API熔断已开启");
//     }
//
//     // 关闭熔断
//     public void closeCircuit() {
//         RedisUtil.delete(CIRCUIT_KEY);
//         log.info("视频API熔断已关闭");
//     }
//
//     // 任务入队（右侧推入，左侧弹出，保证FIFO）
//     public void enqueue(Long taskId) {
//         RedisUtil.lRightPush(QUEUE_KEY, taskId);
//         log.info("任务入队: taskId={}, 队列长度={}", taskId, RedisUtil.lSize(QUEUE_KEY));
//     }
//
//     // 每10分钟执行重试
//     @Scheduled(fixedRate = 600000)
//     public void retryTasks() {
//         long queueSize = RedisUtil.lSize(QUEUE_KEY);
//         if (queueSize == 0) {
//             return;
//         }
//
//         log.info("开始视频重试任务，队列中有{}个任务", queueSize);
//
//         // 取队列第一个任务作为试探
//         Long probeTaskId = RedisUtil.lLeftPop(QUEUE_KEY);
//         if (probeTaskId == null) {
//             return;
//         }
//
//         VideoGenerationTask probeTask = videoGenerationTaskMapper.selectById(probeTaskId);
//         if (probeTask == null) {
//             log.warn("试探任务不存在: id={}", probeTaskId);
//             consumeRemaining();
//             return;
//         }
//
//         // 试探调用API
//         boolean success = submitTask(probeTask);
//         if (!success) {
//             // 试探失败，放回队列头部
//             RedisUtil.lLeftPush(QUEUE_KEY, probeTaskId);
//             log.warn("试探失败，任务放回队列头部: id={}", probeTaskId);
//             return;
//         }
//
//         // 试探成功，关闭熔断，消费剩余任务
//         closeCircuit();
//         log.info("试探成功，开始批量消费剩余任务");
//         consumeRemaining();
//     }
//
//     // 消费队列中剩余任务
//     private void consumeRemaining() {
//         while (true) {
//             Long taskId = RedisUtil.lLeftPop(QUEUE_KEY);
//             if (taskId == null) {
//                 break;
//             }
//
//             VideoGenerationTask task = videoGenerationTaskMapper.selectById(taskId);
//             if (task == null) {
//                 log.warn("队列中的任务不存在: id={}", taskId);
//                 continue;
//             }
//
//             // 已有taskId说明已经提交过，跳过
//             if (StrUtil.isNotBlank(task.getTaskId())) {
//                 log.info("任务已提交过，跳过: id={}, taskId={}", task.getId(), task.getTaskId());
//                 continue;
//             }
//
//             boolean success = submitTask(task);
//             if (!success) {
//                 // 提交失败，重新开启熔断，当前任务和剩余任务留在队列
//                 RedisUtil.lLeftPush(QUEUE_KEY, taskId);
//                 openCircuit();
//                 log.warn("批量消费时失败，重新开启熔断: id={}", taskId);
//                 break;
//             }
//         }
//     }
//
//     // 调用API并更新任务
//     public boolean submitTask(VideoGenerationTask task) {
//         JSONObject response = soraService.createVideoTask(
//                 task.getSiteId(),
//                 task.getModel(),
//                 task.getPrompt(),
//                 task.getAspectRatio(),
//                 task.getDuration(),
//                 task.getImageUrls(),
//                 task.getCharacters()
//         );
//
//         if (response == null) {
//             log.error("重试提交任务失败(response=null): id={}", task.getId());
//             return false;
//         }
//
//         String taskId = soraService.extractTaskId(response);
//         if (StrUtil.isBlank(taskId)) {
//             log.error("重试提交任务失败(taskId为空): id={}, response={}", task.getId(), response.toJSONString());
//             return false;
//         }
//
//         // 更新数据库
//         task.setTaskId(taskId);
//         task.setStatus(VideoGenerationTask.Status.PENDING);
//         videoGenerationTaskMapper.updateById(task);
//
//         // 更新缓存
//         videoTaskCacheService.saveTask(task);
//
//         log.info("重试提交任务成功: id={}, taskId={}", task.getId(), taskId);
//         return true;
//     }
//
//     // ==================== 回调重试相关 ====================
//
//     // 回调任务入队（存储 JSON: {taskId, siteId, videoUrl}）
//     public void enqueueCallback(Long taskId, Long siteId, String videoUrl) {
//         JSONObject data = new JSONObject();
//         data.put("taskId", taskId);
//         data.put("siteId", siteId);
//         data.put("videoUrl", videoUrl);
//         RedisUtil.lRightPush(CALLBACK_QUEUE_KEY, data.toJSONString());
//         log.info("回调任务入队: taskId={}, 队列长度={}", taskId, RedisUtil.lSize(CALLBACK_QUEUE_KEY));
//     }
//
//     // 每5分钟执行回调重试
//     @Scheduled(fixedRate = 300000)
//     public void retryCallbacks() {
//         long queueSize = RedisUtil.lSize(CALLBACK_QUEUE_KEY);
//         if (queueSize == 0) {
//             return;
//         }
//
//         log.info("开始回调重试任务，队列中有{}个任务", queueSize);
//
//         while (true) {
//             String dataStr = RedisUtil.lLeftPop(CALLBACK_QUEUE_KEY);
//             if (dataStr == null) {
//                 break;
//             }
//
//             JSONObject data = JSONObject.parseObject(dataStr);
//             Long taskId = data.getLong("taskId");
//             Long siteId = data.getLong("siteId");
//             String videoUrl = data.getString("videoUrl");
//
//             boolean success = processCallback(taskId, siteId, videoUrl);
//             if (!success) {
//                 // 失败放回队列尾部，等下次重试
//                 RedisUtil.lRightPush(CALLBACK_QUEUE_KEY, dataStr);
//                 log.warn("回调重试失败，放回队列: taskId={}", taskId);
//                 break;
//             }
//         }
//     }
//
//     // 处理回调重试
//     private boolean processCallback(Long taskId, Long siteId, String videoUrl) {
//         VideoGenerationTask task = videoGenerationTaskMapper.selectById(taskId);
//         if (task == null) {
//             log.warn("回调重试任务不存在: id={}", taskId);
//             return true;
//         }
//
//         // 已完成，跳过
//         if (VideoGenerationTask.Status.SUCCEEDED.equals(task.getStatus())) {
//             log.info("任务已完成，跳过: id={}", taskId);
//             return true;
//         }
//
//         // 没有videoUrl，说明是第三方回调失败的情况，需要重新查询API获取结果
//         if (StrUtil.isBlank(videoUrl)) {
//             return retryQueryAndProcess(task);
//         }
//
//         // 有videoUrl，直接重试下载上传
//         return retryDownloadAndUpload(task, siteId, videoUrl);
//     }
//
//     // 重新查询第三方API状态并处理
//     private boolean retryQueryAndProcess(VideoGenerationTask task) {
//         if (StrUtil.isBlank(task.getTaskId())) {
//             log.warn("任务没有taskId，无法查询状态: id={}", task.getId());
//             return false;
//         }
//
//         log.info("重新查询第三方API状态: id={}, taskId={}", task.getId(), task.getTaskId());
//
//         JSONObject response = soraService.queryTaskStatus(task.getSiteId(), task.getTaskId());
//         if (response == null) {
//             log.error("查询任务状态失败(response=null): id={}", task.getId());
//             return false;
//         }
//
//         // 检查是否完成
//         if (soraService.isTaskCompleted(response)) {
//             String resultUrl = soraService.extractResultUrl(response);
//             if (StrUtil.isBlank(resultUrl)) {
//                 log.error("任务已完成但无法获取视频URL: id={}", task.getId());
//                 return false;
//             }
//             return retryDownloadAndUpload(task, task.getSiteId(), resultUrl);
//         }
//
//         // 仍然失败
//         if (soraService.isTaskFailed(response)) {
//             String errorMsg = soraService.extractErrorMessage(response);
//
//             // 判断是否为不可重试的错误
//             if (videoErrorJudgeService.isNonRetryableError(errorMsg)) {
//                 log.warn("第三方任务失败（不可重试），标记为错误: id={}, taskId={}, error={}",
//                         task.getId(), task.getTaskId(), errorMsg);
//                 task.setStatus(VideoGenerationTask.Status.ERROR);
//                 task.setErrorMessage(errorMsg);
//                 task.setCompletedAt(LocalDateTime.now());
//
//                 videoTaskCacheService.updateTask(task);
//                 videoGenerationTaskMapper.updateById(task);
//
//                 // 释放并发槽位
//                 concurrencyLimitService.releaseVideoSlot(task.getUserId());
//
//                 // 更新关联的 VideoResource 为失败状态
//                 updateVideoResourceError(task.getTaskId(), errorMsg);
//
//                 return true; // 返回true表示处理完成，不再重试
//             }
//
//             log.warn("第三方任务仍然失败，继续等待: id={}, taskId={}, error={}",
//                     task.getId(), task.getTaskId(), errorMsg);
//             return false;
//         }
//
//         // 还在处理中，更新进度
//         Integer progress = soraService.extractProgress(response);
//         if (progress != null) {
//             task.setProgress(progress);
//         }
//         if (!VideoGenerationTask.Status.RUNNING.equals(task.getStatus())) {
//             task.setStatus(VideoGenerationTask.Status.RUNNING);
//         }
//         videoGenerationTaskMapper.updateById(task);
//         videoTaskCacheService.saveTask(task);
//         log.info("任务仍在处理中，继续等待: id={}, progress={}", task.getId(), progress);
//         return false;
//     }
//
//     // 重试下载并上传到COS
//     private boolean retryDownloadAndUpload(VideoGenerationTask task, Long siteId, String videoUrl) {
//         log.info("开始重试下载视频: id={}, url={}", task.getId(), videoUrl);
//
//         byte[] videoBytes = downloadVideo(videoUrl);
//         if (videoBytes == null || videoBytes.length == 0) {
//             log.error("重试下载视频失败: id={}", task.getId());
//             return false;
//         }
//
//         log.info("视频下载成功，大小: {} MB, id={}", videoBytes.length / (1024 * 1024), task.getId());
//
//         String fileName = extractFileName(videoUrl);
//         String cosUrl = cosService.uploadFile(siteId, videoBytes, fileName);
//
//         if (StrUtil.isBlank(cosUrl)) {
//             log.error("重试上传视频到COS失败: id={}", task.getId());
//             return false;
//         }
//
//         log.info("视频上传成功: id={}, cosUrl={}", task.getId(), cosUrl);
//
//         // 更新任务状态
//         task.setStatus(VideoGenerationTask.Status.SUCCEEDED);
//         task.setResultUrl(cosUrl);
//         task.setProgress(100);
//         task.setCompletedAt(LocalDateTime.now());
//
//         videoTaskCacheService.updateTask(task);
//         videoGenerationTaskMapper.updateById(task);
//
//         // 释放并发槽位
//         concurrencyLimitService.releaseVideoSlot(task.getUserId());
//
//         // 更新关联的 VideoResource
//         updateVideoResource(task.getTaskId(), cosUrl);
//
//         log.info("回调重试成功: id={}, cosUrl={}", task.getId(), cosUrl);
//         return true;
//     }
//
//     private void updateVideoResource(String videoTaskId, String videoUrl) {
//         if (StrUtil.isBlank(videoTaskId)) {
//             return;
//         }
//
//         List<VideoResource> resources = videoResourceMapper.selectByVideoTaskId(videoTaskId);
//         if (resources == null || resources.isEmpty()) {
//             return;
//         }
//
//         for (VideoResource resource : resources) {
//             resource.setVideoResultUrl(videoUrl);
//             if (VideoResource.Status.VIDEO_GENERATING.equals(resource.getStatus())) {
//                 resource.setStatus(VideoResource.Status.VIDEO_GENERATED);
//             }
//             videoResourceMapper.updateById(resource);
//             log.info("更新 VideoResource 视频URL: id={}, videoTaskId={}", resource.getId(), videoTaskId);
//         }
//     }
//
//     private void updateVideoResourceError(String videoTaskId, String errorMessage) {
//         if (StrUtil.isBlank(videoTaskId)) {
//             return;
//         }
//
//         List<VideoResource> resources = videoResourceMapper.selectByVideoTaskId(videoTaskId);
//         if (resources == null || resources.isEmpty()) {
//             return;
//         }
//
//         for (VideoResource resource : resources) {
//             resource.setStatus(VideoResource.Status.FAILED);
//             resource.setErrorMessage(errorMessage);
//             videoResourceMapper.updateById(resource);
//             log.info("更新 VideoResource 为失败状态: id={}, videoTaskId={}", resource.getId(), videoTaskId);
//         }
//     }
//
//     private byte[] downloadVideo(String videoUrl) {
//         InputStream inputStream = null;
//         HttpURLConnection connection = null;
//
//         try {
//             URL url = new URL(videoUrl);
//             connection = (HttpURLConnection) url.openConnection();
//             connection.setConnectTimeout(30000);
//             connection.setReadTimeout(300000);
//             connection.setRequestMethod("GET");
//             connection.connect();
//
//             int responseCode = connection.getResponseCode();
//             if (responseCode != HttpURLConnection.HTTP_OK) {
//                 log.error("下载视频失败，HTTP状态码: {}", responseCode);
//                 return null;
//             }
//
//             inputStream = connection.getInputStream();
//             ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
//             byte[] buffer = new byte[8192];
//             int bytesRead;
//
//             while ((bytesRead = inputStream.read(buffer)) != -1) {
//                 outputStream.write(buffer, 0, bytesRead);
//             }
//
//             return outputStream.toByteArray();
//
//         } catch (Exception e) {
//             log.error("下载视频异常: {}", e.getMessage(), e);
//             return null;
//         } finally {
//             try {
//                 if (inputStream != null) inputStream.close();
//                 if (connection != null) connection.disconnect();
//             } catch (Exception ignored) {
//             }
//         }
//     }
//
//     private String extractFileName(String videoUrl) {
//         try {
//             String path = new URL(videoUrl).getPath();
//             String fileName = path.substring(path.lastIndexOf('/') + 1);
//             if (fileName.isEmpty() || !fileName.contains(".")) {
//                 return "video.mp4";
//             }
//             int queryIndex = fileName.indexOf('?');
//             if (queryIndex > 0) {
//                 fileName = fileName.substring(0, queryIndex);
//             }
//             return fileName;
//         } catch (Exception e) {
//             return "video.mp4";
//         }
//     }
// }
