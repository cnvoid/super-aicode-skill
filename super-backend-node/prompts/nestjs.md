# nestjs — NestJS 规范

## error 级别硬约束

### 1. 必须启用全局 ValidationPipe

NestJS 应用必须注册全局 ValidationPipe，利用 class-validator 装饰器对请求 DTO 进行自动校验。ValidationPipe 配置：
- whitelist: true — 自动剔除 DTO 中未声明的字段
- forbidNonWhitelisted: true — 请求包含未声明字段时返回 400
- transform: true — 自动将原始值转换为 DTO 声明的类型

DTO 类中使用 class-validator 装饰器声明校验规则（@IsString、@IsInt、@Min、@Max、@IsOptional 等）。

### 2. 必须实现全局异常过滤器

项目必须实现全局异常过滤器（实现 ExceptionFilter 接口并注册为全局），统一捕获所有未处理异常并转换为标准 HTTP 响应格式。异常过滤器按异常类型分级处理：
- 业务异常 → 对应的 HTTP 状态码和业务错误码
- NestJS HttpException → 原始状态码和消息
- 未知异常 → 500 + 通用错误信息

### 3. 模块必须按业务领域拆分

每个 NestJS 模块对应一个业务领域，通过 imports 声明依赖其他模块，通过 exports 暴露可被其他模块使用的 Provider。模块的职责边界必须清晰，不得将全量 Provider 注册到单一模块中。

模块应通过 providers 注册服务类，通过 controllers 注册控制器类，通过 imports 引入依赖的模块。

## warn 级别软约束

- 使用 Guard 处理认证和授权逻辑，不得在 Controller 方法内做权限判断
- 使用 Interceptor 统一包装成功响应格式
- 使用 @nestjs/config 集中管理配置，支持多环境
- 避免模块间循环依赖，必要时使用 forwardRef（作为最后手段）
