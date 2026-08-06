---
name: super-config
description: >
  服务端配置集中管理规范。要求所有环境变量在单一配置模块中集中读取和校验，
  业务代码不得直接访问环境变量。Activates when writing server-side configuration,
  environment variable management, config center, or initialization code.
  Triggers: config, 配置, 集中配置, 环境变量, env, configuration, centralized
  config, process.env, os.Getenv, System.getenv, System.getProperty, dotenv,
  配置管理, config manager, app config, bootstrap, startup config.
---

# Contract

本技能**叠加**在 `super-core` 之上，提供服务端集中式配置管理规范。

> 本技能为 `super-core/prompts/config.md` 的深化扩展。super-core 的 config 规则约束多环境分离和敏感加密，本技能进一步约束业务代码如何访问配置。

## 前置检查

1. 确认 `super-core` 已加载
2. 从合并配置中读取 `scenarios.config.enabled`：
   - `false` → 跳过本技能
   - `true`  → 继续加载
3. 从合并配置中读取 `scenarios.config.rules`，加载对应 prompt。

## 加载规则

| 配置项 | prompt 文件 | 覆盖内容 |
|--------|-----------|---------|
| central | prompts/config-central.md | 集中配置架构：单一入口、启动校验、类型化结构体 |
| env-gate | prompts/env-gate.md | 环境变量网关：禁止业务代码直读 env、读写分离 |

## 自检

代码输出后，在 super-core 自检表后追加：

```
[super-config] 规则检查
  ✅ central    — 配置集中定义于 AppConfig 结构体，启动时 fail-fast 校验
  ✅ env-gate   — 环境变量仅在 config/ 层读取，业务代码 0 处 process.env/os.Getenv
```

## 核心理念

```
┌─────────────────────────────────────────────┐
│                 业务代码                      │
│  Service / Controller / Repository / ...     │
│                                              │
│  import { config } from '@/config'           │
│  const db = new Database(config.db.host)  ✅ │
│                                              │
│  const host = process.env.DB_HOST  ←  ❌     │
│  const host = os.Getenv("DB_HOST") ←  ❌     │
└──────────────────┬──────────────────────────┘
                   │ 只通过 config 对象访问
┌──────────────────▼──────────────────────────┐
│           config/ 配置层 (唯一入口)            │
│                                              │
│  1. 读取所有环境变量                           │
│  2. 校验必填项 + 类型转换 + 默认值              │
│  3. 导出不可变配置对象                         │
│                                              │
│  const dbHost = process.env.DB_HOST  ✅      │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│             环境变量 (.env / K8s / CI)        │
└─────────────────────────────────────────────┘
```
