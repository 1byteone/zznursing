<map version="1.0.1">
<!-- 智颐养老系统-项目复盘口述稿(2分钟+5分钟) -->

<node ID="root" TEXT="智颐养老系统-项目复盘口述稿">
    <!-- 使用说明 -->
    <node ID="intro" TEXT="使用说明" POSITION="right">
        <node TEXT="这份文档是面试时可以直接说出口的话术稿"/>
        <node TEXT="先背2分钟版保证任何面试都能稳定开场"/>
        <node TEXT="再练5分钟版应对面试官追问"/>
        <node TEXT="内容基于项目当前真实代码整理"/>
    </node>

    <!-- 2分钟版口述稿 -->
    <node ID="2min" TEXT="一、2分钟版口述稿" POSITION="right">
        <node TEXT="标准稿">
            <node TEXT="项目定位">
                <node TEXT="智颐养老系统是面向养老院场景的综合管理平台"/>
                <node TEXT="分为后台管理端和家属小程序端"/>
                <node TEXT="后台主要负责老人入住、护理等级、护理计划、合同、健康评估和设备管理"/>
                <node TEXT="小程序端主要给家属做微信登录、预约和信息查询"/>
            </node>
            <node TEXT="技术栈">
                <node TEXT="Spring Boot + MyBatis-Plus + MySQL + Redis"/>
                <node TEXT="接入了微信开放平台、百度千帆和华为云IoTDA"/>
            </node>
            <node TEXT="核心模块一：健康评估">
                <node TEXT="业务场景: 老人入住前上传体检报告自动给出健康分"/>
                <node TEXT="代码链路: PDF上传OSS→解析文本→Redis暂存→调用AI→JSON解析落库"/>
                <node TEXT="亮点: AI输出变成业务系统能稳定接住的结构化数据"/>
            </node>
            <node TEXT="核心模块二：微信小程序登录">
                <node TEXT="整体链路: 微信code→获取openid→获取手机号→自动注册→JWT返回"/>
                <node TEXT="后续请求: MemberInterceptor拦截→Token解析→userId写入ThreadLocal"/>
                <node TEXT="亮点: afterCompletion里做了remove()避免线程复用脏数据"/>
            </node>
            <node TEXT="核心模块三：IoT设备接入">
                <node TEXT="设备管理: 同步产品列表、注册设备、查询设备影子属性"/>
                <node TEXT="注册流程: 先校验再调用华为云创建设备保存本地"/>
                <node TEXT="消息回流: AmqpClient订阅IoT消息异步接收数据落库"/>
            </node>
            <node TEXT="总结">
                <node TEXT="项目虽然不是微服务但业务链路比较完整"/>
                <node TEXT="主要做的是把AI、微信和IoT三类外部能力稳定接进业务系统"/>
            </node>
        </node>
        <node TEXT="拆解提示">
            <node TEXT="开场四句话">
                <node TEXT="这是一个什么项目"/>
                <node TEXT="面向谁"/>
                <node TEXT="解决什么问题"/>
                <node TEXT="技术栈是什么"/>
            </node>
            <node TEXT="主体三模块">
                <node TEXT="健康评估: PDF→Redis→AI→落库"/>
                <node TEXT="小程序登录: code→openid→phone→JWT→ThreadLocal"/>
                <node TEXT="IoT接入: 产品同步→设备注册→AMQP消息回流"/>
            </node>
            <node TEXT="收尾一句">
                <node TEXT="业务链路完整AI、微信和IoT都真正落到代码里"/>
            </node>
        </node>
    </node>

    <!-- 5分钟版口述稿 -->
    <node ID="5min" TEXT="二、5分钟版口述稿" POSITION="right">
        <node TEXT="项目定义">
            <node TEXT="服务养老院场景分为后台管理端和家属小程序端"/>
            <node TEXT="多模块单体项目养老业务集中在zzyl-nursing-platform"/>
        </node>
        <node TEXT="健康评估模块展开">
            <node TEXT="业务背景: 人工解读效率低标准不统一"/>
            <node TEXT="第一阶段: 上传体检报告">
                <node TEXT="PDF上传OSS并用PDFUtil.pdfToString()解析"/>
                <node TEXT="按身份证号写入Redis Hash Key是healthReport"/>
                <node TEXT="过期时间24小时"/>
                <node TEXT="设计点: 把文件上传和AI评估提交拆开"/>
            </node>
            <node TEXT="第二阶段: 提交评估">
                <node TEXT="从Redis取出体检报告文本"/>
                <node TEXT="通过getPrompt()拼接Prompt调用AI"/>
                <node TEXT="返回结果反序列化成HealthReportVo"/>
                <node TEXT="映射为健康分、风险等级、护理等级建议等字段"/>
            </node>
            <node TEXT="技术难点">
                <node TEXT="Prompt约束和业务规则拆分"/>
                <node TEXT="AI负责分析后端负责确定性规则判断"/>
            </node>
        </node>
        <node TEXT="微信小程序登录模块展开">
            <node TEXT="主逻辑在FamilyMemberServiceImpl#login"/>
            <node TEXT="整体链路">
                <node TEXT="前端传微信code和phoneCode"/>
                <node TEXT="通过WechatServiceImpl#getOpenid获取openid"/>
                <node TEXT="getPhone()获取手机号"/>
                <node TEXT="按openid查询本地家属账号没有则自动注册"/>
                <node TEXT="生成JWT把userId和nickName放进claims"/>
            </node>
            <node TEXT="后续请求处理">
                <node TEXT="/member/**接口被MemberInterceptor拦截"/>
                <node TEXT="从请求头拿authorization解析token"/>
                <node TEXT="把userId放进UserThreadLocal"/>
            </node>
            <node TEXT="技术亮点">
                <node TEXT="ThreadLocal生命周期管理"/>
                <node TEXT="afterCompletion里做了UserThreadLocal.remove()"/>
                <node TEXT="体现工程意识不是只会背登录流程"/>
            </node>
        </node>
        <node TEXT="IoT设备接入模块展开">
            <node TEXT="业务场景: 接入智能手环、床垫、定位设备"/>
            <node TEXT="设备管理">
                <node TEXT="DeviceServiceImpl#syncProductList调用华为云产品列表"/>
                <node TEXT="同步到Redis Key是iot:all_product_list"/>
            </node>
            <node TEXT="设备注册">
                <node TEXT="三重校验: 设备名称、节点号、位置+产品组合"/>
                <node TEXT="校验通过后调用IoTDA创建设备"/>
                <node TEXT="云端deviceId和本地绑定关系一起保存"/>
            </node>
            <node TEXT="消息回流">
                <node TEXT="AmqpClient作为ApplicationRunner启动后自动拉起订阅"/>
                <node TEXT="收到消息提交给线程池异步处理"/>
                <node TEXT="解析notify_data批量入库"/>
                <node TEXT="体现异步消费场景理解"/>
            </node>
        </node>
        <node TEXT="入住办理链路">
            <node TEXT="CheckInServiceImpl#apply"/>
            <node TEXT="多表联动: 床位、老人、合同、入住记录、入住配置"/>
            <node TEXT="讲成多表业务状态流转而不是简单CRUD"/>
            <node TEXT="ContractTask定时推进合同状态体现时间驱动型业务"/>
        </node>
        <node TEXT="总结价值">
            <node TEXT="业务理解能力: 老人入住、护理、合同、健康评估链路打通"/>
            <node TEXT="第三方能力接入能力: 微信、百度千帆、华为云IoTDA"/>
            <node TEXT="工程落地能力: AI、认证、缓存、异步消费接进业务代码"/>
        </node>
        <node TEXT="记忆骨架">
            <node TEXT="第一段: 项目定义"/>
            <node TEXT="第二段: 健康评估(uploadFile/PDF解析/Redis/insertHealthAssessment/Prompt/AI)"/>
            <node TEXT="第三段: 小程序登录(FamilyMemberServiceImpl/openid/手机号/JWT/MemberInterceptor/ThreadLocal)"/>
            <node TEXT="第四段: IoT接入(产品同步Redis/三重校验/设备影子/AmqpClient异步消费)"/>
            <node TEXT="第五段: 入住办理(CheckInServiceImpl/多表联动/ContractTask定时)"/>
            <node TEXT="第六段: 总结(业务链路完整/外部能力真实落地)"/>
        </node>
    </node>

    <!-- 面试节奏控制 -->
    <node ID="control" TEXT="三、面试节奏控制" POSITION="right">
        <node TEXT="如果只有1~2分钟">
            <node TEXT="只说: 项目定位+负责的3个模块+每个模块一句亮点"/>
            <node TEXT="不要展开: 具体字段、过多类名、太长代码细节"/>
        </node>
        <node TEXT="如果愿意听5分钟">
            <node TEXT="优先展开顺序: 健康评估→小程序登录→IoT→入住办理"/>
            <node TEXT="原因">
                <node TEXT="健康评估最能拉开差距"/>
                <node TEXT="登录模块最容易被继续追问"/>
                <node TEXT="IoT模块最有辨识度"/>
                <node TEXT="入住办理适合补业务复杂度"/>
            </node>
        </node>
    </node>

    <!-- 加分话 -->
    <node ID="bonus" TEXT="四、面试加分话" POSITION="right">
        <node TEXT="句子一: 强调你不是只会调接口">
            <node TEXT="重点关注能力怎么稳定接入现有业务"/>
            <node TEXT="AI输出怎么结构化落库"/>
            <node TEXT="IoT数据怎么异步回流"/>
            <node TEXT="登录态怎么在业务层方便拿到当前用户"/>
        </node>
        <node TEXT="句子二: 强调工程意识">
            <node TEXT="ThreadLocal的清理"/>
            <node TEXT="Redis缓存的适用场景"/>
            <node TEXT="云端设备和本地设备双写时一致性风险"/>
        </node>
    </node>

    <!-- 自测问题 -->
    <node ID="test" TEXT="五、练习自测问题" POSITION="right">
        <node TEXT="健康评估从上传PDF到结果落库中间发生了什么？"/>
        <node TEXT="小程序登录为什么不只是JWT还要讲ThreadLocal？"/>
        <node TEXT="IoT模块里你觉得最有含金量的代码是哪一段？"/>
    </node>
</node>
</map>