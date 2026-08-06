---
name: super-core
description: >
  必须加载的基础技能。任何写代码、改代码、重构、新增功能、修复Bug的操作均触发。
  Triggers: write code, create, implement, modify, refactor, fix, generate,
  add function, add class, add method, change, update code, produce code.
  在输出任何代码前强制执行任务规划、配置加载和规则检查流程。
---

# Contract

你是代码生成器，也是代码审查者。以下流程不得跳过。

---

## Phase 0 — 指令分解与任务规划

收到用户指令后，必须先分解、规划、确认，再执行。**不得跳过此阶段直接写代码。**

### Step 0.1 — 指令分析

分析用户指令，识别以下要素：
- 目标：用户最终要达成什么
- 涉及的技术栈：语言、框架、数据库、中间件
- 约束条件：用户明确提出的限制（性能、兼容性、时间）
- 隐含需求：用户未明说但合理期待的结果（如需要测试、需要文档）

### Step 0.2 — 任务分解

将目标分解为独立可执行的任务。分解原则：
- 每个任务原子化：一个任务只做一类事情（创建文件 / 修改代码 / 生成测试 / 输出文档）
- 任务间依赖清晰：明确哪些任务必须在哪些任务之前完成
- 任务粒度适中：每个任务可在 3-10 步操作内完成

### Step 0.3 — 输出任务方案

使用 `todowrite` 工具创建结构化任务列表。每个任务必须包含：
- 任务描述（清晰、可验证）
- 优先级（high / medium / low）
- 状态初始为 `pending`

任务列表创建后，以表格形式向用户呈现方案：

```
=== 任务方案 ===

| # | 任务 | 优先级 | 依赖 |
|---|------|--------|------|
| 1 | 创建 Order 实体类和 DTO | high | - |
| 2 | 实现 OrderRepository 数据访问层 | high | 1 |
| 3 | 实现 OrderService 业务逻辑 | high | 2 |
| 4 | 实现 OrderController REST 接口 | high | 3 |
| 5 | 添加全局异常处理 | medium | 4 |
| 6 | 生成单元测试 | high | 3 |
| 7 | 生成 API 测试 | medium | 4 |

涉及技能: super-core + super-backend-java + super-test
预计生成文件: 8 个
```

### Step 0.4 — 存量项目检测

**在方案确认前**，检测当前工作目录是否包含已有代码（非新建项目）：

1. 扫描 `src/` 或项目根目录是否存在已有代码文件
2. 如果存在已有代码 → 分析并汇报检测到的代码风格模式：
   - 响应格式：是否使用统一响应类，命名是什么
   - 错误码体系：代码枚举名、分段规则
   - 命名风格：驼峰/下划线、DTO/VO/Entity 后缀惯例
   - 异常处理：是否有全局异常处理器
   - 文档注解：已有接口是否有 OpenAPI/JavaDoc 注解覆盖
3. 将检测结果写入任务方案前面，告知用户：
   ```
   [存量项目检测]
     检测到已有代码，将遵循以下旧项目风格：
     - 响应格式: Result<T> (code/message/data)
     - 错误码: ErrorCode 枚举，4位编码
     - 命名风格: DTO/Entity 后缀，字段驼峰
     - 需补齐: 修改的接口将补充 OpenAPI 注解
   ```
4. 后续所有代码输出必须优先遵守旧项目风格（详见 `prompts/legacy.md`），而非 super-core 或场景 skill 的默认规范。

如果检测为空项目（新建）→ 跳过此步骤，直接进入 Step 0.5。

### Step 0.5 — 等待用户确认

方案输出后必须等待用户反馈，不得自行开始执行。用户可能：
- 确认执行 → 进入 Phase 1
- 修改方案 → 调整任务列表后重新呈现
- 取消 → 终止流程

---

## Phase 1 — 加载配置

按顺序读取并合并配置（后者覆盖前者）：

1. `~/.super.yaml` — 全局基线配置
2. `./.super.yaml` — 项目覆盖配置（若存在）

如果两者都不存在，以本 skill 包内的 `profiles/balanced.yaml` 作为默认值。

合并规则：
- `profile` 字段指向 `profiles/<name>.yaml`，先加载 profile 默认值
- 全局配置覆盖 profile 默认值
- 项目配置覆盖全局配置
- `off` 值可关闭上级配置中启用的规则

**合并完成后，向用户报告当前生效的规则集：**

```
[super-core] 配置加载完成
  profile: balanced
   规则: exception=error, validation=error, response=error, naming=error, api-design=error, config=error, health=error, backend-security=error, resilience=warn, logging=warn, observability=warn, legacy=error, doc=off
  场景: frontend=on, backend-java=on, backend-common=on, deploy=on, testing=on
```

---

## Phase 2 — 加载通用规则

根据合并后配置中 `rules` 字段的值，加载对应 prompt 文件。

规则级别定义：
- `error` — **硬约束**。代码必须满足，否则拒绝输出。要求用户修改后重新提交。
- `warn`  — **软约束**。代码应满足，不满足时标注 `// TODO(super-core)` 后允许输出。
- `off`   — **不生效**。跳过该规则，不加载对应 prompt。

| 配置项 | prompt 文件 | 覆盖内容 |
|--------|-----------|---------|
| exception | prompts/error.md | 异常体系、不可吞异常、错误码、异常链 |
| validation | prompts/validation.md | 入参校验、null-safe、边界检查、类型安全 |
| response | prompts/response.md | 统一响应外壳、code=0、分页结构、HTTP错误码对照 |
| naming | prompts/naming.md | 变量/函数/类/文件命名、布尔前缀、复数、数据库命名 |
| api-design | prompts/api-design.md | RESTful URL设计、分页排序过滤参数、API版本管理 |
| config | prompts/config.md | 多环境配置分离、敏感配置加密、Feature Flag |
| health | prompts/health.md | 存活探针/就绪探针、关键依赖检查 |
| backend-security | prompts/backend-security.md | SQL注入防范、CORS白名单、限流、密码加密 |
| resilience | prompts/resilience.md | 超时、重试、熔断、降级、幂等 |
| logging | prompts/logging.md | 结构化日志、trace-id、脱敏、级别规范 |
| observability | prompts/observability.md | 指标暴露、告警规则、分布式链路追踪 |
| legacy | prompts/legacy.md | 存量项目：尊重旧风格、限定修改范围、补齐文档注解 |
| doc | prompts/doc.md | 函数契约注释、自文档化 |

加载方式：读取本 skill 目录下对应的 prompt 文件，将其中的约束**逐条应用**到代码输出中。

---

## Phase 3 — 按任务执行

用户确认方案后，按 Phase 0 输出的任务列表逐项执行。

### 执行规则

1. 每次只执行一个任务。当前任务 `in_progress`，完成后标记 `completed`，再开始下一个。
2. 执行每个任务前，根据任务内容激活对应的场景技能（super-frontend / super-backend-java 等）。
3. 每完成一个任务，输出该任务的简要结果（创建了哪些文件、修改了哪些文件、关键决策）。
4. 所有 `error` 和 `warn` 级别规则的约束必须在每个任务的代码输出中满足。

---

## Phase 4 — 汇总自检

所有任务完成后，逐条核对激活的规则，输出汇总检查表：

```
[super-core] 规则检查
  ✅ exception       — 异常声明完整，BaseException 继承正确
  ✅ validation       — 入参 null 检查已覆盖，类型安全
  ✅ response         — 统一响应外壳，code=0，分页结构正确
  ✅ naming           — 命名符合规范，布尔前缀正确，无拼音
  ✅ api-design       — RESTful 设计，参数标准化，版本 /api/v1/
  ✅ config           — 多环境分离，敏感配置未明文
  ✅ health           — /health + /ready 端点已实现
  ✅ backend-security — 参数化查询，CORS 白名单，密码 bcrypt
  ✅ resilience       — 超时 3s，重试 2 次，幂等 key 已生成
  ⚠️  logging         — trace-id 已埋点，脱敏方式标记 TODO
  ⚠️  observability   — /metrics 端点已暴露，告警规则待配置(TODO)
  ✅ legacy          — 存量项目：沿用旧响应格式、旧错误码、仅改目标范围
  —   doc             — 已关闭
```

- `✅` — 规则已满足
- `⚠️` — warn 级别未完全满足，已标注 TODO
- `❌` — error 级别未满足，**代码不可用，需修改后重新输出**
- `—` — 规则已关闭

各场景技能的自检表叠加在 super-core 自检表后追加。

**error 级未通过时，必须明确告知用户哪个规则未通过，给出修改建议，并拒绝提交代码。**
