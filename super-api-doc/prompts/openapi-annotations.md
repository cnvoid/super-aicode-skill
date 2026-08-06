# openapi — OpenAPI 中文注解规范

## error 级别硬约束

### 1. Controller 类必须有 `@Tag` 注解

每个 Controller 类必须在类级别标注中文 Tag 名称和描述。

Java (SpringDoc / Swagger 3)：
```java
@Tag(name = "订单管理", description = "订单的创建、查询、取消、退款等操作接口")
@RestController
@RequestMapping("/api/v1/orders")
public class OrderController { ... }
```

Node.js (NestJS + swagger)：
```typescript
@ApiTags('订单管理')
@Controller('api/v1/orders')
export class OrderController { ... }
```

Go (swaggo)：
```go
// @title 订单管理 API
// @description 订单的创建、查询、取消、退款等操作接口
// @BasePath /api/v1
```

### 2. 每个接口方法必须有 `@Operation` 注解（summary + description 均需中文）

```java
@Operation(
    summary = "创建订单",
    description = "根据购物车商品生成新订单。创建成功后返回订单编号，状态为 PENDING，需在 30 分钟内完成支付。"
)
@PostMapping
public Result<OrderVO> create(@RequestBody @Valid CreateOrderRequest req) { ... }
```

```typescript
@ApiOperation({
    summary: '创建订单',
    description: '根据购物车商品生成新订单。创建成功后返回订单编号，状态为 PENDING，需在 30 分钟内完成支付。',
})
@Post()
async create(@Body() req: CreateOrderDto): Promise<Result<OrderVo>> { ... }
```

description 不得为空字符串，不得是英文直译。必须说明：
- 接口的业务功能
- 成功后的副作用（生成了什么、状态变成了什么）
- 关键的时效约束（如有）

### 3. 所有参数必须有中文描述和示例值

**路径参数：**
```java
@Operation(summary = "查询订单详情")
@GetMapping("/{orderId}")
public Result<OrderVO> getById(
    @Parameter(description = "订单编号，创建订单接口返回的 orderId", example = "ORD20260101001")
    @PathVariable String orderId
) { ... }
```

**Query 参数：**
```java
@GetMapping
public Result<PageResult<OrderVO>> list(
    @Parameter(description = "订单状态", example = "PAID")
    @RequestParam(required = false) String status,

    @Parameter(description = "页码，从 1 开始", example = "1")
    @RequestParam(defaultValue = "1") int page,

    @Parameter(description = "每页条数，最大 100", example = "20")
    @RequestParam(defaultValue = "20") int pageSize
) { ... }
```

**Request Body：** Body 参数在 DTO/VO 类中逐字段注解（见第 5 条）。

### 4. 所有响应的 `@ApiResponse` 必须覆盖全部状态码

每个接口方法至少覆盖以下状态码的响应说明：

```java
@Operation(summary = "创建订单")
@ApiResponse(responseCode = "200", description = "创建成功，返回订单详情")
@ApiResponse(responseCode = "400", description = "参数校验失败：商品不存在、库存不足、收货地址无效")
@ApiResponse(responseCode = "401", description = "未登录或 Token 已过期")
@ApiResponse(responseCode = "403", description = "无权限操作该订单")
@ApiResponse(responseCode = "422", description = "业务规则不满足：订单重复、金额不匹配")
@ApiResponse(responseCode = "429", description = "请求过于频繁，请稍后重试")
@ApiResponse(responseCode = "500", description = "服务器内部错误")
@PostMapping
public Result<OrderVO> create(...) { ... }
```

每个响应码的 `description` 必须说明该状态下返回的具体含义，不得简单写"成功"/"失败"。

### 5. DTO / VO 类的每个字段必须有 `@Schema` 注解（中文描述 + 示例值）

```java
public class CreateOrderRequest {
    @Schema(description = "商品列表，至少 1 项", example = "[{\"skuId\":\"SKU001\",\"quantity\":2}]", requiredMode = REQUIRED)
    @NotEmpty(message = "商品列表不能为空")
    private List<OrderItem> items;

    @Schema(description = "收货地址 ID", example = "ADDR_10086", requiredMode = REQUIRED)
    @NotBlank(message = "收货地址不能为空")
    private String addressId;

    @Schema(description = "优惠券 ID，可选", example = "COUPON_2026")
    private String couponId;

    @Schema(description = "买家备注，最长 200 字", example = "请发顺丰", maxLength = 200)
    private String remark;
}
```

```java
public class OrderVO {
    @Schema(description = "订单编号", example = "ORD20260101001")
    private String orderId;

    @Schema(description = "订单金额（分）", example = "19900")
    private Long amount;

    @Schema(description = "订单状态：PENDING-待支付, PAID-已支付, SHIPPED-已发货, CANCELLED-已取消",
             example = "PENDING",
             allowableValues = {"PENDING", "PAID", "SHIPPED", "CANCELLED"})
    private String status;

    @Schema(description = "创建时间", example = "2026-01-01T12:00:00")
    private LocalDateTime createdAt;
}
```

**枚举值的 description 必须列出全部可选值及其中文含义**，格式为 `值1-含义1, 值2-含义2`。

### 6. 分页结果 DTO 必须注解四要素

```java
public class PageResult<T> {
    @Schema(description = "数据列表")
    private List<T> list;

    @Schema(description = "总记录数", example = "256")
    private Long total;

    @Schema(description = "当前页码，从 1 开始", example = "1")
    private Integer page;

    @Schema(description = "每页条数", example = "20")
    private Integer pageSize;
}
```

## warn 级别软约束

- **分组标签**：建议对接口按业务场景使用 `@Tag` 分组，每个 Controller 最多一个 Tag
- **废弃标注**：已废弃的接口使用 `@Deprecated` + `@Operation(summary = "[已废弃] ...", deprecated = true)`，并在 description 中指明替代接口
- **接口排序**：建议通过 `@Tag` 的 `extensions` 或 Swagger 配置对接口分组排序
- **版本标注**：建议在 `@Operation` 的 description 开头标注接口版本（如 `v1.0`）
- **安全标注**：涉及鉴权的接口必须通过 `@SecurityRequirement` 标注认证方式
