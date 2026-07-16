<map version="1.0.1">
<!-- 智颐养老系统-项目复盘笔记(面试专用) -->

<node ID="root" TEXT="智颐养老系统-项目复盘笔记(面试专用)">
    <!-- 项目概述 -->
    <node ID="overview" TEXT="一、项目概述(黄金表达模板)" POSITION="right">
        <node TEXT="一句话介绍">
            <node TEXT="智颐养老系统是面向养老院的综合管理平台"/>
            <node TEXT="包含后台管理系统和小程序端两部分"/>
            <node TEXT="后台: 老人入住、护理服务、健康评估、设备管理"/>
            <node TEXT="小程序: 微信登录、预约服务、健康数据查询"/>
        </node>
        <node TEXT="项目基本信息">
            <node TEXT="项目类型: B端管理系统 + C端小程序"/>
            <node TEXT="开发周期: 6个月"/>
            <node TEXT="团队规模: 5人"/>
            <node TEXT="我的角色: 核心后端开发"/>
            <node TEXT="技术栈: Spring Boot 2.5 + MyBatis-Plus + Redis + MySQL + 华为云IoT + 百度千帆AI"/>
        </node>
        <node TEXT="项目架构图">
            <node TEXT="客户端层: 后台管理系统(Vue2) + 微信小程序端 + IoT设备端"/>
            <node TEXT="网关层: Nginx负载均衡+反向代理"/>
            <node TEXT="应用层: zzyl-admin + zzyl-nursing + zzyl-framework + zzyl-quartz"/>
            <node TEXT="数据层: MySQL + Redis + 阿里云OSS + 华为云IoT"/>
            <node TEXT="外部服务: 百度千帆AI + 微信开放平台 + 短信服务"/>
        </node>
    </node>

    <!-- STAR法则-健康评估模块 -->
    <node ID="health" TEXT="二、健康评估模块(STAR法则)" POSITION="right">
        <node TEXT="S(背景)">
            <node TEXT="业务问题">
                <node TEXT="效率低: 一份报告人工分析需要8秒以上"/>
                <node TEXT="专业性强: 需要专业医护人员解读"/>
                <node TEXT="标准不统一: 不同人员解读结果可能有差异"/>
                <node TEXT="人力成本高: 需要配备专职健康评估人员"/>
            </node>
            <node TEXT="业务价值">
                <node TEXT="为每位老人建立健康档案"/>
                <node TEXT="自动生成健康评分和护理等级建议"/>
                <node TEXT="提供异常指标解读和健康建议"/>
            </node>
        </node>
        <node TEXT="T(任务)">
            <node TEXT="设计健康评估整体技术方案"/>
            <node TEXT="集成百度千帆AI大模型"/>
            <node TEXT="实现PDF体检报告解析"/>
            <node TEXT="设计Redis缓存策略优化性能"/>
            <node TEXT="实现健康评分算法和护理等级映射"/>
        </node>
        <node TEXT="A(行动)">
            <node TEXT="技术架构">
                <node TEXT="上传体检报告→Redis缓存(24h有效)→提交评估请求"/>
                <node TEXT="↓"/>
                <node TEXT="调用千帆AI(Prompt)→解析JSON响应→保存评估结果"/>
            </node>
            <node TEXT="核心代码设计">
                <node TEXT="Redis缓存策略">
                    <node TEXT="redisTemplate.opsForHash().put('healthReport', idCard, content)"/>
                    <node TEXT="redisTemplate.expire('healthReport', 24, TimeUnit.HOURS)"/>
                </node>
                <node TEXT="Prompt工程">
                    <node TEXT="请以专业医生视角分析体检报告"/>
                    <node TEXT="输出要求: 纯JSON格式"/>
                    <node TEXT="包含健康评分、风险等级、异常分析"/>
                </node>
                <node TEXT="AI调用(OpenAI兼容SDK)">
                    <node TEXT="OpenAIOkHttpClient.builder().apiKey(apiKey).baseUrl(baseUrl)"/>
                    <node TEXT=".responseFormat(ChatCompletionCreateParams.ResponseFormat.ofJsonObject())"/>
                </node>
            </node>
            <node TEXT="性能优化">
                <node TEXT="PDF解析: 每次评估都解析→仅上传时解析1次"/>
                <node TEXT="响应时间: 8秒→1秒(提升87.5%)"/>
                <node TEXT="手段: Redis缓存+异步处理"/>
            </node>
        </node>
        <node TEXT="R(结果)">
            <node TEXT="性能提升">
                <node TEXT="响应时间: 8秒→1秒(提升87.5%)"/>
                <node TEXT="护理人员效率: 提升约30%"/>
                <node TEXT="人力成本: 减少1名专职评估人员"/>
            </node>
            <node TEXT="业务价值">
                <node TEXT="累计评估老人体检报告5000+份"/>
                <node TEXT="准确率达到92%(与人工对比)"/>
                <node TEXT="护理等级推荐采纳率85%"/>
            </node>
        </node>
        <node TEXT="深挖问题准备">
            <node TEXT="Q: 为什么选择百度千帆而不是ChatGPT？">
                <node TEXT="合规性: 国内服务商数据不出境"/>
                <node TEXT="中文优化: 针对中文场景优化"/>
                <node TEXT="成本控制: 提供免费额度"/>
                <node TEXT="SDK兼容: 支持OpenAI SDK"/>
            </node>
            <node TEXT="Q: Redis缓存失效怎么办？">
                <node TEXT="代码检查缓存是否存在"/>
                <node TEXT="不存在时抛友好异常"/>
                <node TEXT="提示用户重新上传"/>
            </node>
            <node TEXT="Q: 如何保证AI分析结果的准确性？">
                <node TEXT="Prompt工程: 详细提示词设计"/>
                <node TEXT="结构化输出: 要求AI返回JSON"/>
                <node TEXT="人工审核: 关键决策需人工确认"/>
            </node>
        </node>
    </node>

    <!-- STAR法则-设备管理模块 -->
    <node ID="device" TEXT="三、设备管理模块(STAR法则)" POSITION="right">
        <node TEXT="S(背景)">
            <node TEXT="业务问题">
                <node TEXT="设备分散管理数据孤岛"/>
                <node TEXT="无法实时获取设备状态"/>
                <node TEXT="设备与老人/位置绑定关系混乱"/>
            </node>
            <node TEXT="业务价值">
                <node TEXT="统一管理所有智能设备"/>
                <node TEXT="实时接收设备上报数据"/>
                <node TEXT="设备与位置/老人精准绑定"/>
            </node>
        </node>
        <node TEXT="T(任务)">
            <node TEXT="集成华为云IoT平台SDK"/>
            <node TEXT="实现产品同步和设备注册"/>
            <node TEXT="设计设备绑定位置机制"/>
            <node TEXT="实现AMQP数据实时接收"/>
        </node>
        <node TEXT="A(行动)">
            <node TEXT="技术架构">
                <node TEXT="华为云IoT平台: 产品管理/设备管理/数据流转/AMQP队列"/>
                <node TEXT="本地系统: 产品同步→Redis/设备注册→MySQL/数据接收→MySQL"/>
            </node>
            <node TEXT="核心代码设计">
                <node TEXT="产品同步到Redis">
                    <node TEXT="ListProductsRequest request = new ListProductsRequest()"/>
                    <node TEXT="request.setLimit(50)"/>
                    <node TEXT="iotDAClient.listProducts(request)"/>
                    <node TEXT="redisTemplate.opsForValue().set(IOT_ALL_PRODUCT_LIST, ...)"/>
                </node>
                <node TEXT="设备注册三重校验">
                    <node TEXT="设备名称不能重复"/>
                    <node TEXT="节点号不能重复"/>
                    <node TEXT="同一位置不能绑定同一产品"/>
                </node>
                <node TEXT="AMQP数据接收">
                    <node TEXT="@Component AmqpClient implements ApplicationRunner"/>
                    <node TEXT="consumer.setMessageListener(message -> executorService.submit(...))"/>
                </node>
            </node>
            <node TEXT="设备绑定位置设计">
                <node TEXT="随身设备(locationType=0): 绑定老人"/>
                <node TEXT="固定设备(locationType=1): 绑定物理位置"/>
                <node TEXT="物理位置三级: 楼层→房间→床位"/>
            </node>
        </node>
        <node TEXT="R(结果)">
            <node TEXT="技术成果">
                <node TEXT="接入智能设备200+台"/>
                <node TEXT="数据接收延迟<1秒"/>
                <node TEXT="设备在线率98%+"/>
            </node>
        </node>
        <node TEXT="深挖问题准备">
            <node TEXT="Q: 为什么选择华为云IoT而不是阿里云？">
                <node TEXT="合规性: 国内服务商数据不出境"/>
                <node TEXT="功能完善: 设备管理/数据流转/规则引擎"/>
                <node TEXT="AMQP支持: 实时推送设备数据"/>
            </node>
            <node TEXT="Q: 设备注册时如何保证数据一致性？">
                <node TEXT="当前: 先调用华为云API再保存本地数据库"/>
                <node TEXT="问题: 华为云成功本地失败导致不一致"/>
                <node TEXT="改进: 消息队列实现最终一致性"/>
            </node>
        </node>
    </node>

    <!-- STAR法则-小程序登录模块 -->
    <node ID="login" TEXT="四、小程序登录模块(STAR法则)" POSITION="right">
        <node TEXT="S(背景)">
            <node TEXT="技术挑战">
                <node TEXT="小程序无Cookie机制"/>
                <node TEXT="多线程环境下用户信息传递"/>
                <node TEXT="线程池复用导致ThreadLocal内存泄漏"/>
            </node>
        </node>
        <node TEXT="T(任务)">
            <node TEXT="实现微信小程序登录流程"/>
            <node TEXT="设计JWT Token认证机制"/>
            <node TEXT="使用ThreadLocal存储用户信息"/>
            <node TEXT="解决内存泄漏问题"/>
        </node>
        <node TEXT="A(行动)">
            <node TEXT="技术架构">
                <node TEXT="wx.login()→获取code→获取手机号"/>
                <node TEXT="↓"/>
                <node TEXT="获取openid→查询/创建用户→生成Token"/>
                <node TEXT="↓"/>
                <node TEXT="拦截器→解析Token→ThreadLocal存储→业务处理→清理"/>
            </node>
            <node TEXT="核心代码设计">
                <node TEXT="ThreadLocal工具类">
                    <node TEXT="private static final ThreadLocal&lt;Long&gt; LOCAL = new ThreadLocal&lt;&gt;()"/>
                    <node TEXT="set(Long) / get() / remove()"/>
                </node>
                <node TEXT="拦截器">
                    <node TEXT="preHandle: 解析Token存储用户ID到ThreadLocal"/>
                    <node TEXT="afterCompletion: 清理ThreadLocal防止内存泄漏"/>
                </node>
            </node>
            <node TEXT="内存泄漏问题解决">
                <node TEXT="问题原因: 线程池复用ThreadLocal数据不会自动清理"/>
                <node TEXT="解决方案: afterCompletion中调用remove()"/>
                <node TEXT="使用try-finally确保清理"/>
            </node>
        </node>
        <node TEXT="R(结果)">
            <node TEXT="登录成功率99.9%+"/>
            <node TEXT="Token认证响应时间<10ms"/>
            <node TEXT="内存泄漏问题完全解决"/>
        </node>
        <node TEXT="深挖问题准备">
            <node TEXT="Q: ThreadLocal原理是什么？">
                <node TEXT="每个Thread对象内部维护ThreadLocalMap"/>
                <node TEXT="Key是ThreadLocal对象Value是存储的值"/>
                <node TEXT="Key是弱引用Value是强引用"/>
            </node>
            <node TEXT="Q: 为什么必须调用remove()？">
                <node TEXT="线程池复用线程不会销毁"/>
                <node TEXT="ThreadLocal数据不会自动清理"/>
                <node TEXT="导致内存泄漏和数据污染"/>
            </node>
        </node>
    </node>

    <!-- 技术深度总结 -->
    <node ID="tech" TEXT="五、技术深度总结" POSITION="right">
        <node TEXT="技术栈全景">
            <node TEXT="后端框架: Spring Boot 2.5.15 + Spring Security 5.7"/>
            <node TEXT="持久层: MyBatis-Plus 3.5.2 + MySQL 8.0"/>
            <node TEXT="缓存: Redis 6.x"/>
            <node TEXT="消息队列: AMQP(Qpid JMS)"/>
            <node TEXT="IoT平台: 华为云IoTDA SDK"/>
            <node TEXT="AI大模型: 百度千帆(OpenAI兼容SDK)"/>
        </node>
        <node TEXT="核心技术亮点">
            <node TEXT="AI大模型应用: Prompt工程+JSON结构化输出"/>
            <node TEXT="Redis缓存: Hash结构+过期策略+缓存穿透防护"/>
            <node TEXT="ThreadLocal应用: 线程隔离+内存泄漏防护"/>
            <node TEXT="AMQP: 多连接消费+异步处理"/>
            <node TEXT="JWT: 无状态认证+Token刷新"/>
        </node>
        <node TEXT="性能优化清单">
            <node TEXT="健康评估响应时间: 8秒→1秒"/>
            <node TEXT="设备数据接收延迟: 5秒→<1秒"/>
            <node TEXT="Token认证时间: 50ms→<10ms"/>
            <node TEXT="产品列表查询: 200ms→<10ms"/>
        </node>
    </node>

    <!-- 面试常见问题 -->
    <node ID="qa" TEXT="六、面试常见问题" POSITION="right">
        <node TEXT="Q: 介绍一下你的项目？">
            <node TEXT="S: 智颐养老系统是面向养老院的综合管理平台"/>
            <node TEXT="T: 我作为核心后端开发负责健康评估、设备管理、小程序登录"/>
            <node TEXT="A: 健康评估集成AI响应时间8秒→1秒/设备管理集成IoT/小程序登录用ThreadLocal"/>
            <node TEXT="R: 累计评估5000+份/接入设备200+台/护理人员效率提升30%"/>
        </node>
        <node TEXT="Q: Redis在项目中的应用场景？">
            <node TEXT="健康评估: 缓存PDF内容(Hash结构)过期24小时"/>
            <node TEXT="设备管理: 缓存产品列表(String结构)"/>
            <node TEXT="系统模块: 缓存字典数据/用户Token/分布式锁"/>
        </node>
        <node TEXT="Q: 如何保证接口幂等性？">
            <node TEXT="Token机制: 每次请求携带Token"/>
            <node TEXT="唯一索引: 数据库层面保证唯一性"/>
            <node TEXT="分布式锁: Redis SETNX实现"/>
            <node TEXT="业务层校验: 查询是否已存在"/>
        </node>
        <node TEXT="Q: 如何设计高并发的健康评估接口？">
            <node TEXT="缓存层: Redis缓存PDF内容和AI分析结果"/>
            <node TEXT="异步处理: 提交评估请求→返回任务ID→前端轮询"/>
            <node TEXT="限流: 令牌桶限流防止AI接口被刷"/>
            <node TEXT="降级: AI服务不可用时返回默认评估结果"/>
        </node>
    </node>

    <!-- 项目亮点话术 -->
    <node ID="highlight" TEXT="七、项目亮点话术" POSITION="right">
        <node TEXT="开场白(30秒)">
            <node TEXT="智颐养老系统面向养老院的综合管理平台"/>
            <node TEXT="我主要负责健康评估、设备管理、小程序登录等核心模块"/>
            <node TEXT="健康评估集成百度千帆AI响应时间8秒→1秒效率提升30%"/>
            <node TEXT="设备管理集成华为云IoT实现200+智能设备统一管理"/>
            <node TEXT="小程序登录使用ThreadLocal解决内存泄漏问题"/>
        </node>
        <node TEXT="技术亮点总结">
            <node TEXT="AI大模型应用: Prompt工程设计/JSON结构化输出"/>
            <node TEXT="IoT平台集成: 设备统一管理/AMQP数据接收"/>
            <node TEXT="ThreadLocal应用: 线程隔离/内存泄漏防护"/>
            <node TEXT="Redis缓存策略: 多场景应用/数据结构选择"/>
        </node>
    </node>

    <!-- 项目复盘检查清单 -->
    <node ID="checklist" TEXT="八、项目复盘检查清单" POSITION="right">
        <node TEXT="能讲清业务">
            <node TEXT="项目背景和目标"/>
            <node TEXT="核心业务流程"/>
            <node TEXT="用户角色和权限"/>
            <node TEXT="业务价值量化"/>
        </node>
        <node TEXT="能讲清架构">
            <node TEXT="系统架构图"/>
            <node TEXT="技术选型理由"/>
            <node TEXT="模块划分"/>
        </node>
        <node TEXT="能讲清技术">
            <node TEXT="核心技术栈"/>
            <node TEXT="技术实现细节"/>
            <node TEXT="技术难点解决"/>
        </node>
        <node TEXT="能讲清问题">
            <node TEXT="遇到的问题"/>
            <node TEXT="问题分析过程"/>
            <node TEXT="解决方案"/>
        </node>
        <node TEXT="能抗住深挖">
            <node TEXT="技术原理"/>
            <node TEXT="源码分析"/>
            <node TEXT="对比方案"/>
        </node>
    </node>
</node>
</map>