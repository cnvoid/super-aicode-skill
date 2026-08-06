---
name: super-frontend
description: >
  Frontend coding standards. Activates when writing React, Vue, Next.js, Nuxt,
  TypeScript, JavaScript, CSS, or any browser-side code. Triggers include:
  React, Vue, component, hook, JSX, TSX, useState, useEffect, props, state,
  context, Redux, Pinia, Zustand, Next.js, Nuxt, CSS, SCSS, Tailwind,
  router, route, axios, fetch, request, interceptor, form, modal, dialog,
  z-index, build, Vite, Webpack, XSS, CSP, security, login, token.
---

# Contract

本技能**叠加**在 `super-core` 之上生效。

## 前置检查

1. 确认 `super-core` 已加载。若未加载，先执行 super-core Phase 1-2。
2. 从合并配置中读取 `scenarios.frontend.enabled`：
   - `false` → 跳过本技能，仅保留 super-core
   - `true`  → 继续加载前端规则
3. 从合并配置中读取 `scenarios.frontend.rules`，按对应级别加载 prompt。

## 加载规则

| 配置项 | prompt 文件 | 覆盖内容 |
|--------|-----------|---------|
| react | prompts/react.md | 组件设计、hooks、性能、错误边界、副作用清理 |
| vue | prompts/vue.md | Composition API、响应式、组件通信、Props/Emits |
| typescript | prompts/typescript.md | strict 模式、禁止 any、类型守卫、discriminated union |
| css | prompts/css.md | 样式隔离、响应式(Mobile-first)、CSS 变量 |
| http | prompts/http.md | 请求实例封装、拦截器、code!=0 统一处理、401 跳转登录 |
| component | prompts/component.md | 通用业务组件、弹窗层级管理(z-index)、副作用清理 |
| state | prompts/state.md | Store 模块拆分、异步三态(loading/error/data) |
| router | prompts/router.md | 路由守卫、懒加载、面包屑、权限路由 |
| form | prompts/form.md | 声明式校验、防重复提交、编辑回填、实时校验 |
| build | prompts/build.md | 环境变量、去调试代码、代理、代码分割 |
| security | prompts/security.md | Token 存储、XSS 防范、禁止硬编码密钥、敏感信息掩码 |

加载方式：读取本 skill 目录下对应 prompt 文件，将其约束逐条应用到前端代码输出中。

## 自检

代码输出后，在 super-core 自检表后追加：

```
[super-frontend] 规则检查
  ✅ react       — ErrorBoundary 存在，memo/useMemo 已使用
  ✅ typescript  — strict 模式，无 any 类型
  ✅ css         — CSS Modules 隔离，响应式断点 3 个
  ✅ http        — 统一实例封装，401 拦截跳转已实现
  ✅ component   — 弹窗 z-index 常量管理，Modal 嵌套层级正确
  ✅ state       — Store 按模块拆分，异步三态完整
  ✅ router      — 全局守卫已配置，页面懒加载
  ✅ form        — react-hook-form + zod，提交 loading 防重复
  ✅ build       — VITE_ 前缀环境变量，生产构建去 console
  ✅ security    — httpOnly Cookie，dangerouslySetInnerHTML 已清洗
  —   vue        — 已关闭（React 项目）
```
