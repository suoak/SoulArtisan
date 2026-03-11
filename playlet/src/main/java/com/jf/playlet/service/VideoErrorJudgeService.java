package com.jf.playlet.service;

import cn.hutool.core.util.StrUtil;
import com.jf.playlet.common.config.VideoTaskProperties;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * 视频错误判断服务
 * 用于判断错误信息是否属于不可重试的错误
 */
@Slf4j
@Service
public class VideoErrorJudgeService {

    private final VideoTaskProperties videoTaskProperties;

    public VideoErrorJudgeService(VideoTaskProperties videoTaskProperties) {
        this.videoTaskProperties = videoTaskProperties;
    }

    /**
     * 判断错误信息是否为不可重试的错误
     * 使用模糊匹配（忽略大小写）
     *
     * @param errorMessage 错误信息
     * @return true: 不可重试，应直接返回失败；false: 可以重试
     */
    public boolean isNonRetryableError(String errorMessage) {
        if (StrUtil.isBlank(errorMessage)) {
            return false;
        }

        String lowerError = errorMessage.toLowerCase();

        for (String pattern : videoTaskProperties.getNonRetryableErrors()) {
            if (StrUtil.isNotBlank(pattern) && lowerError.contains(pattern.toLowerCase())) {
                log.info("检测到不可重试的错误: pattern={}, error={}", pattern, errorMessage);
                return true;
            }
        }

        return false;
    }

    /**
     * 判断错误信息是否可以重试
     *
     * @param errorMessage 错误信息
     * @return true: 可以重试；false: 不可重试
     */
    public boolean isRetryableError(String errorMessage) {
        return !isNonRetryableError(errorMessage);
    }
}
