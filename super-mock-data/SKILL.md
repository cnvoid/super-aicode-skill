---
name: super-mock-data
description: >
  后端测试数据/种子数据造数规范。开发新接口时为新增接口仿造仿真测试数据到测试数据库，
  避免业务空白，并保证关联数据正确关联。Activates when generating mock data, seed
  data, fake data, fixtures, sample data, or demo data for new API endpoints or new
  database tables. Triggers: mock data, 造数据, 测试数据, 样例数据, 种子数据, seed,
  seed data, fixture, fake data, faker, sample data, demo data, 假数据, 仿造数据,
  初始化数据, data factory, 关联数据, 造数.
---

# Contract

本技能**叠加**在 `super-core` 之上，提供后端测试数据（造数 / 种子数据）生成规范。

> 本技能与 `super-test` 的 integration 规则侧重不同：integration 约束测试用例内的数据隔离，本技能约束**为新增接口向测试数据库批量造出仿真数据**，让联调 / 演示时业务不空白。

## 前置检查

1. 确认 `super-core` 已加载
2. 从合并配置中读取 `scenarios.mock-data.enabled`：
   - `false` → 跳过本技能
   - `true`  → 继续加载
3. 从合并配置中读取 `scenarios.mock-data.rules`，加载对应 prompt。

## 加载规则

| 配置项 | prompt 文件 | 覆盖内容 |
|--------|-----------|---------|
| generation | prompts/generation.md | 数据生成：业务语义仿真、随机工具、边界与反例覆盖、敏感信息脱敏 |
| association | prompts/association.md | 关联正确性：外键真实关联、依赖拓扑顺序、枚举字典先插、复用主数据 |
| seed | prompts/seed.md | 落库脚本：幂等可重复、仅测试/开发库、Seed 工具管理、数据量控制 |

## 自检

代码输出后，在 super-core 自检表后追加：

```
[super-mock-data] 规则检查
  ✅ generation  — 数据语义仿真，覆盖正常/边界/异常，敏感字段已脱敏
  ✅ association — 外键全部指向真实记录，依赖顺序正确，枚举/字典先插入
  ✅ seed        — 幂等可重复执行，仅写测试/开发库，数据量可控
```

## 造数流程速查

```
新接口开发完成
      │
      ▼
1. 识别涉及表及关联关系（外键、枚举、字典、多对多）
      │
      ▼
2. 按依赖拓扑排序：字典/枚举 → 主数据(用户/部门) → 业务表 → 关联表
      │
      ▼
3. 逐表造数：正常数据 + 边界 + 异常反例，关联字段引用真实 ID
      │
      ▼
4. 生成幂等 seed 脚本，仅指向测试/开发库
      │
      ▼
5. 执行并验证：接口返回非空、关联可查询、无孤儿数据
```
