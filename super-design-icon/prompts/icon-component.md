# icon-component — 图标组件设计规范

## error 级别硬约束

### 1. 图标必须以 SVG 格式交付

UI 图标必须使用内联 SVG 实现，不得使用 PNG、WebP、JPEG 等位图格式。SVG 的优势：
- 任意分辨率下保持清晰（矢量）
- 可通过 CSS 控制颜色和尺寸
- 文件体积小
- 可以通过 currentColor 继承父级颜色

图标 SVG 的 viewBox 必须统一使用标准画布尺寸。推荐 24x24（大多数现代图标库的标准），特殊情况如徽标类可使用其他尺寸但需保持一致。

### 2. 图标组件必须有统一的 Props 接口

每个图标组件的 Props 接口必须包含以下字段（按语言生态适配命名风格）：

核心 Props：
- size：图标尺寸，类型为 number 或预设的尺寸枚举（xs/sm/md/lg/xl），默认值 md
- color：图标颜色，默认值为 currentColor，使图标自动继承父级文本颜色
- className：额外的 CSS 类名，用于自定义样式覆盖

语义 Props（无障碍相关）：
- title：图标的语义描述，用于辅助技术读屏。装饰性图标不传此值。
- description：图标的详细描述，用于复杂图标的语义补充

组件必须支持 className 透传和 style 扩展，允许使用者在不修改源码的情况下定制样式。所有非核心 Props 通过 rest/spread 语法透传到 SVG 根元素。

### 3. 颜色必须使用 currentColor

图标组件内部不得硬编码颜色值。所有填充色和描边色必须使用 currentColor，使图标自动继承使用场景的文本颜色。使用者通过 color prop 或 CSS color 属性控制图标颜色。

如需支持多色图标（如品牌 Logo），允许在组件内部定义少量色彩变量，但必须提供通过 CSS 变量覆盖的机制。

### 4. 尺寸必须响应式

图标的默认宽高必须设为 1em（相对于当前字体大小），配合 size prop 将 em 值转为具体的数值。图标组件不得设置固定的像素宽高，确保在不同字体大小场景下正确缩放。

## warn 级别软约束

- SVG 源码在上线前通过 SVGO 优化（移除冗余属性、合并路径、压缩空白）
- 图标组件使用 React.forwardRef 或 Vue 的 ref 转发，支持使用者获取 DOM 引用
- 避免在图标内部使用 transform 造成坐标偏移，优先调整 path 数据
- 图标命名遵循 {category}-{name} 格式，如 nav-home、action-delete、status-success
- 提供 TypeScript 类型导出，确保使用 IconName 联合类型约束图标名称的输入
