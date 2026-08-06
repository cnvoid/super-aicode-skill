---
name: super-backend-node
description: >
  Node.js backend coding standards. Activates when writing Express, NestJS,
  Fastify, Koa, Prisma, TypeORM, or any Node.js server code. Triggers include:
  Node.js, Express, NestJS, Fastify, Koa, middleware, Prisma, TypeORM, Sequelize,
  npm, package.json, route, controller, module, guard, pipe, interceptor.
---

# Contract

本技能**叠加**在 `super-core` 之上生效。

## 前置检查

1. 确认 `super-core` 已加载。若未加载，先执行 super-core Phase 1-2。
2. 从合并配置中读取 `scenarios.backend-node.enabled`：
   - `false` → 跳过本技能
   - `true`  → 继续加载
3. 从合并配置中读取 `scenarios.backend-node.rules`，加载对应 prompt。

## 加载规则

| 配置项 | prompt 文件 | 覆盖内容 |
|--------|-----------|---------|
| express | prompts/express.md | 路由、中间件、错误处理 |
| nestjs | prompts/nestjs.md | 模块、守卫、拦截器、管道 |
| prisma | prompts/prisma.md | Schema 设计、迁移、查询优化 |

## 自检

代码输出后，在 super-core 自检表后追加：

```
[super-backend-node] 规则检查
  ✅ express    — 全局错误中间件已注册，路由有 asyncHandler
  ✅ prisma     — 无 N+1，使用 include/select 精确查询
  —   nestjs    — 非 NestJS 项目
```
