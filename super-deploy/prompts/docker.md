# docker — Docker 规范

## error 级别硬约束

### 1. 必须使用多阶段构建

Dockerfile 必须使用多阶段构建，将编译环境和运行环境分离。编译阶段包含完整的构建工具链，运行阶段仅包含运行时依赖。这可以减少最终镜像的体积和攻击面。

编译阶段使用完整的 SDK 镜像，生产运行阶段使用精简镜像（如 alpine、distroless、slim 变体）。不得在单一阶段中完成编译和执行。

### 2. 容器不得以 root 用户运行

Dockerfile 中必须显式创建非 root 用户并切换到该用户执行应用。容器以 root 运行导致容器逃逸漏洞可获取宿主机 root 权限。

实现方式：在 Dockerfile 中使用 USER 指令指定非 root 用户，或在 K8s 安全上下文中配置 runAsNonRoot 和 runAsUser。

### 3. 镜像构建必须固定基础镜像版本

FROM 指令必须指定基础镜像的精确版本标签（如 node:20.11-alpine），禁止使用 latest 标签。latest 标签在不同时间构建可能指向不同版本，导致构建结果不可复现。

### 4. 敏感信息不得写入镜像层

Dockerfile 中的构建参数、环境变量、COPY 指令涉及的文件不得包含敏感信息（密钥、证书、密码）。构建阶段使用的密钥通过 Docker BuildKit 的 --secret 参数传入，不固化在镜像层中。

不得在 Dockerfile 中使用 ENV 设置密码、API Key 等敏感环境变量。

## warn 级别软约束

- 镜像体积控制：生产镜像 < 200MB（Java 可放宽至 300MB），使用 .dockerignore 排除无关文件
- 镜像层数：合并 RUN 指令减少层数，基础层 + 依赖层 + 应用层三层结构
- 健康检查：在 Dockerfile 或 docker-compose 中配置 HEALTHCHECK 指令，指向 /health 端点
- 启动和停止信号：使用 exec form 的 CMD/ENTRYPOINT，确保容器能接收 SIGTERM 信号实现优雅关闭
- 镜像打标签策略：同时打 commit SHA 和语义版本号两个标签，便于追溯和回滚
