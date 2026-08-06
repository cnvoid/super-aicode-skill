# typescript — TypeScript 规范

## error 级别硬约束

### 1. 启用 strict 模式

TypeScript 配置文件必须启用 strict: true，包括 strictNullChecks、noImplicitAny、noImplicitReturns、noFallthroughCasesInSwitch 等子选项全部开启。严格模式在编译期捕获空指针、隐式 any 等大量潜在问题。

### 2. 必须使用可选链 ?. 进行安全取值

所有对可能为 null 或 undefined 的对象的属性访问、方法调用、数组索引，必须使用可选链操作符 `?.` 进行保护。这防止运行时抛出 "Cannot read property of undefined" 错误。

使用场景：
- 访问嵌套对象的深层属性
- 调用可能为 null/undefined 的对象方法
- 访问数组索引前不确定数组是否为空
- 从 API 响应中取值（响应数据可能不完整）

可选链可以连续使用，在任一环节遇到 null/undefined 时短路返回 undefined，不抛出异常。

⚠️ 可选链是防止运行时崩溃的最后一道防线，不得滥用——在类型系统可以确保非空的场景（如通过类型守卫收窄后），不需要可选链。

### 3. 必须使用空值合并 ?? 提供默认值

当需要为空值提供默认值时，必须使用空值合并操作符 `??` 而非逻辑或操作符 `||`。两者的区别：

- `??`：仅在值为 null 或 undefined 时取默认值（空字符串 0 和 false 不会被替换）
- `||`：在所有 falsy 值（null、undefined、0、''、false、NaN）时取默认值

绝大多数业务场景应使用 `??`，因为 0 和空字符串是合法的业务值（如数字 0 表示金额为零，空字符串表示用户未填写该字段，不应被默认值替换）。

### 4. 禁止使用非空断言 !

代码中不得使用非空断言操作符 `!` 绕过 TypeScript 的类型检查。`!` 告诉编译器"我确定这个值不是 null/undefined"，但运行时可能出错——这恰恰是 TypeScript 试图帮开发者避免的问题。

如果确定某个值非空，必须通过以下方式让 TypeScript 参与验证：
- 提前进行显式的 null 检查，利用控制流分析收窄类型
- 使用类型守卫函数返回类型谓词
- 抛出明确的异常（在值为 null 时 fail fast，而非用 `!` 静默跳过）

### 5. 禁止 any 类型

代码中不得使用 any 类型，包括显式标注和隐式推导的 any。对于无法确定类型的外部数据，使用 unknown 类型配合类型守卫进行安全的类型收窄。

类型守卫函数返回布尔值并用 `is` 关键字标注类型谓词，确保通过守卫后类型被正确收窄。

### 6. 使用类型守卫替代类型断言

优先使用类型守卫和 discriminated union 来收窄类型，避免使用 as 和 ! 等绕过类型检查的断言。类型断言跳过编译器检查，隐藏了潜在的类型不匹配问题。

### 7. 使用 discriminated union 描述状态

对于有明确状态转换的数据（如异步请求的 idle/loading/success/error 状态），使用字面量类型的联合类型来建模。利用 TypeScript 的控制流分析能力，在 switch/case 或 if/else 分支中自动收窄类型，确保每个状态都被正确处理。

## warn 级别软约束

- 对象和数组使用 readonly 修饰符防止意外修改
- 使用 const 断言收紧字面量类型
- 泛型参数添加 extends 约束，避免裸泛型
- 纯类型导出使用 export type 显式标记
- 第三方库类型缺失时，在项目根目录创建 .d.ts 声明文件，不使用 any 占位

