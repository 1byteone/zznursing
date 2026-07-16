<map version="1.0.1">
<!-- 设备管理功能-面试提问问题清单 -->

<node ID="root" TEXT="设备管理功能-面试提问问题清单">
    <!-- 业务理解类 -->
    <node ID="business" TEXT="一、业务理解类" POSITION="right">
        <node TEXT="Q1: 请介绍一下设备管理功能在整个养老系统中的作用？">
            <node TEXT="对接华为云IoT平台实现物联网设备统一管理"/>
            <node TEXT="为智能监测、健康预警等业务提供基础支撑"/>
            <node TEXT="包括产品同步、设备注册、设备绑定、数据接收等核心功能"/>
        </node>
        <node TEXT="Q2: 设备绑定位置的设计思路是什么？">
            <node TEXT="随身设备绑定老人固定设备绑定物理位置"/>
            <node TEXT="物理位置支持三级: 楼层→房间→床位"/>
            <node TEXT="locationType区分类型"/>
            <node TEXT="physicalLocationType区分物理位置层级"/>
            <node TEXT="同一位置不能绑定相同类型的设备"/>
        </node>
    </node>

    <!-- 技术实现类 -->
    <node ID="tech" TEXT="二、技术实现类" POSITION="right">
        <node TEXT="Q3: 产品列表为什么要缓存到Redis？">
            <node TEXT="减少华为云API调用频率(有调用限制)"/>
            <node TEXT="提高响应速度(Redis比HTTP请求快)"/>
            <node TEXT="产品列表变化频率低适合缓存"/>
            <node TEXT="使用String类型存储JSON手动触发同步"/>
        </node>
        <node TEXT="Q4: 设备注册时做了哪些校验？">
            <node TEXT="设备名称唯一性校验"/>
            <node TEXT="设备标识(nodeId)唯一性校验"/>
            <node TEXT="位置+产品组合唯一性校验"/>
            <node TEXT="防止数据重复、业务冲突"/>
        </node>
        <node TEXT="Q5: 设备注册时如何保证数据一致性？">
            <node TEXT="当前实现: 先调用华为云API再保存本地数据库"/>
            <node TEXT="潜在问题: 华为云成功但本地失败导致不一致"/>
            <node TEXT="改进方案: 消息队列实现最终一致性"/>
            <node TEXT="定时同步任务、补偿机制"/>
        </node>
        <node TEXT="Q6: AMQP消息是如何接收和处理的？">
            <node TEXT="实现ApplicationRunner接口启动后自动连接"/>
            <node TEXT="配置多个连接(4个)提高消费能力"/>
            <node TEXT="使用线程池异步处理消息避免阻塞AMQP连接"/>
            <node TEXT="Session.AUTO_ACKNOWLEDGE自动确认模式"/>
        </node>
    </node>

    <!-- 深度追问类 -->
    <node ID="deep" TEXT="三、深度追问类" POSITION="right">
        <node TEXT="Q7: 如何处理AMQP消息重复消费问题？">
            <node TEXT="消息ID去重: 使用Redis记录已处理的消息ID"/>
            <node TEXT="数据库唯一索引: 防止重复插入"/>
            <node TEXT="幂等性设计: 更新操作使用upsert"/>
        </node>
        <node TEXT="Q8: 设备修改和删除时操作顺序是怎样的？">
            <node TEXT="顺序: 先操作华为云再操作本地数据库"/>
            <node TEXT="原因: 华为云是数据源头保证云端数据正确"/>
            <node TEXT="问题: 本地操作失败时华为云已变更需补偿机制"/>
        </node>
        <node TEXT="Q9: 华为云返回的时间为什么要做时区转换？">
            <node TEXT="华为云返回UTC时间需转换为本地时间(上海时区)"/>
            <node TEXT="使用Java 8的ZoneId和ZonedDateTime"/>
            <node TEXT="封装DateTimeZoneConverter工具类统一处理"/>
        </node>
        <node TEXT="Q10: AMQP连接断开如何处理？">
            <node TEXT="配置自动重连: reconnectDelay、maxReconnectDelay"/>
            <node TEXT="实现JmsConnectionListener监听连接状态"/>
            <node TEXT="记录日志便于排查问题"/>
        </node>
    </node>

    <!-- 扩展思考类 -->
    <node ID="extend" TEXT="四、扩展思考类" POSITION="right">
        <node TEXT="Q11: 如果让你优化设备列表查询性能你会怎么做？">
            <node TEXT="数据库索引优化(iot_id、product_key、binding_location)"/>
            <node TEXT="分页查询"/>
            <node TEXT="设备状态缓存到Redis"/>
            <node TEXT="异步并行查询设备详情和设备数据"/>
        </node>
        <node TEXT="Q12: 如何实现设备离线告警功能？">
            <node TEXT="定时任务同步华为云设备状态"/>
            <node TEXT="状态变化时触发告警"/>
            <node TEXT="结合消息推送通知相关人员"/>
            <node TEXT="记录告警日志便于追溯"/>
        </node>
    </node>

    <!-- 代码细节类 -->
    <node ID="code" TEXT="五、代码细节类" POSITION="right">
        <node TEXT="Q13: 设备密钥是如何生成的？为什么用UUID？">
            <node TEXT="使用UUID生成随机密钥"/>
            <node TEXT="去除横线保证格式统一"/>
            <node TEXT="UUID随机性强难以猜测"/>
        </node>
        <node TEXT="Q14: 查询设备详情时数据来源有哪些？">
            <node TEXT="本地数据库: 设备基本信息、绑定位置"/>
            <node TEXT="华为云API: 设备状态、激活时间等实时数据"/>
            <node TEXT="原因: 基本信息变化少状态需要实时获取"/>
        </node>
        <node TEXT="Q15: Redis缓存设备最新数据的Key结构是怎样的？">
            <node TEXT="Key: iot:device_last_data"/>
            <node TEXT="Field: iotId"/>
            <node TEXT="Value: 设备数据JSON"/>
            <node TEXT="Hash优势: 一个Key管理所有设备通过Field快速定位"/>
        </node>
    </node>
</node>
</map>
