---
name: super-sse
description: >
  Server-Sent Events real-time push architecture standards covering
  connection lifecycle, frontend performance, and backend performance.
  Triggers: SSE, Server-Sent Events, EventSource, 服务端推送, 实时推送,
  单向流, text/event-stream, sse.
---

# Contract

本技能**叠加**在 `super-core` 之上，提供 SSE（Server-Sent Events）实时推送架构规范。

## 前置检查

1. 确认 `super-core` 已加载
2. 从合并配置中读取 `scenarios.sse.enabled`：
   - `false` → 跳过
   - `true`  → 继续
3. 从合并配置中读取 `scenarios.sse.rules`，加载对应 prompt

## 加载规则

| 配置项 | prompt 文件 | 覆盖内容 |
|--------|-----------|---------|
| sse-client | prompts/sse-client.md | 前端 SSE：连接/断开时机、连接复用、背压处理、虚拟列表 |
| sse-server | prompts/sse-server.md | 后端 SSE：连接模型、心跳清理、pub/sub 广播、消息合并、资源隔离 |

## 自检

代码输出后，在 super-core 自检表后追加：

```
[super-sse] 规则检查
  ✅ sse-client  — EventSource 连接复用 ≤ 2，页面离开/后台超时断开，rAF 合并更新
  ✅ sse-server  — 异步非阻塞连接模型，30s 心跳 + 死连接清理，pub/sub 广播，gzip 压缩
```

## 关键技术约束速查

### SSE 连接时机

| 事件 | 动作 |
|------|------|
| 页面挂载 | 建立连接（useEffect / componentDidMount） |
| 页面卸载 | 断开连接（cleanup / componentWillUnmount） |
| 切到后台 > 30s | 主动断连，避免无效长连接占用 |
| 切回前台 | 检测 EventSource.readyState，断开则重连 |
| 网络离线/在线 | 监听 online/offline 事件，自动断开/重连 |
| 连接意外断开 | EventSource 原生 3s 自动重连，不引入外部重连库 |

### 性能优化速查

| 层级 | 策略 | 级别 |
|------|------|------|
| 前端 | 全局连接复用（1-2 个 EventSource），按 event type 路由 | error |
| 前端 | requestAnimationFrame 合并高频 setState | warn |
| 前端 | 虚拟列表渲染推送驱动的长列表 | warn |
| 后端 | 异步非阻塞连接模型（Flusher / SSEemitter / goroutine） | error |
| 后端 | 30s 心跳 + 死连接清理 | error |
| 后端 | pub/sub 广播（Redis/Kafka），按用户/主题隔离频道 | error |
| 后端 | 50ms 消息合并写入 | warn |
| 后端 | gzip Content-Encoding 压缩 | warn |
