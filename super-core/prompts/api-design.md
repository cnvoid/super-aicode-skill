# api-design — API 设计规范

## error 级别硬约束

### 1. URL 使用名词复数 + 层级结构

RESTful API 的 URL 路径必须使用名词复数表示资源集合，通过路径层级表达资源的从属关系。不得在 URL 中使用动词。

正确示例的思路：
- 资源集合使用复数名词：/orders、/users、/products
- 单一资源通过 ID 定位：/orders/{orderId}
- 子资源表达从属关系：/orders/{orderId}/items、/orders/{orderId}/items/{itemId}
- 操作类接口使用动词后缀：/orders/{orderId}/cancel、/orders/{orderId}/refund

禁止的格式：
- URL 中包含动词（如 /getOrder、/createUser、/deleteProduct）
- 资源名使用单数形式（如 /order、/user）
- URL 大小写混用（统一小写 + 连字符）

### 2. 分页、排序、过滤参数标准化

所有列表查询接口必须支持分页，且参数名统一为：

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| page | int | 否 | 1 | 页码（从 1 开始） |
| pageSize | int | 否 | 20 | 每页条数（最大 100） |
| sort | string | 否 | - | 排序字段，前缀 `-` 表示降序 |
| keyword | string | 否 | - | 全局模糊搜索关键字 |

其他过滤参数直接使用字段名作为查询参数（如 ?status=PAID&userId=123）。

分页查询接口必须返回 total 字段，用于前端计算总页数。默认每页条数不超过 20 条防止查询压力过大。

### 3. API 必须做版本管理

API 版本号必须体现在 URL 路径中（如 /api/v1/orders），或通过请求头的 Accept 字段指定版本。不得发布无版本号的生产 API。

版本策略：
- 兼容性变更（新增字段、新增接口）→ 同一版本内演进，不增加版本号
- 破坏性变更（删除字段、修改字段类型、修改接口语义）→ 发布新版本，旧版本保留至客户端全部迁移

### 4. 请求和响应统一使用 JSON

所有 API 的 Content-Type 和 Accept 必须为 application/json。请求体和响应体统一使用 JSON 格式，字段命名统一为 camelCase。

文件上传接口使用 multipart/form-data，但响应体仍返回 JSON。禁止使用 application/xml 等其他格式。

## warn 级别软约束

- 在接口路径中携带业务含义过于明显的枚举值（如 /orders/status/PAID）时，应考虑是否改为查询参数（/orders?status=PAID），因为路径中的枚举值变更即为破坏性变更
- 批量操作接口使用独立的批量端点（如 POST /orders/batch-delete），接收 ID 数组作为请求体
- 接口文档通过 OpenAPI/Swagger 注解自动生成，与代码保持同步
- 对于超长列表（如日志、审计记录），考虑使用游标分页替代 offset 分页
