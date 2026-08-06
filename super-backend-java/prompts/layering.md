# layering — 分层架构规范

## error 级别硬约束

### 1. Controller 层职责：参数接收、校验、路由、响应

Controller 层的唯一职责是处理 HTTP 层面的关注点：
- 接收和绑定请求参数
- 调用校验框架进行参数校验（声明式校验，不应手写校验逻辑）
- 将请求参数转换为领域对象后调用 Service 层
- 将 Service 层返回的结果转换为 HTTP 响应

Controller 层不得包含：
- 业务逻辑（如判断库存是否充足）
- 直接调用 Repository 层
- 直接操作数据库或缓存
- 手写复杂的条件判断和数据转换

### 2. Service 层职责：业务逻辑编排

Service 层是业务逻辑的核心所在：
- 协调多个 Repository 和外部服务完成业务流程
- 包含事务边界定义
- 包含业务规则和校验
- 发布领域事件

Service 层不得包含：
- HTTP 请求/响应对象
- SQL 语句或数据库连接操作
- JSON/XML 序列化逻辑

Service 应使用构造器注入依赖，通过接口而非具体实现声明依赖关系。

### 3. Repository 层职责：数据访问抽象

Repository 层封装所有数据访问逻辑：
- 提供对外的数据访问接口
- 实现查询优化（N+1 查询防范、分页、索引利用）
- 管理数据库连接和事务

Repository 层不得包含：
- 业务逻辑
- HTTP 调用
- 领域事件发布

### 4. 禁止跨层调用

严格遵守分层调用规则：
- Controller → Service → Repository
- 不得 Controller → Repository（跳过 Service）
- 不得 Service → Controller（反向依赖）
- 各层之间的数据传输使用 DTO/VO，不得直接暴露 Entity

## warn 级别软约束

- DTO、VO、Entity 之间的对象转换集中在独立的工具类或 MapStruct 接口中
- 第三方服务调用封装在独立的 Client 层或防腐层
- 大型 Service 按业务子域拆分为多个小型 Service
