---
name: super-api-doc
description: >
  后端 API 接口文档注解规范。编写后端 API 时必须同步写上 OpenAPI 兼容的中文注解，
  覆盖接口描述、参数说明、响应体 Schema、错误码说明。Activates when writing backend
  API endpoints, REST controllers, or API documentation annotations.
  Triggers: api doc, api文档, 接口文档, swagger, openapi, 注解, annotation,
  api注解, 接口注解, api描述, api description, controller, endpoint,
  @Operation, @ApiOperation, @Schema, @ApiResponse, @ApiProperty, @Tag,
  @ApiParam, @ApiTags, swagger-ui, knife4j, springdoc, swagger-jsdoc.
---

# Contract

本技能**叠加**在 `super-core` 之上，要求编写后端 API 接口时必须同步产出 OpenAPI 兼容的中文文档注解。

> 本技能与 `super-core` 的 `doc` 规则侧重不同：doc 规则约束函数级注释（解释"为什么"），本技能约束 API 级注解（描述接口契约，供 Swagger/Knife4j 等工具生成在线文档）。

## 前置检查

1. 确认 `super-core` 已加载
2. 从合并配置中读取 `scenarios.api-doc.enabled`：
   - `false` → 跳过本技能
   - `true`  → 继续加载
3. 从合并配置中读取 `scenarios.api-doc.rules`，加载对应 prompt。

## 加载规则

| 配置项 | prompt 文件 | 覆盖内容 |
|--------|-----------|---------|
| openapi | prompts/openapi-annotations.md | OpenAPI 注解规范：Controller/方法/参数/响应/Model 的中文描述 |
| sync | prompts/annotation-sync.md | 注解与代码同步：编写即注解、变更即更新、未注解即不完整 |

## 自检

代码输出后，在 super-core 自检表后追加：

```
[super-api-doc] 规则检查
  ✅ openapi    — 接口摘要含中文描述，参数 @Schema 标注格式/示例，响应 Schema 完备
  ✅ sync       — 6 个接口全部附带注解，注解与参数名一致，变更已同步
```

## 注解覆盖清单（速查）

| 层级 | 注解要点 | 语言示例 |
|------|---------|---------|
| Controller | `@Tag(name = "中文名", description = "中文描述")` | Java/Node |
| 接口方法 | `@Operation(summary = "中文摘要", description = "中文详细说明")` | Java/Node |
| 路径参数 | `@Parameter(description = "中文说明", example = "示例值")` | Java/Node |
| Query 参数 | 同上，标注 required、defaultValue | Java/Node |
| Request Body | `@RequestBody(description = "中文说明")` + DTO 内字段级注解 | Java/Node |
| 响应体 | `@ApiResponse(description = "中文说明")` 覆盖所有状态码 | Java/Node |
| 响应 DTO | 每个字段 `@Schema(description = "中文说明", example = "示例值")` | Java/Node |
| 分页 DTO | list/total/page/pageSize 各有中文描述 | Java/Node |
