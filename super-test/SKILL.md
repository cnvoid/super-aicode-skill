---
name: super-test
description: >
  Testing standards across all levels and methodologies. Activates when user
  writes tests, generates test cases, reviews coverage, discusses testing
  strategy, or performs AI-assisted testing. Triggers include: test, unit
  test, integration test, e2e test, api test, performance test, UI test,
  visual regression, accessibility test, a11y, component test, AI testing,
  AI test, golden test, adversarial test, coverage, mock, stub, assert,
  test case, test data, test report, JaCoCo, JUnit, Mockito, Jest, Vitest,
  Playwright, Cypress, Testing Library, go test, pytest.
---

# Contract

本技能**叠加**在 `super-core` 之上生效。

## 前置检查

1. 确认 `super-core` 已加载。若未加载，先执行 super-core Phase 1-2。
2. 从合并配置中读取 `scenarios.testing.enabled`：
   - `false` → 跳过本技能
   - `true`  → 继续加载
3. 从合并配置中读取 `scenarios.testing.rules` 和 `scenarios.testing.coverage`。

## 加载规则

| 配置项 | prompt 文件 | 覆盖内容 |
|--------|-----------|---------|
| unit | prompts/unit.md | 单元测试：正向/边界/异常三类场景、mock 策略、断言规范 |
| api | prompts/api.md | API 测试：契约校验、8 种状态码覆盖、5 种鉴权场景、参数边界、幂等 |
| ui | prompts/ui.md | UI 测试：组件隔离、交互行为、可访问性 a11y、响应式、状态覆盖、视觉回归、跨浏览器 |
| integration | prompts/integration.md | 集成测试：DB、缓存、消息队列、外部服务 |
| ai-testing | prompts/ai-testing.md | AI 测试：幻觉检测、冗余模式检测、规则遵循度验证、AI 生成测试 review 流程、Skill 包自验证 |
| report | prompts/report.md | 测试报告：覆盖率、缺陷分类、风险评级 |

## 覆盖率要求

从配置中读取 `scenarios.testing.coverage` 值作为最低覆盖率阈值。
低于该阈值的代码输出时标注警告。

## 自检

代码输出后，在 super-core 自检表后追加：

```
[super-test] 规则检查
  ✅ unit        — 正向 3 条，边界 3 条，异常 4 条，覆盖率 92%
  ✅ api         — 8 种状态码覆盖，5 种鉴权场景，幂等验证通过
  ✅ ui          — 组件隔离 + 交互 + a11y + 响应式 + 5 种状态全覆盖
  ✅ integration — 容器化测试，端到端流程验证通过
  ⚠️  ai-testing — 规则遵循度已验证，Golden 测试集待补充(TODO)
  ✅ report      — 覆盖率 92%，缺陷 0 个
```
