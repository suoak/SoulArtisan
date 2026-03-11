package com.jf.playlet.admin.dto.request;

import lombok.Data;

/**
 * 算力记录查询请求
 */
@Data
public class PointsRecordQueryRequest {

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 用户名（模糊查询）
     */
    private String username;

    /**
     * 类型: 1-收入 2-支出
     */
    private Integer type;

    /**
     * 来源
     */
    private String source;
}
