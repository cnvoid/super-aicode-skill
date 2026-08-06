# css — CSS 规范

## error 级别硬约束

### 1. 样式方案优先级：原子化 CSS → CSS Modules → 禁止全局样式

样式方案必须按以下优先级选择，前者满足需求时不降级使用后者：

**第一优先 — 原子化 CSS（Tailwind CSS / UnoCSS）：**

新项目必须优先集成 Tailwind CSS 或同类原子化 CSS 框架。原子化 CSS 的核心优势：
- 样式与组件共存于同一文件，不需要在 .css 和 .tsx 之间切换
- 原子类天然可复用且无样式泄漏风险
- 生产构建自动 PurgeCSS，未使用的样式不会进入产物
- 响应式和暗色模式通过原子类前缀（`sm:`、`md:`、`dark:`）直接声明，无需写媒体查询

使用要求：
- 项目必须集成 Tailwind CSS（通过 PostCSS 插件或 Tailwind CLI）或 UnoCSS（通过 Vite 插件）
- 常用原子类组合通过 `@apply` 指令或组件封装提取为语义化类名，避免模板中单个元素堆砌 20+ 原子类
- 主题变量（颜色、间距、字体）在 `tailwind.config` 中集中定义，不得在代码中硬编码色值

**第二优先 — CSS Modules：**

当项目无法使用 Tailwind CSS 时（如旧项目迁移），使用 CSS Modules 实现样式隔离。CSS Modules 通过构建工具自动生成唯一类名，确保样式仅作用于当前组件。文件命名约定：`ComponentName.module.css`。

**第三优先 — CSS-in-JS：**

当以下条件同时满足时，可使用 CSS-in-JS（styled-components / Emotion / CSS Modules + JS）：
- 项目已深度集成 CSS-in-JS 方案
- 样式需要根据运行时数据动态计算（非仅 Props 切换）

不推荐在所有场景使用 CSS-in-JS 的原因：运行时开销、SSR 复杂性、包体积增大。

**禁止的方案：**
- 全局样式表：直接引入 .css 文件使用全局选择器
- 直接设置元素标签的全局样式（如 body、h1、div 等）
- BEM 命名约定手写全局唯一类名（已有 BEM 项目可保留，新项目不得引入）

### 2. 必须支持响应式设计

页面布局和组件样式必须适配移动端、平板和桌面三种视口。使用媒体查询定义断点，推荐断点值：
- 小屏（移动端）：< 768px
- 中屏（平板）：768px - 1024px
- 大屏（桌面）：> 1024px

样式编写采用移动优先策略：基础样式为移动端设计，通过 min-width 媒体查询逐步增强大屏样式。

## warn 级别软约束

- 颜色、间距、字号、圆角等设计 Token 使用 CSS 变量统一管理
- 动画优先使用 transform 和 opacity 属性（GPU 加速），避免 width、height、top、left 等触发布局重排的属性
- 字体大小使用相对单位 rem/em，不使用 px
- 图片和媒体元素设置 max-width: 100% 防止溢出
- 保留 :focus-visible 样式保障键盘导航用户的无障碍体验
