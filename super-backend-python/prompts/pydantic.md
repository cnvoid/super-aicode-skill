# pydantic — Pydantic Schema 规范

## error 级别硬约束

### 1. 所有请求/响应必须使用 Pydantic 模型

不得在路径函数中使用 `dict`、`Any` 或裸类型作为请求体/响应体类型注解：

```python
# ❌ 错误
@router.post("/orders")
async def create_order(data: dict) -> dict:
    ...

# ✅ 正确
@router.post("/orders")
async def create_order(req: CreateOrderRequest) -> OrderResponse:
    ...
```

所有 Pydantic 模型必须集中放在 `app/schemas/` 目录下，按业务域拆分文件。

### 2. 每个字段必须有 Field 约束

```python
from pydantic import BaseModel, Field

class CreateOrderRequest(BaseModel):
    items: list[OrderItem] = Field(
        description="商品列表，至少 1 项",
        min_length=1,
        max_length=50,
    )
    address_id: str = Field(
        description="收货地址 ID",
        min_length=1,
        max_length=64,
    )
    coupon_id: str | None = Field(
        default=None,
        description="优惠券 ID，可选",
    )
    remark: str | None = Field(
        default=None,
        description="买家备注",
        max_length=200,
    )
```

Field 必须包含：
- `description` — 中文说明
- `min_length` / `max_length` — 字符串长度限制
- `ge` / `le` / `gt` / `lt` — 数值范围限制
- `min_length` / `max_length` — 列表项数限制
- `pattern` — 正则格式约束（邮箱、手机号等）
- `default` / `default_factory` — 默认值

### 3. 枚举必须使用 Python Enum 并完整列出

```python
from enum import Enum
from pydantic import BaseModel, Field

class OrderStatus(str, Enum):
    PENDING = "PENDING"     # 待支付
    PAID = "PAID"           # 已支付
    SHIPPED = "SHIPPED"     # 已发货
    CANCELLED = "CANCELLED" # 已取消
    REFUNDED = "REFUNDED"   # 已退款

class OrderVO(BaseModel):
    status: OrderStatus = Field(description="订单状态")
```

枚举值的 docstring 或注释必须标注中文含义。

### 4. 必须设置 model_config

每个 Model 类必须显式设置 `model_config`：

```python
class OrderVO(BaseModel):
    model_config = ConfigDict(
        from_attributes=True,       # ORM 模型 → Pydantic
        use_enum_values=True,       # 枚举序列化为值而非对象
        populate_by_name=True,       # 允许用 ORM 字段名填充
        json_schema_extra={
            "example": {
                "order_id": "ORD20260101",
                "amount": 19900,
                "status": "PENDING",
            }
        },
    )
    ...
```

`json_schema_extra` 中的 `example` 必须提供真实的业务示例值，不得为 `"string"`、`0` 等占位符。

### 5. 请求体与响应体 Model 必须分离

不得将同一个 Model 同时用于请求体和响应体。请求包含用户输入字段，响应包含服务端生成的字段（ID、时间戳等），两者字段集不同：

```python
# ❌ 错误：复用
class OrderSchema(BaseModel):
    items: list[OrderItem]  # 请求需要
    order_id: str            # 响应才有
    created_at: datetime     # 响应才有

# ✅ 正确：分离
class CreateOrderRequest(BaseModel):
    items: list[OrderItem]
    address_id: str

class OrderVO(BaseModel):
    order_id: str
    items: list[OrderItem]
    amount: int
    status: OrderStatus
    created_at: datetime
```

## warn 级别软约束

- **自定义校验**：复杂业务校验使用 `@field_validator` 或 `@model_validator`，而非手写 if-else
- **类型导出**：建议在 `app/schemas/__init__.py` 中统一导出所有对外 Schema
- **示例值**：每个 Model 建议提供 `json_schema_extra` 示例，配合 super-api-doc 自动生成文档
- **兼容性**：字段变更时使用 `Field(alias=...)` 保持 API 向下兼容，而非直接改名
- **类型标注**：使用 Python 3.10+ 的 `X | None` 语法替代 `Optional[X]`
