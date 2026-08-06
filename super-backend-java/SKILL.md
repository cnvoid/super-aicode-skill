---
name: super-backend-java
description: >
  Java backend coding standards. Activates when writing Spring Boot, Spring MVC,
  Spring Cloud, MyBatis, JPA, Maven, or Gradle code. Triggers include: Java,
  Spring, Spring Boot, Controller, Service, Repository, JPA, MyBatis, Hibernate,
  Maven, Gradle, Bean, AOP, Transactional, Feign, RestTemplate, Lombok.
---

# Contract

本技能**叠加**在 `super-core` 之上生效。

## 前置检查

1. 确认 `super-core` 已加载。若未加载，先执行 super-core Phase 1-2。
2. 从合并配置中读取 `scenarios.backend-java.enabled`：
   - `false` → 跳过本技能，仅保留 super-core
   - `true`  → 继续加载 Java 规则
3. 从合并配置中读取 `scenarios.backend-java.rules`，按对应级别加载 prompt。

## 加载规则

| 配置项 | prompt 文件 | 覆盖内容 |
|--------|-----------|---------|
| layering | prompts/layering.md | Controller/Service/Repository 分层约束 |
| exception | prompts/exception.md | 全局异常处理、业务异常体系 |
| jpa | prompts/jpa.md | JPA 查询优化、事务、N+1 |
| bean | prompts/bean.md | 依赖注入、循环依赖、作用域 |

## 自检

代码输出后，在 super-core 自检表后追加：

```
[super-backend-java] 规则检查
  ✅ layering   — Controller→Service→Repository 分层正确
  ✅ exception  — GlobalExceptionHandler 已实现
  ✅ jpa        — 无 N+1，事务隔离级别正确
  ⚠️  bean      — 存在字段注入，建议改为构造器注入(TODO)
```
