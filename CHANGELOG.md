# 更新日志

所有重要的项目变动都会记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [未发布]

### 新增
- 敏感信息检测和处理
- 环境变量配置示例
- 完整的开源文档（README、CONTRIBUTING、SECURITY）
- AGPL-3.0 开源协议

### 改进
- 将硬编码密钥改为环境变量引用
- 更新 .gitignore 规则
- 移除 Git 历史中的敏感信息

### 安全
- 修复 AES 加密密钥硬编码问题
- 修复 JWT Secret 硬编码问题
- 修复数据库密码硬编码问题

## [1.0.0] - 2025-03-11

### 新增
- AI 对话功能（Gemini / OpenAI 兼容）
- AI 图像生成（文生图、图生图）
- AI 视频生成（Sora 等模型）
- 角色项目管理系统
- 可视化工作流编辑器（ReactFlow）
- 多租户管理系统
- 用户认证和授权（Sa-Token + JWT）
- 点数系统和卡密充值
- 腾讯云 COS 集成
- 操作日志和审计功能
- 管理后台（Ant Design）
- 用户端前端（React）

### 技术栈
- 后端：Spring Boot 3.3.5 + Spring AI 1.1.2
- 前端：React 19 + TypeScript 5
- 数据库：MySQL 8.0 + Flyway 迁移
- 缓存：Redis 6.0+
- 认证：Sa-Token 1.44.0

### 文档
- API 文档（Knife4j）
- 项目结构说明
- 快速开始指南
- 部署指南

---

## 版本说明

### 版本号格式

`MAJOR.MINOR.PATCH`

- **MAJOR**：不兼容的 API 变动
- **MINOR**：向后兼容的功能新增
- **PATCH**：向后兼容的 Bug 修复

### 发布周期

- 主要版本（MAJOR）：根据需要发布
- 次要版本（MINOR）：每月发布一次
- 补丁版本（PATCH）：根据需要发布

### 支持周期

- 最新版本：完全支持
- 前一个版本：安全补丁支持
- 更早版本：不再支持

---

## 如何贡献

请参考 [CONTRIBUTING.md](CONTRIBUTING.md) 了解如何贡献代码。

## 安全问题

如果你发现了安全漏洞，请参考 [SECURITY.md](SECURITY.md) 了解如何报告。

## 许可证

本项目基于 [AGPL-3.0](LICENSE) 协议开源。
