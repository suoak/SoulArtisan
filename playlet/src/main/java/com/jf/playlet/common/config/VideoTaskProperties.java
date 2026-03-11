package com.jf.playlet.common.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

/**
 * 视频任务配置属性
 */
@Data
@Component
@ConfigurationProperties(prefix = "video-task")
public class VideoTaskProperties {

    /**
     * 不可重试的错误信息列表（模糊匹配）
     */
    private List<String> nonRetryableErrors = new ArrayList<>();
}
