package com.jf.playlet.controller;

import com.alibaba.fastjson2.JSONObject;
import com.jf.playlet.common.security.SecurityUtils;
import com.jf.playlet.common.security.annotation.SaUserCheckLogin;
import com.jf.playlet.common.util.HttpClientUtil;
import com.jf.playlet.common.util.Result;
import com.jf.playlet.service.SiteConfigProvider;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.annotation.Resource;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/capabilities")
@Tag(name = "能力渠道接口")
@SaUserCheckLogin
public class CapabilityController {

    @Resource
    private SiteConfigProvider siteConfigProvider;

    @GetMapping("/chatModels")
    @Operation(summary = "获取对话模型列表")
    public Result<?> getChatModels() {
        Long siteId = SecurityUtils.getRequiredAppLoginUserSiteId();

        try {
            SiteConfigProvider.GeminiApiConfig config = siteConfigProvider.getGeminiApiConfig(siteId);
            String url = config.getApiUrl() + "/v1/models";

            Map<String, String> headers = new HashMap<>();
            headers.put("Authorization", config.getApiKey());

            JSONObject response = HttpClientUtil.sendGetRequest(url, headers);

            if (response == null) {
                return Result.error("获取对话模型列表失败", 500);
            }

            // /v1/models 返回 OpenAI 格式：{ object: "list", data: [...] }
            Object data = response.get("data");
            if (data == null) {
                return Result.success(new ArrayList<>());
            }

            return Result.success(data);

        } catch (Exception e) {
            log.error("获取对话模型列表失败: {}", e.getMessage(), e);
            return Result.error("获取对话模型列表失败: " + e.getMessage(), 500);
        }
    }

    @GetMapping
    @Operation(summary = "获取能力渠道列表")
    public Result<?> getCapabilities() {
        Long siteId = SecurityUtils.getRequiredAppLoginUserSiteId();

        try {
            // 获取 Prism API 配置
            SiteConfigProvider.PrismApiConfig config = siteConfigProvider.getPrismApiConfig(siteId);
            String url = config.getApiUrl() + "/v1/capabilities";

            // 调用 Prism API
            Map<String, String> headers = new HashMap<>();
            headers.put("Authorization", config.getApiKey());

            JSONObject response = HttpClientUtil.sendGetRequest(url, headers);

            if (response == null) {
                return Result.error("获取能力列表失败", 500);
            }

            // 检查返回码
            Integer code = response.getInteger("code");
            if (code != null && code != 0) {
                String message = response.getString("message");
                return Result.error(message != null ? message : "获取能力列表失败", 500);
            }

            // 提取 data 字段
            Object data = response.get("data");
            if (data == null) {
                return Result.success(new ArrayList<>());
            }

            return Result.success(data);

        } catch (Exception e) {
            log.error("获取能力列表失败: {}", e.getMessage(), e);
            return Result.error("获取能力列表失败: " + e.getMessage(), 500);
        }
    }
}
