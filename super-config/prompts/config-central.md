# config-central — 集中配置架构规范

## error 级别硬约束

### 1. 必须存在唯一的配置加载入口

所有环境变量的读取必须收敛到**一个**配置模块/文件/类中，不得散落在项目各处。各语言实现：

**Node.js：**

```typescript
// src/config/index.ts — 唯一入口
export interface AppConfig {
  server: { port: number; host: string }
  db: { host: string; port: number; user: string; password: string; database: string }
  redis: { host: string; port: number; password?: string }
}

function loadConfig(): AppConfig {
  return {
    server: {
      port: parseInt(process.env.SERVER_PORT ?? '3000', 10),
      host: process.env.SERVER_HOST ?? '0.0.0.0',
    },
    db: {
      host: process.env.DB_HOST ?? 'localhost',
      port: parseInt(process.env.DB_PORT ?? '5432', 10),
      user: process.env.DB_USER ?? 'postgres',
      password: process.env.DB_PASSWORD ?? '',
      database: process.env.DB_NAME ?? 'app',
    },
    redis: {
      host: process.env.REDIS_HOST ?? 'localhost',
      port: parseInt(process.env.REDIS_PORT ?? '6379', 10),
      password: process.env.REDIS_PASSWORD,
    },
  }
}

export const config = Object.freeze(loadConfig())
```

**Go：**

```go
// config/config.go — 包内唯一读取 os.Getenv 的位置
type AppConfig struct {
    Server ServerConfig
    DB     DBConfig
    Redis  RedisConfig
}

func Load() *AppConfig {
    return &AppConfig{
        Server: ServerConfig{
            Port: getEnvInt("SERVER_PORT", 8080),
            Host: getEnv("SERVER_HOST", "0.0.0.0"),
        },
        DB: DBConfig{
            Host:     getEnv("DB_HOST", "localhost"),
            Port:     getEnvInt("DB_PORT", 5432),
            User:     getEnv("DB_USER", "postgres"),
            Password: getEnv("DB_PASSWORD", ""),
            Database: getEnv("DB_NAME", "app"),
        },
    }
}

// getEnv/getEnvInt 是包内私有函数，不导出
func getEnv(key, fallback string) string { ... }
func getEnvInt(key string, fallback int) int { ... }
```

**Java：**

```java
// Config.java — 单一配置类
@ConfigurationProperties(prefix = "app")
@Validated
public record AppConfig(
    @NotNull ServerConfig server,
    @NotNull DbConfig db,
    RedisConfig redis
) {}

// 配合 application.yml 用 Spring 的 env 绑定，
// 或显式从 System.getenv() 读取仅在 Config 类中
```

### 2. 缺失必填配置必须启动失败（fail-fast）

不得以空字符串或默认值掩盖缺失的必填配置项。违反会崩溃更早。

- **必填无默认值**的环境变量：缺失时 `throw new Error` / `log.Fatal` / `panic`，携带明确错误信息
- **有默认值**的配置：允许降级，但需打印 WARN 日志说明使用了默认值

```typescript
// 正确：fail-fast on missing required env
const dbPassword = process.env.DB_PASSWORD
if (!dbPassword) {
  throw new Error('[Config] DB_PASSWORD is required but not set')
}

// 正确：降级 + 警告
const redisHost = process.env.REDIS_HOST ?? 'localhost'
if (!process.env.REDIS_HOST) {
  console.warn('[Config] REDIS_HOST not set, using default: localhost')
}
```

### 3. 配置对象在导出后必须不可变

导出的配置对象不得在运行时被业务代码修改，防止副作用污染全局状态。

- Node.js: `Object.freeze()` 或使用 `as const`
- Go: 结构体字段不导出（小写），通过方法访问，或配置对象只在 main 层持有，通过依赖注入传递
- Java: 使用 `record` 或 `@ConfigurationProperties` + `@Validated`

### 4. 配置项必须有类型化定义

禁止使用 `Map<string, string>` 或 `Record<string, any>` 等弱类型承载配置。

错误示例：
```typescript
const config: Record<string, any> = { ... } // ❌ 禁止
```

正确示例：
```typescript
interface AppConfig {
  server: { port: number; host: string }
  db: { ... }
}
const config: AppConfig = { ... } // ✅ 类型化
```

## warn 级别软约束

- **配置分层**：建议按功能区域拆分配置结构体（Server、DB、Redis、Log、Auth 等），但都从同一入口加载
- **环境标签**：建议通过 `APP_ENV` / `NODE_ENV` 标识当前环境，加载环境对应的默认值策略
- **配置文档**：建议在配置模块顶部注释列出所有环境变量及其用途
- **启动日志**：建议启动时打印非敏感的配置摘要（隐藏 password/secret/key 类字段的值）
- **动态刷新**：对需要运行时变更的配置（如限流阈值），建议通过独立的动态配置通道更新，不走环境变量
