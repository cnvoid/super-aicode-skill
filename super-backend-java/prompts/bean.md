# bean — 依赖注入规范

## error 级别硬约束

### 1. 必须使用构造器注入

所有依赖必须通过构造器注入，不得使用字段注入（@Autowired 直接标注在字段上）或 Setter 注入。构造器注入的优势：
- 依赖不可变（通过 final 修饰）
- 便于单元测试（可以手动传入 mock 对象）
- 避免隐藏的依赖（构造器参数过多提示类职责过重）
- 解决循环依赖问题（构造器注入循环依赖在启动时报错而非运行时）

构造器注入的实现方式：
- 手写构造器（推荐，依赖不超过 3 个时）
- Lombok @RequiredArgsConstructor（推荐，配合 final 字段）
- Spring 4.3+ 的单构造器自动注入（无需 @Autowired）

### 2. 必须解决循环依赖

不得出现 Bean 之间的循环依赖。Spring Boot 默认禁止构造器循环依赖。

解决方案（按优先级）：
- 重构：将共同依赖的逻辑抽离为独立的第三方 Bean
- 事件解耦：使用 ApplicationEventPublisher 替代直接调用，将同步调用转为异步事件
- @Lazy 懒加载：仅作为最后手段，在某一个 Bean 的构造器参数上加 @Lazy 注解

## warn 级别软约束

- 一个 Bean 的构造器依赖超过 5 个时，考虑拆分类或引入门面模式
- 同一类型有多个实现时使用 @Qualifier 明确注入目标
- 避免在 @PostConstruct 中执行耗时操作（会阻塞启动）
- Prototype 作用域的 Bean 注入到 Singleton 时使用 ObjectProvider 或 @Lookup
