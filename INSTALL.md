# 安装指南

Super AI Code Skill 是一套面向 OpenCode / Claude Code / OpenClaw 的编码规范技能包，安装后约束 AI Agent 输出符合生产级标准的代码。

---

## 快速安装

### Linux / macOS

```bash
# 全局安装（所有项目生效）
bash install.sh

# 安装到当前项目
bash install.sh --project

# 更新已有安装
bash install.sh --update
```

### Windows

```powershell
# 全局安装（所有项目生效）
.\install.ps1

# 安装到当前项目
.\install.ps1 -Project

# 更新已有安装
.\install.ps1 -Update
```

---

## 手动安装

### 1. 复制技能文件

**全局安装**（所有 opencode 会话都加载这些技能）：

| 平台 | 目标路径 |
|------|---------|
| Linux / macOS | `~/.config/opencode/skills/super-aicode/` |
| Windows | `~\.config\opencode\skills\super-aicode\` |

```bash
# Linux / macOS
mkdir -p ~/.config/opencode/skills/super-aicode
cp -r super-*/ ~/.config/opencode/skills/super-aicode/
cp -r profiles/ templates/ ~/.config/opencode/skills/super-aicode/
```

```powershell
# Windows
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.config\opencode\skills\super-aicode"
Copy-Item -Recurse -Force super-* "$env:USERPROFILE\.config\opencode\skills\super-aicode\"
Copy-Item -Recurse -Force profiles, templates "$env:USERPROFILE\.config\opencode\skills\super-aicode\"
```

**项目安装**（仅当前项目生效，追加在全局基础之上）：

```bash
# Linux / macOS
mkdir -p .opencode/skills/super-aicode
cp -r super-*/ .opencode/skills/super-aicode/
cp -r profiles/ templates/ .opencode/skills/super-aicode/
```

### 2. 创建全局配置文件

```bash
# Linux / macOS
cp templates/global.yaml ~/.super.yaml
```

```powershell
# Windows
Copy-Item templates\global.yaml "$env:USERPROFILE\.super.yaml"
```

### 3. 创建项目配置文件（可选）

在需要自定义规则的项目根目录：

```bash
cp templates/project.yaml ./.super.yaml
```

编辑 `.super.yaml` 按需调整规则开关和级别。

### 4. 重启 Agent

配置修改后，重启 OpenCode / Claude Code 使技能生效。

---

## 验证安装

重启后，在 Agent 对话中输入以下代码需求，观察是否触发规则检查：

> 帮我写一个创建订单的 REST 接口

预期 Agent 行为：
1. 输出任务方案（Phase 0）
2. 报告加载的配置（Phase 1）
3. 生成代码时遵循所有 error 级规则
4. 代码输出后逐条自检（Phase 4）

如未触发，检查：
- 技能文件是否放在了正确的 skills 目录下
- 目录名是否为 `super-aicode`（与 skill 内部 `name` 字段无关，opencode 按文件夹名加载）
- 是否已重启 Agent

---

## 目录结构

安装后的目录结构：

```
~/.config/opencode/skills/super-aicode/
├── profiles/
│   ├── balanced.yaml
│   ├── strict.yaml
│   └── minimal.yaml
├── templates/
│   ├── global.yaml
│   └── project.yaml
├── super-core/
│   ├── SKILL.md
│   └── prompts/
│       ├── error.md
│       ├── validation.md
│       ├── response.md
│       ├── naming.md
│       ├── api-design.md
│       ├── config.md
│       ├── health.md
│       ├── backend-security.md
│       ├── resilience.md
│       ├── logging.md
│       ├── observability.md
│       └── doc.md
├── super-frontend/
│   ├── SKILL.md
│   └── prompts/ (11 个)
├── super-backend-java/
│   ├── SKILL.md
│   └── prompts/ (4 个)
├── super-backend-node/
│   ├── SKILL.md
│   └── prompts/ (3 个)
├── super-backend-go/
│   ├── SKILL.md
│   └── prompts/ (3 个)
├── super-backend-python/
│   ├── SKILL.md
│   └── prompts/ (4 个)
├── super-backend-common/
│   ├── SKILL.md
│   └── prompts/ (4 个)
├── super-design-icon/
│   ├── SKILL.md
│   └── prompts/ (3 个)
├── super-deploy/
│   ├── SKILL.md
│   └── prompts/ (2 个)
├── super-config/
│   ├── SKILL.md
│   └── prompts/ (2 个)
├── super-api-doc/
│   ├── SKILL.md
│   └── prompts/ (2 个)
├── super-test/
│   ├── SKILL.md
│   └── prompts/ (6 个)
├── super-log/
│   ├── SKILL.md
│   └── prompts/ (2 个)
└── super-sse/
    ├── SKILL.md
    └── prompts/ (2 个)
```

---

## 卸载

```bash
# Linux / macOS — 全局卸载
rm -rf ~/.config/opencode/skills/super-aicode
rm -f ~/.super.yaml

# 项目卸载
rm -rf .opencode/skills/super-aicode
rm -f ./.super.yaml
```

```powershell
# Windows — 全局卸载
Remove-Item -Recurse -Force "$env:USERPROFILE\.config\opencode\skills\super-aicode"
Remove-Item -Force "$env:USERPROFILE\.super.yaml"

# 项目卸载
Remove-Item -Recurse -Force .opencode\skills\super-aicode
Remove-Item -Force .\.super.yaml
```
