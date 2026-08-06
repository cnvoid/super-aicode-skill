# sse-server — SSE 后端服务端规范

## error 级别硬约束

### 1. 必须使用异步非阻塞连接模型

SSE 连接是长连接，不得阻塞请求处理线程。各语言方案：

**Node.js：**
- 使用 `http.ServerResponse` 原生写流，不得使用 Express 的 `res.send()` / `res.json()`
- 必须调用 `res.flushHeaders()` 在写入数据之前发送响应头
- 设置 `res.setTimeout(0)` 禁用请求超时
- 监听 `req.on('close')` 事件，客户端断开时立即清理资源

**Go：**
- 每个 SSE 连接使用独立 goroutine，使用 `http.Flusher` 接口
- 在 handler 开头调用 `flusher, ok := w.(http.Flusher)`，ok==false 时返回 500
- 设置 `w.Header().Set("Connection", "keep-alive")`
- 使用 `context.WithCancel` 配合 `req.Context().Done()` 感知客户端断开

**Java：**
- 使用 `org.springframework.web.servlet.mvc.method.annotation.SseEmitter`，不得用 `@ResponseBody` + 手动写流
- `SseEmitter` 构造器 timeout 设为 `Long.MAX_VALUE` 或长超时（如 1 小时），不得使用默认的 30s
- 使用 `emitter.onCompletion(...)` 和 `emitter.onTimeout(...)` 注册清理回调
- 若用 WebFlux，使用 `Flux<ServerSentEvent<T>>` 配合 `MediaType.TEXT_EVENT_STREAM`

### 2. 必须实现心跳与死连接清理

长连接可能因网络中间设备（NAT/代理/负载均衡）超时断开，服务端必须主动探测：

- **心跳间隔**：每 30s 发一次注释行 `: heartbeat`（SSE 协议规定以 `:` 开头的行是注释，不会触发客户端事件）
- **死连接判定**：超过 30s 无任何读写活动的连接视为死连接
- **清理动作**：调用 `req.socket.destroy()` / `req.destroy()`（Node.js），`ctx.Done()` 触发（Go），`emitter.completeWithError()`（Java）
- **定时器**：使用 server 级别的 `setInterval` 或 `time.Ticker`，不得每个连接创建一个独立定时器
- 清理后必须回收到连接池配额，释放 fd 和内存引用

### 3. 必须使用 pub/sub 广播模型

SSE 后端的数据源必须是发布/订阅模型，不得轮询数据库：

- **频道隔离**：按用户 ID / 租户 ID / 主题划分 pub/sub 频道，每个 SSE 连接只 subscribe 它需要的频道
- **消息路由**：业务变更时 publish 到对应频道 → SSE 连接收到消息 → 写入响应流
- **技术选型**：
  - 单进程场景：内部 EventEmitter / channel / goroutine chan
  - 多进程/多实例场景：Redis Pub/Sub、RabbitMQ Stream、Kafka、NATS（任选其一，不得混用）
  - 不得用数据库 `FOR UPDATE` / 定时 `SELECT` 轮询替代 pub/sub
- **连接断开时**：必须取消订阅（unsubscribe），防止回调引用泄漏

### 4. 连接池上限必须显式配置

单台后端实例的并发 SSE 连接数不得无限制增长：

- **上限值**：单实例 SSE 连接数 ≤ 10,000（根据实例规格调整，2C4G 建议 ≤ 2,000）
- **拒绝策略**：超出上限时返回 HTTP 503 + `Retry-After: 5` 响应头，客户端收到后 5s 后重试
- **优雅降级**：达到 80% 水位线时打印 WARN 日志，触发告警
- 不得在接受连接后再因资源不足崩溃

## warn 级别软约束

- **消息合并**：50ms 时间窗口内同一连接的待发送消息合并为一个 SSE chunk，减少 `write()` 系统调用次数和 TCP 小包数量
- **gzip 压缩**：SSE 文本流使用 `Content-Encoding: gzip`，文本类数据压缩率通常 > 60%。注意：Nginx 等反向代理需配置 `proxy_buffering off` 和 `gzip on`，否则可能阻塞分块传输
- **消息体序列化**：SSE `data` 字段使用 JSON，优先用短字段名（如在服务端做 key 的别名映射），减少带宽；二进制数据 base64 编码放入 data 字段
- **Event 类型标准化**：业务事件使用 `event:` 字段区分类型（如 `event: order_status`），心跳不设 `event:`，浏览器端通过 `addEventListener('order_status', ...)` 接收
- **Last-Event-ID 支持**：服务端必须解析客户端的 `Last-Event-ID` 请求头，在重连后从该事件之后继续推送，确保消息不丢
- **连接打散**：应用启动/重启时大量客户端同时重连可能形成惊群，服务端启动后对首个心跳或初始事件增加随机 0-5s 延迟，打散重连尖峰
- **优雅关闭**：服务停止前向所有 SSE 连接发送 `event: shutdown` 事件，等待 2s 后关闭连接，客户端收到后不再重连
