package com.jf.playlet.admin.dto.request;

import lombok.Data;

/**
 * 管理员调整算力请求
 */
@Data
public class PointsAdjustRequest {

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 类型: 1-增加 2-扣减
     */
    private Integer type;

    /**
     * 算力值（正数）
     */
    private Integer points;

    /**
     * 备注
     */
    private String remark;
}
