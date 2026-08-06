# jpa — JPA 规范

## error 级别硬约束

### 1. 必须防范 N+1 查询

所有涉及关联实体查询的场景，必须显式指定加载策略，避免触发 N+1 次数据库查询。

实现方式（按优先级）：
- JOIN FETCH：在 JPQL/HQL 查询中使用 JOIN FETCH 一次性加载关联实体
- @EntityGraph：使用 @EntityGraph 注解声明需要加载的关联属性
- @BatchSize：在 Entity 类使用 @BatchSize 注解启用批量加载

不得依赖 JPA 的默认延迟加载行为而不做任何优化。

### 2. 事务声明必须完整

所有涉及数据库写操作的方法必须使用 @Transactional 注解，并声明 rollbackFor 回滚策略：
- 写操作：@Transactional(rollbackFor = Exception.class)
- 只读操作：@Transactional(readOnly = true)，数据库可据此进行读写分离优化

事务传播行为默认使用 REQUIRED，仅在明确需要独立事务的场景才使用 REQUIRES_NEW 或 NESTED。

### 3. 批量操作需优化

批量插入或更新操作必须使用 JPA 的批量处理机制：
- 配置 hibernate.jdbc.batch_size 启用 JDBC 批量操作
- 使用 saveAll 方法替代逐条 save
- 定期 flush 和 clear EntityManager 以释放一级缓存

## warn 级别软约束

- 事务方法内避免长时间的外部 RPC/HTTP 调用
- 对并发写敏感的实体使用 @Version 乐观锁
- 大表分页查询使用游标分页而非 offset 分页
- 延迟加载的关联属性确保在事务范围内访问
