package com.jf.playlet.admin.controller;

import com.jf.playlet.admin.annotation.AdminLog;
import com.jf.playlet.admin.annotation.RequireSystemAdmin;
import com.jf.playlet.admin.entity.PointsConfig;
import com.jf.playlet.admin.service.PointsConfigService;
import com.jf.playlet.common.security.annotation.SaAdminCheckLogin;
import com.jf.playlet.common.util.Result;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 算力配置控制器（全局配置）
 * 仅系统管理员可以配置各功能消耗的算力
 */
@Tag(name = "算力配置", description = "算力扣除配置接口（系统管理员）")
@RestController
@RequestMapping("/admin/points/config")
@SaAdminCheckLogin
@RequireSystemAdmin
public class AdminPointsConfigController {

    @Autowired
    private PointsConfigService pointsConfigService;

    /**
     * 获取算力配置列表
     */
    @Operation(summary = "获取算力配置列表", description = "获取所有算力配置")
    @GetMapping("/list")
    public Result<List<PointsConfig>> getConfigList() {
        List<PointsConfig> configs = pointsConfigService.getConfigList();
        return Result.success(configs);
    }

    /**
     * 更新算力配置
     */
    @Operation(summary = "更新算力配置", description = "批量更新算力配置")
    @AdminLog(module = "算力配置", operation = "更新算力配置")
    @PutMapping("/update")
    public Result<Void> updateConfigs(@Valid @RequestBody List<PointsConfig> configs) {
        pointsConfigService.updateConfigs(configs);
        return Result.success(null, "配置更新成功");
    }

    /**
     * 更新单个算力配置
     */
    @Operation(summary = "更新单个算力配置", description = "更新指定的算力配置")
    @AdminLog(module = "算力配置", operation = "更新单个算力配置")
    @PutMapping("/update/{configKey}")
    public Result<Void> updateConfig(
            @PathVariable String configKey,
            @RequestParam(required = false) Integer configValue,
            @RequestParam(required = false) Integer isEnabled) {
        pointsConfigService.updateConfig(configKey, configValue, isEnabled);
        return Result.success(null, "配置更新成功");
    }

    /**
     * 初始化算力配置
     * 如果没有配置，会自动初始化默认配置
     */
    @Operation(summary = "初始化算力配置", description = "初始化默认算力配置")
    @AdminLog(module = "算力配置", operation = "初始化算力配置")
    @PostMapping("/init")
    public Result<List<PointsConfig>> initConfigs() {
        pointsConfigService.initDefaultConfigs();
        List<PointsConfig> configs = pointsConfigService.getConfigList();
        return Result.success(configs, "配置初始化成功");
    }
}
