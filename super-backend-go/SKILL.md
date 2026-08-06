---
name: super-backend-go
description: >
  Go backend coding standards. Activates when writing Go/Golang server code.
  Triggers include: Go, Golang, Gin, Echo, goroutine, channel, struct, interface,
  go mod, go sum, handler, middleware, context, defer, Errorf, fmt.Errorf,
  net/http, database/sql, GORM.
---

# Contract

本技能**叠加**在 `super-core` 之上生效。

## 前置检查

1. 确认 `super-core` 已加载。若未加载，先执行 super-core Phase 1-2。
2. 从合并配置中读取 `scenarios.backend-go.enabled`：
   - `false` → 跳过本技能
   - `true`  → 继续加载
3. 从合并配置中读取 `scenarios.backend-go.rules`，加载对应 prompt。

## 加载规则

| 配置项 | prompt 文件 | 覆盖内容 |
|--------|-----------|---------|
| layering | prompts/layering.md | handler/service/repository 分层 |
| error-handling | prompts/error-handling.md | error wrap、sentinel error、panic recover |
| concurrency | prompts/concurrency.md | goroutine 管理、context 传递、channel |

## 自检

代码输出后，在 super-core 自检表后追加：

```
[super-backend-go] 规则检查
  ✅ layering       — handler→service→repo 分层清晰
  ✅ error-handling — error 全部 wrap + sentinel 错误已定义
  ⚠️  concurrency   — goroutine 退出条件已处理，缺少超时控制(TODO)
```
