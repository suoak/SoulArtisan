package com.jf.playlet.common.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * 视频生成回调请求参数
 * 格式: { "task_id": "xxx", "status": "success/failed", "result": { "url": "xxx" }, "error": "xxx" }
 */
@Data
@Schema(description = "视频生成回调请求参数")
public class VideoCallbackRequest {

    @NotBlank(message = "task_id不能为空")
    @Schema(description = "视频生成任务ID", example = "task_abc123def456")
    private String task_id;

    @NotBlank(message = "status不能为空")
    @Schema(description = "任务状态: success/failed", example = "success")
    private String status;

    @Schema(description = "结果数据")
    private ResultData result;

    @Schema(description = "错误信息（失败时）", example = "generation failed: content policy violation")
    private String error;

    /**
     * 结果数据
     */
    @Data
    public static class ResultData {
        @Schema(description = "视频URL")
        private String url;
    }
}
