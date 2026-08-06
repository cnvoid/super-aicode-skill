# build — 构建配置规范

## error 级别硬约束

### 1. 环境变量必须使用标准前缀

项目中所有环境变量必须使用构建工具约定的前缀，如下：

- Vite 项目：`VITE_` 前缀
- Create React App：`REACT_APP_` 前缀
- Next.js：`NEXT_PUBLIC_` 前缀（客户端可用）

未加前缀的环境变量在客户端代码中不可访问。API 地址、密钥等配置不得硬编码在业务代码中，必须通过环境变量注入。

### 2. 生产构建必须移除调试代码

生产环境的构建产物必须配置以下优化：
- 移除 console.log、console.debug、console.warn（通过构建工具插件）
- 移除 debugger 语句
- 移除 React DevTools 等开发辅助工具
- 压缩 JS/CSS/HTML
- 移除未使用的 CSS（PurgeCSS）

## warn 级别软约束

- 开发服务器配置代理转发（proxy），解决本地开发跨域问题，不得在服务端通过 CORS 全放行
- 构建产物启用 gzip 或 brotli 压缩，配合 Nginx 的静态压缩分发
- CSS 和 JS 文件名包含内容哈希（contenthash），实现长效缓存
- 代码分割策略：node_modules 打包为 vendor chunk，公共组件打包为 common chunk
- 使用构建分析工具（rollup-plugin-visualizer、webpack-bundle-analyzer）定期检查包体积，单个 chunk 不超过 500KB
- 配置 .env.development 和 .env.production 分离开发与生产环境变量
