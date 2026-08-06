# concurrency — Go 并发规范

## error 级别硬约束

### 1. context 必须贯穿整个调用链

所有涉及 I/O 操作（数据库、HTTP、RPC、消息队列）的函数，第一个参数必须是 context.Context。该 context 从请求入口（HTTP Handler）创建，贯穿整个调用链，不得在中间层使用 context.Background() 或 context.TODO() 截断链路。

context 用于传递：
- 超时控制（context.WithTimeout）
- 取消信号（context.WithCancel）
- 请求级别的值（context.WithValue，仅用于 trace-id 等横切关注点）

### 2. 每个 goroutine 必须有明确的退出路径

启动 goroutine 的函数必须提供退出机制，避免 goroutine 泄漏。退出机制包括：
- 监听 context.Done() 通道
- 通过 select 同时监听工作通道和退出信号
- 设置超时时间

禁止启动无限循环且无退出条件的 goroutine。所有 goroutine 在对应的 context 取消时必须能够退出。

### 3. goroutine 必须 recover panic

每个独立启动的 goroutine 顶部必须 defer recover，防止单个 goroutine 的 panic 导致整个进程崩溃。recover 后必须记录完整的错误信息和堆栈日志，并可选择性的上报告警。

### 4. channel 由发送方关闭

channel 的关闭操作必须由发送方执行。向已关闭的 channel 发送数据会 panic，从已关闭的 channel 接收数据不会 panic（返回到零值）。

接收方不得关闭 channel。如需通知发送方停止发送，应使用独立的 context 或 done channel。

## warn 级别软约束

- 使用 sync.WaitGroup 等待多个 goroutine 执行完成
- 使用 sync.Once 保证一次性初始化
- 信号通知场景优先使用 chan struct{}
- 避免在 select 中使用 time.After（会导致内存泄漏），使用 time.NewTimer 配合 Reset
