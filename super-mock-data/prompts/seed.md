# seed — 种子数据落库规范

## error 级别硬约束

### 1. 仅写入测试/开发数据库，生产库禁止写入

seed 脚本必须通过环境/配置判断目标库，生产环境严禁执行造数：

- 通过 profile / env 判断当前环境（`dev` / `test` / `local`），非测试环境直接拒绝执行
- seed 脚本不得读取或覆盖生产连接配置
- 无法区分环境时，默认不执行，要求显式传入 `--env=test` 之类参数

### 2. 幂等可重复执行

seed 脚本重复执行不得产生重复数据，保证可反复初始化：

- 优先策略：先按标记/唯一键清理本次数据，再插入（先清后插）
- 或使用 upsert / `INSERT ... ON CONFLICT DO NOTHING` 按唯一键去重
- 使用固定主键或唯一业务键（如订单号），重复执行结果一致

### 3. 使用官方 seed / 迁移工具管理，不手写临时 SQL

造数必须纳入版本管理，通过项目既定工具落地，禁止随手写一次性 SQL：

| 语言 | 推荐工具 |
|------|---------|
| Java | Flyway / Liquibase 的 data migration，或独立 `@Profile("dev")` Seeder |
| Node.js | Prisma `seed.ts` / TypeORM migration / Knex seed |
| Go | golang-migrate，或 `seed/` 目录下独立程序 |
| Python | Alembic data migration / Django `fixtures` / 独立 `seed.py` |

### 4. 提供清理机制

造出的数据必须能被一键清除，不污染后续测试：

- 数据带可识别的标记或前缀（如 `source='seed'` 或特定 ID 区间）
- 提供对应的清理脚本，能按标记精准删除本次造出的数据
- 清理不得误删测试库中的手工/历史数据

## warn 级别软约束

- 数据量适中：单表 10-100 条，大表/明细表按需控制，避免初始化过慢
- seed 脚本与业务代码同仓库、同版本提交，随代码演进持续维护
- 造数后执行一次验证查询，确认各表有数据且关联完整，再交付联调
