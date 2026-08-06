---
name: super-backend-common
description: >
  Shared backend engineering standards applicable to Java, Node.js, and Go
  projects. Activates when implementing auth, caching, database operations,
  or designing APIs for AI agent consumption. Triggers: authentication,
  authorization, OAuth2, JWT, session, RBAC, permission, cache, Redis,
  caching strategy, cache penetration, database, schema, migration, Flyway,
  Liquibase, indexing, connection pool, transaction, digital worker, AI
  agent, OpenAPI, Swagger, idempotency, API key, audit log.
---

# Contract

本技能**叠加**在 `super-core` 之上，提供跨语言通用的后端工程规范。

## 前置检查

1. 确认 `super-core` 已加载
2. 从合并配置中读取 `scenarios.backend-common.enabled`：
   - `false` → 跳过
   - `true`  → 继续
3. 从合并配置中读取 `scenarios.backend-common.rules`，加载对应 prompt

## 加载规则

| 配置项 | prompt 文件 | 覆盖内容 |
|--------|-----------|---------|
| auth | prompts/auth.md | 认证鉴权：JWT、OAuth2、RBAC、密码策略 |
| cache | prompts/cache.md | 缓存策略：穿透/击穿/雪崩防范、多级缓存、更新策略 |
| database | prompts/database.md | 数据库设计：表设计、索引策略、迁移脚本、连接池 |
| digital-worker | prompts/digital-worker.md | 数字员工接入：OpenAPI可发现、Schema完整、错误自愈、审计 |

## 自检

代码输出后，在 super-core 自检表后追加：

```
[super-backend-common] 规则检查
  ✅ auth            — JWT 双 Token，RBAC 权限模型，密码 bcrypt
  ✅ cache           — 缓存穿透布隆过滤器已配置，雪崩随机 TTL
  ✅ database        — 索引覆盖查询，迁移脚本可回滚，连接池上限合理
  ✅ digital-worker  — OpenAPI 文档完整，幂等键已实现，审计日志标识 operator_type
```
