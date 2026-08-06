---
name: super-deploy
description: >
  Deployment and CI/CD standards. Activates when building pipelines, writing
  Dockerfiles, configuring Kubernetes, or setting up deployment workflows.
  Triggers: deploy, deployment, CI/CD, CI, CD, pipeline, Docker, Dockerfile,
  docker-compose, Kubernetes, K8s, Helm, build, release, artifact, image,
  container, GitHub Actions, Jenkins, GitLab CI, ArgoCD.
---

# Contract

本技能**叠加**在 `super-core` 之上生效。

## 前置检查

1. 确认 `super-core` 已加载
2. 从合并配置中读取 `scenarios.deploy.enabled`：
   - `false` → 跳过
   - `true`  → 继续
3. 从合并配置中读取 `scenarios.deploy.rules`，加载对应 prompt

## 加载规则

| 配置项 | prompt 文件 | 覆盖内容 |
|--------|-----------|---------|
| ci-cd | prompts/ci-cd.md | 流水线设计、分支策略、构建产物管理 |
| docker | prompts/docker.md | Dockerfile 最佳实践、镜像优化、安全 |

## 自检

代码输出后，在 super-core 自检表后追加：

```
[super-deploy] 规则检查
  ✅ ci-cd  — 多环境流水线，构建产物带版本号，制品库存储
  ✅ docker — 多阶段构建，非 root 用户，镜像 <200MB
```
