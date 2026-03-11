# 安全政策

## 报告安全漏洞

如果你发现了安全漏洞，请不要在公开的 Issue 中报告。请通过以下方式私密报告：

1. 发送邮件至 [your-security-email@example.com]
2. 在 GitHub 上使用 Security Advisory 功能

请包含以下信息：
- 漏洞描述
- 受影响的版本
- 复现步骤
- 建议的修复方案

我们会在收到报告后的 48 小时内回复，并在 30 天内发布修复。

## 安全最佳实践

### 环境变量配置

本项目使用环境变量管理所有敏感信息。**绝不要**在代码中硬编码以下内容：

- 数据库密码
- Redis 密码
- API Keys
- JWT Secret
- 加密密钥

### 配置文件

- `application.yml` - 主配置（不包含敏感信息）
- `application-dev.yml` - 开发环境（使用环境变量）
- `application-prod.yml` - 生产环境（使用环境变量）
- `.env.example` - 环境变量示例（已添加到 Git）
- `.env` - 本地环境变量（已添加到 .gitignore）

### 数据库安全

- 使用强密码（至少 16 字符，包含大小写字母、数字、特殊字符）
- 定期更新 MySQL 版本
- 启用 SSL/TLS 连接
- 限制数据库访问 IP
- 定期备份数据库

### API 安全

- 所有 API 端点都需要认证（JWT Token）
- 使用 HTTPS 传输
- 实现速率限制
- 验证所有用户输入
- 使用 CORS 限制跨域请求

### 认证与授权

- JWT Token 有效期：30 天
- 使用 Sa-Token 框架进行权限管理
- 区分系统管理员和站点管理员
- 定期审计管理员操作日志

### 云存储安全

- 腾讯云 COS 凭证存储在数据库中（AES 加密）
- 使用临时凭证生成预签名 URL
- 限制 COS 访问权限
- 启用 COS 访问日志

### 依赖管理

- 定期更新依赖包
- 使用 `mvn dependency:check` 检查已知漏洞
- 使用 `npm audit` 检查前端依赖漏洞
- 避免使用已停止维护的库

## 已知问题

### 历史提交中的敏感信息

本项目的 Git 历史中可能包含已泄露的敏感信息（密码、API Key 等）。

**重要**：如果你从 GitHub 克隆了本项目，请假设以下信息已泄露：

- MySQL 密码：`123456`, `YGaM5MAN2Lin46ws`, `sMw7YnDXZdnYWLst`
- Redis 密码：`super123321`
- JWT Secret：`d60160c01b2d4e85b3e2a9f6b7c1d9e3f2a5b8c4d7e3f1a2b4c6d8e0f1a3b5c7`
- AES 密钥：`AgentVideoSecret`
- AES IV：`1234567890123456`

**必须立即轮换这些凭证**。

### 处理方案

1. 更改所有数据库密码
2. 轮换所有 API Keys
3. 生成新的 JWT Secret
4. 更新 AES 加密密钥
5. 审计所有管理员账户
6. 检查是否有异常访问

## 安全更新

我们会定期发布安全更新。请订阅项目的 Release 通知，及时更新到最新版本。

## 安全审计

本项目定期进行安全审计。如果你发现任何安全问题，请立即报告。

## 许可证

本项目基于 AGPL-3.0 协议开源。详见 [LICENSE](LICENSE) 文件。
