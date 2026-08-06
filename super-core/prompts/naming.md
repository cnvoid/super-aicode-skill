# naming — 命名规范

## error 级别硬约束

### 1. 名称必须表达意图

变量、函数、类、文件、目录的命名必须准确描述其用途和内容，阅读者仅凭名称即可理解其含义。禁止使用无意义的占位名称。

禁止的名称：a、b、c、temp、tmp、foo、bar、test、data、info、obj、flag（无上下文时）、x、xx、xxx、test1、test2。

### 2. 必须遵循各语言社区命名惯例

| 场景 | Java | TypeScript | Go | Python |
|------|------|-----------|-----|--------|
| 类/接口/组件 | PascalCase | PascalCase | PascalCase（导出） | PascalCase |
| 函数/方法 | camelCase | camelCase | PascalCase（导出）/camelCase（非导出） | snake_case |
| 变量 | camelCase | camelCase | camelCase | snake_case |
| 常量 | UPPER_SNAKE_CASE | UPPER_SNAKE_CASE | PascalCase（导出）/camelCase（非导出） | UPPER_SNAKE_CASE |
| 文件名 | PascalCase | PascalCase（组件）/kebab-case（工具） | snake_case | snake_case |
| 包/模块 | lower.dot.case | kebab-case | singleword | snake_case |

不得在同一项目中混用多种命名风格。前端项目中 React 组件文件使用 PascalCase，工具函数文件使用 kebab-case，不出现混合两种风格命名的文件。

### 3. 布尔变量必须使用 is/has/can/should 前缀

布尔类型的变量、属性和函数必须以前缀 is、has、can、should 开头，使其值含义直观可见。

- 状态判断：isLoading、isActive、isVisible、isDisabled
- 拥有判断：hasPermission、hasError、hasChildren
- 能力判断：canEdit、canDelete、canSubmit
- 条件建议：shouldUpdate、shouldRefresh

禁止使用不带前缀的名词（如 loading、visible、disabled）或动词（如 load、edit）命名布尔量。

### 4. 集合类型变量使用复数命名

数组、List、Set、Map 等集合类型的变量必须使用复数形式命名，明确表达该变量包含多个元素。

集合元素类型也应从名称中可推断：复数名词本身表达元素类型。不得使用单数形式或后缀 list/arr 作为替代。

### 5. 数据库命名规范

表名：小写蛇形命名，复数形式。关联表使用两个实体名拼接（按字母序），如下划线分隔。

字段名：小写蛇形命名，不重复表名前缀。外键字段命名为关联表名单数 + _id。

索引名：主键为 pk_{table_name}，唯一索引为 uk_{table_name}_{column_name}，普通索引为 idx_{table_name}_{column_name}。

## warn 级别软约束

- 禁止使用拼音命名（包括拼音缩写），公共领域公认的拼音缩写（如 bj=北京）在注释说明后允许使用
- 名称长度控制在 5-30 字符内，过短无意义、过长影响可读性
- 函数/方法的名称使用"动词 + 名词"结构表达操作语义（如 getUserById、createOrder）
- 不要在名称中重复上下文已有的信息（如 OrderService 类中方法叫 createOrder 而非 create，但在 Order 类中方法叫 create 即可）
