<map version="1.0.1">
<!-- 智颐养老系统-项目复盘笔记(贴代码版) -->

<node ID="root" TEXT="智颐养老系统-项目复盘笔记(贴代码版)">
    <!-- 项目定义 -->
    <node ID="define" TEXT="一、项目代码定义" POSITION="right">
        <node TEXT="从pom.xml看出多模块单体项目">
            <node TEXT="zzyl-admin: 后台启动入口"/>
            <node TEXT="zzyl-framework: 拦截器、Redis配置、认证"/>
            <node TEXT="zzyl-common: 通用工具、AI调用封装"/>
            <node TEXT="zzyl-nursing-platform: 养老业务核心模块"/>
            <node TEXT="zzyl-quartz: 定时任务"/>
            <node TEXT="zzyl-ui: 后台前端"/>
        </node>
        <node TEXT="面试回答模板">
            <node TEXT="基于Spring Boot+MyBatis-Plus+Redis+MySQL的多模块单体项目"/>
            <node TEXT="养老业务集中在zzyl-nursing-platform"/>
            <node TEXT="已接入AI、微信和IoT三类外部能力"/>
        </node>
    </node>

    <!-- 四条主链路 -->
    <node ID="links" TEXT="二、四条主链路" POSITION="right">
        <node TEXT="健康评估链路">
            <node TEXT="PDF报告上传→PDF解析→Redis暂存→AI分析→结构化落库"/>
        </node>
        <node TEXT="小程序登录链路">
            <node TEXT="微信code换openid→获取手机号→自动注册/更新→JWT→ThreadLocal"/>
        </node>
        <node TEXT="IoT设备链路">
            <node TEXT="产品同步→设备注册→查询设备影子→AMQP接收设备数据"/>
        </node>
        <node TEXT="入住办理链路">
            <node TEXT="校验老人状态→更新床位→保存老人→创建合同→写入住记录"/>
        </node>
    </node>

    <!-- 健康评估模块 -->
    <node ID="health" TEXT="三、健康评估模块(贴代码)" POSITION="right">
        <node TEXT="入口Controller">
            <node TEXT="HealthAssessmentController.java"/>
            <node TEXT="uploadFile():55"/>
            <node TEXT="add():129"/>
            <node TEXT="文件预处理和业务提交分阶段设计"/>
        </node>
        <node TEXT="上传阶段代码">
            <node TEXT="OSS上传: HealthAssessmentController.java:61"/>
            <node TEXT="PDF转文本: HealthAssessmentController.java:69"/>
            <node TEXT="Redis Hash暂存: HealthAssessmentController.java:71"/>
            <node TEXT="过期时间24小时: HealthAssessmentController.java:74"/>
            <node TEXT="核心代码">
                <node TEXT="String url = aliyunOSSOperator.upload(...)"/>
                <node TEXT="String content = PDFUtil.pdfToString(...)"/>
                <node TEXT="redisTemplate.opsForHash().put('healthReport', idCardNo, content)"/>
            </node>
            <node TEXT="面试要点">
                <node TEXT="不是前端直接传字符串给AI"/>
                <node TEXT="服务端解析AI输入可控"/>
                <node TEXT="中间态缓存设计"/>
            </node>
        </node>
        <node TEXT="提交评估代码">
            <node TEXT="HealthAssessmentServiceImpl.java"/>
            <node TEXT="insertHealthAssessment():72"/>
            <node TEXT="saveHealthAssessment():90"/>
            <node TEXT="getPrompt():160"/>
            <node TEXT="核心代码">
                <node TEXT="String prompt = getPrompt(healthAssessment.getIdCard())"/>
                <node TEXT="String qianfanResult = aiModelInvoker.qianfanInvoker(prompt)"/>
                <node TEXT="HealthReportVo healthReportVo = JSON.parseObject(qianfanResult, HealthReportVo.class)"/>
            </node>
            <node TEXT="面试要点">
                <node TEXT="强调结构化接入不是调AI"/>
                <node TEXT="Prompt固定输出字段格式"/>
                <node TEXT="AI返回反序列化成对象"/>
            </node>
        </node>
        <node TEXT="AI调用封装">
            <node TEXT="AIModelInvoker.java"/>
            <node TEXT="qianfanInvoker():18"/>
            <node TEXT="核心代码">
                <node TEXT="OpenAIClient client = OpenAIOkHttpClient.builder()..."/>
                <node TEXT="ChatCompletionCreateParams params = ..."/>
                <node TEXT=".responseFormat(ChatCompletionCreateParams.ResponseFormat.ofJsonObject())"/>
            </node>
            <node TEXT="面试要点">
                <node TEXT="第三方模型下沉到公共组件"/>
                <node TEXT="显式指定JSON Object响应格式"/>
                <node TEXT="双保险设计"/>
            </node>
        </node>
        <node TEXT="AI结果回写">
            <node TEXT="saveHealthAssessment():90"/>
            <node TEXT="身份证号反推年龄/性别/生日: :94"/>
            <node TEXT="读取健康分: :99"/>
            <node TEXT="设置风险等级: :103"/>
            <node TEXT="是否建议入住: :106"/>
            <node TEXT="通过分数映射护理等级: :109"/>
            <node TEXT="面试要点">
                <node TEXT="AI只负责认知型分析"/>
                <node TEXT="确定性业务规则放在后端"/>
                <node TEXT="根据分数映射护理等级"/>
            </node>
        </node>
    </node>

    <!-- 微信小程序登录模块 -->
    <node ID="wechat" TEXT="四、微信小程序登录模块(贴代码)" POSITION="right">
        <node TEXT="入口Controller">
            <node TEXT="FamilyMemberController.java"/>
            <node TEXT="login():52"/>
            <node TEXT="认证主逻辑在Service"/>
        </node>
        <node TEXT="登录主逻辑">
            <node TEXT="FamilyMemberServiceImpl.java"/>
            <node TEXT="login():133"/>
            <node TEXT="核心代码">
                <node TEXT="String openId = wechatService.getOpenid(userLoginRequestDto.getCode())"/>
                <node TEXT="FamilyMember familyMember = getOne(...eq(FamilyMember::getOpenId, openId))"/>
                <node TEXT="String phone = wechatService.getPhone(userLoginRequestDto.getPhoneCode())"/>
                <node TEXT="String token = tokenService.createToken(claims)"/>
            </node>
            <node TEXT="代码位置">
                <node TEXT="code换openid: FamilyMemberServiceImpl.java:135"/>
                <node TEXT="按openid查本地用户: :138"/>
                <node TEXT="获取手机号: :147"/>
                <node TEXT="生成token: :157"/>
            </node>
            <node TEXT="面试要点">
                <node TEXT="openid是身份唯一标识"/>
                <node TEXT="首次登录自动注册"/>
                <node TEXT="code→openid→phone→local user→JWT"/>
            </node>
        </node>
        <node TEXT="微信接口封装">
            <node TEXT="WechatServiceImpl.java"/>
            <node TEXT="getOpenid():41"/>
            <node TEXT="getPhone():77"/>
            <node TEXT="getToken():99"/>
            <node TEXT="面试要点">
                <node TEXT="微信HTTP调用封装一层"/>
                <node TEXT="登录主链路更干净"/>
            </node>
        </node>
        <node TEXT="ThreadLocal拦截器">
            <node TEXT="MemberInterceptor.java"/>
            <node TEXT="preHandle():26"/>
            <node TEXT="afterCompletion():63"/>
            <node TEXT="核心代码">
                <node TEXT="String token = request.getHeader('authorization')"/>
                <node TEXT="Claims claims = tokenService.parseToken(token)"/>
                <node TEXT="Long userId = MapUtil.get(claims, 'userId', Long.class)"/>
                <node TEXT="UserThreadLocal.set(userId)"/>
                <node TEXT="UserThreadLocal.remove()"/>
            </node>
            <node TEXT="面试要点">
                <node TEXT="不只是JWT还有MemberInterceptor+UserThreadLocal"/>
                <node TEXT="业务代码直接获取当前家属ID"/>
                <node TEXT="afterCompletion做remove避免脏数据"/>
            </node>
        </node>
        <node TEXT="拦截器配置">
            <node TEXT="ResourcesConfig.java"/>
            <node TEXT="addPathPatterns('/member/**'):59"/>
            <node TEXT="排除: /member/user/login, /member/roomTypes"/>
            <node TEXT="面试要点">
                <node TEXT="接口级认证边界不是全局一把梭"/>
            </node>
        </node>
    </node>

    <!-- IoT设备接入模块 -->
    <node ID="iot" TEXT="五、IoT设备接入模块(贴代码)" POSITION="right">
        <node TEXT="入口Controller">
            <node TEXT="DeviceController.java"/>
            <node TEXT="syncProductList():62"/>
            <node TEXT="registerDevice():81"/>
            <node TEXT="getInfo():92"/>
            <node TEXT="queryServiceProperties():100"/>
        </node>
        <node TEXT="产品同步">
            <node TEXT="DeviceServiceImpl.java"/>
            <node TEXT="syncProductList():130"/>
            <node TEXT="核心代码">
                <node TEXT="ListProductsRequest request = new ListProductsRequest()"/>
                <node TEXT="request.setLimit(50)"/>
                <node TEXT="ListProductsResponse response = iotDAClient.listProducts(request)"/>
                <node TEXT="redisTemplate.opsForValue().set(IOT_ALL_PRODUCT_LIST, ...)"/>
            </node>
            <node TEXT="代码位置">
                <node TEXT="调华为云IoTDA: DeviceServiceImpl.java:136"/>
                <node TEXT="写Redis: :143"/>
            </node>
            <node TEXT="面试要点">
                <node TEXT="产品元数据来自第三方IoT平台"/>
                <node TEXT="没必要每次页面查询都走远程接口"/>
                <node TEXT="同步到Redis后续直接从本地缓存读取"/>
            </node>
        </node>
        <node TEXT="设备注册">
            <node TEXT="registerDevice():167"/>
            <node TEXT="三重校验">
                <node TEXT="设备名称唯一: :169"/>
                <node TEXT="nodeId唯一: :175"/>
                <node TEXT="同位置同产品唯一: :181"/>
            </node>
            <node TEXT="核心代码">
                <node TEXT="count = count(...eq(Device::getDeviceName, dto.getDeviceName()))"/>
                <node TEXT="response = iotDAClient.addDevice(request)"/>
            </node>
            <node TEXT="面试要点">
                <node TEXT="云端设备注册和本地业务绑定放在一个链路"/>
                <node TEXT="注册前校验避免业务冲突"/>
                <node TEXT="注册成功后云端deviceId、本地位置、产品信息、密钥一起落库"/>
            </node>
        </node>
        <node TEXT="设备属性查询">
            <node TEXT="queryServiceProperties():261"/>
            <node TEXT="查询设备影子: :264"/>
            <node TEXT="读取reported: :274"/>
            <node TEXT="封装前端结构: :288"/>
            <node TEXT="面试要点">
                <node TEXT="reported properties转成统一结构"/>
                <node TEXT="前端不用理解第三方SDK原始模型"/>
            </node>
        </node>
        <node TEXT="AMQP消费链路">
            <node TEXT="AmqpClient.java"/>
            <node TEXT="实现ApplicationRunner: :37"/>
            <node TEXT="启动后执行start(): :58"/>
            <node TEXT="收到消息交线程池: :176"/>
            <node TEXT="processMessage(): :188"/>
            <node TEXT="批量入库: :216"/>
            <node TEXT="核心代码">
                <node TEXT="consumer.setMessageListener(messageListener)"/>
                <node TEXT="executorService.submit(() -> processMessage(message))"/>
            </node>
            <node TEXT="面试要点">
                <node TEXT="完整设备数据回流链路"/>
                <node TEXT="消息接收和业务处理解耦"/>
                <node TEXT="收到上报数据后异步线程池处理"/>
            </node>
        </node>
    </node>

    <!-- 入住办理模块 -->
    <node ID="checkin" TEXT="六、入住办理模块(贴代码)" POSITION="right">
        <node TEXT="入口">
            <node TEXT="CheckInController.java"/>
            <node TEXT="apply():57"/>
            <node TEXT="主逻辑: CheckInServiceImpl.java"/>
            <node TEXT="apply():188"/>
        </node>
        <node TEXT="代码执行顺序">
            <node TEXT="校验老人是否已入住: :191"/>
            <node TEXT="更新床位状态: :200"/>
            <node TEXT="保存/更新老人: :205"/>
            <node TEXT="生成合同号并插合同: :208"/>
            <node TEXT="插入住记录: :214"/>
            <node TEXT="插入住配置: :217"/>
        </node>
        <node TEXT="面试要点">
            <node TEXT="多表业务状态流转不是简单CRUD"/>
            <node TEXT="床位、老人、合同、入住记录、入住配置联动"/>
        </node>
        <node TEXT="合同定时更新">
            <node TEXT="ContractTask.java"/>
            <node TEXT="updateContractStatusTask():15"/>
            <node TEXT="ContractServiceImpl.java"/>
            <node TEXT="updateContractStatus():32"/>
            <node TEXT="面试要点">
                <node TEXT="时间驱动型状态流转"/>
                <node TEXT="合同从未生效变为生效中"/>
            </node>
        </node>
    </node>

    <!-- Redis缓存三类用法 -->
    <node ID="redis" TEXT="七、Redis缓存三类用法" POSITION="right">
        <node TEXT="业务中间态缓存">
            <node TEXT="健康评估: HealthAssessmentController.java:71"/>
            <node TEXT="缓存PDF解析结果"/>
            <node TEXT="以身份证号做索引"/>
            <node TEXT="TTL 24小时"/>
        </node>
        <node TEXT="远程元数据缓存">
            <node TEXT="IoT产品列表: DeviceServiceImpl.java:143"/>
            <node TEXT="Key: CacheConstants.IOT_ALL_PRODUCT_LIST"/>
            <node TEXT="缓存来自IoT平台的产品元数据"/>
        </node>
        <node TEXT="基础字典型缓存">
            <node TEXT="护理等级: NursingLevelServiceImpl.java:136"/>
            <node TEXT="护理计划: NursingPlanServiceImpl.java:176"/>
            <node TEXT="读多写少基础数据"/>
            <node TEXT="写操作后删缓存"/>
        </node>
    </node>

    <!-- 面试话术 -->
    <node ID="words" TEXT="八、面试话术" POSITION="right">
        <node TEXT="能说的">
            <node TEXT="健康评估链路PDF报告解析后交给AI结构化分析"/>
            <node TEXT="小程序端微信登录走openid+JWT+ThreadLocal"/>
            <node TEXT="接了华为云IoTDA用AMQP接收设备上报数据"/>
            <node TEXT="入住办理是多表业务链路不是简单CRUD"/>
            <node TEXT="Redis做中间态、元数据、基础数据三类缓存"/>
        </node>
        <node TEXT="不要说的">
            <node TEXT="不要说项目用了SSE(代码里没有)"/>
            <node TEXT="不要说项目是微服务(当前就是单体多模块)"/>
            <node TEXT="不要说做了多智能体编排(代码里没有)"/>
            <node TEXT="不要把AMQP说成Kafka/RocketMQ"/>
        </node>
    </node>

    <!-- 1分钟口述稿 -->
    <node ID="1min" TEXT="九、1分钟口述稿" POSITION="right">
        <node TEXT="核心业务代码在zzyl-nursing-platform"/>
        <node TEXT="做了三个代表性模块"/>
        <node TEXT="健康评估: HealthAssessmentController#uploadFile→PDF上传OSS解析→Redis缓存→HealthAssessmentServiceImpl#insertHealthAssessment→getPrompt()→AIModelInvoker#qianfanInvoker→结构化分析落库"/>
        <node TEXT="小程序登录: FamilyMemberServiceImpl#login→微信code获取openid和手机号→自动注册→JWT→MemberInterceptor解析token→userId放ThreadLocal"/>
        <node TEXT="IoT模块: DeviceServiceImpl产品同步设备注册设备影子查询→AmqpClient订阅设备消息异步消费数据落库"/>
        <node TEXT="项目虽然不是微服务但业务链路完整"/>
    </node>

    <!-- 练习问题 -->
    <node ID="practice" TEXT="十、练习问题" POSITION="right">
        <node TEXT="健康评估为什么要先传PDF再提交评估？"/>
        <node TEXT="小程序登录为什么还要用ThreadLocal？"/>
        <node TEXT="IoT设备模块里最有技术含量的点到底是什么？"/>
    </node>
</node>
</map>