# http — HTTP 请求封装规范

## error 级别硬约束

### 1. 必须封装统一的 HTTP 实例

项目中所有 HTTP 请求必须通过统一的请求实例发起，不得直接使用原生 fetch/axios 进行裸调。统一实例封装以下能力：

- 设置默认 Content-Type 为 application/json
- 携带 withCredentials（如使用 Cookie 认证）
- 统一的超时和重试策略

### 2. API 地址必须通过配置注入，禁止硬编码

统一请求实例的 baseURL 必须从环境变量或配置文件中读取，不得在业务代码中硬编码 API 地址，也不得在每个接口调用处重复拼接地址前缀。

各框架的配置注入方式：
- Vite 项目：`import.meta.env.VITE_API_BASE_URL`
- Create React App：`process.env.REACT_APP_API_BASE_URL`
- Next.js：`process.env.NEXT_PUBLIC_API_BASE_URL`（客户端）或 `process.env.API_BASE_URL`（服务端）
- 全局配置：`window.__APP_CONFIG__.apiBaseUrl`（配合部署时注入的配置文件）

环境变量按环境分离配置：
- `.env.development`：`VITE_API_BASE_URL=http://localhost:8080/api/v1`
- `.env.production`：`VITE_API_BASE_URL=https://api.example.com/api/v1`

禁止的行为：
- baseURL 在创建 axios/fetch 实例时用字符串字面量硬编码
- 在每个接口调用中拼接完整 URL（如 `fetch('https://api.example.com/api/v1/orders')`）
- 开发环境和生产环境使用同一个地址，通过注释切换

### 3. 请求拦截器必须自动注入认证信息

请求拦截器必须在每个请求发出前自动附加认证凭据。Token 不得由每个调用方手动传入请求头。

拦截器职责：
- 从安全的存储位置读取 Token 并注入 Authorization 请求头
- 注入 trace-id（用于全链路追踪）
- 注入请求时间戳（用于防重放）

### 4. 响应拦截器必须统一处理 code != 0

响应拦截器必须对所有响应体进行统一解包处理：

- 检查响应体的 code 字段
- code === 0：解包 data 字段，返回给调用方（调用方无需再处理 code）
- 拦截器自动弹出 Toast 提示（使用 message 字段内容）
- 分页接口的 data 保持分页结构不变，解包后照常透传

### 5. 登录失效必须统一跳转

响应拦截器必须拦截 401 状态码和登录相关的错误 code，执行统一的登出流程：

登出流程：
- 清除本地存储的所有认证信息（Token、用户信息、权限数据）
- 清除 Pinia/Redux/Zustand 等状态管理中的用户状态
- 记录当前页面路径，作为登录成功后的回跳地址
- 跳转到登录页面

该流程必须封装在拦截器中，不得零散分布在各个业务页面的 try-catch 中。

### 6. 请求超时必须设置

每个请求必须显式设置超时时间。不同场景的超时建议值：
- 普通查询：10s
- 文件上传：60s
- 导出下载：120s

超时后需在拦截器中统一弹出提示，避免页面无响应造成"假死"。

## warn 级别软约束

- 请求的错误提示下沉到拦截器统一处理，业务代码只处理业务逻辑，无需逐个 catch 弹 Toast
- 短时间内相同参数的 GET 请求自动去重（复用第一个请求的 Promise），防止按钮快速点击产生冗余请求
- 页面切换时自动取消未完成的请求（通过 AbortController 实现），避免已卸载页面的 setState 警告
- 文件下载请求设置 responseType 为 blob，并根据响应头的 Content-Disposition 提取文件名
- 请求失败时的 Toast 文案区分网络超时、服务端异常、业务异常三种场景
- 支持静默请求模式（不显示 loading 和错误 Toast），适用于轮询、自动保存等后台操作
