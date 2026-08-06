# sqlalchemy — SQLAlchemy ORM 规范

## error 级别硬约束

### 1. 必须使用异步引擎和 AsyncSession

所有数据库操作必须使用异步模式，不得阻塞事件循环：

```python
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

engine = create_async_engine(
    config.db_url,          # postgresql+asyncpg://...
    pool_size=20,
    max_overflow=10,
    pool_pre_ping=True,     # 连接健康检查
    echo=False,             # 生产环境必须 False
)

AsyncSessionFactory = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False, # 提交后不过期对象
)
```

不得在异步路径函数中调用 `session.execute()` 的同步写法或使用同步 `Engine`。

### 2. 必须防范 N+1 查询——使用 selectinload

所有涉及关联查询的地方必须显式声明加载策略：

```python
from sqlalchemy import select
from sqlalchemy.orm import selectinload

# ❌ 错误：隐式延迟加载，触发 N+1
stmt = select(Order).where(Order.user_id == user_id)
result = await session.execute(stmt)
orders = result.scalars().all()
for order in orders:
    print(order.items)  # 每次触发一条新查询

# ✅ 正确：selectinload 一次性加载
stmt = (
    select(Order)
    .where(Order.user_id == user_id)
    .options(
        selectinload(Order.items),
        selectinload(Order.address),
    )
)
result = await session.execute(stmt)
orders = result.unique().scalars().all()
```

不得依赖 SQLAlchemy 的默认 lazy loading 行为。

### 3. 会话生命周期必须由 Depends 管理

每个请求一个会话，请求结束时自动回滚/关闭：

```python
from collections.abc import AsyncGenerator

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionFactory() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise

# 在路由中使用
@router.post("/orders")
async def create_order(
    req: CreateOrderRequest,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> OrderVO:
    ...
```

不得在模块级别或缓存中持有 `AsyncSession` 实例。不得手动管理 session 的 commit/rollback 而不经过 Depends 声明周期。

### 4. 所有 Model 迁移必须通过 Alembic

数据库表结构变更必须使用 Alembic 迁移脚本，不得手动执行 SQL：

```bash
# 生成迁移脚本
alembic revision --autogenerate -m "add order table"

# 执行迁移
alembic upgrade head

# 回滚
alembic downgrade -1
```

每个迁移必须包含完整的 `upgrade()` 和 `downgrade()` 逻辑，确保可回滚。不得跳过 Alembic 直接用 `Base.metadata.create_all` 在生产环境建表。

### 5. 连接池必须显式配置

```python
engine = create_async_engine(
    url,
    pool_size=20,              # 常驻连接数
    max_overflow=10,           # 最大溢出连接数
    pool_recycle=3600,         # 连接回收时间（秒）
    pool_pre_ping=True,        # 每次检出前 ping 测试
    connect_args={
        "statement_cache_size": 0,  # asyncpg 需要，防止 prepared statement 冲突
    },
)
```

不得使用默认连接池配置。

## warn 级别软约束

- **Repository 封装**：数据库操作建议封装在 Repository 层，不在路径函数中直接写 select
- **批量操作**：批量插入建议使用 `session.add_all()` 而非逐条 `add()`
- **大表查询**：大表分页建议使用 keyset pagination（游标），而非 offset 分页
- **连接泄漏**：建议在开发环境设置 `echo_pool="debug"` 监控连接池状态
- **事务隔离**：写操作建议根据业务需求声明隔离级别，如 `session.connection(execution_options={"isolation_level": "REPEATABLE READ"})`
