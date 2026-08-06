# error-handling — Go 错误处理规范

## error 级别硬约束

### 1. 必须检查和处理每一个 error 返回值

所有返回 error 的函数调用，必须检查返回的 error 值并做出相应处理。不得使用 _ 忽略 error 返回值。

### 2. 使用 fmt.Errorf + %w 包装 error

向上层传递 error 时必须使用 fmt.Errorf 配合 %w 动词包装原始 error，保留完整的错误链。这确保上层可以通过 errors.Is 和 errors.As 判断错误类型。

包装时应在错误消息中添加当前操作的上下文信息（如 "save order: %w"、"deduct inventory: %w"），形成可读的错误调用链。

不得使用字符串拼接或 %v 格式化丢失错误链。

### 3. 必须定义 sentinel error

项目中可预期的错误（如"订单不存在"、"库存不足"、"支付失败"）必须定义为包级别的 sentinel error 变量（使用 errors.New）。上层调用方通过 errors.Is 判断是否为特定错误。

不得在业务代码中通过字符串比较 err.Error() 来判断错误类型。

### 4. panic 仅限于不可恢复场景

panic 仅允许在以下场景使用：
- 程序初始化阶段（init 函数中配置加载失败）
- 编程错误（如参数是 nil 但文档明确禁止 nil）

业务逻辑中不得使用 panic，必须使用 error 返回值。

任何启动 goroutine 的函数顶部必须 defer recover 以防止 panic 导致整个程序崩溃。recover 后需记录完整堆栈日志。

## warn 级别软约束

- 自定义错误类型需实现 Error() 和 Unwrap() 方法
- 循环中拼接错误使用 errors.Join（Go 1.20+）
- 第三方库返回的 error 包装后再向上传递，不直接暴露
