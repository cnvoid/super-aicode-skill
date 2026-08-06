---
name: super-log
description: >
  工作日志记录与周报/月报生成技能。在会话中自动记录完成事项，支持按时间维度汇总生成总结报告。
  Triggers: log, worklog, 日志, 周报, 月报, 工作总结, daily report, weekly report,
  monthly report, 工作记录, task log, 日报, summary, 生成汇报, 事项记录.
---

# Contract

本技能**叠加**在 `super-core` 之上，提供工作事项记录与周期性总结报告生成规范。

## 前置检查

1. 确认 `super-core` 已加载
2. 从合并配置中读取 `scenarios.log.enabled`：
   - `false` → 跳过本技能
   - `true`  → 继续加载
3. 从合并配置中读取 `scenarios.log.rules`，加载对应 prompt。

## 加载规则

| 配置项 | prompt 文件 | 覆盖内容 |
|--------|-----------|---------|
| worklog | prompts/worklog.md | 任务记录：格式、分类、粒度、存储位置 |
| report | prompts/report.md | 总结报告：周报/月报模板、数据汇总、输出格式 |

## 自检

报告输出后，在 super-core 自检表后追加：

```
[super-log] 规则检查
  ✅ worklog   — 本次会话 N 条事项已记录，含类型/模块/完成状态
  ✅ report    — 周报已生成，包含完成事项、进行中事项、计划事项、风险项
```

## 工作原理

### 自动记录模式（open）

会话中每完成一个事项，主动追加到日志文件。日志文件路径从 `scenarios.log.worklog_file` 读取，默认为项目根目录 `WORKLOG.md`。

记录时机：
- 用户确认任务完成后
- 用户说"记录一下"/"记个日志"
- 会话结束前主动提醒

### 总结模式（report）

用户请求"生成周报"/"生成月报"/"工作总结"时，读取已有日志数据，按报告模板输出总结。

## 记录格式速查

每一条记录的格式：

```
### YYYY-MM-DD
- [x] **{类型}** [{模块}] {事项描述} — 耗时 {N}h | 关联 #{issue}
```

类型枚举：`feature` / `fix` / `refactor` / `test` / `doc` / `ops` / `research` / `review` / `other`
