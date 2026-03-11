package com.jf.playlet.common.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * 站点公开配置响应（用于用户端展示，不含敏感信息）
 */
@Data
@Schema(description = "站点公开配置响应")
public class SitePublicConfigResponse {

    @Schema(description = "站点ID")
    private Long siteId;

    @Schema(description = "站点编码")
    private String siteCode;

    @Schema(description = "站点名称")
    private String siteName;

    @Schema(description = "站点显示名称（用户看到的名称，如未设置则使用siteName）")
    private String displayName;

    @Schema(description = "站点域名")
    private String domain;

    @Schema(description = "Logo URL")
    private String logo;

    @Schema(description = "网站图标URL")
    private String favicon;

    @Schema(description = "主题色")
    private String themeColor;

    @Schema(description = "站点描述")
    private String description;

    @Schema(description = "页脚文字")
    private String footerText;

    @Schema(description = "版权信息")
    private String copyright;

    @Schema(description = "是否开启注册")
    private Boolean enableRegister;

    @Schema(description = "联系地址")
    private String contactAddress;

    @Schema(description = "联系电话")
    private String contactPhone;

    @Schema(description = "联系邮箱")
    private String contactEmail;
}
