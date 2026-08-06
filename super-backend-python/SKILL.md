---
name: super-backend-python
description: >
  Python backend coding standards for FastAPI, Django, and Flask projects.
  Activates when writing Python server code, API endpoints, ORM models,
  or data validation schemas. Triggers: Python, FastAPI, Django, Flask,
  pydantic, SQLAlchemy, Alembic, tortoise-orm, async def, uvicorn,
  gunicorn, pytest-asyncio, poetry, pip, black, ruff, mypy.
---

# Contract

本技能**叠加**在 `super-core` 之上生效。

## 前置检查

1. 确认 `super-core` 已加载
2. 从合并配置中读取 `scenarios.backend-python.enabled`：
   - `false` → 跳过本技能
   - `true`  → 继续加载
3. 从合并配置中读取 `scenarios.backend-python.rules`，加载对应 prompt。

## 加载规则

| 配置项 | prompt 文件 | 覆盖内容 |
|--------|-----------|---------|
| fastapi | prompts/fastapi.md | FastAPI 路由、依赖注入、中间件、异常处理、生命周期 |
| pydantic | prompts/pydantic.md | Pydantic Schema、字段校验、类型导出、序列化配置 |
| sqlalchemy | prompts/sqlalchemy.md | SQLAlchemy 异步、会话管理、N+1 防范、Alembic 迁移 |
| layering | prompts/layering.md | Router/Service/Repository 分层、跨层禁止 |

## 自检

代码输出后，在 super-core 自检表后追加：

```
[super-backend-python] 规则检查
  ✅ fastapi     — APIRouter 模块化拆分，Depends 依赖注入，HTTPException 统一处理
  ✅ pydantic    — 所有请求/响应使用 Pydantic 模型，Field 约束完整，model_config 设置
  ✅ sqlalchemy  — AsyncSession 工厂，selectinload 防 N+1，Alembic 迁移脚本已生成
  ✅ layering    — Router → Service → Repository 单向依赖，DTO 与 Entity 分离
```
