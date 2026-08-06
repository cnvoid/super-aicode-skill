# security — 前端安全规范

## error 级别硬约束

### 1. Token 不得存储在 localStorage 或 sessionStorage

认证 Token 必须存储在 httpOnly Cookie 中（由服务端 Set-Cookie 下发），禁止存储在 localStorage 或 sessionStorage 中。httpOnly Cookie 对 JavaScript 不可见，可有效防止 XSS 攻击窃取 Token。

如因架构限制无法使用 Cookie，必须使用内存变量存储 Token（刷新页面后需重新登录），不得退而求其次使用 localStorage。

### 2. 用户输入内容渲染前必须转义

所有来自用户输入的内容（包括 URL 参数、表单输入、富文本编辑器内容）在渲染到页面上前，必须进行 HTML 转义处理，防止 XSS 攻击。

React 的 JSX 默认对 `{variable}` 插值进行转义，此场景天然安全。需要重点防范的场景：
- 使用 dangerouslySetInnerHTML 直接注入 HTML——必须先用 DOMPurify 清洗
- 在 a 标签的 href 中拼接用户输入——校验协议前缀，只允许 http/https
- 使用 v-html 指令（Vue）——必须先用 DOMPurify 清洗

### 3. 禁止在前端代码中硬编码密钥

API Key、密钥、证书、私钥等敏感凭据不得出现在前端源代码、环境变量文件、构建产物中。需要密钥的加密/解密操作必须在服务端完成，前端不得持有密钥。

## warn 级别软约束

- 在 index.html 中通过 `<meta http-equiv="Content-Security-Policy">` 配置基础的 CSP 策略
- 登录、支付、删除等敏感操作页面，添加二次确认或验证码校验
- 第三方 iframe 嵌入使用 sandbox 属性限制其能力
- 对外部跳转链接（target="_blank"）添加 rel="noopener noreferrer"
- 敏感数据（手机号、身份证）在前端展示时部分掩码
- 开发环境与生产环境使用不同的应用标识，防止开发环境数据污染生产
