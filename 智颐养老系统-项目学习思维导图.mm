<map version="1.0.1">
<!-- 智颐养老系统 - Java项目学习思维导图 -->

<node ID="root" TEXT="智颐养老系统（ZZYL）">
    <!-- 第一层：项目概述 -->
    <node ID="overview" TEXT="1. 项目概述" POSITION="right">
        <node TEXT="项目名称">
            <node TEXT="智颐养老系统（ZZYL）"/>
            <node TEXT="中州养老综合管理平台"/>
        </node>
        <node TEXT="项目背景">
            <node TEXT="传统养老院痛点">
                <node TEXT="数据分散，老人档案、入住、护理计划分开管理"/>
                <node TEXT="家属获取老人健康信息不及时"/>
                <node TEXT="体检报告解读强依赖人工"/>
                <node TEXT="智能设备数据难以汇总使用"/>
            </node>
            <node TEXT="行业趋势">
                <node TEXT="老龄化社会加速到来"/>
                <node TEXT="养老机构数字化转型需求"/>
                <node TEXT="智慧养老政策支持"/>
            </node>
        </node>
        <node TEXT="项目目标">
            <node TEXT="提升护理效率30%"/>
            <node TEXT="减少人工统计成本"/>
            <node TEXT="增强健康状态数字化管理"/>
            <node TEXT="实现老人全生命周期闭环管理"/>
        </node>
        <node TEXT="用户角色">
            <node TEXT="后台用户">
                <node TEXT="养老院管理员"/>
                <node TEXT="护理员"/>
                <node TEXT="运营人员"/>
            </node>
            <node TEXT="前台用户">
                <node TEXT="老人家属"/>
            </node>
            <node TEXT="外部系统">
                <node TEXT="微信开放平台"/>
                <node TEXT="百度千帆AI"/>
                <node TEXT="华为云IoT"/>
            </node>
        </node>
        <node TEXT="核心功能">
            <node TEXT="老人入住管理"/>
            <node TEXT="护理服务管理"/>
            <node TEXT="健康评估（AI分析）"/>
            <node TEXT="设备管理（IoT接入）"/>
            <node TEXT="小程序端服务"/>
        </node>
        <node TEXT="项目成果">
            <node TEXT="累计评估体检报告5000+份"/>
            <node TEXT="接入智能设备200+台"/>
            <node TEXT="护理人员效率提升30%"/>
            <node TEXT="系统稳定性99.9%"/>
            <node TEXT="准确率92%（与人工对比）"/>
        </node>
    </node>

    <!-- 第二层：业务分析 -->
    <node ID="business" TEXT="2. 业务分析" POSITION="right">
        <node TEXT="核心业务流程">
            <node TEXT="老人入住主链路">
                <node TEXT="提交入住申请"/>
                <node TEXT="↓"/>
                <node TEXT="校验老人是否已入住"/>
                <node TEXT="↓"/>
                <node TEXT="更新床位状态"/>
                <node TEXT="↓"/>
                <node TEXT="保存老人档案"/>
                <node TEXT="↓"/>
                <node TEXT="创建合同"/>
                <node TEXT="↓"/>
                <node TEXT="写入入住记录"/>
                <node TEXT="↓"/>
                <node TEXT="写入入住配置"/>
            </node>
            <node TEXT="健康评估主链路">
                <node TEXT="上传PDF体检报告"/>
                <node TEXT="↓"/>
                <node TEXT="OSS存储"/>
                <node TEXT="↓"/>
                <node TEXT="PDF解析成文本"/>
                <node TEXT="↓"/>
                <node TEXT="Redis缓存（24h）"/>
                <node TEXT="↓"/>
                <node TEXT="提交评估表单"/>
                <node TEXT="↓"/>
                <node TEXT="调用百度千帆AI"/>
                <node TEXT="↓"/>
                <node TEXT="返回结构化JSON"/>
                <node TEXT="↓"/>
                <node TEXT="落库保存结果"/>
            </node>
            <node TEXT="小程序登录主链路">
                <node TEXT="小程序wx.login()"/>
                <node TEXT="↓"/>
                <node TEXT="获取code换openid"/>
                <node TEXT="↓"/>
                <node TEXT="获取手机号"/>
                <node TEXT="↓"/>
                <node TEXT="查询/创建用户"/>
                <node TEXT="↓"/>
                <node TEXT="生成JWT Token"/>
                <node TEXT="↓"/>
                <node TEXT="后续请求带Token"/>
                <node TEXT="↓"/>
                <node TEXT="拦截器解析→ThreadLocal"/>
            </node>
            <node TEXT="IoT设备接入链路">
                <node TEXT="同步产品列表"/>
                <node TEXT="↓"/>
                <node TEXT="Redis缓存IoT产品"/>
                <node TEXT="↓"/>
                <node TEXT="注册设备"/>
                <node TEXT="↓"/>
                <node TEXT="校验唯一性"/>
                <node TEXT="↓"/>
                <node TEXT="调用华为云创建"/>
                <node TEXT="↓"/>
                <node TEXT="本地保存设备信息"/>
                <node TEXT="↓"/>
                <node TEXT="AMQP异步接收数据"/>
                <node TEXT="↓"/>
                <node TEXT="解析入库"/>
            </node>
        </node>
        <node TEXT="业务模块划分">
            <node TEXT="老人管理">
                <node TEXT="入住管理"/>
                <node TEXT="在住管理"/>
                <node TEXT="退住管理"/>
                <node TEXT="档案管理"/>
            </node>
            <node TEXT="护理服务">
                <node TEXT="护理项目"/>
                <node TEXT="护理等级"/>
                <node TEXT="护理计划"/>
                <node TEXT="护理执行"/>
            </node>
            <node TEXT="健康评估">
                <node TEXT="体检报告上传"/>
                <node TEXT="AI智能分析"/>
                <node TEXT="健康评分"/>
                <node TEXT="风险等级"/>
            </node>
            <node TEXT="设备管理">
                <node TEXT="产品同步"/>
                <node TEXT="设备注册"/>
                <node TEXT="设备绑定"/>
                <node TEXT="数据接收"/>
                <node TEXT="告警规则"/>
            </node>
            <node TEXT="小程序端">
                <node TEXT="微信登录"/>
                <node TEXT="预约服务"/>
                <node TEXT="房型查看"/>
                <node TEXT="健康数据查询"/>
            </node>
            <node TEXT="系统管理">
                <node TEXT="用户管理"/>
                <node TEXT="角色管理"/>
                <node TEXT="权限管理"/>
                <node TEXT="字典管理"/>
            </node>
        </node>
        <node TEXT="业务价值">
            <node TEXT="老人全生命周期闭环"/>
            <node TEXT="家属小程序降低沟通成本"/>
            <node TEXT="AI辅助健康评估"/>
            <node TEXT="设备数据进入业务系统"/>
        </node>
    </node>

    <!-- 第三层：技术架构 -->
    <node ID="architecture" TEXT="3. 技术架构" POSITION="right">
        <node TEXT="前端技术栈">
            <node TEXT="后台管理端">
                <node TEXT="Vue2"/>
                <node TEXT="Element UI"/>
                <node TEXT="Axios"/>
            </node>
            <node TEXT="小程序端">
                <node TEXT="微信原生小程序"/>
            </node>
        </node>
        <node TEXT="后端技术栈">
            <node TEXT="核心框架">
                <node TEXT="Spring Boot 2.5.15"/>
                <node TEXT="Spring MVC"/>
                <node TEXT="Spring Security 5.7"/>
            </node>
            <node TEXT="持久层">
                <node TEXT="MyBatis-Plus 3.5.2"/>
                <node TEXT="MySQL 8.0"/>
                <node TEXT="Druid连接池"/>
                <node TEXT="PageHelper分页"/>
            </node>
            <node TEXT="缓存">
                <node TEXT="Redis 6.x"/>
                <node TEXT="Lettuce客户端"/>
            </node>
            <node TEXT="认证授权">
                <node TEXT="JWT 0.9.1"/>
                <node TEXT="Spring Security"/>
                <node TEXT="ThreadLocal"/>
            </node>
        </node>
        <node TEXT="外部服务集成">
            <node TEXT="AI能力">
                <node TEXT="百度千帆大模型"/>
                <node TEXT="OpenAI兼容SDK"/>
                <node TEXT="Prompt工程"/>
            </node>
            <node TEXT="IoT平台">
                <node TEXT="华为云IoTDA"/>
                <node TEXT="AMQP消息接收"/>
                <node TEXT="设备影子查询"/>
            </node>
            <node TEXT="对象存储">
                <node TEXT="阿里云OSS 3.17"/>
            </node>
            <node TEXT="微信开放平台">
                <node TEXT="小程序登录"/>
                <node TEXT="获取手机号"/>
            </node>
        </node>
        <node TEXT="工具库">
            <node TEXT="Hutool 5.8"/>
            <node TEXT="FastJSON 2.0"/>
            <node TEXT="Lombok"/>
            <node TEXT="Swagger 3.0"/>
        </node>
        <node TEXT="调度与部署">
            <node TEXT="Quartz定时任务"/>
            <node TEXT="Nginx反向代理"/>
            <node TEXT="Docker容器化"/>
            <node TEXT="Jenkins CI/CD"/>
        </node>
        <node TEXT="系统架构图">
            <node TEXT="客户端层">
                <node TEXT="后台管理系统(Vue2)"/>
                <node TEXT="微信小程序"/>
                <node TEXT="IoT设备端(智能手环/床垫)"/>
            </node>
            <node TEXT="网关层">
                <node TEXT="Nginx(负载均衡/反向代理/静态资源)"/>
            </node>
            <node TEXT="应用层">
                <node TEXT="zzyl-admin(后台入口)"/>
                <node TEXT="zzyl-nursing-platform(护理业务)"/>
                <node TEXT="zzyl-system(系统管理)"/>
                <node TEXT="zzyl-framework(框架核心)"/>
                <node TEXT="zzyl-common(通用工具)"/>
                <node TEXT="zzyl-oss(对象存储)"/>
                <node TEXT="zzyl-quartz(定时任务)"/>
            </node>
            <node TEXT="数据层">
                <node TEXT="MySQL(主从复制)"/>
                <node TEXT="Redis(缓存集群)"/>
                <node TEXT="阿里云OSS(文件存储)"/>
                <node TEXT="华为云IoT(设备管理)"/>
            </node>
        </node>
    </node>

    <!-- 第四层：数据库设计 -->
    <node ID="database" TEXT="4. 数据库设计" POSITION="right">
        <node TEXT="核心业务表">
            <node TEXT="老人管理">
                <node TEXT="elder - 老人档案表">
                    <node TEXT="id/name/id_card/phone"/>
                    <node TEXT="gender/birth_date/status"/>
                </node>
                <node TEXT="check_in - 入住记录表">
                    <node TEXT="elder_id/bed_id"/>
                    <node TEXT="start_time/end_time"/>
                </node>
                <node TEXT="bed - 床位表">
                    <node TEXT="bed_number/room_id"/>
                    <node TEXT="status(空闲/已入住)"/>
                </node>
                <node TEXT="room - 房间表">
                    <node TEXT="room_number/floor_id"/>
                    <node TEXT="room_type_id"/>
                </node>
                <node TEXT="floor - 楼层表"/>
            </node>
            <node TEXT="护理服务">
                <node TEXT="nursing_level - 护理等级表">
                    <node TEXT="level_name/fee"/>
                    <node TEXT="description"/>
                </node>
                <node TEXT="nursing_project - 护理项目表">
                    <node TEXT="project_name/price"/>
                    <node TEXT="execute_cycle"/>
                </node>
                <node TEXT="nursing_plan - 护理计划表">
                    <node TEXT="elder_id/level_id"/>
                    <node TEXT="start_time/end_time"/>
                </node>
            </node>
            <node TEXT="健康评估">
                <node TEXT="health_assessment - 健康评估表">
                    <node TEXT="elder_id/report_url"/>
                    <node TEXT="health_score/risk_level"/>
                    <node TEXT="assessment_result(JSON)"/>
                </node>
            </node>
            <node TEXT="设备管理">
                <node TEXT="device - 设备表">
                    <node TEXT="iot_id/secret"/>
                    <node TEXT="device_name/product_key"/>
                    <node TEXT="binding_location/location_type"/>
                    <node TEXT="physical_location_type(楼层/房间/床位)"/>
                </node>
                <node TEXT="device_data - 设备数据表">
                    <node TEXT="iot_id/product_key"/>
                    <node TEXT="function_id/data_value"/>
                    <node TEXT="alarm_time"/>
                </node>
                <node TEXT="alert_rule - 告警规则表">
                    <node TEXT="product_key/function_id"/>
                    <node TEXT="operator/value/threshold"/>
                    <node TEXT="status(启用/禁用)"/>
                </node>
                <node TEXT="alert_data - 告警数据表">
                    <node TEXT="iot_id/data_value"/>
                    <node TEXT="alert_reason"/>
                    <node TEXT="status(待处理/已处理)"/>
                </node>
            </node>
            <node TEXT="小程序端">
                <node TEXT="family_member - 家属表">
                    <node TEXT="phone/name/open_id"/>
                    <node TEXT="avatar/gender"/>
                </node>
                <node TEXT="reservation - 预约表">
                    <node TEXT="name/mobile/time"/>
                    <node TEXT="visitor/type/status"/>
                </node>
            </node>
            <node TEXT="合同管理">
                <node TEXT="contract - 合同表">
                    <node TEXT="contract_no/elder_id"/>
                    <node TEXT="start_time/end_time"/>
                    <node TEXT="total_fee/status"/>
                </node>
            </node>
        </node>
        <node TEXT="表关系设计">
            <node TEXT="楼层 → 房间 → 床位 → 老人"/>
            <node TEXT="老人 → 入住记录 → 合同"/>
            <node TEXT="老人 → 护理计划 → 护理等级"/>
            <node TEXT="老人 → 健康评估"/>
            <node TEXT="设备 → 位置(楼层/房间/床位/老人)"/>
            <node TEXT="设备 → 设备数据 → 告警数据"/>
        </node>
        <node TEXT="索引设计">
            <node TEXT="device: iot_id + product_key"/>
            <node TEXT="device_data: idx_iot_id_product_key"/>
            <node TEXT="reservation: mobile + time (唯一索引)"/>
        </node>
    </node>

    <!-- 第五层：核心业务实现 -->
    <node ID="implementation" TEXT="5. 核心业务实现" POSITION="right">
        <node TEXT="健康评估模块（AI大模型应用）">
            <node TEXT="业务背景">
                <node TEXT="人工分析体检报告效率低(8秒+)"/>
                <node TEXT="专业门槛高，标准不统一"/>
            </node>
            <node TEXT="技术方案">
                <node TEXT="PDF解析">
                    <node TEXT="Apache PDFBox"/>
                    <node TEXT="解析为纯文本"/>
                </node>
                <node TEXT="Redis缓存策略">
                    <node TEXT="Key: healthReport"/>
                    <node TEXT="Field: 身份证号"/>
                    <node TEXT="Value: PDF文本内容"/>
                    <node TEXT="TTL: 24小时"/>
                </node>
                <node TEXT="AI调用">
                    <node TEXT="百度千帆大模型"/>
                    <node TEXT="OpenAI兼容SDK"/>
                    <node TEXT="Prompt工程：强制JSON输出"/>
                </node>
                <node TEXT="结构化落库">
                    <node TEXT="健康评分"/>
                    <node TEXT="风险等级"/>
                    <node TEXT="异常指标列表"/>
                    <node TEXT="八大系统评分"/>
                </node>
            </node>
            <node TEXT="性能优化">
                <node TEXT="优化前：8秒（每次都解析PDF）"/>
                <node TEXT="优化后：1秒（Redis缓存）"/>
                <node TEXT="提升：87.5%"/>
            </node>
            <node TEXT="核心代码">
                <node TEXT="上传PDF：PDFUtil.pdfToString()"/>
                <node TEXT="缓存：redisTemplate.opsForHash()"/>
                <node TEXT="AI调用：OpenAIClient.builder()"/>
                <node TEXT="解析：FastJSON.parseObject()"/>
            </node>
        </node>
        <node TEXT="设备管理模块（华为云IoT集成）">
            <node TEXT="业务背景">
                <node TEXT="智能手环/床垫等设备统一管理"/>
                <node TEXT="设备数据实时接收"/>
            </node>
            <node TEXT="技术方案">
                <node TEXT="产品同步">
                    <node TEXT="华为云IoTDA SDK"/>
                    <node TEXT="ListProductsRequest"/>
                    <node TEXT="Redis缓存产品列表"/>
                </node>
                <node TEXT="设备注册">
                    <node TEXT="三重校验：名称/节点号/绑定位置"/>
                    <node TEXT="调用华为云API创建"/>
                    <node TEXT="本地保存设备密钥"/>
                </node>
                <node TEXT="设备绑定位置设计">
                    <node TEXT="locationType=0: 随身设备→绑定老人"/>
                    <node TEXT="locationType=1: 固定设备→绑定物理位置"/>
                    <node TEXT="physicalLocationType: 楼层/房间/床位"/>
                </node>
                <node TEXT="AMQP数据接收">
                    <node TEXT="多连接提高消费能力"/>
                    <node TEXT="异步线程池处理"/>
                    <node TEXT="批量入库优化"/>
                </node>
            </node>
            <node TEXT="核心代码">
                <node TEXT="产品同步：iotDAClient.listProducts()"/>
                <node TEXT="设备注册：CreateDeviceRequest"/>
                <node TEXT="AMQP消费：AmqpClient implements ApplicationRunner"/>
                <node TEXT="消息处理：executorService.submit()"/>
            </node>
        </node>
        <node TEXT="小程序登录模块（ThreadLocal应用）">
            <node TEXT="业务背景">
                <node TEXT="小程序无Cookie机制"/>
                <node TEXT="多线程环境下用户信息传递"/>
            </node>
            <node TEXT="技术方案">
                <node TEXT="微信登录流程">
                    <node TEXT="wx.login()获取code"/>
                    <node TEXT="code换openid"/>
                    <node TEXT="获取手机号"/>
                    <node TEXT="自动注册/登录"/>
                </node>
                <node TEXT="JWT Token认证">
                    <node TEXT="无状态认证"/>
                    <node TEXT="Token过期刷新"/>
                </node>
                <node TEXT="ThreadLocal存储">
                    <node TEXT="用户ID存储"/>
                    <node TEXT="线程隔离"/>
                    <node TEXT="拦截器解析"/>
                </node>
            </node>
            <node TEXT="内存泄漏解决">
                <node TEXT="问题：线程池复用导致ThreadLocal数据残留"/>
                <node TEXT="解决：afterCompletion中调用remove()"/>
                <node TEXT="保证：try-finally确保清理"/>
            </node>
            <node TEXT="核心代码">
                <node TEXT="UserThreadLocal.set()/get()/remove()"/>
                <node TEXT="MemberInterceptor拦截器"/>
                <node TEXT="preHandle: 解析Token存储"/>
                <node TEXT="afterCompletion: 清理ThreadLocal"/>
            </node>
        </node>
        <node TEXT="合同管理模块">
            <node TEXT="定时任务维护合同状态"/>
            <node TEXT="Quartz调度器"/>
            <node TEXT="自动更新到期合同"/>
        </node>
    </node>

    <!-- 第六层：系统设计 -->
    <node ID="design" TEXT="6. 系统设计" POSITION="right">
        <node TEXT="分层架构">
            <node TEXT="Controller层">
                <node TEXT="接收请求"/>
                <node TEXT="参数校验"/>
                <node TEXT="返回响应"/>
            </node>
            <node TEXT="Service层">
                <node TEXT="业务逻辑处理"/>
                <node TEXT="事务管理"/>
                <node TEXT="调用外部服务"/>
            </node>
            <node TEXT="Mapper层">
                <node TEXT="MyBatis-Plus"/>
                <node TEXT="数据访问"/>
            </node>
            <node TEXT="Entity层">
                <node TEXT="实体类"/>
                <node TEXT="DTO/VO转换"/>
            </node>
        </node>
        <node TEXT="模块划分">
            <node TEXT="zzyl-admin - 后台启动入口"/>
            <node TEXT="zzyl-framework - 框架核心">
                <node TEXT="认证拦截器"/>
                <node TEXT="Redis配置"/>
                <node TEXT="线程池配置"/>
            </node>
            <node TEXT="zzyl-common - 通用工具">
                <node TEXT="常量定义"/>
                <node TEXT="AI调用封装"/>
                <node TEXT="工具方法"/>
            </node>
            <node TEXT="zzyl-nursing-platform - 养老业务核心"/>
            <node TEXT="zzyl-system - 系统管理"/>
            <node TEXT="zzyl-quartz - 定时任务"/>
            <node TEXT="zzyl-oss - 对象存储"/>
        </node>
        <node TEXT="缓存设计">
            <node TEXT="应用场景">
                <node TEXT="护理等级/项目/计划 - 高频读低频写"/>
                <node TEXT="IoT产品列表 - 第三方数据缓存"/>
                <node TEXT="健康评估PDF内容 - 24小时缓存"/>
                <node TEXT="用户Token - 登录态管理"/>
            </node>
            <node TEXT="缓存策略">
                <node TEXT="读穿透：先读缓存，miss则读DB回写"/>
                <node TEXT="写穿透：先更新DB，再删除缓存"/>
                <node TEXT="过期策略：根据数据变化频率设置"/>
            </node>
            <node TEXT="数据结构选择">
                <node TEXT="String: 产品列表、Token"/>
                <node TEXT="Hash: PDF内容(便于管理)"/>
            </node>
        </node>
        <node TEXT="安全设计">
            <node TEXT="认证">
                <node TEXT="JWT Token无状态认证"/>
                <node TEXT="Spring Security权限控制"/>
            </node>
            <node TEXT="授权">
                <node TEXT="角色菜单权限"/>
                <node TEXT="数据权限隔离"/>
            </node>
            <node TEXT="防护">
                <node TEXT="验证码"/>
                <node TEXT="防重复提交"/>
                <node TEXT="接口幂等性"/>
            </node>
        </node>
        <node TEXT="异常处理">
            <node TEXT="统一异常处理器"/>
            <node TEXT="业务异常BaseException"/>
            <node TEXT="错误码规范"/>
        </node>
        <node TEXT="日志设计">
            <node TEXT="操作日志记录"/>
            <node TEXT="登录日志"/>
            <node TEXT="异常日志"/>
        </node>
    </node>

    <!-- 第七层：开发流程 -->
    <node ID="process" TEXT="7. 开发流程" POSITION="right">
        <node TEXT="开发周期">
            <node TEXT="项目周期：6个月"/>
            <node TEXT="团队规模：5人"/>
            <node TEXT="角色：核心后端开发"/>
        </node>
        <node TEXT="开发阶段">
            <node TEXT="需求分析">
                <node TEXT="业务场景梳理"/>
                <node TEXT="用例识别"/>
                <node TEXT="边界定义"/>
            </node>
            <node TEXT="数据库设计">
                <node TEXT="ER图设计"/>
                <node TEXT="表结构定义"/>
                <node TEXT="索引规划"/>
            </node>
            <node TEXT="接口设计">
                <node TEXT="API规范定义"/>
                <node TEXT="Swagger文档"/>
                <node TEXT="前后端联调"/>
            </node>
            <node TEXT="编码开发">
                <node TEXT="核心模块开发"/>
                <node TEXT="第三方集成"/>
                <node TEXT="单元测试"/>
            </node>
            <node TEXT="测试优化">
                <node TEXT="功能测试"/>
                <node TEXT="性能优化"/>
                <node TEXT="Bug修复"/>
            </node>
            <node TEXT="部署上线">
                <node TEXT="Docker镜像构建"/>
                <node TEXT="Nginx配置"/>
                <node TEXT="生产环境部署"/>
            </node>
        </node>
        <node TEXT="技术选型决策">
            <node TEXT="AI模型选择百度千帆">
                <node TEXT="合规性：数据不出境"/>
                <node TEXT="中文优化：体检报告分析更准确"/>
                <node TEXT="成本可控：免费额度"/>
                <node TEXT="SDK兼容：OpenAI兼容"/>
            </node>
            <node TEXT="IoT平台选择华为云">
                <node TEXT="功能完善：设备管理/数据流转"/>
                <node TEXT="AMQP支持：实时推送"/>
                <node TEXT="SDK成熟"/>
            </node>
            <node TEXT="单体架构而非微服务">
                <node TEXT="业务复杂度适中"/>
                <node TEXT="降低部署复杂度"/>
                <node TEXT="优先业务落地"/>
            </node>
        </node>
    </node>

    <!-- 第八层：测试与优化 -->
    <node ID="optimization" TEXT="8. 测试与优化" POSITION="right">
        <node TEXT="性能优化清单">
            <node TEXT="健康评估响应时间">
                <node TEXT="优化前：8秒"/>
                <node TEXT="优化后：1秒"/>
                <node TEXT="手段：Redis缓存PDF内容"/>
            </node>
            <node TEXT="设备数据接收延迟">
                <node TEXT="优化前：5秒"/>
                <node TEXT="优化后：&lt;1秒"/>
                <node TEXT="手段：AMQP多连接+异步处理"/>
            </node>
            <node TEXT="Token认证时间">
                <node TEXT="优化前：50ms"/>
                <node TEXT="优化后：&lt;10ms"/>
                <node TEXT="手段：JWT无状态+ThreadLocal"/>
            </node>
            <node TEXT="产品列表查询">
                <node TEXT="优化前：200ms"/>
                <node TEXT="优化后：&lt;10ms"/>
                <node TEXT="手段：Redis缓存"/>
            </node>
        </node>
        <node TEXT="问题与解决">
            <node TEXT="问题1：健康评估响应慢">
                <node TEXT="分析：每次评估都解析PDF"/>
                <node TEXT="解决：Redis缓存PDF文本"/>
                <node TEXT="效果：响应时间降低87.5%"/>
            </node>
            <node TEXT="问题2：ThreadLocal内存泄漏">
                <node TEXT="分析：线程池复用导致数据残留"/>
                <node TEXT="解决：拦截器afterCompletion清理"/>
                <node TEXT="效果：彻底解决内存泄漏"/>
            </node>
            <node TEXT="问题3：设备注册数据一致性">
                <node TEXT="分析：华为云成功，本地失败"/>
                <node TEXT="解决：本地事务失败时补偿删除"/>
                <node TEXT="改进：考虑消息队列最终一致性"/>
            </node>
        </node>
        <node TEXT="测试覆盖">
            <node TEXT="单元测试"/>
            <node TEXT="接口测试"/>
            <node TEXT="集成测试"/>
        </node>
    </node>

    <!-- 第九层：部署上线 -->
    <node ID="deployment" TEXT="9. 部署上线" POSITION="right">
        <node TEXT="部署架构">
            <node TEXT="前端">
                <node TEXT="Vue构建产物"/>
                <node TEXT="Nginx静态资源托管"/>
            </node>
            <node TEXT="后端">
                <node TEXT="SpringBoot JAR"/>
                <node TEXT="Docker容器化"/>
            </node>
            <node TEXT="数据库">
                <node TEXT="MySQL主从复制"/>
                <node TEXT="Redis缓存集群"/>
            </node>
        </node>
        <node TEXT="CI/CD">
            <node TEXT="Jenkins流水线"/>
            <node TEXT="自动化构建"/>
            <node TEXT="自动化部署"/>
        </node>
        <node TEXT="监控运维">
            <node TEXT="服务监控"/>
            <node TEXT="日志收集"/>
            <node TEXT="告警通知"/>
        </node>
    </node>

    <!-- 第十层：项目总结 -->
    <node ID="summary" TEXT="10. 项目总结" POSITION="right">
        <node TEXT="技术收获">
            <node TEXT="AI大模型应用">
                <node TEXT="Prompt工程设计"/>
                <node TEXT="JSON结构化输出"/>
                <node TEXT="响应时间优化"/>
            </node>
            <node TEXT="IoT平台集成">
                <node TEXT="设备统一管理"/>
                <node TEXT="AMQP消息消费"/>
                <node TEXT="设备绑定位置设计"/>
            </node>
            <node TEXT="ThreadLocal深入理解">
                <node TEXT="线程隔离原理"/>
                <node TEXT="内存泄漏防护"/>
                <node TEXT="拦截器设计"/>
            </node>
            <node TEXT="Redis多场景应用">
                <node TEXT="数据结构选择"/>
                <node TEXT="缓存策略设计"/>
                <node TEXT="过期策略"/>
            </node>
        </node>
        <node TEXT="项目亮点">
            <node TEXT="响应时间从8秒降到1秒"/>
            <node TEXT="接入智能设备200+台"/>
            <node TEXT="护理人员效率提升30%"/>
            <node TEXT="健康评估准确率92%"/>
        </node>
        <node TEXT="后续规划">
            <node TEXT="引入消息队列异步处理"/>
            <node TEXT="WebSocket实时推送"/>
            <node TEXT="微服务拆分（按需）"/>
            <node TEXT="性能监控告警"/>
        </node>
        <node TEXT="面试话术">
            <node TEXT="开场白（30秒）">
                <node TEXT="智颐养老系统，面向养老院的综合管理平台"/>
                <node TEXT="后台管理+小程序端"/>
                <node TEXT="核心负责：健康评估/设备管理/小程序登录"/>
                <node TEXT="成果：评估5000+份，接入设备200+台"/>
            </node>
            <node TEXT="深挖应对">
                <node TEXT="为什么选择百度千帆？"/>
                <node TEXT="为什么选择华为云IoT？"/>
                <node TEXT="ThreadLocal原理是什么？"/>
                <node TEXT="如何保证AI分析准确性？"/>
            </node>
        </node>
    </node>

    <!-- 技术深度问题 -->
    <node ID="deep-dive" TEXT="技术深挖问题" POSITION="left">
        <node TEXT="Redis相关">
            <node TEXT="应用场景有哪些？">
                <node TEXT="健康评估：缓存PDF内容"/>
                <node TEXT="设备管理：缓存产品列表"/>
                <node TEXT="系统模块：缓存字典/Token"/>
            </node>
            <node TEXT="缓存策略是什么？">
                <node TEXT="读穿透"/>
                <node TEXT="写穿透"/>
                <node TEXT="过期策略"/>
            </node>
            <node TEXT="如何防止缓存穿透？">
                <node TEXT="参数校验"/>
                <node TEXT="空值缓存"/>
                <node TEXT="布隆过滤器"/>
            </node>
        </node>
        <node TEXT="AI相关">
            <node TEXT="为什么选择百度千帆？">
                <node TEXT="合规性"/>
                <node TEXT="中文优化"/>
                <node TEXT="成本可控"/>
                <node TEXT="SDK兼容"/>
            </node>
            <node TEXT="如何保证AI分析准确性？">
                <node TEXT="Prompt工程"/>
                <node TEXT="结构化输出"/>
                <node TEXT="人工审核"/>
            </node>
            <node TEXT="Prompt如何设计？">
                <node TEXT="明确角色定位"/>
                <node TEXT="规定输出格式"/>
                <node TEXT="限制输出范围"/>
            </node>
        </node>
        <node TEXT="ThreadLocal相关">
            <node TEXT="原理是什么？">
                <node TEXT="每个Thread维护ThreadLocalMap"/>
                <node TEXT="Key是ThreadLocal对象"/>
                <node TEXT="Value是存储值"/>
            </node>
            <node TEXT="为什么必须调用remove()？">
                <node TEXT="线程池复用问题"/>
                <node TEXT="内存泄漏"/>
                <node TEXT="数据污染"/>
            </node>
            <node TEXT="内存泄漏原因？">
                <node TEXT="Key是弱引用会被GC"/>
                <node TEXT="Value是强引用不会自动回收"/>
                <node TEXT="线程池复用时Value残留"/>
            </node>
        </node>
        <node TEXT="IoT相关">
            <node TEXT="为什么选择华为云IoT？">
                <node TEXT="功能完善"/>
                <node TEXT="AMQP支持"/>
                <node TEXT="SDK成熟"/>
                <node TEXT="成本可控"/>
            </node>
            <node TEXT="设备注册如何保证一致性？">
                <node TEXT="本地事务"/>
                <node TEXT="补偿机制"/>
                <node TEXT="改进：消息队列"/>
            </node>
        </node>
        <node TEXT="架构设计">
            <node TEXT="为什么用单体架构？">
                <node TEXT="业务复杂度适中"/>
                <node TEXT="降低部署复杂度"/>
                <node TEXT="事务一致性简单"/>
            </node>
            <node TEXT="如何设计高并发健康评估接口？">
                <node TEXT="缓存层"/>
                <node TEXT="异步处理"/>
                <node TEXT="限流降级"/>
            </node>
        </node>
    </node>

    <!-- 性能数据 -->
    <node ID="performance" TEXT="性能数据汇总" POSITION="left">
        <node TEXT="响应时间优化">
            <node TEXT="健康评估：8秒→1秒（提升87.5%）"/>
            <node TEXT="设备数据接收：5秒→&lt;1秒"/>
            <node TEXT="Token认证：50ms→&lt;10ms"/>
            <node TEXT="产品查询：200ms→&lt;10ms"/>
        </node>
        <node TEXT="业务数据">
            <node TEXT="评估体检报告：5000+份"/>
            <node TEXT="接入智能设备：200+台"/>
            <node TEXT="设备在线率：98%+"/>
            <node TEXT="准确率：92%"/>
        </node>
        <node TEXT="效率提升">
            <node TEXT="护理人员效率：+30%"/>
            <node TEXT="设备管理效率：+50%"/>
            <node TEXT="人力成本：减少1人"/>
        </node>
    </node>

    <!-- 代码模块清单 -->
    <node ID="modules" TEXT="代码模块清单" POSITION="left">
        <node TEXT="Controller层">
            <node TEXT="ElderController - 老人管理"/>
            <node TEXT="CheckInController - 入住管理"/>
            <node TEXT="ContractController - 合同管理"/>
            <node TEXT="HealthAssessmentController - 健康评估"/>
            <node TEXT="DeviceController - 设备管理"/>
            <node TEXT="DeviceDataController - 设备数据"/>
            <node TEXT="AlertRuleController - 告警规则"/>
            <node TEXT="FamilyMemberController - 家属管理"/>
            <node TEXT="NursingLevelController - 护理等级"/>
            <node TEXT="NursingPlanController - 护理计划"/>
        </node>
        <node TEXT="Service层">
            <node TEXT="核心业务逻辑"/>
            <node TEXT="AI调用封装"/>
            <node TEXT="IoT SDK集成"/>
        </node>
        <node TEXT="工具类">
            <node TEXT="UserThreadLocal - 线程本地存储"/>
            <node TEXT="PDFUtil - PDF解析"/>
            <node TEXT="AIModelInvoker - AI调用封装"/>
        </node>
    </node>
</node>
</map>