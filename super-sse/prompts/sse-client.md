# sse-client — SSE 前端客户端规范

## error 级别硬约束

### 1. 连接生命周期必须在组件层级正确管理

SSE 连接必须跟随页面/组件生命周期：

| 时机 | 框架 | 动作 |
|------|------|------|
| 页面进入 / 组件挂载 | React: `useEffect(() => {}, [])` / Vue: `onMounted` | `new EventSource(url)` 建立连接 |
| 页面离开 / 组件卸载 | React: `useEffect` return cleanup / Vue: `onUnmounted` | `eventSource.close()` 断开连接 |
| 浏览器切到后台 > 30s | `document.addEventListener('visibilitychange', ...)` | 主动 `close()`，节省带宽 |
| 浏览器切回前台 | 同上 `visibilitychange` | 检查 `eventSource.readyState === EventSource.CLOSED`，是则重连 |
| 网络离线 | `window.addEventListener('offline', ...)` | 主动 `close()`，避免无效重连 |
| 网络恢复在线 | `window.addEventListener('online', ...)` | 重新建立连接 |

- 不得在全局作用域创建 EventSource 后不随页面卸载而关闭
- 不得忽略 `visibilitychange` 事件，使后台页面维持无效长连接
- 不得在离线状态下反复重连消耗电量

### 2. 必须全局复用 SSE 连接，不得按组件创建

整个应用最多维持 **1-2 个** SSE 连接：

- **连接池管理**：创建一个模块级单例（如 `sseConnection.ts`），暴露 `subscribe(eventType, handler)` 和 `unsubscribe(eventType, handler)` 接口
- **事件路由**：服务端通过 `event:` 字段区分事件类型（如 `event: order_update`），前端通过 `addEventListener` 按类型接收
- 组件挂载时调用 `subscribe(...)` 注册回调，卸载时调用 `unsubscribe(...)` 移除回调
- 不得每个列表、每个详情页、每个通知组件各建一个 EventSource
- 不得将 EventSource 实例作为 React state 或 Vue ref，应存储在模块闭包中

**推荐实现模式：**

```typescript
// sseConnection.ts — 全局单例
let eventSource: EventSource | null = null;
const listeners = new Map<string, Set<(data: any) => void>>();

export function subscribe(eventType: string, handler: (data: any) => void) { ... }
export function unsubscribe(eventType: string, handler: (data: any) => void) { ... }
export function connect(url: string) { ... }
export function disconnect() { ... }
```

### 3. 必须处理连接异常与重连

EventSource 原生支持自动重连（3s 间隔），但需要额外处理：

- 监听 `eventSource.onerror` 事件，根据 `readyState` 判断：`CLOSED (2)` = 永久关闭，`CONNECTING (0)` = 正在重连
- 永久关闭条件：连续重连失败 > 10 次 或 后端返回 503 + `Retry-After` 或 页面后台超过 5 分钟 → 停止重连，UI 提示用户刷新
- 重连时根据 `Last-Event-ID` 请求头断点续传（EventSource 自动发送）
- 不得对 `onerror` 不做任何处理，也不得每个 onerror 直接 `close()` 阻断自动重连

### 4. 高频推送必须使用 rAF 合并更新

当推送频率 > 10 条/秒时，不得每条消息直接调用 `setState` / `ref.value = `：

- 使用 `requestAnimationFrame` 合并同一帧内的多次数据更新
- 使用缓冲队列：消息到达 → push 到 buffer → rAF callback 中 drain buffer → 一次性 setState
- buffer 用普通数组，drain 时拿到引用后清空，避免频繁的数组拷贝

**推荐实现模式：**

```typescript
let buffer: Message[] = [];
let rafId: number | null = null;

function onMessage(msg: Message) {
  buffer.push(msg);
  if (rafId !== null) return;
  rafId = requestAnimationFrame(() => {
    const batch = buffer;
    buffer = [];
    rafId = null;
    // 一次 setState 处理整批
    setMessages(prev => mergeUpdate(prev, batch));
  });
}
```

## warn 级别软约束

- **虚拟列表**：当 SSE 推送的数据驱动长列表渲染时（如日志流、交易记录），必须使用虚拟列表库（react-window / vue-virtual-scroller / ngx-virtual-scroller），只渲染可视区域的 DOM 节点。列表过长时设置 maxSize 截断旧数据
- **增量更新**：后端推送的 data 结构应为增量变更（`{ type: 'update', id: 1, delta: { status: 'done' } }`），前端做 `Object.assign` / `immer.produce` merge，不得后端每次推送全量列表导致前端整体替换 DOM
- **心跳忽略**：后端心跳注释行 `: heartbeat` 不触发 `message` 事件，不消耗回调。若后端未用注释格式，前端须在 `onmessage` 中过滤心跳数据，不得让其进入业务逻辑或触发 re-render
- **内存回收**：页面上长时间打开的 SSE 推送列表（如实时日志），对 DOM 节点或 JS 对象引入 WeakMap/WeakRef 避免意外滞留；超过屏幕范围外的旧数据可用 `slice` 裁剪，维持内存上限
- **并发连接感知**：若同一域名下有 WebSocket 或其他长连接，SSE + WS 总数仍受浏览器同域 6 连接限制。对 6 个以上的需求应合并为复用方案或退化为轮询
- **页面隐藏时的降级**：`visibilitychange` 到隐藏时，buffer 中的消息暂存不清空；切回可见时一次性 flush，避免丢失后台期间的事件
