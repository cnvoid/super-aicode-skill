# validation — 入参校验规范

## error 级别硬约束

### 1. 所有 public 方法的入参必须校验

不得假设调用方传入的参数是合法值。每个 public 方法必须在方法体开头对全部入参执行校验，校验不通过应抛出明确的校验异常。

校验内容包括但不限于：
- 引用类型参数的非空检查
- 字符串参数的非空和非空白检查
- 数值参数的合法范围检查
- 集合参数的非空检查
- 枚举参数的合法值检查

### 2. null/undefined 安全

所有可能为 null 或 undefined 的返回值，在访问其成员前必须进行判空。

各语言应对方案：
- Java：使用 Optional 包装可能为 null 的返回值，调用方显式处理 orElse/orElseThrow；详见 `super-core/prompts/error.md` 中异常链和 `super-backend-java/prompts/exception.md` 中全局异常处理
- Go：对指针类型、接口类型、map/slice/chan 类型的返回值进行 nil 检查；详见 `super-backend-go/prompts/error-handling.md` 中 error wrap 和 sentinel error
- TypeScript/JavaScript：必须使用可选链操作符 `?.` 访问可能为 null/undefined 的属性或方法；必须使用空值合并操作符 `??` 提供默认值（不使用 `||`）；禁止使用非空断言 `!` 跳过类型检查。详见 `super-frontend/prompts/typescript.md`

不得对可能为 null 的值直接调用方法或访问属性。

### 3. 集合操作前必须判空

对集合进行遍历、取值、聚合操作前，必须检查集合是否为 null 或空。空集合应返回空结果而非抛出 NullPointerException 或 panic。

### 4. 对输入数据进行类型和格式校验

接收外部输入（HTTP 请求体、消息队列消息、文件内容）时，必须进行结构化校验：
- 字段类型正确
- 必填字段存在
- 字符串长度在允许范围内
- 数值在合法范围内
- 枚举值在预定义集合内

建议使用声明式校验框架（JSR303、zod、go-playground/validator 等）而非手写 if-else。

## warn 级别软约束

- 对外部系统的返回结果进行非空和状态校验后再使用
- 字符串参数限制最大长度，防止恶意超长输入
- 数值参数检查范围，防止整数溢出
