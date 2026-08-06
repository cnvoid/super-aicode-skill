# sync — 注解与代码同步规范

## error 级别硬约束

### 1. 编写接口即编写注解，不得事后补齐

编写任何对外 HTTP 接口时，必须在**同一个代码提交**中附带完整的 OpenAPI 注解。禁止以下行为：

- 先写好接口逻辑，commit，然后用下一个 commit 补注解
- 注解写个空壳 `summary = ""`，声称"后续完善"
- 只注解 Controller 类，不注解方法、参数、响应
- 只注解成功的 response (200)，不注解异常响应码

每次生成或修改接口代码时，注解必须与接口代码一起输出。

### 2. 接口变更必须同步更新注解

修改接口的任何以下方面时，必须同时更新对应的注解：

| 变更内容 | 需同步更新的注解 |
|---------|----------------|
| 新增/删除/重命名接口路径 | `@Operation` summary/description |
| 新增/删除/修改参数 | `@Parameter` description/example/requiredMode |
| 修改参数类型 | `@Schema` 的 type/format/example |
| 新增/删除响应状态码 | `@ApiResponse` 列表 |
| 修改枚举值范围 | `@Schema` 的 allowableValues/description |
| 修改字段必填/可选 | `@Schema` 的 requiredMode |
| 修改业务规则 | `@Operation` description 中的约束说明 |

### 3. 注解描述必须与代码逻辑一致

注解中的 description 必须准确反映代码的实际行为。常见的不一致场景（必须修复）：

```java
// ❌ 错误：注解说"返回用户列表"，实际只返回当前租户下的用户
@Operation(summary = "获取用户列表")
public Result<List<UserVO>> listUsers(Long tenantId) { ... }

// ✅ 正确：描述应包含实际约束
@Operation(summary = "获取当前租户下的用户列表")
public Result<List<UserVO>> listUsers(Long tenantId) { ... }
```

```java
// ❌ 错误：注解说 status 必填，代码中 required = false
@Parameter(description = "订单状态", required = true)
@RequestParam(required = false) String status

// ✅ 正确：注解与代码一致
@Parameter(description = "订单状态，可选，不传则查全部", required = false)
@RequestParam(required = false) String status
```

### 4. 不得使用自动工具生成后不检查

Swagger/Knife4j 可以自动根据代码生成基本的 OpenAPI 文档，但自动生成的文档：
- 缺少中文 description
- 枚举类型不展示可选值
- 复杂嵌套对象不展开
- 响应码不覆盖异常场景

因此，严禁依赖框架自动生成的文档作为最终输出。所有注解必须手工编写，确保描述准确、完整、中文。

## warn 级别软约束

- **代码评审检查项**：建议将 API 注解完整性纳入 Code Review checklist，缺少注解的接口视为不完整
- **CI 检查**：建议在 CI 流水线中增加注解覆盖率检查（如使用 `springdoc-openapi` 的 `GroupedOpenApi` 验证）
- **注解模板**：同一项目中相似类型的接口（如 CRUD 接口），建议其注解 description 模式保持一致
- **分组更新**：如果一个提交涉及多个接口变更，建议在 commit message 中列出需关注的接口清单，方便 reviewer 逐个对照
- **废弃标注演练**：废弃接口时，建议在 description 中附带预计下线日期，方便调用方制定迁移计划
