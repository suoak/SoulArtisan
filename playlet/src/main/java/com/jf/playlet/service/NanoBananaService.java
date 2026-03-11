package com.jf.playlet.service;

import cn.hutool.core.util.StrUtil;
import com.alibaba.fastjson2.JSONObject;
import com.jf.playlet.common.util.HttpClientUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class NanoBananaService {

    @Autowired
    private SiteConfigProvider siteConfigProvider;

    public JSONObject textToImage(Long siteId, String prompt, String model, String aspectRatio, String imageSize, String channel) {
        SiteConfigProvider.PrismApiConfig config = siteConfigProvider.getPrismApiConfig(siteId);
        String url = config.getApiUrl() + "/v1/capabilities/" + model;

        Map<String, Object> data = new HashMap<>();
        // Prism API 使用 channel 参数替代 model
        prompt = "Clean image, no text, no logos, no subtitles, no watermarks." + prompt;
        data.put("prompt", prompt);
        data.put("aspect_ratio", StrUtil.isBlank(aspectRatio) ? "1:1" : aspectRatio);

        // 传递渠道标识
        if (StrUtil.isNotBlank(channel)) {
            data.put("channel", channel);
        }

        return sendRequest(url, data, "POST", config.getApiKey());
    }

    public JSONObject imageToImage(Long siteId, String prompt, List<String> imageUrls, String model, String aspectRatio, String imageSize, String channel) {
        SiteConfigProvider.PrismApiConfig config = siteConfigProvider.getPrismApiConfig(siteId);
        String url = config.getApiUrl() + "/v1/capabilities/" + model;

        Map<String, Object> data = new HashMap<>();
        // Prism API 使用 channel 参数替代 model
        prompt = "Clean image, no text, no logos, no subtitles, no watermarks." + prompt;
        data.put("prompt", prompt);
        data.put("aspect_ratio", StrUtil.isBlank(aspectRatio) ? "1:1" : aspectRatio);
        data.put("image_urls", imageUrls);

        // 传递渠道标识
        if (StrUtil.isNotBlank(channel)) {
            data.put("channel", channel);
        }

        log.info("[ImageToImage] 调用Prism API: url={}, prompt={}, aspectRatio={}",
                url, prompt, aspectRatio);

        return sendRequest(url, data, "POST", config.getApiKey());
    }

    public JSONObject queryTaskStatus(Long siteId, String taskId) {
        SiteConfigProvider.PrismApiConfig config = siteConfigProvider.getPrismApiConfig(siteId);
        String url = config.getApiUrl() + "/v1/tasks/" + taskId;
        return sendRequest(url, null, "GET", config.getApiKey());
    }

    private JSONObject sendRequest(String url, Map<String, Object> data, String method, String apiKey) {
        try {
            Map<String, String> headers = new HashMap<>();
            headers.put("Authorization", apiKey);

            if ("POST".equalsIgnoreCase(method)) {
                return HttpClientUtil.sendPostRequest(url, data, headers);
            } else if ("GET".equalsIgnoreCase(method)) {
                return HttpClientUtil.sendGetRequest(url, headers);
            }

            return null;

        } catch (Exception e) {
            log.error("Prism API请求异常: {}", e.getMessage(), e);
            return null;
        }
    }

    /**
     * 从响应中提取任务ID
     * Prism API 返回格式: { data: { task_id: "xxx" } }
     */
    public String extractTaskId(JSONObject response) {
        if (response == null) {
            return null;
        }

        // 优先从 data.task_id 获取
        JSONObject data = response.getJSONObject("data");
        if (data != null && data.containsKey("task_id")) {
            return data.getString("task_id");
        }

        // 兼容直接返回 task_id 的格式
        if (response.containsKey("task_id")) {
            return response.getString("task_id");
        }

        return null;
    }

    /**
     * 检查任务是否已完成
     * Prism API 返回格式: { data: { status: "succeeded" } }
     */
    public boolean isTaskCompleted(JSONObject response) {
        if (response == null) {
            return false;
        }

        // 从 data.status 检查是否完成
        JSONObject data = response.getJSONObject("data");
        if (data != null && data.containsKey("status")) {
            String status = data.getString("status");
            return "success".equals(status) || "completed".equals(status);
        }

        return false;
    }

    /**
     * 检查任务是否失败
     * Prism API 返回格式: { data: { status: "failed", error: "xxx" } }
     */
    public boolean isTaskFailed(JSONObject response) {
        if (response == null) {
            return false;
        }

        // 检查 code 是否非0
        Integer code = response.getInteger("code");
        if (code != null && code != 0) {
            return true;
        }

        // 从 data.status 检查是否失败
        JSONObject data = response.getJSONObject("data");
        if (data != null) {
            String status = data.getString("status");
            if ("failed".equals(status) || "error".equals(status)) {
                return true;
            }
            // 检查 error 字段是否有内容
            String error = data.getString("error");
            if (StrUtil.isNotBlank(error)) {
                return true;
            }
        }

        return false;
    }

    /**
     * 从响应中提取结果URL
     * Prism API 返回格式: { data: { result: "url" } }
     */
    public String extractResultUrl(JSONObject response) {
        if (response == null) {
            return null;
        }

        // 获取 data 对象
        JSONObject data = response.getJSONObject("data");
        if (data == null) {
            return null;
        }

        // 从 data.result 获取结果
        Object result = data.get("result");
        if (result != null) {
            // 如果 result 是字符串，直接返回
            if (result instanceof String) {
                return (String) result;
            }
            // 如果 result 是对象，尝试获取 url 字段
            if (result instanceof JSONObject) {
                JSONObject resultObj = (JSONObject) result;
                if (resultObj.containsKey("url")) {
                    return resultObj.getString("url");
                }
            }
        }

        return null;
    }

    /**
     * 从响应中提取错误信息
     * Prism API 返回格式: { message: "xxx", data: { error: "xxx" } }
     */
    public String extractErrorMessage(JSONObject response) {
        if (response == null) {
            return "Unknown error";
        }

        // 优先从 data.error 获取
        JSONObject data = response.getJSONObject("data");
        if (data != null && StrUtil.isNotBlank(data.getString("error"))) {
            return data.getString("error");
        }

        // 从 message 字段获取错误信息
        if (response.containsKey("message") && StrUtil.isNotBlank(response.getString("message"))) {
            String msg = response.getString("message");
            if (!"success".equalsIgnoreCase(msg)) {
                return msg;
            }
        }

        return "Unknown error";
    }
}
