# layering — Python 后端分层架构规范

## error 级别硬约束

### 1. Router 层职责：HTTP 关注点

Router 层（FastAPI 的路径函数）的唯一职责：
- 解析请求参数（路径参数、Query 参数、Body）
- 调用 Pydantic 进行声明式校验（通过类型注解自动触发）
- 将请求数据传递给 Service 层
- 将 Service 返回的领域对象返回（FastAPI 自动序列化 Pydantic）

Router 层禁止包含：
- 业务逻辑（如计算折扣、检查库存）
- 数据库操作（select/insert/update/delete）
- 调用外部 API
- 复杂的条件判断和数据转换

```python
# ✅ 正确：薄 Router 层
@router.post("/orders")
async def create_order(
    req: CreateOrderRequest,
    service: Annotated[OrderService, Depends()],
    current_user: Annotated[User, Depends(get_current_user)],
) -> OrderVO:
    return await service.create(req, user_id=current_user.id)


# ❌ 错误：业务逻辑泄露到 Router
@router.post("/orders")
async def create_order(
    req: CreateOrderRequest,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> OrderVO:
    # 在 Router 中做库存检查
    for item in req.items:
        sku = await db.get(Sku, item.sku_id)
        if sku.stock < item.quantity:
            raise HTTPException(400, "库存不足")
    ...
```

### 2. Service 层职责：业务逻辑编排

Service 层是业务逻辑的核心所在：
- 协调多个 Repository 完成业务流程
- 包含业务规则和校验
- 管理事务边界
- 调用外部服务（通过 Client 层封装）
- 返回 Pydantic Schema 对象（不返回 ORM Entity）

Service 层禁止包含：
- HTTP 请求/响应对象（Request、Response）
- 直接使用 FastAPI 的 Depends、HTTPException
- 原始 SQL 字符串

```python
# app/services/order_service.py
from pydantic import BaseModel

class OrderService:
    def __init__(self, order_repo: OrderRepository, sku_repo: SkuRepository):
        self.order_repo = order_repo
        self.sku_repo = sku_repo

    async def create(self, req: CreateOrderRequest, user_id: str) -> OrderVO:
        for item in req.items:
            sku = await self.sku_repo.get_by_id(item.sku_id)
            if sku is None:
                raise AppException(f"商品 {item.sku_id} 不存在", code="SKU_NOT_FOUND")
            if sku.stock < item.quantity:
                raise AppException(f"商品 {item.sku_id} 库存不足", code="STOCK_INSUFFICIENT")

        order = Order(user_id=user_id, status=OrderStatus.PENDING, items=req.items)
        order = await self.order_repo.create(order)
        return OrderVO.model_validate(order)
```

### 3. Repository 层职责：数据访问抽象

Repository 层封装所有数据库操作：
- 提供领域对象的 CRUD 接口
- 实现复杂查询（JOIN、聚合、分页）
- 封装查询优化（selectinload、索引利用）
- 数据库异常 → 业务异常转换

Repository 层禁止包含：
- 业务规则判断
- HTTP 调用
- 打印日志（日志在 Service 层打印）

```python
# app/repositories/order_repo.py
class OrderRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_by_id(self, order_id: str) -> Order | None:
        stmt = (
            select(Order)
            .where(Order.id == order_id)
            .options(selectinload(Order.items))
        )
        result = await self.db.execute(stmt)
        return result.scalar_one_or_none()

    async def create(self, order: Order) -> Order:
        self.db.add(order)
        await self.db.flush()
        return order
```

### 4. 禁止跨层调用

严格遵守分层调用规则：
```
Router → Service → Repository
```
- 不得 Router → Repository（跳过 Service）
- 不得 Service → Router（反向依赖）
- 各层之间的数据传输使用 Pydantic Schema，不得直接暴露 SQLAlchemy Entity 到 Router

### 5. 目录结构必须清晰分层

```
app/
├── main.py                # FastAPI 入口，挂载路由、中间件
├── config.py               # 集中配置
├── api/
│   └── v1/
│       ├── __init__.py
│       ├── orders.py       # APIRouter
│       ├── users.py
│       └── deps.py         # 公共 Depends
├── services/               # 业务逻辑
│   ├── __init__.py
│   ├── order_service.py
│   └── user_service.py
├── repositories/            # 数据访问
│   ├── __init__.py
│   ├── order_repo.py
│   └── user_repo.py
├── models/                  # SQLAlchemy ORM 模型
│   ├── __init__.py
│   ├── order.py
│   └── user.py
├── schemas/                 # Pydantic Schema
│   ├── __init__.py
│   ├── order.py
│   └── user.py
└── exceptions.py            # 统一业务异常
```

## warn 级别软约束

- **依赖注入容器**：大型项目建议使用 `dependency-injector` 或类似的 DI 容器管理依赖关系
- **防腐层**：建议在 Service 和外部 API 调用之间插入 Client 层，封装第三方接口细节
- **Service 瘦身**：单个 Service 超过 500 行建议按业务子领域拆分
- **异步化**：所有 I/O 操作（DB、Redis、HTTP）必须使用 async/await，不得混用同步代码
