# layering — Go 分层架构规范

## error 级别硬约束

### 1. Handler 层职责：参数绑定、调用 Service、返回响应

Handler 层只处理传输层的关注点：
- 从 HTTP 请求中绑定和提取参数
- 参数格式校验（如必填、格式合法）
- 调用 Service 层方法
- 将 Service 层返回的结果转换为 HTTP 响应

Handler 层不得包含：
- 业务逻辑（如库存判断、价格计算）
- 直接调用 Repository 层
- 数据库事务管理
- 复杂的 if-else 业务判断

### 2. Service 层职责：业务逻辑实现

Service 层是业务逻辑的核心，通过接口对外暴露能力：
- 定义业务方法的契约（接收领域对象，返回领域对象 + error）
- 编排多个 Repository 和外部服务的调用
- 实现业务规则和校验逻辑
- 管理数据库事务

Service 层依赖 Repository 的接口而非具体实现（依赖倒置原则），便于单元测试和实现替换。

### 3. Repository 层职责：数据访问抽象

Repository 层封装所有数据访问逻辑。Repository 接口定义在 Service 所在的包中（依赖倒置），具体实现在基础设施层。

Repository 接口的方法签名只应涉及领域对象，不暴露数据库实现细节（如 SQL 语句、ORM 特定类型）。

### 4. 禁止跨层调用和反向依赖

Handler 不得直接调用 Repository，必须通过 Service。Service 不依赖 Handler。各层之间的数据传输使用领域对象或专用 DTO，不得直接使用 HTTP 请求/响应对象在层间传递。

## warn 级别软约束

- Service 通过接口暴露能力，测试时用 mock 实现替换
- 实体对象和 DTO 之间的转换集中在独立的 assembler 包中
- 使用依赖注入工具（Wire）管理对象的创建和依赖关系
