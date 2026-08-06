# vue — Vue 组件规范

## error 级别硬约束

### 1. 组件必须职责单一

每个组件只承担一个职责。判断标准：能用一句话描述组件职责且不包含"和"字。

违反单一职责的信号：
- 组件内部有多个互不相关的响应式数据
- 组件 Props 数量超过 8 个
- 模板嵌套层级超过 4 层
- 组件代码超过 200 行

### 2. Props 必须设计为最小接口

组件 Props 只暴露使用者真正需要控制的属性。设计原则：
- 必填 Props 仅设置核心数据
- 可选 Props 提供合理的默认值，不传 Props 时组件能正常渲染
- 不得将整个 API 响应对象作为 Props 传递
- 事件使用 defineEmits 声明，命名使用 kebab-case（模板中使用）或 camelCase（JS 中使用）

### 3. 优先使用插槽实现组合

组件内容定制必须优先使用插槽，而非通过 Props 传入 HTML 字符串或配置对象。

插槽类型：
- 默认插槽：主内容区的替换
- 具名插槽：多个内容区域的精确替换（如 header、footer、actions）
- 作用域插槽：将子组件数据暴露给父组件，由父组件决定渲染方式

不得通过 Props 传入完整的 HTML 标记或 JSX/VNode。

### 4. 可复用逻辑必须抽离为组合式函数

跨组件复用的响应式逻辑必须封装为组合式函数（composables），以 use 前缀命名。组合式函数内部必须处理加载、错误、数据三种状态，不得将错误直接抛给调用组件。

不得在多个组件中复制粘贴相同的 ref + watch + onMounted 组合。

### 5. 使用 Composition API

Vue 3 项目组件逻辑必须使用 Composition API（script setup 语法）。响应式数据使用 ref 或 reactive，计算属性使用 computed，侦听器使用 watch 或 watchEffect。

组件挂载和卸载的逻辑分别放在 onMounted 和 onUnmounted 中，确保资源正确释放。

### 6. 最大限度减少 watch 和 computed，使用单向数据流

组件的数据流动必须遵循单向数据流原则：父组件通过 Props 向下传递数据，子组件通过 Emits 向上通知事件。数据的派生和转换应在数据源头完成，而非在组件内部通过 watch 被动同步。

**减少 watch 的使用：**

以下场景不得使用 watch，应改用其他方式：

| 场景 | 错误做法 | 正确做法 |
|------|---------|---------|
| 根据 Props 计算派生值 | watch Props → 修改本地 ref | 直接用 computed 基于 Props 计算 |
| Props 变化后更新本地状态 | watch Props → set(newValue) | 重新设计：本地状态是否需要存在？考虑直接使用 Props |
| 一个数据变化后同步另一个数据 | watch A → 修改 B | 让 B 通过 computed 从 A 派生，或触发事件由父组件协调 |
| 组件初始化加载数据 | watch Props.id → fetch | 使用 onMounted 或 watchEffect（自动追踪依赖） |

watch 仅允许用于以下场景：
- 响应数据变化产生副作用（调用 API、操作 DOM、操作第三方库）
- 监听非响应式数据源（URL 参数、localStorage、window 事件）
- 需要访问变化前后的新旧值

**减少 computed 的误用：**

computed 必须是纯计算属性——接收响应式数据，返回派生值，不产生副作用。以下行为在 computed 中禁止：
- 修改其他响应式数据
- 发起异步请求
- 操作 DOM
- 修改浏览器 URL

一个组件中 computed 超过 5 个时，检查是否存在冗余派生——多个 computed 链式计算时，中间 computed 可能可以合并。

**单向数据流检查清单：**

- 子组件不得修改 Props 的值
- 子组件通知父组件的行为统一通过 defineEmits 发送事件
- 兄弟组件间的数据同步通过共同的父组件协调，不得互相 watch
- 跨层级共享状态使用 Pinia Store 或 provide/inject，不得层层传递事件

### 7. Props 必须声明类型和校验规则

每个组件的 Props 通过 defineProps 声明类型（TypeScript 泛型方式），并在必要时提供默认值。不得接收未声明的 Props。

### 8. provide/inject 必须声明类型和默认值

跨层级数据传递的 provide/inject 必须使用 InjectionKey 声明注入键类型，inject 时提供默认值，防止祖先组件未 provide 导致的运行时错误。

## warn 级别软约束

- 子组件向父组件通信使用 defineEmits 声明事件及参数类型，不使用 $parent 或直接修改 Props
- 复杂模板表达式提取为 computed 属性
- 大列表数据使用 shallowRef 优化性能
- 组件文件与组件同名，一个文件只导出一个主组件
- 使用 defineOptions 声明组件名称（用于 DevTools 调试）
