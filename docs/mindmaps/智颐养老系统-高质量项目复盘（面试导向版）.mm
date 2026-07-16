<map version="1.0.1">
<!-- 智颐养老系统-高质量项目复盘(面试导向版) -->

<node ID="root" TEXT="智颐养老系统-高质量项目复盘(面试导向版)">
    <!-- 项目介绍 -->
    <node ID="intro" TEXT="一、项目一句话介绍" POSITION="right">
        <node TEXT="30秒版本">
            <node TEXT="智颐养老系统是面向养老院场景的综合管理平台"/>
            <node TEXT="包含后台管理端和微信小程序端"/>
            <node TEXT="解决老人入住、护理服务、健康评估、家属登录查询及智能设备接入"/>
            <node TEXT="帮助养老机构提升护理效率、减少人工统计成本"/>
        </node>
        <node TEXT="1分钟版本">
            <node TEXT="技术栈: Spring Boot + Vue + MyBatis-Plus + MySQL + Redis"/>
            <node TEXT="后台管理端: 老人档案、入住办理、护理等级、护理计划、合同、设备管理"/>
            <node TEXT="小程序端: 微信登录、预约、房型查询"/>
            <node TEXT="代表性技术点">
                <node TEXT="健康评估: PDF体检报告+百度千帆大模型结构化分析"/>
                <node TEXT="小程序登录: 微信code获取openid+JWT+ThreadLocal"/>
                <node TEXT="IoT设备接入: 华为云IoTDA+AMQP异步接收设备数据"/>
                <node TEXT="基础性能优化: Redis缓存护理等级、护理计划、IoT产品列表"/>
            </node>
        </node>
    </node>

    <!-- 项目定位与业务价值 -->
    <node ID="value" TEXT="二、项目定位与业务价值" POSITION="right">
        <node TEXT="项目服务对象">
            <node TEXT="后台用户: 养老院管理员、护理员、运营人员"/>
            <node TEXT="前台用户: 老人家属"/>
            <node TEXT="外部系统: 微信开放平台、百度千帆、华为云IoTDA、阿里云OSS"/>
        </node>
        <node TEXT="核心问题">
            <node TEXT="业务层面">
                <node TEXT="传统养老院数据分散"/>
                <node TEXT="家属获取老人健康情况不够及时"/>
                <node TEXT="老人体检报告解读强依赖人工效率低"/>
                <node TEXT="智能设备接入后数据难以汇总"/>
            </node>
            <node TEXT="系统层面">
                <node TEXT="需要统一后台承接入住+护理+健康+设备业务"/>
                <node TEXT="需要前台认证机制支持家属端访问"/>
                <node TEXT="需要把第三方AI和IoT能力接入业务系统"/>
            </node>
        </node>
        <node TEXT="项目业务价值">
            <node TEXT="老人从预约/入住/护理/健康评估/设备监测串成闭环"/>
            <node TEXT="家属可通过小程序查询与预约降低线下沟通成本"/>
            <node TEXT="健康评估从人工经验判断转向AI辅助分析"/>
            <node TEXT="设备上报数据能进入业务系统为预警提供基础"/>
        </node>
    </node>

    <!-- 技术架构总览 -->
    <node ID="arch" TEXT="三、技术架构总览" POSITION="right">
        <node TEXT="技术栈">
            <node TEXT="后端: Spring Boot"/>
            <node TEXT="权限认证: Spring Security、JWT"/>
            <node TEXT="ORM: MyBatis-Plus"/>
            <node TEXT="数据库: MySQL"/>
            <node TEXT="缓存: Redis"/>
            <node TEXT="对象存储: 阿里云OSS"/>
            <node TEXT="AI能力: 百度千帆(OpenAI兼容SDK)"/>
            <node TEXT="IoT能力: 华为云IoTDA"/>
            <node TEXT="消息接收: AMQP"/>
            <node TEXT="前端: Vue2 + Element UI"/>
            <node TEXT="调度: Quartz"/>
        </node>
        <node TEXT="代码模块划分">
            <node TEXT="zzyl-admin: 后台启动入口"/>
            <node TEXT="zzyl-framework: 认证、拦截器、Redis配置、线程池"/>
            <node TEXT="zzyl-common: 公共工具、常量、AI调用封装"/>
            <node TEXT="zzyl-nursing-platform: 养老业务核心模块"/>
            <node TEXT="zzyl-quartz: 定时任务"/>
            <node TEXT="zzyl-oss: 对象存储支持"/>
        </node>
        <node TEXT="面试可直接讲的架构图">
            <node TEXT="家属小程序/后台管理端 → Controller → Service → MyBatis-Plus/Mapper → MySQL+Redis"/>
            <node TEXT="↓"/>
            <node TEXT="微信开放平台 | 百度千帆大模型 | 华为云IoTDA"/>
        </node>
        <node TEXT="为什么这样设计">
            <node TEXT="为什么是单体而不是微服务">
                <node TEXT="业务复杂度处于一个业务域内多模块协同阶段"/>
                <node TEXT="降低部署、联调、事务一致性复杂度"/>
                <node TEXT="养老业务对流程稳定落地优先级高于服务拆分"/>
            </node>
            <node TEXT="为什么用Redis">
                <node TEXT="护理等级、护理项目、护理计划高频读低频写数据"/>
                <node TEXT="IoT产品列表来自第三方云平台没必要每次远程查"/>
                <node TEXT="健康评估PDF文本一次上传多次使用"/>
            </node>
            <node TEXT="为什么用JWT+自定义拦截器">
                <node TEXT="小程序端天然不适合传统Session"/>
                <node TEXT="JWT天然适合无状态认证"/>
                <node TEXT="配合MemberInterceptor+ThreadLocal业务代码方便拿到前台用户ID"/>
            </node>
            <node TEXT="为什么AI调用放在业务服务层">
                <node TEXT="当前业务目标是快速落地体检报告自动分析"/>
                <node TEXT="把AI调用封装成AIModelInvoker避免控制层直接依赖第三方SDK"/>
                <node TEXT="后续替换模型只需调整配置和调用封装层"/>
            </node>
        </node>
    </node>

    <!-- 核心业务流程 -->
    <node ID="flow" TEXT="四、核心业务流程" POSITION="right">
        <node TEXT="老人入住主链路">
            <node TEXT="后台提交入住申请"/>
            <node TEXT="↓"/>
            <node TEXT="校验老人是否已入住"/>
            <node TEXT="↓"/>
            <node TEXT="更新床位状态为已入住"/>
            <node TEXT="↓"/>
            <node TEXT="保存或更新老人档案"/>
            <node TEXT="↓"/>
            <node TEXT="生成合同编号并创建合同"/>
            <node TEXT="↓"/>
            <node TEXT="写入入住记录/入住配置"/>
            <node TEXT="面试表达重点">
                <node TEXT="典型多表业务事务"/>
                <node TEXT="涉及elder、bed、contract、check_in、check_in_config多张表"/>
                <node TEXT="重点是如何保证入住流程数据完整、状态一致"/>
            </node>
        </node>
        <node TEXT="健康评估主链路">
            <node TEXT="上传PDF体检报告"/>
            <node TEXT="↓"/>
            <node TEXT="文件上传到OSS"/>
            <node TEXT="↓"/>
            <node TEXT="PDF解析成文本"/>
            <node TEXT="↓"/>
            <node TEXT="按身份证号写入Redis Hash(24小时过期)"/>
            <node TEXT="↓"/>
            <node TEXT="提交健康评估表单"/>
            <node TEXT="↓"/>
            <node TEXT="拼接Prompt调用百度千帆"/>
            <node TEXT="↓"/>
            <node TEXT="返回结构化JSON"/>
            <node TEXT="↓"/>
            <node TEXT="解析健康分数、风险等级、异常项、建议"/>
            <node TEXT="↓"/>
            <node TEXT="落库保存健康评估结果"/>
            <node TEXT="面试表达重点">
                <node TEXT="核心不是调用了AI而是如何让AI输出能稳定接进业务系统"/>
                <node TEXT="做了三件事: 报告预处理、Prompt约束、结构化落库"/>
            </node>
        </node>
        <node TEXT="小程序登录主链路">
            <node TEXT="小程序发起登录"/>
            <node TEXT="↓"/>
            <node TEXT="前端code换openid"/>
            <node TEXT="↓"/>
            <node TEXT="调用微信接口获取手机号"/>
            <node TEXT="↓"/>
            <node TEXT="查询家属是否已存在"/>
            <node TEXT="↓"/>
            <node TEXT="不存在则自动注册存在则更新手机号"/>
            <node TEXT="↓"/>
            <node TEXT="生成JWT token"/>
            <node TEXT="↓"/>
            <node TEXT="后续请求带token"/>
            <node TEXT="↓"/>
            <node TEXT="拦截器解析token userId放入ThreadLocal"/>
            <node TEXT="↓"/>
            <node TEXT="业务代码读取当前用户ID"/>
        </node>
        <node TEXT="IoT设备接入链路">
            <node TEXT="后台同步产品列表"/>
            <node TEXT="↓"/>
            <node TEXT="Redis缓存IoT产品信息"/>
            <node TEXT="↓"/>
            <node TEXT="后台注册设备"/>
            <node TEXT="↓"/>
            <node TEXT="先校验名称/节点号/绑定位置唯一性"/>
            <node TEXT="↓"/>
            <node TEXT="调用华为云IoTDA创建设备"/>
            <node TEXT="↓"/>
            <node TEXT="本地保存设备信息与密钥"/>
            <node TEXT="↓"/>
            <node TEXT="设备上报数据到IoTDA"/>
            <node TEXT="↓"/>
            <node TEXT="本系统通过AMQP异步消费消息"/>
            <node TEXT="↓"/>
            <node TEXT="解析上报数据并批量入库"/>
        </node>
    </node>

    <!-- 健康评估模块深度分析 -->
    <node ID="health" TEXT="五、健康评估模块(最适合深挖)" POSITION="right">
        <node TEXT="业务背景">
            <node TEXT="养老院接收老人入住前需参考体检报告判断健康状况"/>
            <node TEXT="人工解读问题: 专业门槛高/耗时长/标准不一致"/>
            <node TEXT="目标: 做AI辅助分析工具快速产出结构化健康结论"/>
        </node>
        <node TEXT="实际实现方案">
            <node TEXT="第一步: 上传PDF并做预处理">
                <node TEXT="用户上传体检报告PDF"/>
                <node TEXT="文件先上传到阿里云OSS"/>
                <node TEXT="后端用PDFUtil.pdfToString()将PDF解析成纯文本"/>
                <node TEXT="以healthReport作为Redis Hash Key身份证号作为field"/>
                <node TEXT="TTL设置为24小时"/>
            </node>
            <node TEXT="第二步: 提交评估请求">
                <node TEXT="业务表单里带上老人基本信息尤其是身份证号"/>
                <node TEXT="服务层根据身份证号去Redis中拿到报告文本"/>
                <node TEXT="如果Redis没有数据直接抛业务异常"/>
            </node>
            <node TEXT="第三步: 构造强约束Prompt">
                <node TEXT="明确要求输出: 总检日期/健康评估结果/风险分布/异常数据列表/八大系统评分/总结"/>
                <node TEXT="要求: 只能输出JSON/不要夹带解释性文字/字段名固定"/>
            </node>
            <node TEXT="第四步: AI返回后做结构化落库">
                <node TEXT="AI返回JSON后反序列化成HealthReportVo"/>
                <node TEXT="通过身份证号解析出生日期、年龄、性别"/>
                <node TEXT="取AI生成的健康分数/风险等级"/>
                <node TEXT="根据健康分数映射护理等级名称"/>
                <node TEXT="生成是否建议入住标记"/>
            </node>
        </node>
        <node TEXT="为什么这个设计合理">
            <node TEXT="为什么先把PDF文本放Redis">
                <node TEXT="PDF解析是一次性动作不需要每次重复做"/>
                <node TEXT="上传和提交评估在交互上是两个动作"/>
                <node TEXT="Redis作为临时缓存减少中间状态落库复杂度"/>
            </node>
            <node TEXT="为什么不让前端直接调用AI">
                <node TEXT="体检报告属于敏感数据不能把AI Key暴露给前端"/>
                <node TEXT="后端统一做Prompt、结构校验、异常处理更安全"/>
            </node>
            <node TEXT="为什么用结构化JSON">
                <node TEXT="纯文本很难直接落表"/>
                <node TEXT="前端渲染和后端统计都需要结构化字段"/>
            </node>
        </node>
        <node TEXT="最值得讲的技术点">
            <node TEXT="技术点1: Prompt工程">
                <node TEXT="把业务问题拆成机器可执行的输出协议"/>
                <node TEXT="风险等级枚举化/异常指标列表字段固定化"/>
                <node TEXT="我不是直接把PDF扔给模型而是先把业务需要落库的字段设计出来"/>
            </node>
            <node TEXT="技术点2: AI结果和业务规则结合">
                <node TEXT="AI只负责做认知型分析"/>
                <node TEXT="真正确定性的业务规则还是放在后端"/>
                <node TEXT="根据健康分推导护理等级/根据分数判断是否建议入住"/>
            </node>
            <node TEXT="技术点3: 异常处理清晰">
                <node TEXT="上传后未提交或缓存过期"/>
                <node TEXT="AI调用前找不到报告文本"/>
                <node TEXT="体现工程意识"/>
            </node>
        </node>
        <node TEXT="不足与可优化点">
            <node TEXT="当前不足">
                <node TEXT="Redis Key设计较简单适合当前规模但隔离性一般"/>
                <node TEXT="没有对AI返回JSON做二次字段校验"/>
                <node TEXT="没有做失败重试或降级"/>
            </node>
            <node TEXT="可优化方案">
                <node TEXT="Redis Key改成更细粒度格式health:report:{idCard}"/>
                <node TEXT="对AI返回结果做JSON Schema校验"/>
                <node TEXT="增加重试机制和兜底提示"/>
                <node TEXT="把AI响应时间、失败率纳入监控"/>
            </node>
        </node>
    </node>

    <!-- 小程序登录模块深度分析 -->
    <node ID="login" TEXT="六、小程序登录模块(适合讲认证设计)" POSITION="right">
        <node TEXT="业务背景">
            <node TEXT="系统有后台管理端和家属小程序端"/>
            <node TEXT="小程序端用户体系和后台管理员体系隔离"/>
            <node TEXT="主要难点: 小程序无Cookie/Session/登录第一步是code换openid/首次登录系统无账号"/>
        </node>
        <node TEXT="实际实现流程">
            <node TEXT="第一步: 根据code获取openid">
                <node TEXT="小程序端先拿微信登录code"/>
                <node TEXT="后端调用微信jscode2session接口获取openid"/>
            </node>
            <node TEXT="第二步: 根据手机号补全家属信息">
                <node TEXT="后端再通过微信接口获取用户绑定手机号"/>
                <node TEXT="以openid作为唯一身份标识"/>
                <node TEXT="如果数据库有家属则更新手机号没有则自动创建新用户"/>
            </node>
            <node TEXT="第三步: 生成JWT">
                <node TEXT="把userId、nickName放入claims"/>
                <node TEXT="通过TokenService.createToken()生成JWT"/>
            </node>
            <node TEXT="第四步: 请求拦截与上下文透传">
                <node TEXT="小程序后续请求把token放在请求头authorization中"/>
                <node TEXT="MemberInterceptor在preHandle中解析token"/>
                <node TEXT="取出userId放入UserThreadLocal"/>
                <node TEXT="请求结束后在afterCompletion里执行remove()"/>
            </node>
        </node>
        <node TEXT="最值得讲的技术点">
            <node TEXT="技术点1: 登录即注册">
                <node TEXT="解决小程序用户第一次进来系统没账号的问题"/>
                <node TEXT="降低注册流程复杂度/用户体验更顺滑"/>
            </node>
            <node TEXT="技术点2: ThreadLocal生命周期控制">
                <node TEXT="Tomcat/线程池会复用线程"/>
                <node TEXT="如果不清理前一个请求数据可能串到后一个请求"/>
                <node TEXT="必须在afterCompletion中remove()"/>
            </node>
            <node TEXT="技术点3: 前台接口只拦/member/**">
                <node TEXT="ResourcesConfig里对小程序端接口做单独拦截规则"/>
                <node TEXT="说明理解的是接口级认证边界"/>
            </node>
        </node>
        <node TEXT="可优化点">
            <node TEXT="微信access_token每次实时获取没有本地缓存"/>
            <node TEXT="token里只放了少量字段没有做更完整的前台用户会话治理"/>
            <node TEXT="没有显式做前台token刷新策略"/>
        </node>
    </node>

    <!-- IoT设备接入模块深度分析 -->
    <node ID="iot" TEXT="七、IoT设备接入模块(适合拉开差距)" POSITION="right">
        <node TEXT="业务背景">
            <node TEXT="养老场景接入智能手环、床垫、定位设备"/>
            <node TEXT="系统要做设备管理也要接住设备上报数据"/>
            <node TEXT="真正业务价值: 设备与老人/房间/床位建立绑定关系/平台能实时拿到设备状态和属性"/>
        </node>
        <node TEXT="实际实现内容">
            <node TEXT="功能一: 同步IoT产品列表">
                <node TEXT="后端调用华为云IoTDA的listProducts"/>
                <node TEXT="把产品列表缓存到Redis Key iot:all_product_list"/>
            </node>
            <node TEXT="功能二: 设备注册">
                <node TEXT="三重校验: 设备名称不能重复/nodeId不能重复/同一位置不能绑定同一产品"/>
                <node TEXT="校验通过后调用IoTDA的addDevice创建设备"/>
                <node TEXT="生成设备密钥secret"/>
                <node TEXT="把设备云端ID、本地绑定关系、产品信息一起落库"/>
            </node>
            <node TEXT="功能三: 设备详情与影子数据查询">
                <node TEXT="通过IoTDA查询设备详情"/>
                <node TEXT="获取设备在线状态、激活时间"/>
                <node TEXT="获取设备影子reported属性"/>
            </node>
            <node TEXT="功能四: AMQP异步消费设备上报数据">
                <node TEXT="使用ApplicationRunner在启动时拉起消费者"/>
                <node TEXT="支持多连接配置"/>
                <node TEXT="MessageListener收到消息后提交到线程池异步处理"/>
                <node TEXT="解析notify_data再交给deviceDataService.batchInsertDeviceData()入库"/>
            </node>
        </node>
        <node TEXT="最有价值的讲法">
            <node TEXT="技术点1: 本地业务模型和云端设备模型映射">
                <node TEXT="设备不只是云上有一台设备"/>
                <node TEXT="本地系统还要知道: 属于哪个产品/绑定的是老人还是房间/云端ID和本地业务ID如何关联"/>
            </node>
            <node TEXT="技术点2: 实时数据接入链路">
                <node TEXT="不是只做设备增删改查"/>
                <node TEXT="把IoT平台上报数据通过AMQP拉回到本地系统"/>
                <node TEXT="用异步线程池处理形成完整的数据接入链路"/>
            </node>
            <node TEXT="技术点3: 时区转换">
                <node TEXT="云端返回UTC时间系统做转上海时区处理"/>
                <node TEXT="体现处理第三方平台集成时的工程完整性"/>
            </node>
        </node>
        <node TEXT="不足与改进">
            <node TEXT="设备云端创建成功本地保存失败存在一致性风险"/>
            <node TEXT="产品列表缓存没有过期策略和主动刷新机制"/>
            <node TEXT="上报数据消费缺少幂等控制和重放保护"/>
            <node TEXT="面试推荐主动说的优化方案">
                <node TEXT="设备注册引入补偿逻辑"/>
                <node TEXT="通过消息队列实现最终一致性"/>
                <node TEXT="上报数据增加幂等设计"/>
            </node>
        </node>
    </node>

    <!-- 高频面试问题 -->
    <node ID="qa" TEXT="八、高频面试问题与标准答法" POSITION="right">
        <node TEXT="Q: 介绍一下这个项目？">
            <node TEXT="智颐养老系统面向养老院场景的管理平台"/>
            <node TEXT="分后台管理端和家属小程序端"/>
            <node TEXT="我主要参与健康评估、微信小程序登录、IoT设备接入"/>
            <node TEXT="项目技术栈Spring Boot、MyBatis-Plus、MySQL、Redis"/>
            <node TEXT="对接百度千帆、微信开放平台和华为云IoTDA"/>
        </node>
        <node TEXT="Q: 项目里最有亮点的模块是什么？">
            <node TEXT="第一健康评估模块: PDF体检报告解析后交给AI做结构化分析"/>
            <node TEXT="第二小程序登录模块: 微信登录、JWT和ThreadLocal上下文透传"/>
            <node TEXT="第三IoT设备接入模块: 对接华为云并通过AMQP接收设备上报数据"/>
        </node>
        <node TEXT="Q: Redis在项目里用在哪？">
            <node TEXT="基础框架层: 登录态、限流、防重复提交"/>
            <node TEXT="业务基础数据缓存: 护理等级、护理项目、护理计划"/>
            <node TEXT="第三方产品数据缓存: IoT产品列表"/>
            <node TEXT="AI中间数据缓存: 体检报告PDF解析后的文本按身份证号临时缓存24小时"/>
        </node>
        <node TEXT="Q: 怎么处理缓存一致性？">
            <node TEXT="目前采用读缓存、写数据库、删缓存的旁路缓存方案"/>
            <node TEXT="护理等级、护理计划写频率低这种模式足够简单稳定"/>
            <node TEXT="后续并发增大可考虑延迟双删或消息通知式失效"/>
        </node>
        <node TEXT="Q: 为什么小程序登录要用ThreadLocal？">
            <node TEXT="后续很多业务接口都需要当前用户ID"/>
            <node TEXT="如果每层都手动传会比较啰嗦"/>
            <node TEXT="拦截器解析token后把userId放入ThreadLocal"/>
            <node TEXT="Controller和Service可以直接拿到当前用户"/>
            <node TEXT="ThreadLocal最大风险是线程复用带来的脏数据"/>
            <node TEXT="请求结束后做了remove"/>
        </node>
        <node TEXT="Q: 怎么保证AI结果能落库？">
            <node TEXT="没有直接让模型自由输出"/>
            <node TEXT="通过Prompt约束字段结构"/>
            <node TEXT="再指定JSON响应格式"/>
            <node TEXT="最后后端再按对象反序列化"/>
        </node>
    </node>

    <!-- 1分钟项目介绍模板 -->
    <node ID="template" TEXT="九、1分钟项目介绍模板(可直接背)" POSITION="right">
        <node TEXT="基于Spring Boot+Vue+MyBatis-Plus+MySQL+Redis的养老院综合管理系统"/>
        <node TEXT="分为后台管理端和微信小程序端"/>
        <node TEXT="后台负责老人入住、护理等级、护理计划、合同、健康评估和设备管理"/>
        <node TEXT="小程序端主要给家属做微信登录、预约和查询"/>
        <node TEXT="我主要参与三个部分"/>
        <node TEXT="第一健康评估模块: PDF体检报告解析后交给百度千帆做结构化分析再把健康分数、风险等级和异常建议落库"/>
        <node TEXT="第二小程序登录模块: 基于微信code获取openid和手机号再结合JWT与ThreadLocal做前台认证"/>
        <node TEXT="第三IoT设备接入模块: 对接华为云IoTDA实现设备注册、设备影子查询和AMQP异步接收设备数据"/>
        <node TEXT="项目虽然是单体架构但业务链路完整也接入了AI和IoT两类外部能力"/>
    </node>

    <!-- 面试时必须诚实说明的边界 -->
    <node ID="boundary" TEXT="十、面试时必须诚实说明的边界" POSITION="right">
        <node TEXT="项目真实具备的亮点">
            <node TEXT="单体项目里的多模块业务整合能力"/>
            <node TEXT="AI结构化分析接入能力"/>
            <node TEXT="微信小程序登录与认证设计"/>
            <node TEXT="IoT第三方平台接入"/>
            <node TEXT="Redis缓存和定时任务"/>
            <node TEXT="多表业务链路设计"/>
        </node>
        <node TEXT="项目当前没有的能力">
            <node TEXT="没有微服务拆分"/>
            <node TEXT="没有分布式事务框架"/>
            <node TEXT="没有真正的消息队列中台(但有AMQP消费外部设备消息)"/>
            <node TEXT="没有SSE流式输出"/>
            <node TEXT="没有多智能体编排"/>
        </node>
        <node TEXT="最稳的说法">
            <node TEXT="这是一个典型的业务型单体系统"/>
            <node TEXT="但里面已经接入了AI和IoT两类外部能力"/>
            <node TEXT="虽然架构不算重但业务链路比较完整"/>
            <node TEXT="我重点做的是把外部能力稳定接进业务系统"/>
        </node>
    </node>

    <!-- 最后给自己的复盘口径提醒 -->
    <node ID="reminder" TEXT="十一、复盘口径提醒" POSITION="right">
        <node TEXT="一定要讲清楚">
            <node TEXT="项目服务谁"/>
            <node TEXT="你负责什么"/>
            <node TEXT="用户操作后链路怎么走"/>
            <node TEXT="为什么这么设计"/>
            <node TEXT="遇到了什么难点"/>
            <node TEXT="有什么真实优化点"/>
        </node>
        <node TEXT="一定不要乱讲">
            <node TEXT="不要把没有的SSE、微服务、多智能体强行说成已有能力"/>
            <node TEXT="不要只背Controller、Service、Mapper三层结构"/>
            <node TEXT="不要只说用了Redis做缓存要说清缓存什么为什么缓存如何失效"/>
            <node TEXT="不要只说调用了AI要说清为什么能稳定接到业务里"/>
        </node>
        <node TEXT="最稳的面试原则">
            <node TEXT="代码细节可以记不住"/>
            <node TEXT="但业务目标、技术决策、权衡和结果一定要讲清楚"/>
        </node>
    </node>
</node>
</map>