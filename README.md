# Super AI Code Skill

AI 编码 Agent（OpenCode / Claude Code / OpenClaw）的技能包，安装后约束 Agent 输出生产级代码。

## 设计理念

- **配置驱动**：一套规则库，多套配置，不同项目不同力度
- **双层隔离**：全局 `.super.yaml` 定义个人基线，项目 `.super.yaml` 定义团队规范
- **必须加载 + 按需激活**：`super-core` 永远在线，场景 skill 按触发词自动匹配
- **契约式约束**：每个规则文件是**可执行的契约**，Agent 输出代码后必须逐条自检

## 技能体系

```
super-core (必须加载)
  ├── prompts/error.md          异常处理: 不可吞异常、错误码、异常链 (配置键: exception)
  ├── prompts/validation.md     入参校验: null-safe、边界、类型安全
  ├── prompts/response.md       统一响应: 外壳封装、code=0、分页结构、错误码对照表
  ├── prompts/naming.md          命名规范: 语言惯例、布尔前缀、数据库命名
  ├── prompts/api-design.md      API设计: RESTful URL、分页排序、版本管理
  ├── prompts/config.md           配置管理: 多环境分离、敏感加密、Feature Flag
  ├── prompts/health.md           健康检查: /health存活探针、/ready就绪探针
  ├── prompts/backend-security.md 后端安全: SQL注入、CORS、限流、密码加密
  ├── prompts/resilience.md     容错容灾: 超时、重试、熔断、降级、幂等
  ├── prompts/logging.md        结构化日志: JSON格式、trace-id、脱敏
  ├── prompts/observability.md  可观测性: /metrics指标、告警规则、链路追踪
  ├── prompts/legacy.md         存量项目: 尊重旧风格、限定修改范围、补齐文档注解
  └── prompts/doc.md            文档注释: 函数契约、自文档化

super-frontend (触发词: react, vue, component, hook, JSX, axios, modal, router, form)
  ├── prompts/react.md          React 组件、hooks、性能、ErrorBoundary
  ├── prompts/vue.md            Composition API、响应式、Props/Emits
  ├── prompts/typescript.md     strict 模式、类型守卫、泛型约束
  ├── prompts/css.md            样式方案: Tailwind CSS 优先 → CSS Modules → CSS-in-JS
  ├── prompts/http.md           请求封装、API地址配置注入、拦截器、401 跳转登录
  ├── prompts/component.md      通用业务组件、弹窗层级(z-index)管理
  ├── prompts/state.md          Store 模块拆分、异步三态
  ├── prompts/router.md         路由守卫、懒加载、权限路由
  ├── prompts/form.md           声明式校验、防重复提交、编辑回填
  ├── prompts/build.md          环境变量、去调试代码、代码分割
  └── prompts/security.md       Token 存储、XSS 防范、敏感信息掩码

super-backend-java (触发词: Java, Spring, JPA, Maven)
  ├── prompts/layering.md       Controller→Service→Repository 分层
  ├── prompts/exception.md      全局异常处理、业务异常体系
  ├── prompts/jpa.md            N+1 排查、事务、批量操作
  └── prompts/bean.md           构造器注入、循环依赖

super-backend-node (触发词: Node, Express, NestJS, Prisma)
  ├── prompts/express.md        全局错误中间件、asyncHandler
  ├── prompts/nestjs.md         ValidationPipe、异常过滤器、模块拆分
  └── prompts/prisma.md         精确查询、事务、索引

super-backend-go (触发词: Go, Gin, goroutine, channel)
  ├── prompts/layering.md       handler/service/repo 分层 + 接口隔离
  ├── prompts/error-handling.md %w 包装、sentinel error、panic recover
  └── prompts/concurrency.md    context 传递、goroutine 退出、channel 规范

super-backend-python (触发词: Python, FastAPI, Django, Flask, Pydantic, SQLAlchemy)
  ├── prompts/fastapi.md        APIRouter 模块化、Depends 依赖注入、异常处理、CORS
  ├── prompts/pydantic.md       Schema 字段校验、枚举定义、model_config、Request/Response 分离
  ├── prompts/sqlalchemy.md     AsyncSession、selectinload 防 N+1、Alembic 迁移、连接池
  └── prompts/layering.md       Router/Service/Repository 分层、禁止跨层调用

super-design-icon (触发词: icon, SVG, icon component, icon library)
  ├── prompts/icon-component.md  SVG 组件设计、Props 接口、尺寸与颜色
  ├── prompts/icon-system.md     图标系统架构、tree-shaking、类型生成
  └── prompts/accessibility.md    图标无障碍、aria 属性、语义标注、对比度

super-backend-common (触发词: auth, cache, database, OAuth2, JWT, Redis, digital worker)
  ├── prompts/auth.md            认证鉴权: JWT、OAuth2、RBAC、密码策略
  ├── prompts/cache.md           缓存策略: 穿透/击穿/雪崩防范、多级缓存
  ├── prompts/database.md         数据库设计: 表设计、索引、迁移脚本、连接池
  └── prompts/digital-worker.md   数字员工接入: OpenAPI/Schema/错误自愈/审计/幂等

super-deploy (触发词: deploy, CI/CD, Docker, Kubernetes, pipeline)
  ├── prompts/ci-cd.md           CI/CD: 多环境流水线、构建产物管理、回滚
  └── prompts/docker.md          Docker: 多阶段构建、非root用户、镜像优化

super-config (触发词: config, 集中配置, 环境变量, env, configuration)
  ├── prompts/config-central.md   集中配置架构: 单一入口/启动校验/类型化/不可变
  └── prompts/env-gate.md         环境变量网关: 禁止业务代码直读 env、读写分离

super-api-doc (触发词: api doc, 接口文档, openapi, swagger, 注解, annotation)
  ├── prompts/openapi-annotations.md  OpenAPI 注解规范: Controller/参数/响应/Model 中文描述
  └── prompts/annotation-sync.md      注解同步: 编写即注解/变更即更新/不得事后补齐

super-test (触发词: test, unit test, mock, coverage, api test, UI test, a11y, AI testing)
  ├── prompts/unit.md           正向/边界/异常三类场景、mock 策略
  ├── prompts/api.md            API测试: 契约/8状态码/5鉴权/边界/幂等/限流/版本
  ├── prompts/ui.md             UI测试: 组件隔离/交互/无障碍/响应式/状态/视觉/跨浏览器
  ├── prompts/integration.md    Testcontainers、数据隔离、流程验证
  ├── prompts/ai-testing.md     AI测试: 幻觉检测/冗余检测/规则遵循/Skill自验证
  └── prompts/report.md         覆盖率、缺陷分类、用例统计

super-log (触发词: log, worklog, 周报, 月报, 工作总结, daily report, 日报, summary)
  ├── prompts/worklog.md         任务记录: 格式/分类/粒度/自动触发
  └── prompts/report.md          总结报告: 周报模板/月报模板/数据汇总/趋势分析

super-mock-data (触发词: mock data, 造数据, 测试数据, seed, fixture, faker, 假数据, 关联数据)
  ├── prompts/generation.md      测试数据生成: 业务语义仿真、faker 工具、边界与反例、脱敏
  ├── prompts/association.md     关联正确性: 外键真实关联、依赖拓扑顺序、字典先插、复用主数据
  └── prompts/seed.md            落库脚本: 幂等可重复、仅测试/开发库、Seed 工具管理、数据量控制
```

## 快速开始

### Linux / macOS

```bash
# 方式一：一键安装（推荐）
bash install.sh

# 方式二：手动安装
mkdir -p ~/.config/opencode/skills/super-aicode
cp -r super-*/ profiles/ templates/ ~/.config/opencode/skills/super-aicode/
cp templates/global.yaml ~/.super.yaml
```

### Windows

```powershell
# 方式一：一键安装（推荐）
.\install.ps1

# 方式二：手动安装
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.config\opencode\skills\super-aicode"
Copy-Item -Recurse -Force super-* "$env:USERPROFILE\.config\opencode\skills\super-aicode\"
Copy-Item -Recurse -Force profiles, templates "$env:USERPROFILE\.config\opencode\skills\super-aicode\"
Copy-Item templates\global.yaml "$env:USERPROFILE\.super.yaml"
```

### 项目配置（可选）

```bash
# Linux / macOS / Windows (在项目根目录)
cp templates/project.yaml ./.super.yaml
# 编辑 .super.yaml 调整规则开关和级别
```

### 重启 opencode

配置修改后需重启 opencode 生效。

> 详细安装说明见 [INSTALL.md](INSTALL.md)

## 配置说明

### 规则级别

| 级别 | 含义 |
|------|------|
| `error` | 硬约束，代码必须满足，否则拒绝输出 |
| `warn` | 软约束，不满足时标注 TODO 后允许输出 |
| `info` | 建议，输出时提及即可（当前版本未实现） |
| `off` | 关闭，跳过该规则 |

### 预置策略

| 策略 | 适用场景 | 特点 |
|------|---------|------|
| `balanced` | 大部分项目（默认） | 核心规则 error，辅助规则 warn |
| `strict` | 核心系统/金融/安全 | 全部 error，覆盖率 ≥ 90% |
| `minimal` | 遗留系统/快速原型 | 仅安全底线为 error，存量项目优先 |

### 三层优先级

```
project/.super.yaml  >  ~/.super.yaml  >  profiles/balanced.yaml
```

## 文件结构

```
super-aicode-skill/
├── profiles/                 # 预置策略
│   ├── balanced.yaml
│   ├── strict.yaml
│   └── minimal.yaml
├── templates/                # 配置模板（复制用）
│   ├── global.yaml           #  → ~/.super.yaml
│   └── project.yaml          #  → ./.super.yaml
├── super-core/               # 必须加载的基础技能
│   ├── SKILL.md
│   └── prompts/*.md
├── super-frontend/           # 前端场景技能
├── super-backend-java/       # Java 场景技能
├── super-backend-node/       # Node.js 场景技能
├── super-backend-go/         # Go 场景技能
├── super-backend-python/     # Python 场景技能
├── super-backend-common/     # 通用后端工程技能
├── super-design-icon/        # 图标设计场景技能
├── super-deploy/             # 部署运维场景技能
├── super-config/             # 集中配置场景技能
├── super-api-doc/            # API 文档注解场景技能
├── super-test/               # 测试场景技能
├── super-log/                # 日志与报告场景技能
├── super-mock-data/          # 测试数据造数场景技能
├── install.sh                # Linux/macOS 一键安装
├── install.ps1               # Windows 一键安装
├── INSTALL.md                # 详细安装文档
└── README.md
```

## 工作流示例

```
用户: "写一个 React 订单列表组件"

Agent:
   [super-core] Phase 0 — 任务方案
     | # | 任务 | 优先级 |
     |---|------|--------|
     | 1 | 创建 OrderList 组件 | high |
     | 2 | 封装 API 请求层 | high |
     | ...

   [super-core] Phase 0 — 存量项目检测
     检测到已有代码，将遵循旧项目风格：Result<T> / ErrorCode 枚举

   [super-core] 配置加载完成
     profile: balanced
     规则: exception=error, validation=error, response=error, legacy=error, resilience=warn, ...

  [super-frontend] 激活: react=error, typescript=error, css=warn

  (生成组件代码...)

  [super-core] 规则检查
     ✅ exception       — 异常声明完整，BaseException 继承正确
     ✅ validation      — 入参 null 检查已覆盖，类型安全
     ✅ response        — 统一响应外壳，code=0
     ✅ legacy          — 存量项目：沿用旧风格，仅改目标范围
     ✅ resilience      — ErrorBoundary 包裹，AbortController 超时
     ⚠️  logging        — trace-id 待补充(TODO)
     —   doc            — 已关闭

  [super-frontend] 规则检查
     ✅ react       — memo/useMemo/ErrorBoundary 已使用
     ✅ typescript  — strict，无 any，?. 和 ?? 取值容错
     ✅ css         — Tailwind CSS 原子类，响应式 sm:/md:/lg:
     ✅ http        — API 地址 VITE_API_BASE_URL 注入，无硬编码
```
