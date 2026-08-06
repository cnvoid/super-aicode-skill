---
name: super-design-icon
description: >
  Icon and SVG design standards. Activates when user creates icons, builds
  icon libraries, designs SVG components, or integrates icon systems.
  Triggers: icon, icons, SVG, icon component, icon library, icon system,
  icon font, icon design, icon set, pictogram, glyph, material icons,
  heroicons, lucide, phosphor, fontawesome, feather icons, icones,
  @iconify, SVGR, svgo, SVG sprite, icon sprite, inline SVG.
---

# Contract

本技能**叠加**在 `super-core` 之上生效。触发后将加载以下规则约束。

## 前置检查

1. 确认 `super-core` 已加载。若未加载，先执行 super-core Phase 1-2。
2. 从合并配置中读取 `scenarios.design-icon.enabled`：
   - `false` → 跳过本技能
   - `true`  → 继续加载
3. 从合并配置中读取 `scenarios.design-icon.rules`，按对应级别加载 prompt。

## 加载规则

| 配置项 | prompt 文件 | 覆盖内容 |
|--------|-----------|---------|
| component | prompts/icon-component.md | 图标组件设计规范：SVG 标准、Props 接口、尺寸与颜色 |
| system | prompts/icon-system.md | 图标系统架构：目录结构、构建工具、按需加载、类型生成 |
| accessibility | prompts/accessibility.md | 图标无障碍：aria 属性、语义标注、对比度 |

## 自检

代码输出后，在 super-core 自检表后追加：

```
[super-design-icon] 规则检查
  ✅ component     — Props 接口完整，viewBox 标准化，currentColor 使用
  ✅ system        — 目录结构合理，tree-shaking 友好，类型文件已生成
  ✅ accessibility — aria-hidden 正确，语义图标有 title，对比度达标
```

## 支持的输出格式

根据用户需求，本技能支持产出以下类型：

| 输出类型 | 说明 |
|---------|------|
| 单个图标组件 | React/Vue/Web Component 格式的 SVG 图标组件 |
| 图标组件库 | 包含多个图标的完整组件库，含类型定义和导出入口 |
| 图标精灵图 | SVG sprite 方案 + 引用组件 |
| 图标系统方案 | 包含目录结构、构建配置、使用文档的完整方案 |
