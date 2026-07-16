<map version="1.0.1">
<!-- 设备管理功能-项目复盘笔记 -->

<node ID="root" TEXT="设备管理功能-项目复盘">
    <!-- 功能概述 -->
    <node ID="overview" TEXT="一、功能概述" POSITION="right">
        <node TEXT="业务背景">
            <node TEXT="养老院智能管理系统对接华为云IoT"/>
            <node TEXT="物联网设备统一管理"/>
            <node TEXT="为智能监测/健康预警提供支撑"/>
        </node>
        <node TEXT="核心功能">
            <node TEXT="产品同步 - 华为云→Redis缓存"/>
            <node TEXT="设备注册 - 华为云+本地数据库"/>
            <node TEXT="设备绑定 - 位置/老人绑定"/>
            <node TEXT="设备管理 - CRUD操作"/>
            <node TEXT="数据接收 - AMQP异步接收"/>
        </node>
        <node TEXT="技术栈">
            <node TEXT="华为云IoTDA SDK - 设备管理API"/>
            <node TEXT="Redis - 产品/设备数据缓存"/>
            <node TEXT="AMQP(Qpid JMS) - 实时数据接收"/>
            <node TEXT="MyBatis-Plus - 持久层"/>
            <node TEXT="Spring Boot - 后端框架"/>
            <node TEXT="Hutool - JSON/HTTP工具"/>
        </node>
    </node>

    <!-- 核心业务流程 -->
    <node ID="flow" TEXT="二、核心业务流程" POSITION="right">
        <node TEXT="整体架构图">
            <node TEXT="华为云IoT平台">
                <node TEXT="产品管理"/>
                <node TEXT="设备管理"/>
                <node TEXT="数据流转"/>
                <node TEXT="AMQP队列"/>
            </node>
            <node TEXT="本地系统">
                <node TEXT="产品同步→Redis"/>
                <node TEXT="设备注册→MySQL"/>
                <node TEXT="设备管理CRUD"/>
                <node TEXT="数据接收→MySQL"/>
            </node>
        </node>
        <node TEXT="设备注册流程">
            <node TEXT="前端提交设备注册信息"/>
            <node TEXT="↓"/>
            <node TEXT="参数校验">
                <node TEXT="设备名称唯一性"/>
                <node TEXT="设备标识(nodeId)唯一性"/>
                <node TEXT="位置+产品组合唯一性"/>
            </node>
            <node TEXT="↓"/>
            <node TEXT="生成设备密钥(UUID)"/>
            <node TEXT="↓"/>
            <node TEXT="调用华为云API注册设备"/>
            <node TEXT="↓"/>
            <node TEXT="获取IoT设备ID(iotId)"/>
            <node TEXT="↓"/>
            <node TEXT="保存到本地数据库"/>
        </node>
        <node TEXT="产品同步流程">
            <node TEXT="触发同步请求"/>
            <node TEXT="↓"/>
            <node TEXT="调用华为云ListProducts API"/>
            <node TEXT="↓"/>
            <node TEXT="获取产品列表(最多50条)"/>
            <node TEXT="↓"/>
            <node TEXT="序列化JSON存入Redis"/>
            <node TEXT="Key: iot:all_product_list"/>
        </node>
    </node>

    <!-- 核心代码实现 -->
    <node ID="code" TEXT="三、核心代码实现" POSITION="right">
        <node TEXT="华为云IoT客户端配置">
            <node TEXT="IotClientConfig.java"/>
            <node TEXT="@Bean注入IoTDAClient"/>
            <node TEXT="AK/SK认证"/>
            <node TEXT="withDerivedPredicate"/>
            <node TEXT="面试要点">
                <node TEXT="@Bean单例复用"/>
                <node TEXT="AK/SK认证安全性"/>
                <node TEXT="衍生算法配置"/>
            </node>
        </node>
        <node TEXT="产品同步到Redis">
            <node TEXT="DeviceServiceImpl.syncProductList()"/>
            <node TEXT="ListProductsRequest.setLimit(50)"/>
            <node TEXT="iotDAClient.listProducts()"/>
            <node TEXT="redisTemplate.opsForValue().set()"/>
            <node TEXT="面试要点">
                <node TEXT="减少API调用频率"/>
                <node TEXT="提高响应速度"/>
                <node TEXT="产品变化频率低"/>
                <node TEXT="手动触发同步无过期"/>
            </node>
        </node>
        <node TEXT="查询产品列表(从Redis)">
            <node TEXT="DeviceServiceImpl.allProduct()"/>
            <node TEXT="redisTemplate.opsForValue().get()"/>
            <node TEXT="JSONUtil.toList()"/>
            <node TEXT="Collections.emptyList()返回空集合"/>
        </node>
        <node TEXT="设备注册(核心业务)">
            <node TEXT="DeviceServiceImpl.registerDevice()"/>
            <node TEXT="三重校验">
                <node TEXT="设备名称唯一性"/>
                <node TEXT="设备标识唯一性"/>
                <node TEXT="位置+产品组合唯一性"/>
            </node>
            <node TEXT="调用华为云AddDeviceRequest"/>
            <node TEXT="UUID生成密钥"/>
            <node TEXT="保存本地数据库"/>
            <node TEXT="面试要点">
                <node TEXT="三重校验机制"/>
                <node TEXT="分布式事务问题"/>
                <node TEXT="密钥UUID生成"/>
                <node TEXT="先云后库顺序"/>
            </node>
        </node>
        <node TEXT="查询设备详情">
            <node TEXT="DeviceServiceImpl.queryDeviceDetail()"/>
            <node TEXT="本地数据库+华为云API组合"/>
            <node TEXT="ShowDeviceRequest"/>
            <node TEXT="DateTimeZoneConverter.utcToShanghai()"/>
            <node TEXT="面试要点">
                <node TEXT="数据来源组合"/>
                <node TEXT="时区转换UTC→本地"/>
                <node TEXT="状态实时获取"/>
            </node>
        </node>
        <node TEXT="查询设备影子">
            <node TEXT="DeviceServiceImpl.queryServiceProperties()"/>
            <node TEXT="ShowDeviceShadowRequest"/>
            <node TEXT="shadow[0].reported.properties"/>
            <node TEXT="面试要点">
                <node TEXT="设备影子概念"/>
                <node TEXT="华为云时间格式"/>
                <node TEXT="属性解析处理"/>
            </node>
        </node>
        <node TEXT="设备修改">
            <node TEXT="DeviceServiceImpl.customUpdateDevice()"/>
            <node TEXT="先修改IoTDA平台"/>
            <node TEXT="校验排除当前设备(.ne)"/>
            <node TEXT="修改本地数据库"/>
        </node>
        <node TEXT="设备删除">
            <node TEXT="DeviceServiceImpl.customDeleteDeviceById()"/>
            <node TEXT="先删除华为云"/>
            <node TEXT="HTTP状态200或204"/>
            <node TEXT="再删除本地数据库"/>
            <node TEXT="面试要点">
                <node TEXT="删除顺序先云后库"/>
                <node TEXT="状态码200/204"/>
                <node TEXT="事务补偿机制"/>
            </node>
        </node>
    </node>

    <!-- AMQP数据接收 -->
    <node ID="amqp" TEXT="四、AMQP数据接收" POSITION="right">
        <node TEXT="AMQP客户端配置">
            <node TEXT="AmqpClient.java"/>
            <node TEXT="implements ApplicationRunner"/>
            <node TEXT="Spring Boot启动后自动执行"/>
            <node TEXT="多连接(4个)提高消费能力"/>
            <node TEXT="Session.AUTO_ACKNOWLEDGE"/>
            <node TEXT="面试要点">
                <node TEXT="ApplicationRunner自动执行"/>
                <node TEXT="多连接提高消费"/>
                <node TEXT="SDK自动确认"/>
            </node>
        </node>
        <node TEXT="消息处理">
            <node TEXT="MessageListener.messageListener"/>
            <node TEXT="executorService.submit()异步处理"/>
            <node TEXT="processMessage()解析消息"/>
            <node TEXT="JSONUtil.parseObj()"/>
            <node TEXT="deviceDataService.batchInsertDeviceData()"/>
            <node TEXT="面试要点">
                <node TEXT="异步处理避免阻塞"/>
                <node TEXT="华为云JSON格式"/>
                <node TEXT="幂等性考虑"/>
            </node>
        </node>
    </node>

    <!-- 数据模型设计 -->
    <node ID="data" TEXT="五、数据模型设计" POSITION="right">
        <node TEXT="Device实体">
            <node TEXT="id - 主键"/>
            <node TEXT="iotId - 物联网设备ID(华为云)"/>
            <node TEXT="secret - 设备密钥"/>
            <node TEXT="deviceName - 设备名称"/>
            <node TEXT="nodeId - 设备标识码(IMEI/MAC)"/>
            <node TEXT="productKey/productName - 产品信息"/>
            <node TEXT="bindingLocation - 绑定位置ID"/>
            <node TEXT="locationType - 位置类型(0随身/1固定)"/>
            <node TEXT="physicalLocationType - 物理位置(0楼层/1房间/2床位)"/>
            <node TEXT="deviceDescription - 位置备注"/>
            <node TEXT="haveEntranceGuard - 是否门禁"/>
        </node>
        <node TEXT="设备绑定位置设计">
            <node TEXT="随身设备(locationType=0)">
                <node TEXT="绑定老人"/>
                <node TEXT="bindingLocation=老人ID"/>
                <node TEXT="physicalLocationType=-1"/>
            </node>
            <node TEXT="固定设备(locationType=1)">
                <node TEXT="绑定物理位置"/>
                <node TEXT="physicalLocationType: 楼层/房间/床位"/>
                <node TEXT="bindingLocation=位置ID"/>
            </node>
        </node>
        <node TEXT="ProductVo">
            <node TEXT="productId - 产品ID(ProductKey)"/>
            <node TEXT="name - 产品名称"/>
        </node>
        <node TEXT="DeviceDetailVo">
            <node TEXT="iotId/deviceName/nodeId"/>
            <node TEXT="secret/productKey/productName"/>
            <node TEXT="locationType/bindingLocation"/>
            <node TEXT="deviceStatus(ONLINE/OFFLINE/ABNORMAL)"/>
            <node TEXT="activeTime/createTime"/>
        </node>
    </node>

    <!-- Redis缓存设计 -->
    <node ID="redis" TEXT="六、Redis缓存设计" POSITION="right">
        <node TEXT="缓存Key设计">
            <node TEXT="iot:all_product_list - 产品列表"/>
            <node TEXT="iot:device_last_data - 设备最新数据"/>
        </node>
        <node TEXT="缓存使用场景">
            <node TEXT="iot:all_product_list - String - 手动更新"/>
            <node TEXT="iot:device_last_data - Hash - 实时更新"/>
        </node>
        <node TEXT="设备数据缓存">
            <node TEXT="RoomServiceImpl.getRoomsWithDeviceByFloorId()"/>
            <node TEXT="redisTemplate.opsForHash().get()"/>
            <node TEXT="房间设备+床位设备"/>
            <node TEXT="面试要点">
                <node TEXT="Hash结构存储"/>
                <node TEXT="避免重复API调用"/>
                <node TEXT="AMQP实时更新"/>
            </node>
        </node>
    </node>

    <!-- 时区转换工具 -->
    <node ID="timezone" TEXT="七、时区转换工具" POSITION="right">
        <node TEXT="DateTimeZoneConverter.java"/>
        <node TEXT="UTC_ZONE = ZoneOffset.UTC"/>
        <node TEXT="SHANGHAI_ZONE = Asia/Shanghai"/>
        <node TEXT="utcToShanghai(LocalDateTime)"/>
        <node TEXT="面试要点">
            <node TEXT="华为云返回UTC时间"/>
            <node TEXT="Java 8 ZoneId/ZonedDateTime"/>
        </node>
    </node>

    <!-- 面试常见问题 -->
    <node ID="qa" TEXT="八、面试常见问题" POSITION="right">
        <node TEXT="Q1：为什么选择华为云IoT？">
            <node TEXT="国内合规：数据不出境"/>
            <node TEXT="功能完善：设备管理/数据流转"/>
            <node TEXT="AMQP支持：实时推送"/>
            <node TEXT="SDK成熟：Java SDK"/>
            <node TEXT="成本可控"/>
        </node>
        <node TEXT="Q2：产品列表缓存到Redis？">
            <node TEXT="减少API调用频率"/>
            <node TEXT="提高响应速度"/>
            <node TEXT="产品变化频率低"/>
            <node TEXT="降低云服务费用"/>
        </node>
        <node TEXT="Q3：设备注册数据一致性？">
            <node TEXT="当前：先华为云后本地"/>
            <node TEXT="问题：华为云成功本地失败"/>
            <node TEXT="改进：消息队列/定时同步/补偿"/>
        </node>
        <node TEXT="Q4：AMQP消息重复消费？">
            <node TEXT="消息ID去重"/>
            <node TEXT="数据库唯一索引"/>
            <node TEXT="幂等性设计"/>
        </node>
        <node TEXT="Q5：设备绑定位置设计？">
            <node TEXT="随身设备绑老人"/>
            <node TEXT="固定设备绑物理位置"/>
            <node TEXT="物理位置三级"/>
            <node TEXT="同一位置不能绑同类型"/>
        </node>
        <node TEXT="Q6：AMQP连接断开处理？">
            <node TEXT="自动重连配置"/>
            <node TEXT="reconnectDelay/maxReconnectDelay"/>
            <node TEXT="JmsConnectionListener监听"/>
        </node>
        <node TEXT="Q7：设备列表查询优化？">
            <node TEXT="数据库索引"/>
            <node TEXT="分页查询"/>
            <node TEXT="设备状态缓存"/>
            <node TEXT="异步并行查询"/>
        </node>
    </node>

    <!-- 项目亮点 -->
    <node ID="highlight" TEXT="九、项目亮点总结" POSITION="right">
        <node TEXT="技术亮点">
            <node TEXT="华为云IoT集成">
                <node TEXT="官方SDK"/>
                <node TEXT="AK/SK认证"/>
                <node TEXT="多连接AMQP"/>
            </node>
            <node TEXT="Redis缓存策略">
                <node TEXT="产品列表缓存"/>
                <node TEXT="设备数据缓存"/>
                <node TEXT="Hash结构"/>
            </node>
            <node TEXT="数据一致性">
                <node TEXT="三重校验"/>
                <node TEXT="先云后库"/>
                <node TEXT="完善异常处理"/>
            </node>
            <node TEXT="时区处理"/>
        </node>
        <node TEXT="业务亮点">
            <node TEXT="灵活绑定机制"/>
            <node TEXT="实时数据接收"/>
            <node TEXT="完善设备管理"/>
        </node>
    </node>

    <!-- 扩展思考 -->
    <node ID="extend" TEXT="十、扩展思考" POSITION="right">
        <node TEXT="可优化方向">
            <node TEXT="分布式事务：Seata/消息队列"/>
            <node TEXT="设备状态同步"/>
            <node TEXT="批量操作"/>
            <node TEXT="监控告警"/>
        </node>
        <node TEXT="面试加分项">
            <node TEXT="IoT协议：MQTT/AMQP"/>
            <node TEXT="Redis高级：Pipeline/Lua"/>
            <node TEXT="分布式：CAP/最终一致性"/>
        </node>
    </node>
</node>
</map>