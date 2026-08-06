# config — 配置管理规范

## error 级别硬约束

### 1. 多环境配置必须分离

项目必须支持至少以下四个环境的独立配置，各环境的配置文件物理分离：

- dev：本地开发环境，连接本地服务
- test：测试环境，连接测试中间件
- staging：预发布环境，与生产配置一致但使用隔离数据
- prod：生产环境

各语言项目的配置文件拆分方式应遵循其框架惯例：
- Spring Boot: application-{profile}.yml
- Node.js: .env.development / .env.production
- Go: config.{env}.yaml 或 viper 的环境前缀
- 前端: .env.development / .env.production

不得所有环境共享同一个配置文件，通过修改文件内容切换环境。

### 2. 敏感配置不得明文存储

以下配置项禁止以明文形式存储在配置文件中：

- 数据库密码
- 第三方服务 API Key / Secret
- 加密密钥、签名私钥
- 消息队列密码
- Token 签名密钥

敏感配置的存储方案（按推荐优先级）：
- 环境变量注入（容器化部署首选）
- 密钥管理服务（AWS Secrets Manager、HashiCorp Vault）
- 配置中心加密存储（Nacos/Apollo 的加密配置功能）
- CI/CD 管道注入（构建时以构建变量注入）

### 3. 配置文件必须纳入版本控制

除包含真实敏感值的生产配置文件外，所有配置文件必须纳入 Git 版本控制。需提供模板文件（如 .env.example、application-sample.yml）供开发者复制后填写本地值。

.gitignore 中排除的文件仅限于包含真实敏感信息的本地配置文件，不得排除所有配置文件。

## warn 级别软约束

- 复杂系统使用配置中心（Nacos、Apollo、Consul）集中管理配置，替代多份环境配置文件
- 对需要动态调整的配置（如限流阈值、开关标记）支持运行时热刷新，无需重启服务
- 所有配置项在代码中集中定义，有明确的默认值，未配置时不导致服务启动失败（降级到默认值）
- 引入 Feature Flag 控制新功能的灰度发布，Flag 的变更不需要重新部署
