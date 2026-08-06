# fastapi — FastAPI 路由与中间件规范

## error 级别硬约束

### 1. 路由必须按模块使用 APIRouter 拆分

不得将所有路由写在同一个文件或 `app = FastAPI()` 的直接作用域中。每个业务领域必须拥有独立的 APIRouter，并带 prefix 和 tags：

```python
# app/api/v1/orders.py
from fastapi import APIRouter

router = APIRouter(prefix="/orders", tags=["订单管理"])


@router.post("/", summary="创建订单")
async def create_order(req: CreateOrderRequest, service: Annotated[OrderService, Depends()]) -> OrderVO:
    ...


@router.get("/{order_id}", summary="查询订单详情")
async def get_order(order_id: str, service: Annotated[OrderService, Depends()]) -> OrderVO:
    ...
```

主 app 中通过 `include_router` 挂载：

```python
# app/main.py
from app.api.v1 import orders, users, payments

app = FastAPI()
app.include_router(orders.router, prefix="/api/v1")
app.include_router(users.router, prefix="/api/v1")
app.include_router(payments.router, prefix="/api/v1")
```

### 2. 必须使用依赖注入（Depends），不得在路径函数内创建依赖

```python
# ❌ 错误：路径函数内部控制反转
@router.get("/{order_id}")
async def get_order(order_id: str):
    async with AsyncSessionFactory() as session:
        repo = OrderRepository(session)
        return await repo.get_by_id(order_id)

# ✅ 正确：通过 Depends 注入
@router.get("/{order_id}")
async def get_order(
    order_id: str,
    repo: Annotated[OrderRepository, Depends()],
) -> OrderVO:
    return await repo.get_by_id(order_id)
```

`Depends` 可注入的常见依赖：
- 数据库会话、Repository
- Service 层实例
- 当前用户（从 Token 解析）
- 配置对象
- 限流器、权限检查器

### 3. 异常必须使用 HTTPException 或自定义异常处理器

路径函数中不得直接 `return {"error": "..."}` 或 `raise ValueError`。必须使用 HTTPException 或通过项目统一异常处理器转换：

```python
from fastapi import HTTPException, status

# ✅ 正确：FastAPI 标准异常
raise HTTPException(
    status_code=status.HTTP_404_NOT_FOUND,
    detail="订单不存在",
)

# ✅ 正确：自定义业务异常 + 全局 handler
class OrderNotFoundError(AppException):
    def __init__(self, order_id: str):
        super().__init__(f"订单 {order_id} 不存在", code="ORDER_NOT_FOUND")
```

### 4. 必须配置全局异常处理器（Exception Handler）

所有未捕获异常必须被全局处理器转换为统一响应格式：

```python
from fastapi import Request
from fastapi.responses import JSONResponse

@app.exception_handler(AppException)
async def app_exception_handler(request: Request, exc: AppException):
    return JSONResponse(
        status_code=exc.http_status,
        content={"code": exc.code, "message": exc.message, "data": None},
    )

@app.exception_handler(Exception)
async def unhandled_exception_handler(request: Request, exc: Exception):
    logger.exception("Unhandled exception")
    return JSONResponse(
        status_code=500,
        content={"code": "INTERNAL_ERROR", "message": "服务器内部错误", "data": None},
    )
```

### 5. 必须配置 CORS 中间件并设置白名单

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=config.cors_origins,  # 从配置读取，不得写 "*"
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["Authorization", "Content-Type"],
)
```

## warn 级别软约束

- **路径操作函数装饰器**：建议 `summary` 使用中文描述，与 `super-api-doc` 规范一致
- **lifespan**：建议使用 `@asynccontextmanager` lifespan 管理启动/关闭资源（连接池、Redis 客户端），而非 `@app.on_event`
- **后台任务**：非关键路径的异步操作使用 `BackgroundTasks`，不得阻塞请求响应
- **流式响应**：大文件下载或 SSE 推送使用 `StreamingResponse`，不得将全部内容读入内存
