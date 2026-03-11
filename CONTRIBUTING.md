# 贡献指南

感谢你对 SoulArtisan 项目的兴趣！我们欢迎各种形式的贡献。

## 贡献方式

### 报告 Bug

如果你发现了 Bug，请创建一个 Issue 并包含以下信息：

- 清晰的标题
- 详细的描述
- 复现步骤
- 预期行为 vs 实际行为
- 环境信息（OS、Java 版本、Node 版本等）
- 错误日志或截图

### 提交功能建议

如果你有新功能的想法，请创建一个 Issue 并描述：

- 功能的用途
- 预期的行为
- 可能的实现方案
- 相关的用例

### 提交代码

1. **Fork 项目**

```bash
git clone https://github.com/your-username/SoulArtisan.git
cd SoulArtisan
```

2. **创建特性分支**

```bash
git checkout -b feature/your-feature-name
# 或修复 Bug
git checkout -b fix/bug-description
```

3. **遵循代码规范**

详见下方的代码规范部分。

4. **提交更改**

```bash
git add .
git commit -m "feat: add new feature"
# 或
git commit -m "fix: resolve issue #123"
```

5. **推送分支**

```bash
git push origin feature/your-feature-name
```

6. **创建 Pull Request**

- 清晰的 PR 标题
- 详细的描述（关联相关 Issue）
- 列出主要改动
- 附加截图或演示（如适用）

## 代码规范

### Java 后端

遵循项目的 Java 规范（见 CLAUDE.md）：

- 类名 PascalCase，方法名 camelCase，常量 UPPER_SNAKE_CASE
- 包名全小写
- 分层：Controller → Service → Mapper/Repository
- 统一返回 `Result<T>` 包装类型
- 使用 Slf4j 日志，禁止 System.out.println
- 异常用全局异常处理器

示例：

```java
@RestController
@RequestMapping("/api/users")
@Slf4j
public class UserController {

    @Autowired
    private UserService userService;

    @GetMapping("/{id}")
    public Result<UserDTO> getUser(@PathVariable Long id) {
        try {
            UserDTO user = userService.getUserById(id);
            return Result.success(user);
        } catch (Exception e) {
            log.error("Failed to get user: {}", id, e);
            return Result.error("User not found");
        }
    }
}
```

### TypeScript / React 前端

遵循项目的 Vue/React 规范：

- 使用 Composition API + setup 语法糖（Vue）或 Hooks（React）
- 使用 Tailwind CSS 4 进行样式
- 时间用 dayjs 格式化为 `YYYY-MM-DD HH:mm:ss`
- 使用 pnpm 管理依赖
- 文字最小 14px
- 不用 `||` 加默认值
- HTTP API 有封装不会 reject，调用不用 try-catch

示例：

```typescript
import { useState } from 'react';
import { getUserById } from '@/api/user';

export const UserDetail = ({ userId }: { userId: string }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(false);

  const fetchUser = async () => {
    setLoading(true);
    const data = await getUserById(userId);
    setUser(data);
    setLoading(false);
  };

  return (
    <div className="p-4">
      {loading && <p>Loading...</p>}
      {user && <p className="text-lg">{user.name}</p>}
    </div>
  );
};
```

### SQL 数据库迁移

- 使用 Flyway 管理迁移脚本
- 命名规范：`V{YYYYMMDD}__{description}.sql`
- 每个迁移脚本应该是幂等的（可以安全地重复执行）
- 包含注释说明迁移的目的

示例：

```sql
-- V20250115__add_user_avatar.sql
-- 为 user 表添加头像字段

ALTER TABLE `user` ADD COLUMN `avatar` VARCHAR(500) COMMENT '用户头像 URL';
ALTER TABLE `user` ADD INDEX `idx_user_avatar` (`avatar`);
```

## Commit 规范

使用 Conventional Commits 规范：

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type

- `feat:` 新功能
- `fix:` Bug 修复
- `refactor:` 代码重构
- `docs:` 文档更新
- `style:` 代码格式（不影响功能）
- `test:` 测试相关
- `chore:` 构建/工具变动
- `perf:` 性能优化

### Scope

可选，表示影响的模块：

- `admin` - 管理后台
- `agent` - 用户端
- `api` - 后端 API
- `db` - 数据库
- `auth` - 认证模块
- `ai` - AI 服务

### Subject

- 使用祈使句（"add" 而不是 "added"）
- 不要大写首字母
- 不要以句号结尾
- 限制在 50 个字符以内

### Body

- 解释 what 和 why，而不是 how
- 每行 72 个字符
- 可选

### Footer

- 关联 Issue：`Closes #123`
- Breaking Changes：`BREAKING CHANGE: description`

### 示例

```
feat(auth): add JWT token refresh endpoint

Add a new endpoint to refresh expired JWT tokens without re-login.
This improves user experience by allowing seamless token renewal.

Closes #456
```

## 测试

### 后端测试

```bash
cd playlet
mvn test
```

### 前端测试

```bash
cd agent-web
pnpm test

cd admin-web
pnpm test
```

## 文档

- 更新 README.md 中的相关部分
- 为新功能添加 API 文档注释
- 在 CHANGELOG.md 中记录重要变动

## 审查流程

1. 自动化检查（CI/CD）
2. 代码审查（至少 1 个维护者）
3. 测试验证
4. 合并到 main 分支

## 行为准则

我们致力于为所有贡献者提供一个友好、包容的环境。

- 尊重他人的观点和经验
- 接受建设性的批评
- 关注对项目最有利的事情
- 对其他社区成员表示同情

## 许可证

通过提交代码，你同意你的贡献将在 AGPL-3.0 协议下发布。

## 问题？

- 查看 [README.md](README.md)
- 查看 [SECURITY.md](SECURITY.md)
- 创建 Issue 提问
- 联系维护者

感谢你的贡献！🎉
