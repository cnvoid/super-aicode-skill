# env-gate — 环境变量网关隔离规范

## error 级别硬约束

### 1. 业务代码禁止直接读取环境变量

除配置模块外，项目内任何其他模块、类、文件的代码**严禁**出现以下调用：

| 语言 | 禁止的调用 |
|------|-----------|
| Node.js / TS | `process.env.XXX`、`process.env['XXX']` |
| Go | `os.Getenv("XXX")`、`os.LookupEnv("XXX")`、`viper.Get("XXX")`（直接使用 viper 也算） |
| Java | `System.getenv("XXX")`、`System.getProperty("XXX")`、`@Value("${...}")` 在非 Config 类中使用 |
| Python | `os.environ["XXX"]`、`os.getenv("XXX")` |

检测到上述调用在配置模块之外，即为违规，代码必须重构。

### 2. 所有环境变量访问必须走配置模块

正确模式：

```typescript
// ❌ 错误：Service 层直接读环境变量
class OrderService {
  async create() {
    const dbHost = process.env.DB_HOST  // 违规
    const db = new Database(dbHost)
  }
}

// ✅ 正确：通过配置模块
import { config } from '@/config'

class OrderService {
  async create() {
    const db = new Database(config.db.host)  // 合规
  }
}
```

Go 示例：

```go
// ❌ 错误
func NewOrderService() *OrderService {
    host := os.Getenv("DB_HOST") // 违规
    return &OrderService{db: connect(host)}
}

// ✅ 正确
func NewOrderService(cfg *config.AppConfig) *OrderService {
    return &OrderService{db: connect(cfg.DB.Host)}
}
```

Java 示例：

```java
// ❌ 错误
@Service
public class OrderService {
    @Value("${db.host}")  // 违规：在业务类中使用 @Value
    private String dbHost;
}

// ✅ 正确
@Service
public class OrderService {
    private final AppConfig config;
    public OrderService(AppConfig config) { // 注入整个配置对象
        this.config = config;
    }
    public void create() {
        String host = config.db().host(); // 通过配置对象访问
    }
}
```

### 3. 环境变量读取点必须可审计

配置模块中所有读取环境变量的位置必须集中、可追溯：

- 所有 `process.env.XXX` / `os.Getenv("XXX")` 调用必须在**同一个文件**或**同一 package** 内
- 不得存在多个分散的"辅助读取函数"（如 `utils/getEnv.ts` + `helpers/env.go` + `common/config.go` 同时存在）
- 新增环境变量时，必须在配置模块中新增字段，同时更新配置文档注释

### 4. 第三方库/SDK 初始化也必须走配置模块

不要因为第三方库需要直接读环境变量就绕开配置模块。将配置值传入第三方库的构造器：

```typescript
// ❌ 错误：依赖库隐式读 process.env
import Redis from 'ioredis'
const redis = new Redis() // ioredis 内部自己读 REDIS_HOST 等

// ✅ 正确：显式传参
import { config } from '@/config'
const redis = new Redis({
  host: config.redis.host,
  port: config.redis.port,
  password: config.redis.password,
})
```

## warn 级别软约束

- **环境变量命名规范**：建议统一使用大写蛇形命名（`UPPER_SNAKE_CASE`），如 `DB_HOST`、`REDIS_MAX_CONNECTIONS`
- **前缀约定**：同一项目的环境变量建议携带统一前缀以避免冲突，如 `MYAPP_DB_HOST`、`MYAPP_REDIS_HOST`
- **env 文件管理**：`.env` 文件仅用于本地开发，不得提交到版本控制（已在 `.gitignore` 中排除），提供 `.env.example` 模板
- **容器化部署**：K8s ConfigMap/Secret 中注入的环境变量也应遵循同样的命名规范
- **lint 规则**：建议配置 ESLint / golangci-lint 规则，禁止在非配置模块中调用 `process.env` / `os.Getenv` / `System.getenv`，从工具层面拦截至
