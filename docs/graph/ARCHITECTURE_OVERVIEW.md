# 智颐养老系统（中州养老）架构图解手册

> 基于若依 RuoYi v3.8.9 改造，Java 11，Spring Boot 2.5.15，Spring Security 5.7.12  
> 9 个 Maven 模块，核心业务涵盖楼层-房间-床位三级位置、入住/退住、护理方案-等级-项目四层体系、IoT 设备接入（华为云 IoTDA + AMQP 1.0）、健康评估（百度千帆 Ernie 5.0 AI）、微信小程序、合同全生命周期管理  
> 所有图片位于 `D:/code/codeJava/heima-phase4/zznursing/docs/graph/` 目录，格式为 `.png`

---

## 第一批：系统全局架构（01~08）

### 01 — 系统架构 C4 容器图

![01-system-architecture](D:/code/codeJava/heima-phase4/zznursing/docs/graph/01-system-architecture.png)

**概述：** 基于 C4_Container 风格绘制的系统高层架构图，展示了智颐养老系统的整体容器划分和交互关系。

**核心容器：**
- **zzyl-admin** — Web 服务入口，Spring Boot 应用，运行在 8080 端口，聚合所有模块
- **zzyl-nursing-platform** — 核心护理业务模块，16 个 Controller，19 个 Mapper，处理入住/退住/合同等业务
- **zzyl-framework** — 框架核心，Spring Security + JWT + AOP + Redis 缓存
- **zzyl-system** — 系统管理，RBAC 权限、字典、配置
- **zzyl-quartz** — 定时任务调度引擎，基于 Quartz 动态调度
- **zzyl-oss** — 阿里云 OSS 对象存储
- **zzyl-generator** — 代码生成器，Velocity 模板引擎
- **zzyl-common** — 通用工具层，所有模块的公共依赖

**外部系统：**
- MySQL 主从数据库、Redis 缓存、阿里云 OSS、华为云 IoTDA、百度千帆 AI

**交互协议：** HTTP REST、Redis TCP、MySQL JDBC、AMQP 1.0（华为云）、OpenAI 兼容接口（百度千帆）

---

### 02 — Maven 模块依赖关系图

![02-module-dependency](D:/code/codeJava/heima-phase4/zznursing/docs/graph/02-module-dependency.png)

**概述：** 展示 9 个 Maven 模块之间的编译期依赖关系和运行时打包策略。

**关键依赖链：**
1. `zzyl-common` 是最底层，无内部依赖，被所有模块直接或间接依赖
2. `zzyl-system` 依赖 `zzyl-common`，提供 RBAC 权限数据模型
3. `zzyl-framework` 依赖 `zzyl-system`，是框架核心层
4. `zzyl-nursing-platform` 是核心业务，直接依赖 `zzyl-framework`、`zzyl-oss`、`zzyl-common`
5. `zzyl-admin` 是应用入口，聚合 `zzyl-framework`、`zzyl-quartz`、`zzyl-generator`、`zzyl-nursing-platform`、`zzyl-oss`
6. 打包产物为 `zzyl-admin.jar`，使用 `spring-boot-maven-plugin` 的 `repackage` goal

---

### 03 — 实体类图（19 个核心实体）

![03-entity-classdiagram](D:/code/codeJava/heima-phase4/zznursing/docs/graph/03-entity-classdiagram.png)

**概述：** 项目中 19 个核心业务实体的类关系图，展示各个实体之间的关联、继承关系和关键字段。

**主要实体分组：**
- **位置体系：** Floor（楼层）、Room（房间）、Bed（床位）、RoomType（房型）
- **老人/客户：** Elder（老人）、FamilyMember（家属/小程序用户）、CheckIn（入住）、CheckInConfig（入住配置）
- **合同：** Contract（合同）
- **护理：** NursingProject（护理项目）、NursingPlan（护理计划）、NursingLevel（护理等级）、NursingElder（护工关联）
- **评估：** HealthAssessment（健康评估）
- **设备：** Device（设备）、DeviceData（设备数据）、AlertRule（报警规则）
- **用户：** BaseEntity（审计字段基类）、SysUser、SysRole、SysMenu

**核心设计：**
- 多数实体继承 `BaseEntity`，获得 `createBy`、`createTime`、`updateBy`、`updateTime` 审计字段
- `RoomType` 通过 `price` 和 `capacity` 支持不同类型房间定价
- `CheckInConfig` 作为值对象关联到入住记录，存储订金、床位费、护理费、医保支付、政府补贴等费用数据

---

### 04 — 用例图（3 角色 23 用例）

![04-usecase-diagram](D:/code/codeJava/heima-phase4/zznursing/docs/graph/04-usecase-diagram.png)

**概述：** 识别系统三个核心角色及其 23 个主要用例，展示系统的功能边界。

**角色与权限等级：**
- **系统管理员（admin）：** 拥有最高权限，管理用户/角色/菜单/字典/配置/操作日志/在线用户/缓存/服务器监控，负责全局系统配置
- **护理主管（supervisor）：** 日常运营核心用户，管理楼层/房间/床位/老人/入住/退住/合同/护理方案/健康评估/设备/报警规则
- **老人家属/访客（member）：** 小程序端用户，预约参观/探访、查看房型、在线签约

**关键用例：**
- 入住办理是系统最核心的用例，串联了选房、签合同、配置费用、记录家属信息等多个子流程
- 健康评估是 AI 赋能的关键功能，通过百度千帆分析体检报告 PDF，自动推荐护理等级

---

### 05 — 入住办理活动图

![05-checkin-activity](D:/code/codeJava/heima-phase4/zznursing/docs/graph/05-checkin-activity.png)

**概述：** 老人入住流程的完整活动图，详细展示从选择楼层到入住完成的全部步骤。

**流程步骤：**
1. **位置选择：** 选择楼层 → 选择房型 → 选择房间 → 选择床位（展示未占用的树形结构）
2. **信息录入：** 录入老人基本信息（姓名、身份证、照片、身份证图片）→ 添加家属信息（姓名、关系、电话）
3. **订金与费用配置：** 设置订金金额、护理费、床位费、其他费用、起止日期、医保支付、政府补贴
4. **合同生成：** 自动生成合同编号（HT 前缀 + 18 位随机数字），签署日期，丙方信息，上传协议 PDF
5. **业务检查：** 校验老人是否已入住（身份证去重），校验床位是否已被占用
6. **完成：** 更新床位状态为占用，创建老人记录，生成合同和入住记录，配置费用信息

---

### 06 — 登录认证时序图

![06-login-sequence](D:/code/codeJava/heima-phase4/zznursing/docs/graph/06-login-sequence.png)

**概述：** 用户登录认证的完整时序流程，展示 JWT Token 的生成、缓存和后续自动认证机制。

**核心流程：**
1. 前端发起到 `/login` 的 POST 请求，携带用户名、密码、验证码 UUID 和用户输入值
2. `SysLoginController` 调用 `SysLoginService.login()`，该服务先校验验证码（从 Redis 读取 `captcha_codes:{uuid}`），再调用 `AuthenticationManager.authenticate()` 执行 Spring Security 认证
3. 认证成功后，创建 `LoginUser` 对象（包含用户 ID、用户名、权限列表、登录 IP、地理位置、浏览器、操作系统信息）
4. `TokenService.createToken()` 生成 UUID token，将 `LoginUser` 存储到 Redis `login_tokens:{uuid}`，TTL 30 分钟
5. 生成 JWT Token（含 `login_user_key:{uuid}` 声明），返回给前端
6. 后续请求通过 `JwtAuthFilter` 解析 JWT，从 Redis 获取 `LoginUser`，放入 `SecurityContextHolder`

**关键设计：**
- JWT 仅作为凭证令牌，真正的用户会话数据存储在 Redis 中
- 每次请求自动续期 TTL（`TokenService.verifyToken()`）
- Token 自动续期策略：如果剩余 TTL 小于 10 分钟，刷新为 30 分钟

---

### 07 — 部署架构图

![07-deployment-diagram](D:/code/codeJava/heima-phase4/zznursing/docs/graph/07-deployment-diagram.png)

**概述：** 系统部署拓扑图，展示生产环境的多节点部署架构和网络分层。

**部署层级：**
- **负载层：** Nginx 反向代理，分发 HTTP 请求到多个应用实例，支持 WebSocket 代理
- **应用层：** Spring Boot 应用（zzyl-admin）多节点部署，JDK 11，JVM 堆 512MB~1024MB
- **数据层：** MySQL 主从架构 + 阿里云 OSS 对象存储
- **缓存层：** Redis 单节点，存储会话、验证码、字典、配置、设备数据、护理数据等

**CI/CD：**
- Jenkins 参数化构建，支持选择部署分支、清除数据、备份数据库、推送 Docker 镜像
- Docker 容器运行，基础镜像 `openjdk:11.0-jre-buster`

---

### 08 — 护理业务领域类图

![08-nursing-domain-class](D:/code/codeJava/heima-phase4/zznursing/docs/graph/08-nursing-domain-class.png)

**概述：** 护理业务子域的核心领域模型，展示护理项目-计划-等级四层体系以及 Controller-Service-Mapper 三层架构。

**四层体系：**
- **NursingProject（护理项目）：** 最顶层，如"生活照料"、"医疗护理"、"康复训练"，有排序号、名称、状态
- **NursingPlan（护理计划）：** 关联到项目，如"生活照料"下的"晨间护理"、"晚间护理"、"饮食照料"，有状态和描述
- **NursingLevel（护理等级）：** 关联到计划，每个等级有一个费用，如特级/一级/二级/三级/四级护理
- 这种设计支持灵活的定价模型：每个计划可以有不同的等级，每个等级有不同的费用

**三层架构：**
- Controller 层：`NursingProjectController`、`NursingPlanController`、`NursingLevelController`
- Service 层：`INursingProjectService`、`INursingPlanService`、`INursingLevelService`
- Mapper 层：继承 `BaseMapper<T>`，使用 MyBatis-Plus

---

## 第二批：业务核心流程（09~16）

### 09 — IoT 数据接入时序图

![09-iot-data-flow](D:/code/codeJava/heima-phase4/zznursing/docs/graph/09-iot-data-flow.png)

**概述：** 展示华为云 IoT 设备数据通过 AMQP 1.0 协议实时接入系统的完整时序。

**核心流程：**
1. **启动阶段：** `AmqpClient` 实现 `ApplicationRunner`，在应用启动时自动建立到华为云 IoTDA 的 AMQP 连接（TLS/SSL 加密），创建 Session 和 MessageConsumer
2. **消息接收：** 设备上报数据到华为云物联网平台后，平台将消息推送到指定队列，`MessageListener` 异步接收
3. **消息处理：** 通过线程池（`ExecutorService`）异步处理，解析 JSON 载荷，提取 `notify_data` → `body` → `services`，获取 `service_id`、`properties`（属性键值对）、`event_time`
4. **数据持久化：** 调用 `IDeviceDataService.batchInsertDeviceData()` 批量存入 `device_data` 表
5. **断线重连：** 使用 JMS `failover:` 传输协议，配置重连延迟（10 秒起步，最大 300 秒），支持自动重连

---

### 10 — 合同状态机图

![10-contract-state-machine](D:/code/codeJava/heima-phase4/zznursing/docs/graph/10-contract-state-machine.png)

**概述：** 合同四种状态的转换规则图，展示合同从创建到终止的完整生命周期。

**四种状态：**
- **未生效（0）：** 合同创建时的初始状态，如果 startDate > 当前日期
- **已生效（1）：** 到达 startDate 后自动转为已生效
- **已过期（2）：** 超过 endDate 后自动过期
- **已失效（3）：** 通过退住流程手动终止，记录终止提交人、终止日期、终止协议 PDF

**状态转换触发：**
- 入住办理时自动创建合同，状态根据开始日期判断（0 或 1）
- `ContractTask.updateContractStatusTask()` 是 Quartz 定时任务，每分钟执行一次，自动检查合同日期并更新状态（0→1，1→2）
- 退住时由退住流程触发合同失效（1→3）
- 失效是最终状态，无法回到其他状态

---

### 11 — 健康评估 AI 解析活动图

![11-health-assessment-flow](D:/code/codeJava/heima-phase4/zznursing/docs/graph/11-health-assessment-flow.png)

**概述：** 健康评估模块中 AI 分析体检报告 PDF 的完整活动流程。

**流程步骤：**
1. **上传阶段：** 用户上传 PDF 格式的体检报告，系统使用 `PDFUtil.pdfToString()`（基于 PDFBox）提取文本内容，存储到 Redis（key 为 `healthReport:{idCardNo}`，TTL 24 小时）
2. **AI 分析阶段：** 用户填写老人基本信息（姓名、性别、年龄、身份证号），系统从 Redis 获取 PDF 文本，构造包含年龄、性别和完整报告内容的提示词
3. **调用百度千帆：** 通过 `AIModelInvoker.chatCompletion()` 调用百度千帆 Ernie 5.0 模型（OpenAI 兼容接口），模型返回结构化 JSON
4. **解析结果：** 解析 AI 返回的 JSON 包含健康指数（0-100）、风险等级（healthy/caution/risk/danger/severeDanger）、风险分布百分比、八大体统评分（呼吸/消化/内分泌/免疫/循环/泌尿/运动/感官）、异常指标列表
5. **推荐护理等级：** 基于健康分数自动推荐护理等级（≥85 四级、≥70 三级、≥55 二级、≥40 一级、<40 特级），并给出是否建议入住

---

### 12 — 护理方案-等级-项目结构图

![12-nursing-plan-structure](D:/code/codeJava/heima-phase4/zznursing/docs/graph/12-nursing-plan-structure.png)

**概述：** 护理业务四级体系的层次结构和关联关系图解。

**四层层次：**
- **护理项目（NursingProject）：** 分类如生活照料、医疗护理、康复训练、心理支持等
- **护理计划（NursingPlan）：** 如果"生活照料"项目下包含"晨间护理"、"晚间护理"、"饮食照料"、"翻身拍背"等计划
- **护理等级（NursingLevel）：** 每个计划关联多个等级（特级/一级/二级/三级/四级），每个等级有独立的费用
- **缓存方案：** 三种数据都有对应的 Redis 缓存（`nursingLevel:all`、`nursingProject:all`、`nursingPlan:all`），采用相同的缓存预热和清除策略

---

### 13 — 微信小程序登录时序图

![13-miniprogram-login](D:/code/codeJava/heima-phase4/zznursing/docs/graph/13-miniprogram-login.png)

**概述：** 微信小程序用户登录的完整流程，展示微信登录凭证交换和 JWT Token 生成。

**核心流程：**
1. 微信小程序端调用 `wx.login()` 获取临时 code，再调用 `wx.getPhoneNumber()` 获取加密手机号数据
2. 前端调用微信服务器获取手机号明文，然后将 code 和手机号发送到后端
3. `FamilyMemberController` 调用 `WechatService.code2Session()`，将 code 发送到微信服务器换取 `openid`
4. 根据 openid 查询或创建用户记录
5. 生成 JWT Token（使用 `jwtUtils`，密钥 `weChatSecret`，过期时间 `weChatExpireTime`），返回给前端

---

### 14 — RBAC 权限数据模型类图

![14-rbac-model](D:/code/codeJava/heima-phase4/zznursing/docs/graph/14-rbac-model.png)

**概述：** 基于 RBAC（Role-Based Access Control）的 5 表权限模型类图，包含数据权限范围规则。

**核心表结构：**
- `sys_user`（用户）↔ `sys_user_role`（用户角色关联）↔ `sys_role`（角色）↔ `sys_role_menu`（角色菜单关联）↔ `sys_menu`（菜单/权限）
- `sys_dept`（部门）通过 `data_scope` 字段支持五种数据权限级别

**数据权限范围：**
- **ALL（1）：** 全部数据权限
- **DEPT_CUSTOM（2）：** 自定数据权限（通过 `sys_role_dept` 关联部门）
- **DEPT_ONLY（3）：** 仅本部门数据
- **DEPT_AND_CHILD（4）：** 本部门及以下数据
- **SELF（5）：** 仅本人数据

---

### 15 — Quartz 定时任务组件图

![15-quartz-architecture](D:/code/codeJava/heima-phase4/zznursing/docs/graph/15-quartz-architecture.png)

**概述：** Quartz 定时任务组件的架构图，展示任务调度引擎的核心组件和交互关系。

**架构层次：**
- **Web 层：** `SysJobController`（CRUD + 状态管理 + 立即执行）和 `SysJobLogController`（日志查询）
- **服务层：** `SysJobServiceImpl`，包含 `@PostConstruct init()`（启动时同步加载任务）
- **调度工具：** `ScheduleUtils`，负责创建 JobDetail + CronTrigger + 安全管理（黑名单/白名单）
- **执行器：** `AbstractQuartzJob`（基类，处理 before/after 日志记录）→ `QuartzJobExecution`（允许并发）/ `QuartzDisallowConcurrentExecution`（禁止并发）
- **反射调用：** `JobInvokeUtil` 解析 `invokeTarget` 字符串，通过反射调用 Spring Bean 方法或全限定类名方法

**安全机制：** 禁止 `rmi://`、`ldap://`、`http://`、`https://` 等不安全调用，白名单包路径验证

---

### 16 — 退住流程活动图

![16-checkout-activity](D:/code/codeJava/heima-phase4/zznursing/docs/graph/16-checkout-activity.png)

**概述：** 老人退住/出院流程活动图，展示从申请到完成的完整步骤。

**流程步骤：**
1. 选择要退住的老人（通过姓名/身份证/房间号/床位号检索）
2. 核对老人信息，展示合同状态、入住时长、费用缴纳情况
3. 选择退住类型（到期退住 / 提前退住 / 其他），填写退住原因
4. 上传退住协议 PDF（`terminationAgreementPath`），记录终止提交人和终止日期
5. 更新合同状态为失效（3）
6. 更新老人状态（根据退住类型决定是否禁用账号）
7. 释放床位资源（`bed_status` 置为 0）
8. 创建退住记录

---

## 第三批：安全与基础架构（17~24）

### 17 — 安全过滤链组件图

![17-security-filter-chain](D:/code/codeJava/heima-phase4/zznursing/docs/graph/17-security-filter-chain.png)

**概述：** Spring Security 安全过滤链的组件级图展示，展示从请求进入到权限验证的完整过滤链。

**过滤链顺序：**
1. **CorsFilter：** 跨域支持，允许指定来源（前端应用域名）的请求
2. **XssFilter：** XSS 攻击防护，过滤请求参数中的恶意 HTML/JavaScript 代码
3. **JwtAuthFilter：** JWT 认证过滤器，从请求头提取 Bearer token，解析并从 Redis 获取 LoginUser
4. **UsernamePasswordAuthenticationToken** 设置到 SecurityContextHolder
5. **FilterSecurityInterceptor：** 方法级别的 `@PreAuthorize` 注解检查
6. **ExceptionTranslationFilter：** 异常翻译，401/403 错误处理

---

### 18 — AOP 操作日志记录时序图

![18-aop-logging-flow](D:/code/codeJava/heima-phase4/zznursing/docs/graph/18-aop-logging-flow.png)

**概述：** 基于 AOP 的操作日志记录时序流程，展示通过 `@Log` 注解自动记录操作日志的实现机制。

**核心流程：**
1. Controller 方法标注 `@Log(title="xxx", businessType=INSERT/UPDATE/DELETE)`
2. `LogAspect` 的 `@Around` 环绕通知拦截请求，记录开始时间
3. 反射获取 `@Log` 注解属性和 `@PreAuthorize` 注解的方法权限标识
4. 提取请求信息（URL、IP、请求方式、请求参数）
5. 执行目标方法，捕获返回结果或异常
6. 调用 `AsyncFactory.recordOper()` 异步提交日志任务到线程池
7. 日志记录包含：操作人、IP、地理位置、浏览器、OS、请求 URL、方法名、请求参数、返回结果、执行耗时、状态（成功/异常）
8. 日志持久化到 `sys_oper_log` 表

---

### 19 — 文件上传时序图

![19-oss-upload-flow](D:/code/codeJava/heima-phase4/zznursing/docs/graph/19-oss-upload-flow.png)

**概述：** 通用文件上传功能的时序流程，展示从文件接收、校验到阿里云 OSS 存储的完整链路。

**核心流程：**
1. 前端提交 `MultipartFile` 到 `POST /common/upload`
2. `CommonController.uploadFile()` 调用 `FileUploadUtils` 进行校验：文件大小不超过 50MB、文件名不超过 100 字符、扩展名在白名单内
3. 校验通过后，调用 `AliyunOSSOperator.upload()`，将文件上传到阿里云 OSS
4. OSS 自动生成存储路径：`{bucket}/yyyy/MM/{UUID}.{ext}`
5. 返回完整的 OSS URL 和文件名称信息

---

### 20 — 设备注册活动图（华为云 IoTDA）

![20-device-register-flow](D:/code/codeJava/heima-phase4/zznursing/docs/graph/20-device-register-flow.png)

**概述：** IoT 设备注册到华为云 IoTDA 平台的活动流程，展示产品同步和设备注册两个主要路径。

**流程步骤：**
1. **同步产品列表：** 调用华为云 IoTDA API 获取产品列表，同步到本地数据库，将产品信息存储到 Redis（`iot:all_product_list`）
2. **注册设备：** 选择产品 → 填写设备名称 → 调用华为云 IoTDA 创建设备 API → 平台返回设备 ID 和认证信息 → 存储设备信息到本地 `device` 表
3. **设备管理：** 支持查询设备详情、查询设备上报属性、删除设备

---

### 21 — 老人状态机图（6 态）

![21-elder-state-machine](D:/code/codeJava/heima-phase4/zznursing/docs/graph/21-elder-state-machine.png)

**概述：** 老人业务状态的六种状态及其转换规则，覆盖从预约到退住的完整生命周期。

**六种状态：**
- **待入住（0）：** 已预约或已完成入住申请但未实际入住
- **已入住（1）：** 办理入住手续后，分配床位，开始计费
- **外出（2）：** 临时外出（请假），暂离养老院
- **住院（3）：** 因疾病转入医院治疗
- **退住申请（4）：** 发起退住申请但未完成手续
- **已退住（5）：** 完成退住手续，释放床位资源

---

### 22 — 预约参观/探访活动图

![22-reservation-flow](D:/code/codeJava/heima-phase4/zznursing/docs/graph/22-reservation-flow.png)

**概述：** 小程序端预约参观/探访功能的完整活动流程，支持两种预约类型和四种状态。

**流程步骤：**
1. 访客选择预约类型（0=参观预约 / 1=探访预约）
2. 填写访客信息（姓名、手机号、预约时间、被访老人信息）
3. 系统查询该时间段剩余名额（`GET /member/reservation/countByTime`），检查用户取消次数（`GET /member/reservation/cancelled-count`）
4. 提交预约，状态为待报道（0）
5. 预约状态转换：待报道 → 已完成（扫码签到）/ 取消 / 过期

---

### 23 — 数据权限过滤机制组件图

![23-data-permission-model](D:/code/codeJava/heima-phase4/zznursing/docs/graph/23-data-permission-model.png)

**概述：** 数据权限过滤机制的组件图，展示 `DataScopeAspect` 切面如何注入数据权限过滤 SQL。

**核心机制：**
1. `@DataScope(deptAlias="d", userAlias="u")` 注解标注在 Service 方法上
2. `DataScopeAspect` 使用 `@Before` 通知拦截方法调用
3. 从当前登录用户的 LoginUser 获取 `role` 对象，读取 `dataScope` 值
4. 根据五种数据权限范围，动态拼接 WHERE 条件：
   - 本部门：`d.dept_id = currentDeptId`
   - 本部门及子部门：`d.dept_id IN (deptId, childDeptIds)`
   - 自定义：`d.dept_id IN (customDeptIds)`
   - 仅本人：`u.user_id = currentUserId`
5. 过滤条件通过 MyBatis `${params.dataScope}` 或 MyBatis-Plus 的 `DataPermissionInterceptor` 注入

---

### 24 — 缓存架构图（9 类 Redis 缓存）

![24-cache-architecture](D:/code/codeJava/heima-phase4/zznursing/docs/graph/24-cache-architecture.png)

**概述：** 系统 9 类 Redis 缓存的全景图，展示每种缓存的数据类型、TTL 策略和使用场景。

**9 类缓存：**

| 缓存键前缀 | 类型 | TTL | 预热时机 | 用途 |
|-----------|------|-----|----------|------|
| `login_tokens:{uuid}` | String(JSON) | 30分钟 | 登录时 | 用户会话 |
| `captcha_codes:{uuid}` | String | 2分钟 | 生成时 | 验证码 |
| `sys_dict:{type}` | String(JSON) | 永不过期 | 启动时 | 字典数据 |
| `sys_config:{key}` | String | 永不过期 | 启动时 | 参数配置 |
| `repeat_submit:{url}` | String | 1秒 | 请求时 | 防重复提交 |
| `rate_limit:{key}` | String | 按配置 | 请求时 | 限流计数 |
| `pwd_err_cnt:{user}` | String | 按配置 | 失败时 | 密码错误计数 |
| `nursingLevel:all` | String(JSON) | 永不过期 | 首次查询 | 护理等级 |
| `iot:all_product_list` | String(JSON) | 永不过期 | 同步时 | IoT 设备产品 |

---

## 第四批：高级架构与 DevOps（25~32）

### 25 — 代码生成器架构图

![25-code-generator](D:/code/codeJava/heima-phase4/zznursing/docs/graph/25-code-generator.png)

**概述：** 代码生成器的四层架构图，展示从数据库表读取到代码生成的完整流水线。

**四层架构：**
- **模板层（Velocity）：** Controller、Service、ServiceImpl、Mapper、Mapper.xml、Domain、页面模板（index.vue、add-edit 表单）
- **配置层：** 生成器配置（包路径、模块名、作者）、类型映射（数据库类型 → Java 类型）、模板路径
- **核心引擎（GenController → GenServiceImpl）：** 读取表结构 → 解析列元数据 → 应用类型映射 → 填充模板 → 打包为 ZIP
- **数据源：** MySQL `information_schema.TABLES/COLUMNS`

**生成流程：**
1. `GET /tool/gen` 查询 `gen_table`，展示可生成的表列表
2. 导入表：读取 `information_schema`，分析字段名、类型、注释、主键、索引
3. 配置生成选项：是否支持 CRUD、树形结构、编辑字段、列表字段、查询字段
4. 生成：Velocity 模板引擎填充数据，生成 Java + HTML 文件
5. 打包为 ZIP 下载

---

### 26 — 前端 Vuex + 路由架构图

![26-frontend-architecture](D:/code/codeJava/heima-phase4/zznursing/docs/graph/26-frontend-architecture.png)

**概述：** 前端 Vue + Vuex + Router 的架构图，展示状态管理和路由系统的组织方式。

**Vuex 模块：**
- **app.js：** 侧边栏状态（打开/关闭）、设备类型（mobile/desktop）
- **user.js：** Token、用户信息、角色列表、权限标识列表
- **settings.js：** 主题、侧边栏风格、固定头部、TagsView 开关
- **tagsView.js：** 已打开页面标签（标注活跃、缓存）

**Router 模块：**
- 静态路由：`/login`、`/register`、`/404`
- 动态路由：根据后端 `/getRouters` 返回的菜单树动态加载组件
- 组件引用转换：后端返回 `"system/user/index"` → 前端 `() => import('@/views/system/user/index')`

**导航守卫：** `router.beforeEach` 检查登录状态、获取用户信息、动态添加路由

---

### 27 — 限流器 AOP 时序图（Redis Lua）

![27-rate-limiter-flow](D:/code/codeJava/heima-phase4/zznursing/docs/graph/27-rate-limiter-flow.png)

**概述：** 基于 Redis Lua 脚本实现的高性能限流器时序流程，支持 IP 和用户级别的限流。

**核心机制：**
1. `@RateLimiter(time=10, count=5, limitType=IP)` 标注在 Controller 方法上
2. `RateLimiterAspect` 使用 `@Around` 环绕通知拦截请求
3. 构造限流键：`rate_limit:{userId/IP}:{className.methodName}`
4. 执行 Redis Lua 脚本：
   - 检查键是否存在，不存在则创建并设置过期时间
   - 原子递增计数器
   - 如果当前计数 > 限流阈值，返回 0（拒接）
   - 否则返回 1（放行）
5. Lua 脚本保证原子性，避免竞态条件
6. 限流器不支持批量操作的（如导出），会自动降级

---

### 28 — 主从数据源切换组件图（Druid + DynamicDataSource）

![28-datasource-switch](D:/code/codeJava/heima-phase4/zznursing/docs/graph/28-datasource-switch.png)

**概述：** 基于 Druid 连接池和 DynamicDataSource 的主从数据源切换机制图解。

**组件结构：**
- **DruidConfig：** 配置两台 Druid 数据源（master + slave），设置连接池参数
- **DynamicDataSource：** 继承 `AbstractRoutingDataSource`，通过 `@DataSource("slave")` 注解切换
- **DataSourceAspect：** `@Around` 环绕通知，解析 `@DataSource` 注解值，设置 `DynamicDataSourceContextHolder` 的 ThreadLocal
- **Druid 监控：** 内置 Druid StatViewServlet 和 WebStatFilter，支持 SQL 监控和慢查询日志

**切换逻辑：**
- 默认使用 master 数据源
- Service 方法标注 `@DataSource("slave")` 时切换到从库（读操作）
- 写操作始终使用主库

---

### 29 — 动态路由生成时序图

![29-dynamic-route](D:/code/codeJava/heima-phase4/zznursing/docs/graph/29-dynamic-route.png)

**概述：** 后端动态路由生成的时序流程，展示用户登录后如何根据权限动态构建菜单树。

**核心流程：**
1. 用户登录成功后，前端调用 `getInfo` 获取用户信息和权限标识
2. 前端调用 `getRouters` 请求可访问的菜单树
3. `SysMenuController` 调用 `MenuService.selectMenuTreeByUserId()`
4. 服务层递归查询：根据用户 ID 查出角色，根据角色查出菜单，构建父子层级
5. 前端将菜单树转换为 Vue Router 路由：component 字符串（如 `"system/user/index"`）动态导入对应的 Vue 组件
6. `router.addRoutes(accessRoutes)` 动态添加路由

---

### 30 — Jenkins CI/CD 流水线活动图

![30-cicd-pipeline](D:/code/codeJava/heima-phase4/zznursing/docs/graph/30-cicd-pipeline.png)

**概述：** Jenkins 参数化构建的完整 CI/CD 流水线活动图，展示从 Git 代码拉取到 Docker 容器部署的全过程。

**流水线阶段：**
1. **参数化构建：** 选择部署分支、是否清除数据、是否备份数据库、是否推送 Docker 镜像
2. **代码拉取：** 从 Git 仓库检出指定分支代码
3. **Maven 构建：** `mvn clean package -DskipTests`
4. **Docker 镜像构建和推送：** 根据参数决定是否推送到镜像仓库
5. **部署：** SSH 到目标服务器，停止旧容器，启动新容器映射 8080 端口
6. **健康检查：** 检查应用是否正常启动

---

### 31 — 全局异常处理类图

![31-global-exception](D:/code/codeJava/heima-phase4/zznursing/docs/graph/31-global-exception.png)

**概述：** 全局异常处理机制的类图，展示 12 种业务异常和 `@RestControllerAdvice` 的统一处理策略。

**异常分类：**
- **HTTP 状态映射：** `BaseException`（通用业务异常）、`CaptchaException`（验证码错误）、`CaptchaExpireException`（验证码过期）、`UserPasswordNotMatchException`（密码错误）、`UserNotExistsException`（用户不存在）、`UserPasswordRetryLimitException`（密码重试超限）
- **文件异常：** `FileSizeLimitExceededException`、`FileNameLengthLimitExceededException`、`InvalidExtensionException`
- **工具异常：** `UtilException`、`DemoModeException`、`ServiceException`

**处理策略：**
- `GlobalExceptionHandler` 使用 `@RestControllerAdvice` 统一拦截
- 每个异常类型对应一个 `@ExceptionHandler` 方法
- 安全过滤：生产环境不向客户端暴露详细错误堆栈
- 统一封装为 `AjaxResult` 返回

---

### 32 — 华为云 IoT 集成架构图

![32-huawei-iot-integration](D:/code/codeJava/heima-phase4/zznursing/docs/graph/32-huawei-iot-integration.png)

**概述：** 华为云 IoT 平台与系统的集成架构全景图，展示设备数据从采集到存储的端到端链路。

**架构层次：**
- **设备层：** 床垫传感器、门窗传感器、紧急按钮等终端设备（通过 Wi-Fi/4G/ZigBee 连接）
- **华为云 IoTDA：** 设备接入服务，支持 MQTT/CoAP/HTTP 协议，管理设备连接、数据路由、规则引擎
- **系统接入层：** `AmqpClient` 通过 AMQP 1.0 协议消费设备上报消息，`DeviceController` 通过 REST API 管理设备和产品，`DeviceDataService` 存储设备数据到 `device_data` 表
- **业务应用层：** `DeviceDataController` 提供分页查询，`AlertRuleController` 管理报警规则，`AlertRuleEngine` 评估报警规则产生报警

---

## 第五批：基础设施与工具（33~40）

### 33 — BaseController + PageHelper 分页查询时序图

![33-basecontroller-pagination](D:/code/codeJava/heima-phase4/zznursing/docs/graph/33-basecontroller-pagination.png)

**概述：** 展示基于 BaseController 和 PageHelper 的分页查询完整时序，包括参数读取、排序、COUNT 查询、结果封装和清理。

**核心流程：**
1. Controller 调用 `BaseController.startPage()`，通过 `TableSupport.buildPageRequest()` 从 `HttpServletRequest` 读取 pageNum、pageSize、orderByColumn、isAsc、reasonable 参数
2. `PageHelper.startPage()` 通过 ThreadLocal 设置分页参数
3. `BaseController.startOrderBy()` 调用 `SqlUtil.escapeOrderBySql()` 进行 SQL 注入过滤，只允许字母/数字/下划线/空格
4. Service 执行 Mapper 查询，PageHelper 自动拦截第一个 MyBatis 查询，改写 SQL 添加 LIMIT + COUNT 两条语句
5. Controller 调用 `BaseController.getDataTable(list)`，通过 `PageInfo` 获取 total 和 pageNum，封装到 `TableDataInfo`
6. `clearPage()` 清理 ThreadLocal

---

### 34 — Axios 请求/响应拦截器活动图

![34-axios-interceptors](D:/code/codeJava/heima-phase4/zznursing/docs/graph/34-axios-interceptors.png)

**描述：** 前端 Axios 拦截器处理请求和响应的活动图，展示 Token 注入、重复提交防范、错误处理的完整逻辑。

**请求拦截处理：**
- Token 注入：从 store 获取 token，添加到 Authorization: Bearer 头
- GET 参数序列化：`tansParams()` 将对象转为 URL 查询字符串
- 重复提交防范：基于 `{url}+{data}+{时间}` 计算指纹，1 秒内同一请求拦截
- 大数据跳过重复检测（>5MB）

**响应拦截处理：**
- 二进制响应直接返回 blob/arraybuffer
- 401 状态码 → 弹出确认框"登录状态已过期" → 确认后退出登录 → 跳转首页
- 500 状态码 → `Message.error(errMsg)`
- 业务错误码 601 → `Message.warning(msg)`
- 其他错误码 → `Notification.error(msg)`
- 200 正常返回 `response.data`

---

### 35 — 前端布局组件结构图

![35-frontend-layout](D:/code/codeJava/heima-phase4/zznursing/docs/graph/35-frontend-layout.png)

**描述：** Vue 前端页面布局的组件树结构，展示 Layout 主布局的五大区域及其子组件。

**五大区域：**
- **Sidebar（侧边栏）：** Logo → SidebarItem（递归渲染子菜单）→ Link 菜单链接
- **Navbar（顶栏）：** Hamburger（折叠按钮）→ Breadcrumb（面包屑）→ HeaderSearch（全局搜索）→ Screenfull（全屏）→ SizeSelect（尺寸选择）→ Avatar（用户头像）
- **TagsView（标签页）：** ScrollPane（滚动容器）→ Tag（标签页）→ ContextMenu（右键菜单：关闭/刷新/关闭其他）
- **AppMain（主内容区）：** router-view（路由视图）→ IframeToggle（内嵌 iframe 页面）
- **Settings（主题设置面板）：** 主题颜色、侧边栏风格、TagsView 开关、固定头部、侧边栏 Logo

**响应状态：** Vuex 管理的 `sidebar.opened`、`sidebar.hide`、`device`（mobile/desktop）、settings 系列配置项。移动端 Sidebar 作为 Drawer 弹出。

---

### 36 — 前端路由导航守卫活动图

![36-frontend-navigation-guard](D:/code/codeJava/heima-phase4/zznursing/docs/graph/36-frontend-navigation-guard.png)

**描述：** Vue Router `beforeEach` 导航守卫的执行逻辑活动图，展示权限检查和动态路由加载的完整流程。

**核心逻辑：**
1. 获取 token 和 roles
2. **Token 存在：**
   - 如果访问 `/login` → 已登录跳转首页
   - 如果 roles 为空（首次加载）→ dispatch `GetInfo` 获取用户信息和权限列表 → dispatch `GenerateRoutes` 调用 `/getRouters` 获取菜单树 → `router.addRoutes(accessRoutes)` 动态添加路由 → `next({...to, replace: true})` 重新导航
   - 否则正常放行
3. **Token 不存在：** 检查路由在白名单（`/login`、`/register`）→ 放行或重定向到登录页
4. `afterEach` 触发时调用 `NProgress.done()` 结束进度条

---

### 37 — Excel 工具类架构图

![37-excel-util-architecture](D:/code/codeJava/heima-phase4/zznursing/docs/graph/37-excel-util-architecture.png)

**描述：** 基于 Apache POI 的通用 Excel 工具类 `ExcelUtil<T>` 架构图，展示注解驱动的导出/导入机制。

**`@Excel` 注解属性：** name（列名）、sort（排序）、dateFormat（日期格式）、dictType（字典类型自动转换）、readConverterExp（读取转换表达式）、cellType（单元格类型）、width（列宽）、isStatistics（统计行）、isImport/Export（导入导出开关）、align（对齐方式）、height（行高）、prompt（提示信息）、combo（下拉框）、targetAttr（多级字段解析）、image（图片导出）

**核心能力：**
- 字典值自动转换：导出时 value→label，导入时 label→value
- 公式注入防护：检测以 `= - + @` 开头的单元格值，自动加前缀
- 图片导出：通过 `@Excel(image=true)` 将字段值作为图片路径嵌入单元格
- 统计行：自动计算合计值
- 多级字段解析：支持 `order.user.name` 格式

---

### 38 — 线程池架构图

![38-thread-pool-architecture](D:/code/codeJava/heima-phase4/zznursing/docs/graph/38-thread-pool-architecture.png)

**描述：** 系统两种线程池的架构图，展示主线程池和定时任务线程池的配置参数和使用场景。

**主线程池（`threadPoolTaskExecutor`）：**
- corePoolSize=50，maxPoolSize=200，queueCapacity=1000
- keepAliveSeconds=300，CallerRunsPolicy 拒绝策略
- 任务提交流程：核心线程 → 阻塞队列 → 扩到最大 → 提交者线程执行

**定时任务线程池（`ScheduledExecutorService`）：**
- Daemon=true，命名模式 `schedule-pool-%d`
- `afterExecute()` 自动打印异常堆栈
- CallerRunsPolicy 拒绝策略

**使用场景：**
- 操作日志异步记录（`AsyncFactory.recordOper`）
- 登录日志异步记录（`AsyncFactory.recordLogininfor`）
- IoT 消息推送（`AmqpClient.executorService`）
- `@Async` 注解异步方法
- `@Scheduled` 定时任务

**优雅关闭：** `ShutdownManager` 在 `@PreDestroy` 时调用 `shutdownAndAwaitTermination()` 优雅关闭线程池

---

### 39 — Swagger API 文档配置图

![39-swagger-api-config](D:/code/codeJava/heima-phase4/zznursing/docs/graph/39-swagger-api-config.png)

**描述：** Swagger/OpenAPI 3.0 的配置结构图，展示 Docket Bean 的构建方式和 API 文档生成策略。

**配置组件：**
- **Docket Bean：** OpenAPI 3.0（OAS_30），标题"中州养老系统_接口文档"，版本 3.8.9
- **API 筛选：** 启用 `@ApiOperation` 注解扫描，路径 `PathSelectors.any()`
- **安全方案：** ApiKey（Authorization Header），全局 SecurityContext 要求全部路径认证
- **外部配置：** `swagger.enabled` 控制开关，`swagger.pathMapping` 设置路径前缀（`/dev-api`）
- **前端访问：** zzyl-ui 中 `/tool/swagger` 内嵌页面，访问 URL 为 `/swagger-ui.html`

---

### 40 — 部署脚本架构图

![40-deployment-scripts](D:/code/codeJava/heima-phase4/zznursing/docs/graph/40-deployment-scripts.png)

**描述：** Linux（`ry.sh`）和 Windows（`ry.bat`）部署脚本架构对比图，展示 JVM 参数和部署命令。

**JVM 参数：**
- 堆内存：`-Xms512m -Xmx1024m`
- 元空间：`-XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=512m`
- GC 策略：`-XX:+UseParallelGC -XX:+UseParallelOldGC`
- 新生代：`-XX:NewRatio=1 -XX:SurvivorRatio=30`
- OOM 自动 Dump：`-XX:+HeapDumpOnOutOfMemoryError`
- 时区：`-Duser.timezone=Asia/Shanghai`

**管理命令：** start（启动）、stop（停止）、restart（重启）、status（查看状态）
- Linux：`nohup java -jar &` / `kill -TERM` 优雅关闭
- Windows：`javaw` 静默启动 / `taskkill /f` 强制终止

**Docker 部署：** 基础镜像 `openjdk:11.0-jre-buster`，`EXPOSE 8080`，`java -jar /app.jar`

---

## 第六批：技术体系深度解析（41~48）

### 41 — Maven 模块层级与依赖关系图

![41-maven-module-hierarchy](D:/code/codeJava/heima-phase4/zznursing/docs/graph/41-maven-module-hierarchy.png)

**描述：** 完整的 Maven 模块依赖层次图，展示四层架构和 16 个核心外部依赖库的版本信息。

**四层架构：**
- **应用入口层：** zzyl-admin（Web 服务入口，`spring-boot-maven-plugin` 打包）
- **核心业务层：** zzyl-nursing-platform（16 Controller 19 Mapper）、zzyl-quartz（Quartz 调度）、zzyl-generator（代码生成器）
- **中间层：** zzyl-framework（Security/JWT/AOP/Redis）、zzyl-oss（阿里云 OSS）、zzyl-system（RBAC 权限）
- **基础层：** zzyl-common（零内部依赖，携带有用工具）

**外部依赖版本矩阵（16 个）：** Spring Boot 2.5.15、Spring Security 5.7.12、MyBatis-Plus 3.5.2、Redis、MySQL（Druid 1.2.23）、Huawei IoTDA 3.1.76、Baidu Qianfan、Aliyun OSS 3.17.4、Quartz、PageHelper 1.4.7、Knife4j 3.0.3、OKHttp 4.12.0、FastJSON 2.0.53、Lombok 1.18.22、Hutool 5.8.10、Apache POI 4.1.2

---

### 42 — MyBatis-Plus 拦截器链图

![42-mybatisplus-interceptors](D:/code/codeJava/heima-phase4/zznursing/docs/graph/42-mybatisplus-interceptors.png)

**描述：** MyBatis-Plus 拦截器链组件图，展示三个内置拦截器和 MetaObjectHandler 自动字段填充的工作机制。

**三个拦截器：**
- **PaginationInnerInterceptor：** 物理分页，自动检测 MySQL 方言，`setMaxLimit(-1)` 不限
- **OptimisticLockerInnerInterceptor：** 乐观锁，配合 `@Version` 注解（项目中尚未使用 `@Version`）
- **BlockAttackInnerInterceptor：** 防全表操作，拦截不带 WHERE 条件的 UPDATE/DELETE 语句

**MetaObjectHandler（`MyMetaObjectHandler`）：**
- `insertFill`：自动填充 `createTime=new Date()`、`createBy=当前用户ID`（排除 `/member/**` 请求）
- `updateFill`：自动填充 `updateTime=new Date()`、`updateBy=当前用户ID`（排除 `/member/**` 请求）

**YAML 配置：** `typeAliasesPackage=com.zzyl.**.domain`、`mapperLocations=classpath*:mapper/**/*Mapper.xml`、`id-type=auto`、`map-underscore-to-camel=true`

---

### 43 — Logback 日志架构图

![43-logback-architecture](D:/code/codeJava/heima-phase4/zznursing/docs/graph/43-logback-architecture.png)

**描述：** 基于 `logback.xml` 的日志架构组件图，展示四个 Appender 及其过滤规则和滚动策略。

**日志模式：** `%d{HH:mm:ss.SSS} [%thread] %-5level %logger{20} - [%method,%line] - %msg%n`

**四个 Appender：**
- **console：** `ConsoleAppender`，无过滤，输出到标准输出
- **file_info：** `RollingFileAppender`，`sys-info.log`，`LevelFilter` 仅接受 INFO 级别，每日滚动保留 60 天
- **file_error：** `RollingFileAppender`，`sys-error.log`，`LevelFilter` 仅接受 ERROR 级别，每日滚动保留 60 天
- **sys-user：** `RollingFileAppender`，`sys-user.log`，无级别过滤，记录用户访问日志

**Logger 定义：** `com.zzyl` 默认 INFO（yml 覆盖为 DEBUG）、`org.springframework` WARN、`sys-user` INFO

**日志路径：** `/home/ruoyi/logs`（硬编码 Linux 路径），无异步 Appender，仅时间滚动（无大小限制）

---

### 44 — IP 地址解析与在线用户追踪活动图

![44-ip-resolution-flow](D:/code/codeJava/heima-phase4/zznursing/docs/graph/44-ip-resolution-flow.png)

**描述：** 完整的 IP 地址解析链路和在线用户追踪活动图，展示从请求头提取 IP 到 Redis 会话管理的完整流程。

**IP 获取六层回退（`IpUtils.getIpAddr()`）：**
1. `x-forwarded-for` 头
2. `Proxy-Client-IP` 头
3. `X-Forwarded-For` 头
4. `WL-Proxy-Client-IP` 头
5. `X-Real-IP` 头
6. `request.getRemoteAddr()`（回退）

**地理定位（`AddressUtils.getRealAddressByIP()`）：**
- 检测内网 IP（`10.x`、`172.16-31.x`、`192.168.x`、`127.x`）→ 返回"内网IP"
- 调用 `whois.pconline.com.cn` 在线 API（默认禁用，由 `ruoyi.addressEnabled` 控制）
- 解析 JSON 提取 `pro`（省份）和 `city`（城市）

**设备解析（UserAgentUtils）：** 使用 Bitwalker 库解析 `User-Agent` 请求头，提取浏览器名称和操作系统

**在线用户追踪：** `LoginUser` 存储在 Redis `login_tokens:{uuid}`，TTL 30 分钟；`SysUserOnlineController` 扫描 Redis 查出在线用户，支持按 IP/用户名筛选和强制下线

---

### 45 — AI 健康评估（体检报告解析）时序图

![45-ai-health-assessment-flow](D:/code/codeJava/heima-phase4/zznursing/docs/graph/45-ai-health-assessment-flow.png)

**描述：** 健康评估模块中 AI 分析体检报告 PDF 的完整时序流程，展示 PDF 解析、Redis 缓存、AI 调用和结果解析的详细步骤。

**流程步骤：**
1. **PDF 上传：** `POST /nursing/healthAssessment/upload`，用户上传 PDF 文件和身份证号，`PDFUtil.pdfToString()`（PDFBox）提取文本，存入 Redis `healthReport:{idCardNo}`，TTL 24 小时
2. **提交评估：** `POST /nursing/healthAssessment`，用户填写姓名、性别、年龄、身份证号，系统构造 AI Prompt（包含系统角色"资深全科医生"、用户信息、体检报告全文）
3. **AI 调用：** `AIModelInvoker.chatCompletion()` 通过 OpenAI 兼容接口调用百度千帆 Ernie 5.0
4. **结果解析：** AI 返回结构化 JSON，包含 healthIndex（0-100）、riskLevel（五级）、riskDistribution（风险分布%）、SystemScore（八大系统评分）、abnormalData（异常指标）
5. **等级推荐：** ≥85→四级护理、≥70→三级、≥55→二级、≥40→一级、<40→特级，同时给出是否建议入住

---

### 46 — 护士-老人关联分配活动图

![46-nurse-elder-assignment](D:/code/codeJava/heima-phase4/zznursing/docs/graph/46-nurse-elder-assignment.png)

**描述：** 护士-老人关联分配的活动图，展示按楼层和按房间两种分配方式。

**两种分配方式：**
- **按楼层：** 通过 `FloorController.getRoomsWithNurByFloorId()` 获取该楼层下所有房间及负责护士，展示房间-护士关系
- **按房间：** 通过 `RoomController.getRoomsByFloorId()` 展示房间列表，选择目标房间

**分配机制：** `NursingElderController.setNursing()` 执行全量替换（先删除旧关联再批量插入新关联），支持一个护士负责多个老人、一个老人关联多个护士（不同班次）

---

### 47 — IoT 报警规则引擎组件图

![47-iot-alert-rule-engine](D:/code/codeJava/heima-phase4/zznursing/docs/graph/47-iot-alert-rule-engine.png)

**描述：** IoT 报警规则引擎的组件图，展示六步评估链和规则配置模型。

**AlertRule 实体字段：** alertType（0=老人异常/1=设备异常）、productId/moduleId/functionId（绑定设备属性）、operator（> </=）、value（阈值）、duration（持续周期数）、alertEffectivePeriod（生效时段）、alertSilentPeriod（静默分钟）、status（0=禁用/1=启用）

**六步评估链：**
1. 加载启用规则，匹配设备 product
2. 检查上报属性是否匹配 functionId
3. 比较上报值与阈值
4. 连续 duration 次触发才算报警
5. 当前时间在生效时段内
6. 距上次报警超过静默期

**数据源：** AMQP 消费者实时接收 + Quartz 定时扫描

---

### 48 — 楼层/房间/床位树形结构类图

![48-room-bed-floor-tree](D:/code/codeJava/heima-phase4/zznursing/docs/graph/48-room-bed-floor-tree.png)

**描述：** 楼层→房间→床位三级位置体系的类图，展示各实体间的关联关系和树形查询方法。

**实体关系：** Floor（1）→ Room（N）→ Bed（N），Room → RoomType（N:1），Bed → Elder（1:1），Elder → NursingElder（1:N），Room → Device（1:N）

**树形查询方法：**
- `getRoomAndBedByBedStatus(status)`：按床位状态（0=未占用/1=已占用）递归楼层→房间→床位树，用于入住选房
- `getRoomsWithNurByFloorId(floorId)`：获取指定楼层房间及护理员
- `getRoomsWithDeviceByFloorId(floorId)`：获取指定楼层房间及 IoT 设备
- `getAllFloorsWithNur()` / `getAllFloorsWithDevice()`：带关联数据获取全部楼层

---

## 第七批：运维与附加功能（49~56）

### 49 — 验证码生成与校验时序图

![49-captcha-flow](D:/code/codeJava/heima-phase4/zznursing/docs/graph/49-captcha-flow.png)

**描述：** 基于 Google Kaptcha 库的验证码生成与校验完整时序流程，展示双模式验证码和 Redis 缓存校验机制。

**双模式配置：**
- **字符模式（captchaProducer）：** 宽 160 × 高 60，字体大小 38，4 位随机字符，ShadowGimpy 风格
- **数学模式（captchaProducerMath）：** 宽 160 × 高 60，字体大小 35，自定义算式生成器（加减乘随机混合），返回结果数字

**验证流程：**
1. 前端请求 `GET /captchaImage`，系统生成 UUID，根据配置的 `captchaType`（math/char）生成验证码图片
2. 答案存储到 Redis `captcha_codes:{uuid}`，TTL 2 分钟（`Constants.CAPTCHA_EXPIRATION`）
3. 返回 JSON：`{uuid, img(base64编码), captchaEnabled}`
4. 登录/注册时用户提交 `uuid` 和 `code`，系统从 Redis 取出答案比较，验证后立即删除（一次性使用）
5. 支持全局限流开关（`sys.account.captchaEnabled`），可一键关闭验证码

---

### 50 — 通用文件上传下载活动图

![50-file-upload-download](D:/code/codeJava/heima-phase4/zznursing/docs/graph/50-file-upload-download.png)

**描述：** `CommonController` 通用文件上传下载的活动图，展示四种文件操作路径及其安全校验规则。

**四种操作路径：**
- **单文件上传（`POST /common/upload`）：** 50MB 大小校验 → 文件名 100 字符校验 → 扩展名白名单校验 → `AliyunOSSOperator.upload()` 上传到阿里云 OSS（路径格式：`bucket/yyyy/MM/UUID.ext`）→ 返回 OSS URL
- **多文件上传（`POST /common/uploads`）：** 遍历文件列表 → 本地存储（路径：`{profile}/upload/yyyymmdd/name_seq.ext`）→ 拼接本地 URL
- **文件下载（`GET /common/download`）：** 下载安全校验 → 从 `{profile}/download/` 读取 → 支持可选删除
- **资源下载（`GET /common/download/resource`）：** 从 `{profile}/` 下载资源文件

---

### 51 — 服务器与缓存监控组件图

![51-server-cache-monitor](D:/code/codeJava/heima-phase4/zznursing/docs/graph/51-server-cache-monitor.png)

**描述：** 基于 OSHI 库的服务器监控和基于 RedisTemplate 的缓存监控组件图，展示监控数据采集和管理操作。

**服务器监控（OSHI）五维数据：**
- **CPU：** 逻辑核心数、sys/used/wait/free 百分比（两次采样计算差值）
- **内存：** total/used/free 字节数、使用百分比
- **JVM：** total/max/free 内存、JDK 版本、启动时间、运行时参数
- **系统：** 主机名、IP、操作系统名称/架构、用户目录
- **磁盘：** 每个挂载点的类型、total/free/used%

**缓存监控七类：** `login_tokens`、`sys_config`、`sys_dict`、`captcha_codes`、`repeat_submit`、`rate_limit`、`pwd_err_cnt`

**缓存操作：** 按前缀查询键列表、读取键值、按前缀清除、单键删除、清空全部（高危操作！）

---

### 52 — 字典管理数据流图

![52-dict-management-flow](D:/code/codeJava/heima-phase4/zznursing/docs/graph/52-dict-management-flow.png)

**描述：** 字典管理（类型+数据两级）的完整数据流组件图，展示缓存预热、读写回填、值转换的全过程。

**两级数据结构：**
- `SysDictType`：dictId、dictName、dictType、status、remark
- `SysDictData`：dictCode、dictSort、dictLabel、dictValue、dictType、cssClass、listClass、isDefault、status

**缓存策略：**
- 启动时 `@PostConstruct init()` 查询所有启用（status=0）的字典数据，按 dictType 分组排序后批量存入 Redis
- 首次查询时缓存未命中→回表查询数据库→自动回填 Redis
- 字典数据发生 CRUD 操作时清除全部字典缓存（`clearDictCache`）
- 工具类 `DictUtils` 提供 `getDictLabel(type, value)`（值转标签）、`getDictValue(type, label)`（标签转值）等便捷方法

---

### 53 — Quartz 定时任务动态调度组件图

![53-quartz-dynamic-scheduling](D:/code/codeJava/heima-phase4/zznursing/docs/graph/53-quartz-dynamic-scheduling.png)

**描述：** Quartz 定时任务动态调度的完整组件图，展示从任务 CRUD 到反射执行的完整链路。

**核心组件链：**
- `SysJobController` → `SysJobServiceImpl`（DB + Scheduler 双重操作）→ `ScheduleUtils.createScheduleJob()` 创建 JobDetail + CronTrigger
- 基于 `invokeTarget` 字符串自动选择执行类：`concurrent=0` → `QuartzJobExecution`（允许并发）、`concurrent=1` → `QuartzDisallowConcurrentExecution`（禁止并发 + `@DisallowConcurrentExecution`）
- `AbstractQuartzJob` 提供模板方法：`before()`（记录开始时间）→ `doExecute()`（业务逻辑）→ `after()`（自动记录 `SysJobLog`）
- `JobInvokeUtil.invokeMethod()` 使用反射解析 `beanName.method(params)` 或 `com.xxx.Class.method(params)`，自动推断参数类型（String/Boolean/Long/Double/Integer）

**安全管理：** 启动时 `scheduler.clear()` + 重新加载全部任务；禁止 `rmi://`、`ldap://`、`http://` 协议调用；白名单包路径验证

---

### 54 — 启动初始化预热活动图

![54-startup-initialization](D:/code/codeJava/heima-phase4/zznursing/docs/graph/54-startup-initialization.png)

**描述：** 应用启动时的三阶段初始化预热活动图，展示 @PostConstruct 数据预热、ApplicationRunner IoT 连接启动和首次请求懒加载。

**三阶段初始化：**
1. **@PostConstruct 数据预热：**
   - `SysDictTypeServiceImpl.init()` — 加载所有启用字典数据到 Redis
   - `SysConfigServiceImpl.init()` — 加载所有系统配置参数到 Redis
   - `SysJobServiceImpl.init()` — 清空 Quartz Scheduler，重新注册全部定时任务
2. **ApplicationRunner IoT 连接：** `AmqpClient.run()` 建立多条 AMQPS 连接到华为云 IoTDA，配置 failover 重连机制，注册 MessageListener，启动线程池处理设备消息
3. **首次请求懒加载：** 用户首次访问时，缓存未命中自动回填，业务数据（如护理等级、护理项目等）按需加载到 Redis

---

### 55 — 前端权限指令实现原理图

![55-frontend-permission-directive](D:/code/codeJava/heima-phase4/zznursing/docs/graph/55-frontend-permission-directive.png)

**描述：** 前端权限指令 `v-hasPermi` 和 `v-hasRole` 的实现原理组件图，展示从 Vuex 数据流到 DOM 控制的完整路径。

**权限数据流：**
1. 用户登录成功后，后端 API `/getInfo` 返回用户角色列表（`roles: ["admin"]`）和权限标识列表（`permissions: ["system:user:list"]`）
2. Vuex store（`user.js`）通过 `SET_ROLES` 和 `SET_PERMISSIONS` 突变保存
3. `getters.js` 提供 `roles` 和 `permissions` 导出
4. 指令在 `inserted` 钩子中读取 Vuex 数据，检查是否包含任一所需标识或超级管理员（`*:*:*` 通配符 / `admin` 角色）
5. 权限不足时使用 `el.parentNode.removeChild(el)` 直接移除 DOM 元素（完全隐藏，而非 disable）

**双层安全模型：**
- 前端控制 UI 显示/隐藏（`v-hasPermi` / `v-hasRole`）
- 后端 `@PreAuthorize("@ss.hasPermi('xxx')")` 控制 API 访问

**使用场景：** 按钮级（新增用户）、面板级（管理员面板）、表格列级（编辑操作）

---

### 56 — 用户注册流程时序图

![56-user-registration-flow](D:/code/codeJava/heima-phase4/zznursing/docs/graph/56-user-registration-flow.png)

**描述：** 用户注册的完整时序流程，展示从获取验证码到注册成功的六步验证链路。

**六步验证链路：**
1. **验证码获取：** 前端请求 `/captchaImage` 获取验证码图片和 UUID
2. **注册开关检查：** 查询 `sys_config` 键 `sys.account.registerUser`，未开启时立即返回错误
3. **验证码校验：** 从 Redis 取 `captcha_codes:{uuid}` 比较，单次使用，校验后立即删除
4. **用户名/密码校验：** 非空检查 + 长度检查（用户名 2-20 字符、密码 5-20 字符）
5. **用户名唯一性：** 调用 `userService.checkUserNameUnique(username)` 防止重复注册
6. **用户创建：** 密码使用 `SecurityUtils.encryptPassword()`（BCrypt）加密，执行 `INSERT INTO sys_user`，异步记录注册日志

---

## 附录：图类型统计

| 图类型 | 数量 | 图编号 |
|--------|------|--------|
| 时序图 | 12 | 06, 09, 13, 18, 19, 27, 29, 33, 45, 49, 56, plus 其他混合 |
| 活动图 | 12 | 05, 11, 16, 20, 22, 30, 34, 36, 44, 46, 50, 54 |
| 组件图 | 12 | 15, 17, 23, 25, 28, 32, 35, 37, 39, 47, 51, 55 |
| 类图 | 6 | 03, 08, 14, 21, 31, 48 |
| 结构/架构图 | 6 | 01, 02, 07, 24, 26, 41 |
| 状态机图 | 2 | 10, 21 |
| 用例图 | 1 | 04 |
| 部署图 | 1 | 07 |
| 流程图 | 4 | 34, 36, 38, 40 |

**总计：56 张图，112 个文件（.puml 源码 + .png 渲染图）**

**覆盖范围：**
- 项目架构：模块依赖、C4 容器、部署拓扑、Maven 层级
- 认证与安全：登录认证、JWT 过滤链、AOP 操作日志、限流、数据权限、前端权限指令
- 核心业务：入住/退住、健康评估 AI、护理方案、合同管理、护士关联
- IoT集成：华为云 IoTDA 集成、AMQP 数据接入、设备注册、报警规则引擎
- 前端架构：布局组件、Vuex+路由、导航守卫、Axios 拦截器、权限指令
- 基础设施：MyBatis-Plus 拦截器、Quartz 调度、线程池、缓存、日志、Excel 工具
- DevOps：部署脚本、Jenkins CI/CD、Docker 构建、JVM 调优
- 运维监控：服务器监控、缓存监控、在线用户、字典管理、代码生成器
