package com.jf.playlet.service.ai;

import com.fasterxml.jackson.databind.MapperFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.jf.playlet.admin.entity.PointsConfig;
import com.jf.playlet.common.security.SecurityUtils;
import com.jf.playlet.service.PointsDeductService;
import com.jf.playlet.service.SiteConfigProvider;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.model.ChatResponse;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.ai.openai.OpenAiChatModel;
import org.springframework.ai.openai.OpenAiChatOptions;
import org.springframework.ai.openai.api.OpenAiApi;
import org.springframework.http.HttpHeaders;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.util.concurrent.ConcurrentHashMap;

/**
 * Gemini ChatModel 工厂
 * 从数据库读取 API 配置，动态创建 OpenAiChatModel
 */
@Slf4j
@Component
public class GeminiChatClientFactory {

    private final SiteConfigProvider siteConfigProvider;
    private final PointsDeductService pointsDeductService;

    /**
     * ChatModel 缓存：key = siteId
     */
    private final ConcurrentHashMap<Long, OpenAiChatModel> modelCache = new ConcurrentHashMap<>();

    public GeminiChatClientFactory(SiteConfigProvider siteConfigProvider, PointsDeductService pointsDeductService) {
        this.siteConfigProvider = siteConfigProvider;
        this.pointsDeductService = pointsDeductService;
    }

    /**
     * 获取指定站点的 ChatModel
     *
     * @param siteId 站点ID
     * @return OpenAiChatModel 实例
     */
    public OpenAiChatModel getChatModel(Long siteId) {
        return modelCache.computeIfAbsent(siteId, this::createChatModel);
    }

    /**
     * 刷新指定站点的 ChatModel 缓存（配置变更时调用）
     *
     * @param siteId 站点ID
     */
    public void refreshClient(Long siteId) {
        OpenAiChatModel removed = modelCache.remove(siteId);
        if (removed != null) {
            log.info("已刷新站点 {} 的 ChatModel 缓存", siteId);
        }
    }

    /**
     * 刷新所有 ChatModel 缓存
     */
    public void refreshAllClients() {
        modelCache.clear();
        log.info("已刷新所有 ChatModel 缓存");
    }

    /**
     * 创建 ChatModel
     */
    private OpenAiChatModel createChatModel(Long siteId) {
        log.info("为站点 {} 创建新的 ChatModel", siteId);

        // 从数据库读取配置
        SiteConfigProvider.GeminiApiConfig config = siteConfigProvider.getGeminiApiConfig(siteId);

        // 配置支持枚举大小写不敏感的 ObjectMapper
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.enable(MapperFeature.ACCEPT_CASE_INSENSITIVE_ENUMS);

        // 自定义 RestClient.Builder
        RestClient.Builder restClientBuilder = RestClient.builder()
                .messageConverters(converters -> {
                    converters.clear();
                    converters.add(new MappingJackson2HttpMessageConverter(objectMapper));
                })
                .requestInterceptor((request, body, execution) -> {
                    request.getHeaders().set(HttpHeaders.AUTHORIZATION, config.getApiKey());
                    return execution.execute(request, body);
                });

        OpenAiApi openAiApi = OpenAiApi.builder()
                .baseUrl(config.getApiUrl())
                .apiKey("placeholder")
                .restClientBuilder(restClientBuilder)
                .build();

        // 创建 ChatModel
        OpenAiChatModel chatModel = OpenAiChatModel.builder()
                .openAiApi(openAiApi)
                .defaultOptions(OpenAiChatOptions.builder()
                        .model("gemini-2.5-flash")
                        .temperature(0.7)
                        .build())
                .build();

        log.info("站点 {} 的 ChatModel 创建成功, apiUrl={}", siteId, config.getApiUrl());

        return chatModel;
    }

    /**
     * 调用 ChatModel 并自动扣除算力
     * 从 SecurityUtils 获取当前登录用户ID
     *
     * @param siteId 站点ID
     * @param prompt 请求
     * @return ChatResponse
     */
    public ChatResponse callWithPointsDeduct(Long siteId, Prompt prompt) {
        Long userId = SecurityUtils.getAppLoginUserId();
        return callWithPointsDeduct(siteId, userId, prompt);
    }

    /**
     * 调用 ChatModel 并自动扣除算力
     *
     * @param siteId 站点ID
     * @param userId 用户ID
     * @param prompt 请求
     * @return ChatResponse
     */
    public ChatResponse callWithPointsDeduct(Long siteId, Long userId, Prompt prompt) {
        // 检查算力
        if (userId != null && !pointsDeductService.checkBalance(userId, PointsConfig.ConfigKey.GEMINI_CHAT)) {
            Integer requiredPoints = pointsDeductService.getRequiredPoints(userId, PointsConfig.ConfigKey.GEMINI_CHAT);
            throw new RuntimeException("算力不足，需要" + requiredPoints + "算力");
        }

        // 调用 API
        OpenAiChatModel chatModel = getChatModel(siteId);
        ChatResponse response = chatModel.call(prompt);

        // 扣除算力
        if (userId != null) {
            try {
                pointsDeductService.deductForGeminiChat(userId, null);
            } catch (Exception e) {
                log.warn("扣除算力失败: {}", e.getMessage());
            }
        }

        return response;
    }
}
