# 智颐养老系统 - 面试项目实战练习题（四）

> 本练习题集聚焦IoT设备管理模块，每道题包含完整代码参考、单元测试、详细解析和面试思维链。

---

## 四、IoT设备管理模块篇（5题）

### 第16题：华为云IoT平台集成

**题目描述**：
请实现与华为云IoTDA平台的集成，包括：客户端配置、产品列表同步、设备注册、设备详情查询。

**核心考察点**：
- 华为云IoTDA SDK使用
- AK/SK认证
- 第三方平台集成设计

**IoT平台架构图**：

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           华为云IoTDA                                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────────┐  ┌────────────┐               │
│  │ 产品     │  │ 设备     │  │ 设备影子     │  │ AMQP队列   │               │
│  │ Product  │  │ Device   │  │ Shadow       │  │            │               │
│  └──────────┘  └──────────┘  └──────────────┘  └────────────┘               │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                              本地系统                                        │
│  ┌───────────────────┐                                                       │
│  │ IotClientConfig   │───创建客户端──→  产品                        │
│  │ AK/SK认证         │                                                       │
│  └───────────────────┘                                                       │
│                                                                              │
│  ┌───────────────────┐                                                       │
│  │ 产品同步服务      │───同步产品列表──→  产品                        │
│  │                   │───缓存──→  ┌───────────┐                             │
│  └───────────────────┘           │ Redis缓存 │                             │
│                                  └───────────┘                             │
│  ┌───────────────────┐           ┌───────────┐                             │
│  │ 设备注册服务      │──注册设备─→│ 设备      │                             │
│  │                   │──保存─────→│ MySQL数据库│                             │
│  └───────────────────┘           └───────────┘                             │
│  ┌───────────────────┐                                                       │
│  │ 设备查询服务      │──查询详情──→  设备                        │
│  │                   │──查询影子──→  设备影子                │
│  └───────────────────┘                                                       │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                              物理设备                                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                       │
│  │ 智能手环     │  │ 智能床垫     │  │ 定位胸卡     │                       │
│  └──────────────┘  └──────────────┘  └──────────────┘                       │
│        │                  │                  │                              │
│        └───────MQTT上报───┴──────────────────┘                              │
│                         │                                                    │
│                         ↓                                                    │
│                    设备影子                                    │
│                         │                                                    │
│                         └──数据转发──→  AMQP队列                             │
│                                              │                               │
│                                              └──AMQP消费──→  本地系统        │
└─────────────────────────────────────────────────────────────────────────────┘
```

**涉及实体类**：

<details>
<summary>点击展开：Device、DeviceData 实体类定义</summary>

```java
// Device.java - 设备实体（项目实际实体）
@Data
@NoArgsConstructor
@AllArgsConstructor
@ApiModel(value="Device对象", description="设备表")
public class Device extends BaseEntity {
    private static final long serialVersionUID = 1L;

    @ApiModelProperty("主键")
    private Long id;

    @ApiModelProperty("物联网设备ID")
    private String iotId;

    @ApiModelProperty("设备秘钥")
    private String secret;

    @ApiModelProperty("绑定位置")
    private String bindingLocation;

    @ApiModelProperty("位置类型 0：随身设备 1：固定设备")
    private Integer locationType;

    @ApiModelProperty("物理位置类型 0楼层 1房间 2床位")
    private Integer physicalLocationType;

    @ApiModelProperty("设备名称")
    private String deviceName;

    @ApiModelProperty("产品key")
    private String productKey;

    @ApiModelProperty("产品名称")
    private String productName;

    @ApiModelProperty("位置备注")
    private String deviceDescription;

    @ApiModelProperty("产品是否包含门禁，0：否，1：是")
    private Integer haveEntranceGuard;

    @ApiModelProperty("节点id")
    private String nodeId;
}

// DeviceData.java - 设备数据实体
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DeviceData extends BaseEntity {
    private Long id;
    private String iotId;           // 设备ID
    private String functionId;      // 属性标识（如BodyTemp、HeartRate）
    private String functionName;    // 属性名称
    private String value;           // 属性值
    private LocalDateTime eventTime; // 上报时间
    private String unit;            // 单位
}
```

</details>

**核心代码实现**：

<details>
<summary>点击展开：IotClientConfig、HuaWeiIotConfigProperties、DeviceServiceImpl 完整实现</summary>

```java
// IotClientConfig.java - IoT客户端配置
@Configuration
@Slf4j
public class IotClientConfig {

    @Autowired
    private HuaWeiIotConfigProperties properties;

    /**
     * 创建华为云IoT客户端
     */
    @Bean
    public IoTDAClient iotDAClient() {
        // AK/SK认证
        ICredential auth = new BasicCredentials()
                .withAk(properties.getAk())
                .withSk(properties.getSk())
                .withDerivedPredicate(BasicCredentials.DEFAULT_DERIVED_PREDICATE)
                .withProjectId(properties.getProjectId());

        // 创建客户端
        return IoTDAClient.newBuilder()
                .withCredential(auth)
                .withRegion(new Region(
                    properties.getRegionId(),
                    properties.getEndpoint()))
                .build();
    }
}

// HuaWeiIotConfigProperties.java - 配置属性
@Data
@Configuration
@ConfigurationProperties(prefix = "huaweicloud")
public class HuaWeiIotConfigProperties {
    private String ak;              // Access Key
    private String sk;              // Secret Key
    private String regionId;        // 区域ID（如cn-east-3）
    private String endpoint;       // IoTDA端点
    private String projectId;      // 项目ID

    // AMQP配置
    private String host;
    private String accessKey;
    private String accessCode;
    private String queueName;
    private Integer connectionCount = 4;
}

// DeviceServiceImpl.java - 设备业务实现
@Service
@Slf4j
public class DeviceServiceImpl extends ServiceImpl<DeviceMapper, Device>
    implements IDeviceService {

    @Autowired
    private IoTDAClient iotDAClient;

    @Autowired
    private RedisTemplate<Object, Object> redisTemplate;

    /**
     * 同步产品列表到Redis
     */
    @Override
    public void syncProductList() {
        log.info("开始同步IoT产品列表...");

        try {
            // 1. 构建请求
            ListProductsRequest request = new ListProductsRequest();
            request.setLimit(50);  // 单次最多50条

            // 2. 调用华为云API
            ListProductsResponse response = iotDAClient.listProducts(request);

            if (response.getHttpStatusCode() != 200) {
                throw new BaseException("物联网接口 - 查询产品，同步失败");
            }

            // 3. 存储到Redis
            List<ProductVo> products = response.getProducts();
            redisTemplate.opsForValue().set(
                CacheConstants.IOT_ALL_PRODUCT_LIST,
                JSONUtil.toJsonStr(products)
            );

            log.info("产品列表同步完成, 数量: {}", products.size());

        } catch (Exception e) {
            log.error("同步产品列表失败", e);
            throw new BaseException("同步产品列表失败: " + e.getMessage());
        }
    }

    /**
     * 查询所有产品（从Redis）
     */
    @Override
    public List<ProductVo> allProduct() {
        String jsonStr = (String) redisTemplate.opsForValue()
            .get(CacheConstants.IOT_ALL_PRODUCT_LIST);

        if (StringUtils.isEmpty(jsonStr)) {
            return Collections.emptyList();
        }

        return JSONUtil.toList(jsonStr, ProductVo.class);
    }

    /**
     * 注册设备（核心业务）
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void registerDevice(DeviceDto dto) {
        log.info("开始注册设备, deviceName: {}", dto.getDeviceName());

        // ========== 1. 三重校验 ==========

        // 1.1 设备名称唯一性校验
        Long nameCount = count(Wrappers.<Device>lambdaQuery()
            .eq(Device::getDeviceName, dto.getDeviceName()));
        if (nameCount > 0) {
            throw new BaseException("设备名称已存在，请重新输入");
        }

        // 1.2 设备标识(nodeId)唯一性校验
        Long nodeIdCount = count(Wrappers.<Device>lambdaQuery()
            .eq(Device::getNodeId, dto.getNodeId()));
        if (nodeIdCount > 0) {
            throw new BaseException("设备标识码已存在，请重新输入");
        }

        // 1.3 位置+产品组合唯一性校验
        // 同一位置不能绑定相同类型的设备
        Long locationProductCount = count(Wrappers.<Device>lambdaQuery()
            .eq(Device::getProductKey, dto.getProductKey())
            .eq(Device::getBindingLocation, dto.getBindingLocation())
            .eq(Device::getLocationType, dto.getLocationType())
            .eq(dto.getPhysicalLocationType() != null,
                Device::getPhysicalLocationType, dto.getPhysicalLocationType()));
        if (locationProductCount > 0) {
            throw new BaseException("该老人/位置已绑定该产品，请重新选择");
        }

        // ========== 2. 调用华为云API注册设备 ==========

        // 生成设备密钥
        String secret = UUID.randomUUID().toString().replace("-", "");

        AddDeviceRequest request = new AddDeviceRequest();
        AddDevice body = new AddDevice();
        body.withProductId(dto.getProductKey());
        body.withDeviceName(dto.getDeviceName());
        body.withNodeId(dto.getNodeId());

        AuthInfo authInfo = new AuthInfo();
        authInfo.withSecret(secret);
        body.withAuthInfo(authInfo);
        request.withBody(body);

        AddDeviceResponse response;
        try {
            response = iotDAClient.addDevice(request);
            log.info("华为云设备创建成功, deviceId: {}", response.getDeviceId());
        } catch (Exception e) {
            log.error("调用华为云API注册设备失败", e);
            throw new BaseException("物联网接口 - 注册设备，同步失败");
        }

        // ========== 3. 保存到本地数据库 ==========

        Device device = BeanUtil.toBean(dto, Device.class);
        device.setSecret(secret);
        device.setIotId(response.getDeviceId());
        device.setProductName(dto.getProductName());

        save(device);
        log.info("设备保存成功, id: {}, iotId: {}", device.getId(), device.getIotId());
    }

    /**
     * 查询设备详情（本地数据 + 云端数据）
     */
    @Override
    public DeviceDetailVo queryDeviceDetail(String iotId) {
        // 1. 查询本地数据
        Device device = getOne(Wrappers.<Device>lambdaQuery()
            .eq(Device::getIotId, iotId));

        if (ObjectUtil.isEmpty(device)) {
            return null;
        }

        // 2. 调用华为云API获取实时状态
        ShowDeviceRequest request = new ShowDeviceRequest();
        request.setDeviceId(iotId);

        ShowDeviceResponse response;
        try {
            response = iotDAClient.showDevice(request);
        } catch (Exception e) {
            log.error("查询设备详情失败, iotId: {}", iotId, e);
            throw new BaseException("物联网接口 - 查询设备详情失败");
        }

        // 3. 组装返回数据
        DeviceDetailVo vo = BeanUtil.toBean(device, DeviceDetailVo.class);
        vo.setDeviceStatus(response.getStatus());

        // 4. 时区转换（UTC → 上海时区）
        String activeTimeStr = response.getActiveTime();
        if (StringUtils.isNotEmpty(activeTimeStr)) {
            LocalDateTime activeTime = LocalDateTimeUtil.parse(
                activeTimeStr, DatePattern.UTC_MS_PATTERN);
            vo.setActiveTime(DateTimeZoneConverter.utcToShanghai(activeTime));
        }

        return vo;
    }

    /**
     * 查询设备影子（最新上报数据）
     */
    @Override
    public AjaxResult queryServiceProperties(String iotId) {
        // 1. 调用华为云API
        ShowDeviceShadowRequest request = new ShowDeviceShadowRequest();
        request.setDeviceId(iotId);

        ShowDeviceShadowResponse response;
        try {
            response = iotDAClient.showDeviceShadow(request);
        } catch (Exception e) {
            log.error("查询设备影子失败, iotId: {}", iotId, e);
            throw new BaseException("物联网接口 - 查询设备影子失败");
        }

        if (response.getHttpStatusCode() != 200) {
            return AjaxResult.success(Collections.emptyList());
        }

        // 2. 解析影子数据
        List<DeviceShadowData> shadow = response.getShadow();
        if (CollUtil.isEmpty(shadow)) {
            return AjaxResult.success(Collections.emptyList());
        }

        DeviceShadowProperties reported = shadow.get(0).getReported();
        JSONObject properties = JSONUtil.parseObj(reported.getProperties());

        // 3. 处理时间
        String eventTimeStr = reported.getEventTime();
        LocalDateTime eventTime = null;
        if (StringUtils.isNotEmpty(eventTimeStr)) {
            LocalDateTime utcTime = LocalDateTimeUtil.parse(
                eventTimeStr, "yyyyMMdd'T'HHmmss'Z'");
            eventTime = DateTimeZoneConverter.utcToShanghai(utcTime);
        }

        // 4. 封装返回数据
        List<Map<String, Object>> list = new ArrayList<>();
        JSONObject finalProperties = properties;
        LocalDateTime finalEventTime = eventTime;

        properties.forEach((key, value) -> {
            Map<String, Object> map = new HashMap<>();
            map.put("functionId", key);
            map.put("value", value);
            map.put("eventTime", finalEventTime);
            list.add(map);
        });

        return AjaxResult.success(list);
    }
}
```

</details>

**单元测试**：

<details>
<summary>点击展开：IoT设备单元测试代码</summary>

```java
@SpringBootTest
public class IoTDeviceTest {

    @Autowired
    private IDeviceService deviceService;

    @Autowired
    private RedisTemplate<Object, Object> redisTemplate;

    @Autowired
    private DeviceMapper deviceMapper;

    /**
     * 测试产品列表缓存
     */
    @Test
    public void testProductListCache() {
        // 模拟产品列表
        List<ProductVo> products = new ArrayList<>();
        ProductVo p1 = new ProductVo();
        p1.setProductId("smart_watch_001");
        p1.setName("智能手环");
        products.add(p1);

        // 存储到Redis
        redisTemplate.opsForValue().set(
            CacheConstants.IOT_ALL_PRODUCT_LIST,
            JSONUtil.toJsonStr(products)
        );

        // 验证获取
        List<ProductVo> result = deviceService.allProduct();
        assertThat(result).hasSize(1);
        assertThat(result.get(0).getName()).isEqualTo("智能手环");

        // 清理
        redisTemplate.delete(CacheConstants.IOT_ALL_PRODUCT_LIST);
    }

    /**
     * 测试设备名称唯一性校验
     */
    @Test
    @Transactional
    public void testDeviceNameUniqueness() {
        // 创建设备
        Device device = new Device();
        device.setDeviceName("测试设备001");
        device.setIotId("iot_test_001");
        device.setNodeId("node_001");
        device.setProductKey("product_001");
        device.setBindingLocation("loc_001");
        device.setLocationType(0);
        deviceMapper.insert(device);

        // 尝试创建同名设备
        DeviceDto dto = new DeviceDto();
        dto.setDeviceName("测试设备001"); // 相同名称

        assertThrows(BaseException.class, () -> {
            deviceService.registerDevice(dto);
        });
    }

    /**
     * 测试设备标识唯一性校验
     */
    @Test
    @Transactional
    public void testNodeIdUniqueness() {
        Device device = new Device();
        device.setDeviceName("测试设备A");
        device.setIotId("iot_test_a");
        device.setNodeId("node_unique_001");
        device.setProductKey("product_001");
        deviceMapper.insert(device);

        DeviceDto dto = new DeviceDto();
        dto.setDeviceName("新设备");
        dto.setNodeId("node_unique_001"); // 相同nodeId

        assertThrows(BaseException.class, () -> {
            deviceService.registerDevice(dto);
        });
    }

    /**
     * 测试位置+产品组合唯一性校验
     */
    @Test
    @Transactional
    public void testLocationProductUniqueness() {
        Device device = new Device();
        device.setDeviceName("床位设备001");
        device.setIotId("iot_bed_001");
        device.setNodeId("node_bed_001");
        device.setProductKey("smart_bed");
        device.setBindingLocation("bed_001");
        device.setLocationType(1);
        device.setPhysicalLocationType(2); // 床位
        deviceMapper.insert(device);

        // 同一床位绑定同类型设备
        DeviceDto dto = new DeviceDto();
        dto.setDeviceName("床位设备002");
        dto.setNodeId("node_bed_002");
        dto.setProductKey("smart_bed"); // 相同产品
        dto.setBindingLocation("bed_001"); // 相同位置
        dto.setLocationType(1);
        dto.setPhysicalLocationType(2);

        assertThrows(BaseException.class, () -> {
            deviceService.registerDevice(dto);
        });
    }

    /**
     * 测试密钥生成
     */
    @Test
    public void testSecretGeneration() {
        String secret1 = UUID.randomUUID().toString().replace("-", "");
        String secret2 = UUID.randomUUID().toString().replace("-", "");

        assertThat(secret1).isNotEqualTo(secret2);
        assertThat(secret1.length()).isEqualTo(32); // UUID去掉横线后32字符
        assertThat(secret1).matches("[a-f0-9]{32}"); // 只包含十六进制字符
    }

    /**
     * 测试时区转换
     */
    @Test
    public void testTimeZoneConversion() {
        LocalDateTime utcTime = LocalDateTime.of(2026, 6, 16, 10, 0, 0);
        LocalDateTime shanghaiTime = DateTimeZoneConverter.utcToShanghai(utcTime);

        // 上海时区是UTC+8
        assertThat(shanghaiTime.getHour()).isEqualTo(18); // 10 + 8 = 18

        System.out.println("UTC时间: " + utcTime);
        System.out.println("上海时间: " + shanghaiTime);
    }
}
```

</details>

**详细解析**：

1. **华为云IoTDA核心概念**：
   - **产品**：设备模型的抽象，定义属性和服务
   - **设备**：产品下的具体实例
   - **设备影子**：设备最新状态的缓存
   - **NodeId**：设备唯一标识（IMEI/MAC等）

2. **设备注册的三重校验**：
   - 设备名称唯一：便于运维识别
   - NodeId唯一：保证设备物理唯一性
   - 位置+产品组合唯一：防止业务冲突

3. **数据一致性挑战**：
   - 先调用华为云API，再保存本地数据库
   - 云端成功、本地失败 → 数据不一致
   - 改进方案：使用消息队列实现最终一致性

**面试思维链**：

```
面试官问：IoT设备是怎么对接的？

思维链：
1. 先说整体架构：华为云IoTDA + 本地数据库 + Redis缓存
2. 再说核心流程：产品同步 → 设备注册 → 数据接收
3. 重点说校验设计：三重校验保证数据唯一性

回答要点：
"IoT设备对接华为云IoTDA平台，分三个步骤：

1. 产品同步：调用华为云API获取产品列表，缓存到Redis
   - 减少对华为云的调用频率
   - 产品列表变化少，适合缓存

2. 设备注册：三重校验后调用华为云API
   - 设备名称唯一：运维识别需要
   - NodeId唯一：物理设备唯一性
   - 位置+产品唯一：同一床位不能绑两个手环

3. 数据接收：通过AMQP异步接收设备上报数据
   - 实时性好，设备数据秒级到达本地系统

最大的挑战是云端和本地数据一致性：
当前是先云后库，如果本地失败需要补偿机制。
"

追问应对：
Q: 华为云API调用失败怎么办？
A: 1. 记录日志并返回友好错误提示
   2. 设备注册支持重试机制
   3. 可考虑增加本地缓存，离线时先存本地

Q: 为什么要先云后库？
A: 1. 设备必须在云端注册才能激活
   2. 云端注册失败则本地无意义
   3. 保证云端和本地数据一致性
```

---

### 第17题：AMQP设备数据接收

**题目描述**：
请实现通过AMQP协议接收华为云IoT平台推送的设备数据，包括：连接管理、消息监听、数据解析、批量入库。

**核心考察点**：
- AMQP协议理解
- 消息异步处理
- 线程池使用

**AMQP数据接收流程图**：

```
时序图 - AMQP数据接收流程:

  物理设备          华为云IoTDA        AMQP队列         AmqpClient        线程池         MySQL         Redis
  [Device]         [IoTDA]           [AMQP]          [Client]         [Pool]         [DB]          [Redis]
      │                │                │                │               │              │              │
      │──MQTT上报数据──→│                │                │               │              │              │
      │                │──数据转发规则──→│                │               │              │              │
      │                │                │──推送消息─────→│               │              │              │
      │                │                │                │               │              │              │
      │                │                │                │──提交异步任务──→│              │              │
      │                │                │←──立即返回─────│  (不阻塞连接)  │              │              │
      │                │                │                │               │              │              │
      │                │                │                │               │──解析JSON消息 │              │
      │                │                │                │               │              │              │
      │                │                │                │               │──批量入库───→│              │
      │                │                │                │               │  (DeviceData) │              │
      │                │                │                │               │              │              │
      │                │                │                │               │──更新最新数据缓存──────────→│
      │                │                │                │               │              │              │
```

**AMQP多连接设计图**：

```
                        ┌─────────────────────────────────┐
                        │         AMQP队列                │
                        │     IoT数据队列                 │
                        └───────────┬─────────────────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    │               │               │
           消息分发 │      消息分发 │      消息分发 │      消息分发
                    │               │               │
                    ↓               ↓               ↓               ↓
        ┌───────────────┐ ┌───────────────┐ ┌───────────────┐ ┌───────────────┐
        │   连接1       │ │   连接2       │ │   连接3       │ │   连接4       │
        │   (AmqpClient)│ │   (AmqpClient)│ │   (AmqpClient)│ │   (AmqpClient)│
        └───────┬───────┘ └───────┬───────┘ └───────┬───────┘ └───────┬───────┘
                │                 │                 │                 │
            submit            submit            submit            submit
                │                 │                 │                 │
                ↓                 ↓                 ↓                 ↓
        ┌───────────────┐ ┌───────────────┐ ┌───────────────┐ ┌───────────────┐
        │  工作线程1    │ │  工作线程2    │ │  工作线程3    │ │  工作线程4    │
        └───────┬───────┘ └───────┬───────┘ └───────┬───────┘ └───────┬───────┘
                │                 │                 │                 │
                │   批量写入      │   批量写入      │   批量写入      │   批量写入
                │                 │                 │                 │
                └─────────────────┴────────┬────────┴─────────────────┘
                                           │
                                           ↓
                                ┌───────────────────┐
                                │     MySQL数据库    │
                                └───────────────────┘
```

**核心代码实现**：

<details>
<summary>点击展开：AmqpClient、DeviceDataServiceImpl 完整实现</summary>

```java
// AmqpClient.java - AMQP客户端
@Slf4j
@Component
public class AmqpClient implements ApplicationRunner {

    @Resource
    private HuaWeiIotConfigProperties properties;

    @Resource
    private ExecutorService executorService;

    @Resource
    private IDeviceDataService deviceDataService;

    // 连接列表
    private final List<Connection> connections = new ArrayList<>();

    /**
     * Spring Boot启动后自动执行
     */
    @Override
    public void run(ApplicationArguments args) throws Exception {
        log.info("开始初始化AMQP客户端...");
        start();
    }

    /**
     * 启动AMQP连接
     */
    public void start() throws Exception {
        // 创建多个连接（提高消费能力）
        for (int i = 0; i < properties.getConnectionCount(); i++) {
            Connection connection = getConnection();
            connections.add(connection);

            // 添加连接监听器
            ((JmsConnection) connection).addConnectionListener(connectionListener);

            // 创建Session
            Session session = connection.createSession(
                false, Session.AUTO_ACKNOWLEDGE);

            // 启动连接
            connection.start();

            // 创建消费者
            MessageConsumer consumer = newConsumer(session, connection,
                properties.getQueueName());

            // 设置消息监听器
            consumer.setMessageListener(messageListener);

            log.info("AMQP连接[{}]已建立", i + 1);
        }
    }

    /**
     * 创建AMQP连接
     */
    private Connection getConnection() throws Exception {
        // 构建连接URL
        String connectionUrl = String.format(
            "amqps://%s:5671?amqp.vhost=default",
            properties.getHost()
        );

        // 构建JMS选项
        Map<String, String> jmsOptions = new HashMap<>();
        jmsOptions.put("failover.reconnectDelay", "3000");
        jmsOptions.put("failover.maxReconnectDelay", "30000");
        jmsOptions.put("failover.maxReconnectAttempts", "-1"); // 无限重试
        jmsOptions.put("transport.trustAll", "true");

        // 构建连接工厂
        JmsConnectionFactory factory = new JmsConnectionFactory();
        factory.setRemoteURI(failoverUrl(connectionUrl, jmsOptions));
        factory.setUsername(properties.getAccessKey());
        factory.setPassword(properties.getAccessCode());

        return factory.createConnection();
    }

    /**
     * 构建failover URL
     */
    private String failoverUrl(String url, Map<String, String> options) {
        StringBuilder sb = new StringBuilder("failover:(urls)");
        sb.append("?").append("failover.reconnectDelay=")
          .append(options.get("failover.reconnectDelay"));
        return sb.toString().replace("urls", url);
    }

    /**
     * 创建消费者
     */
    private MessageConsumer newConsumer(Session session, Connection connection,
                                        String queueName) throws Exception {
        Destination destination = session.createQueue(queueName);
        return session.createConsumer(destination);
    }

    /**
     * 消息监听器 - 接收消息后提交到线程池异步处理
     */
    private final MessageListener messageListener = message -> {
        try {
            // 异步处理消息，避免阻塞AMQP连接
            executorService.submit(() -> processMessage(message));
        } catch (Exception e) {
            log.error("提交消息处理任务失败", e);
        }
    };

    /**
     * 连接监听器 - 监控连接状态
     */
    private final JmsConnectionListener connectionListener = new JmsConnectionListener() {
        @Override
        public void onConnectionInterrupted(URI remoteURI) {
            log.warn("AMQP连接中断: {}", remoteURI);
        }

        @Override
        public void onConnectionRestored(URI remoteURI) {
            log.info("AMQP连接恢复: {}", remoteURI);
        }
    };

    /**
     * 处理消息
     */
    private void processMessage(Message message) {
        try {
            // 1. 获取消息内容
            String contentStr = message.getBody(String.class);
            String topic = message.getStringProperty("topic");
            String messageId = message.getStringProperty("messageId");

            log.debug("收到消息, topic: {}, messageId: {}", topic, messageId);

            // 2. 解析消息
            JSONObject jsonMsg = JSONUtil.parseObj(contentStr);
            JSONObject jsonNotifyData = jsonMsg.getJSONObject("notify_data");

            if (ObjectUtil.isEmpty(jsonNotifyData)) {
                log.warn("消息数据为空, messageId: {}", messageId);
                return;
            }

            // 3. 转换为对象
            IotMsgNotifyData notifyData = JSONUtil.toBean(
                jsonNotifyData, IotMsgNotifyData.class);

            if (ObjectUtil.isEmpty(notifyData.getBody()) ||
                ObjectUtil.isEmpty(notifyData.getBody().getServices())) {
                log.warn("设备数据为空, messageId: {}", messageId);
                return;
            }

            // 4. 批量保存设备数据
            deviceDataService.batchInsertDeviceData(notifyData);

            log.debug("设备数据处理完成, messageId: {}", messageId);

        } catch (Exception e) {
            log.error("处理AMQP消息失败", e);
        }
    }

    /**
     * 停止AMQP连接
     */
    public void stop() {
        for (Connection connection : connections) {
            try {
                connection.close();
            } catch (Exception e) {
                log.error("关闭AMQP连接失败", e);
            }
        }
        log.info("AMQP客户端已停止");
    }
}

// DeviceDataServiceImpl.java - 设备数据业务实现
@Service
@Slf4j
public class DeviceDataServiceImpl
    extends ServiceImpl<DeviceDataMapper, DeviceData>
    implements IDeviceDataService {

    @Autowired
    private RedisTemplate<Object, Object> redisTemplate;

    /**
     * 批量插入设备数据
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void batchInsertDeviceData(IotMsgNotifyData notifyData) {
        // 1. 获取设备信息
        String iotId = notifyData.getHeader().getDeviceId();
        LocalDateTime eventTime = parseEventTime(
            notifyData.getBody().getServices().get(0).getEventTime());

        // 2. 解析属性数据
        List<DeviceData> deviceDataList = new ArrayList<>();
        JSONObject properties = notifyData.getBody()
            .getServices().get(0).getProperties();

        for (Map.Entry<String, Object> entry : properties.entrySet()) {
            DeviceData deviceData = new DeviceData();
            deviceData.setIotId(iotId);
            deviceData.setFunctionId(entry.getKey());
            deviceData.setFunctionName(getFunctionName(entry.getKey()));
            deviceData.setValue(String.valueOf(entry.getValue()));
            deviceData.setEventTime(eventTime);
            deviceData.setUnit(getUnit(entry.getKey()));
            deviceDataList.add(deviceData);
        }

        // 3. 批量入库
        if (!deviceDataList.isEmpty()) {
            saveBatch(deviceDataList);
        }

        // 4. 更新Redis缓存（设备最新数据）
        updateDeviceLatestData(iotId, deviceDataList);

        log.debug("设备数据批量入库完成, iotId: {}, 数量: {}",
            iotId, deviceDataList.size());
    }

    /**
     * 解析事件时间
     */
    private LocalDateTime parseEventTime(String eventTimeStr) {
        if (StringUtils.isEmpty(eventTimeStr)) {
            return LocalDateTime.now();
        }
        try {
            LocalDateTime utcTime = LocalDateTimeUtil.parse(
                eventTimeStr, "yyyyMMdd'T'HHmmss'Z'");
            return DateTimeZoneConverter.utcToShanghai(utcTime);
        } catch (Exception e) {
            return LocalDateTime.now();
        }
    }

    /**
     * 更新设备最新数据到Redis
     */
    private void updateDeviceLatestData(String iotId, List<DeviceData> dataList) {
        String jsonStr = JSONUtil.toJsonStr(dataList);
        redisTemplate.opsForHash().put(
            CacheConstants.IOT_DEVICE_LAST_DATA, iotId, jsonStr);
    }

    /**
     * 获取属性名称（可配置化）
     */
    private String getFunctionName(String functionId) {
        Map<String, String> nameMap = new HashMap<>();
        nameMap.put("BodyTemp", "体温");
        nameMap.put("HeartRate", "心率");
        nameMap.put("xueyang", "血氧");
        nameMap.put("BatteryPercentage", "电量");
        return nameMap.getOrDefault(functionId, functionId);
    }

    /**
     * 获取单位
     */
    private String getUnit(String functionId) {
        Map<String, String> unitMap = new HashMap<>();
        unitMap.put("BodyTemp", "℃");
        unitMap.put("HeartRate", "次/分");
        unitMap.put("xueyang", "%");
        unitMap.put("BatteryPercentage", "%");
        return unitMap.getOrDefault(functionId, "");
    }
}
```

</details>

**单元测试**：

<details>
<summary>点击展开：AMQP消息处理单元测试</summary>

```java
@SpringBootTest
public class AMQPTest {

    @Autowired
    private IDeviceDataService deviceDataService;

    @Autowired
    private RedisTemplate<Object, Object> redisTemplate;

    @Autowired
    private DeviceDataMapper deviceDataMapper;

    /**
     * 测试消息解析
     */
    @Test
    public void testMessageParsing() {
        // 模拟华为云推送的消息格式
        String mockMessage = "{"
            + "\"resource\": \"device.property\","
            + "\"event\": \"report\","
            + "\"event_time\": \"20260616T100000Z\","
            + "\"notify_data\": {"
            + "  \"header\": {"
            + "    \"device_id\": \"device_001\""
            + "  },"
            + "  \"body\": {"
            + "    \"services\": [{"
            + "      \"service_id\": \"watch_services\","
            + "      \"event_time\": \"20260616T100000Z\","
            + "      \"properties\": {"
            + "        \"BodyTemp\": 36.8,"
            + "        \"HeartRate\": 72,"
            + "        \"xueyang\": 98,"
            + "        \"BatteryPercentage\": 85"
            + "      }"
            + "    }]"
            + "  }"
            + "}"
            + "}";

        // 解析消息
        JSONObject jsonMsg = JSONUtil.parseObj(mockMessage);
        JSONObject jsonNotifyData = jsonMsg.getJSONObject("notify_data");
        IotMsgNotifyData notifyData = JSONUtil.toBean(
            jsonNotifyData, IotMsgNotifyData.class);

        // 验证解析结果
        assertThat(notifyData.getHeader().getDeviceId()).isEqualTo("device_001");
        assertThat(notifyData.getBody().getServices()).hasSize(1);

        JSONObject properties = notifyData.getBody()
            .getServices().get(0).getProperties();
        assertThat(properties.getDouble("BodyTemp")).isEqualTo(36.8);
        assertThat(properties.getInteger("HeartRate")).isEqualTo(72);
    }

    /**
     * 测试批量数据入库
     */
    @Test
    @Transactional
    public void testBatchInsertDeviceData() {
        // 构建测试数据
        IotMsgNotifyData notifyData = new IotMsgNotifyData();
        notifyData.setHeader(new IotMsgNotifyData.Header());
        notifyData.getHeader().setDeviceId("test_device_001");

        IotMsgNotifyData.Body body = new IotMsgNotifyData.Body();
        IotMsgNotifyData.Service service = new IotMsgNotifyData.Service();
        service.setEventTime("20260616T100000Z");

        JSONObject properties = new JSONObject();
        properties.put("BodyTemp", 36.8);
        properties.put("HeartRate", 72);
        service.setProperties(properties);

        body.setServices(List.of(service));
        notifyData.setBody(body);

        // 执行批量入库
        deviceDataService.batchInsertDeviceData(notifyData);

        // 验证数据已入库
        List<DeviceData> dataList = deviceDataMapper.selectList(
            Wrappers.<DeviceData>lambdaQuery()
                .eq(DeviceData::getIotId, "test_device_001")
        );

        assertThat(dataList).hasSize(2);
    }

    /**
     * 测试Redis缓存更新
     */
    @Test
    public void testRedisCacheUpdate() {
        String iotId = "test_device_redis";
        List<DeviceData> dataList = new ArrayList<>();

        DeviceData data = new DeviceData();
        data.setIotId(iotId);
        data.setFunctionId("BodyTemp");
        data.setValue("36.8");
        dataList.add(data);

        // 更新缓存
        String jsonStr = JSONUtil.toJsonStr(dataList);
        redisTemplate.opsForHash().put(
            CacheConstants.IOT_DEVICE_LAST_DATA, iotId, jsonStr);

        // 验证缓存
        String cached = (String) redisTemplate.opsForHash()
            .get(CacheConstants.IOT_DEVICE_LAST_DATA, iotId);
        assertThat(cached).isNotNull();
        assertThat(cached).contains("BodyTemp");

        // 清理
        redisTemplate.opsForHash()
            .delete(CacheConstants.IOT_DEVICE_LAST_DATA, iotId);
    }

    /**
     * 测试多连接并发消费
     */
    @Test
    public void testConcurrentConsumption() throws Exception {
        ExecutorService executor = Executors.newFixedThreadPool(4);
        List<Future<String>> futures = new ArrayList<>();

        for (int i = 0; i < 4; i++) {
            final int index = i;
            Future<String> future = executor.submit(() -> {
                String iotId = "device_" + index;
                return "Processed: " + iotId;
            });
            futures.add(future);
        }

        // 验证所有任务完成
        for (Future<String> future : futures) {
            String result = future.get(5, TimeUnit.SECONDS);
            assertThat(result).contains("Processed:");
        }

        executor.shutdown();
    }
}
```

</details>

**详细解析**：

1. **AMQP vs MQTT对比**：
   | 协议 | 特点 | 适用场景 |
   |------|------|---------|
   | AMQP | 消息队列模型，支持确认、事务 | 平台间数据流转 |
   | MQTT | 发布订阅模型，轻量级 | 设备端上报 |

2. **为什么用线程池处理消息**：
   - `onMessage`回调中不适合做重逻辑
   - 直接同步处理会阻塞AMQP连接
   - 使用线程池解耦"消息接收"和"业务处理"

3. **消息幂等性设计**：
   - 使用messageId去重（存Redis）
   - 数据库唯一索引（iotId + functionId + eventTime）
   - Upsert操作（存在则更新）

**面试思维链**：

```
面试官问：设备数据是怎么实时接收的？

思维链：
1. 先说技术选型：AMQP协议，华为云推送
2. 再说核心设计：多连接 + 线程池 + 批量入库
3. 重点说幂等性和可靠性

回答要点：
"设备数据通过AMQP协议实时接收：
1. 华为云IoT平台配置数据转发规则，推送到AMQP队列
2. 本系统启动时创建多个AMQP连接（4个），提高消费能力
3. 消息到达后提交到线程池异步处理，避免阻塞连接
4. 解析JSON数据后批量入库，同时更新Redis缓存

关键设计：
- 多连接：提高吞吐量
- 线程池：解耦消息接收和业务处理
- 幂等性：messageId去重 + 数据库唯一索引
- 自动重连：配置failover参数，断线自动重试
"

追问应对：
Q: AMQP连接断了怎么办？
A: 1. failover参数自动重连
   2. 断线期间消息积压在队列，重连后继续消费
   3. 监控告警及时发现连接异常

Q: 消息处理失败了怎么保证不丢失？
A: 1. 数据库唯一索引防止重复数据
   2. 失败消息记录日志，支持手动重试
   3. 可引入死信队列处理异常消息
```

---

### 第18题：设备绑定位置设计

**题目描述**：
养老院设备需要绑定物理位置或老人。请分析设备绑定位置的设计思路，包括数据模型、唯一性校验、查询逻辑。

**核心考察点**：
- 数据建模能力
- 业务规则设计
- 多维度查询

**设备绑定位置模型图**：

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              物理层级                                        │
│                                                                              │
│     楼层 (Floor)                                                             │
│         │                                                                    │
│         └──────────→ 房间 (Room)                                             │
│                          │                                                   │
│                          └──────────→ 床位 (Bed)                             │
│                                           │                                  │
│                                           └──────────→ 老人 (Elder)         │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                              设备类型                                        │
│                                                                              │
│  ┌─────────────────────────────┐     ┌─────────────────────────────┐        │
│  │  随身设备 (locationType=0)   │     │  固定设备 (locationType=1)   │        │
│  │  手环/胸卡                   │     │  床垫/门禁                   │        │
│  └──────────────┬──────────────┘     └──────────────┬──────────────┘        │
│                 │                                    │                       │
│                 │ 绑定老人ID                          │ 绑定位置ID            │
│                 │ bindingLocation = elder.id         │ bindingLocation       │
│                 │ physicalLocationType = null        │                       │
│                 │                                    │                       │
│                 ↓                                    ↓                       │
│         ┌──────────────┐         ┌──────────────────────────────────┐        │
│         │   老人       │         │  楼层 (physicalLocationType=0)    │        │
│         │   (Elder)    │         │  房间 (physicalLocationType=1)    │        │
│         └──────────────┘         │  床位 (physicalLocationType=2)    │        │
│                                  └──────────────────────────────────┘        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

```
设备绑定位置设计：

1. 位置类型 (locationType)
   ├── 0: 随身设备 → 绑定老人
   │   └── bindingLocation = 老人ID (elder.id)
   │   └── physicalLocationType = null（随身设备无物理位置）
   │
   └── 1: 固定设备 → 绑定物理位置
       ├── physicalLocationType = 0 → 楼层 (floor.id)
       ├── physicalLocationType = 1 → 房间 (room.id)
       └── physicalLocationType = 2 → 床位 (bed.id)
       └── bindingLocation = 对应位置ID

2. 唯一性规则：
   - 设备名称全局唯一
   - 设备标识(nodeId)全局唯一
   - 同一位置不能绑定相同类型的设备

3. 数据模型：
   device
   ├── locationType: 0(随身) / 1(固定)
   ├── physicalLocationType: 0(楼层) / 1(房间) / 2(床位) / null
   └── bindingLocation: 绑定对象的ID
```

**面试思维链**：

```
面试官问：设备绑定位置怎么设计的？

思维链：
1. 先说业务场景：随身设备绑老人，固定设备绑位置
2. 再说数据模型：locationType区分类型
3. 重点说唯一性规则：三重校验

回答要点：
"设备绑定分两种：
- 随身设备（手环）：绑定老人，跟随老人移动
- 固定设备（床垫、门禁）：绑定物理位置（楼层/房间/床位）

数据模型：
locationType: 0=随身, 1=固定
physicalLocationType: 0=楼层, 1=房间, 2=床位
bindingLocation: 绑定对象ID

唯一性规则：
1. 设备名称唯一：便于运维识别
2. NodeId唯一：物理设备唯一
3. 位置+产品唯一：同一床位不能绑两个手环
"

追问应对：
Q: 如果设备从一个床位移到另一个床位怎么办？
A: 1. 先解绑原床位（删除绑定关系）
   2. 再绑定新床位
   3. 操作记录日志便于追溯

Q: 随身设备（手环）和固定设备有什么区别？
A: 1. 随身设备绑老人，跟随移动
   2. 固定设备绑位置，不移动
   3. 数据展示方式不同
```

---

### 第19题：设备数据查询与展示

**题目描述**：
请实现智能床位功能：查询楼层下所有房间的设备及最新数据，包括多层嵌套查询和Redis缓存使用。

**智能床位数据层级图**：

```
                                  ┌──────────────────┐
                                  │  楼层 (一层)     │
                                  │    Floor         │
                                  └────────┬─────────┘
                                           │
                        ┌──────────────────┴──────────────────┐
                        │                                     │
                        ↓                                     ↓
              ┌──────────────────┐                 ┌──────────────────┐
              │  房间 101        │                 │  房间 102        │
              └────────┬─────────┘                 └────────┬─────────┘
                       │                                    │
           ┌───────────┴───────────┐                       │
           │                       │                       │
           ↓                       ↓                       ↓
   ┌───────────────┐      ┌───────────────┐      ┌───────────────┐
   │  床位 01      │      │  床位 02      │      │  门禁设备     │
   └───────┬───────┘      └───────┬───────┘      │  状态:正常    │
           │                      │              └───────────────┘
           ↓                      ↓
   ┌───────────────┐      ┌───────────────┐
   │  手环设备     │      │  床垫设备     │
   │  体温:36.8    │      │  在床:是      │
   │  心率:72      │      │  呼吸:16      │
   └───────┬───────┘      └───────┬───────┘
           │                      │
           │                      │
           └──────────┬───────────┘
                      │
                      │ iotId查询
                      ↓
         ┌────────────────────────────────────────┐
         │              数据来源                  │
         │                                        │
         │   ┌──────────────┐  ┌──────────────┐   │
         │   │ MySQL        │  │ Redis        │   │
         │   │ 基础信息     │  │ 最新数据     │   │
         │   └──────────────┘  └──────────────┘   │
         │                                        │
         └────────────────────────────────────────┘
```

**核心代码实现**：

<details>
<summary>点击展开：RoomServiceImpl 智能床位数据查询</summary>

```java
// RoomServiceImpl.java - 房间与设备数据查询
@Override
public List<RoomVo> getRoomsWithDeviceByFloorId(Long floorId) {
    // 1. 查询基础数据（房间、床位、设备）
    List<RoomVo> roomVos = roomMapper.getRoomsWithDeviceByFloorId(floorId);

    if (CollUtil.isEmpty(roomVos)) {
        return Collections.emptyList();
    }

    // 2. 从Redis获取设备最新数据
    roomVos.forEach(roomVo -> {
        // 房间设备
        enrichDeviceData(roomVo.getDeviceVos());

        // 床位设备
        roomVo.getBedVoList().forEach(bedVo -> {
            enrichDeviceData(bedVo.getDeviceVos());
        });
    });

    return roomVos;
}

/**
 * 补充设备最新数据
 */
private void enrichDeviceData(List<DeviceInfo> deviceVos) {
    if (CollUtil.isEmpty(deviceVos)) {
        return;
    }

    deviceVos.forEach(device -> {
        String jsonStr = (String) redisTemplate.opsForHash()
            .get(CacheConstants.IOT_DEVICE_LAST_DATA, device.getIotId());

        if (StringUtils.isNotEmpty(jsonStr)) {
            List<DeviceDataVo> dataVos = JSONUtil.toList(jsonStr, DeviceDataVo.class);
            device.setDeviceDataVos(dataVos);
        }
    });
}
```

</details>

**面试思维链**：

```
面试官问：智能床位功能怎么实现的？

思维链：
1. 先说数据结构：楼层 → 房间 → 床位 → 设备 → 数据
2. 再说查询流程：基础数据 + Redis缓存
3. 重点说性能优化：避免N+1查询

回答要点：
"智能床位功能展示楼层下所有房间的设备状态：
1. 查询数据库获取房间、床位、设备基础信息
2. 从Redis Hash获取每个设备的最新数据
3. 组装成嵌套结构返回前端

数据结构：楼层 → 房间列表 → 床位列表 → 设备列表 → 设备数据

性能优化：
- 设备数据缓存到Redis，避免每次调华为云API
- 使用Hash结构，按iotId快速定位
"

追问应对：
Q: 如果设备数据量很大，Redis内存不够怎么办？
A: 1. 只缓存最新一条数据，历史数据存数据库
   2. 设置合理的过期时间
   3. 可考虑用Redis Cluster扩展

Q: 为什么用Hash而不是String？
A: 1. Hash按iotId分组，便于批量查询
   2. 单个key下多设备数据，内存效率更高
   3. 支持部分更新，不需要全量覆盖
```

---

### 第20题：设备管理完整业务流程

**题目描述**：
请综合分析设备从注册到数据接收的完整业务流程，包括：产品同步、设备注册、数据接收、数据展示、设备修改/删除。

**完整业务流程图**：

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              阶段1：准备                                     │
│                                                                              │
│   ┌──────────────────┐           ┌──────────────────┐                        │
│   │ 同步产品列表     │──────────→│ 缓存到Redis      │                        │
│   └──────────────────┘           └──────────────────┘                        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                              阶段2：注册                                     │
│                                                                              │
│   ┌──────────────────┐           ┌──────────────────┐                        │
│   │ 选择产品         │──────────→│   三重校验       │                        │
│   └──────────────────┘           └────────┬─────────┘                        │
│                                           │                                  │
│                          ┌────────────────┴────────────────┐                 │
│                          │                                 │                 │
│                          ↓                                 ↓                 │
│                 ┌───────────────┐              ┌───────────────┐             │
│                 │ 通过          │              │ 不通过        │             │
│                 └───────┬───────┘              └───────┬───────┘             │
│                         │                              │                     │
│                         ↓                              ↓                     │
│               ┌──────────────────┐          ┌──────────────────┐             │
│               │ 调用华为云API    │          │ 返回错误提示     │             │
│               └────────┬─────────┘          └──────────────────┘             │
│                        │                                                     │
│                        ↓                                                     │
│               ┌──────────────────┐                                           │
│               │ 生成设备密钥     │                                           │
│               └────────┬─────────┘                                           │
│                        │                                                     │
│                        ↓                                                     │
│               ┌──────────────────┐                                           │
│               │ 保存本地数据库   │                                           │
│               └──────────────────┘                                           │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                              阶段3：运行                                     │
│                                                                              │
│   ┌──────────────────┐                                                       │
│   │ 设备MQTT上报     │                                                       │
│   └────────┬─────────┘                                                       │
│            │                                                                 │
│            ↓                                                                 │
│   ┌──────────────────┐                                                       │
│   │ 华为云数据转发   │                                                       │
│   └────────┬─────────┘                                                       │
│            │                                                                 │
│            ↓                                                                 │
│   ┌──────────────────┐                                                       │
│   │ AMQP队列         │                                                       │
│   └────────┬─────────┘                                                       │
│            │                                                                 │
│            ↓                                                                 │
│   ┌──────────────────┐                                                       │
│   │ AmqpClient消费   │                                                       │
│   └────────┬─────────┘                                                       │
│            │                                                                 │
│            ↓                                                                 │
│   ┌──────────────────┐                                                       │
│   │ 线程池异步处理   │                                                       │
│   └────────┬─────────┘                                                       │
│            │                                                                 │
│     ┌──────┴──────┐                                                          │
│     │             │                                                          │
│     ↓             ↓                                                          │
│  ┌────────────┐ ┌────────────┐                                               │
│  │ 批量入库   │ │ 更新Redis  │                                               │
│  └────────────┘ │ 缓存       │                                               │
│                 └────────────┘                                               │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                              阶段4：展示                                     │
│                                                                              │
│   ┌──────────────────┐                                                       │
│   │ 查询设备列表     │                                                       │
│   └────────┬─────────┘                                                       │
│            │                                                                 │
│            ↓                                                                 │
│   ┌──────────────────┐                                                       │
│   │ 从DB获取基础信息 │                                                       │
│   └────────┬─────────┘                                                       │
│            │                                                                 │
│            ↓                                                                 │
│   ┌──────────────────┐                                                       │
│   │ 从Redis获取      │                                                       │
│   │ 最新数据         │                                                       │
│   └────────┬─────────┘                                                       │
│            │                                                                 │
│            ↓                                                                 │
│   ┌──────────────────┐                                                       │
│   │ 组装返回         │                                                       │
│   └──────────────────┘                                                       │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                              阶段5：维护                                     │
│                                                                              │
│   ┌──────────────────┐           ┌──────────────────┐                        │
│   │ 修改设备         │──────────→│ 校验唯一性       │                        │
│   └──────────────────┘           └────────┬─────────┘                        │
│                                           │                                  │
│                                           ↓                                  │
│                                  ┌──────────────────┐                        │
│                                  │ 通过             │                        │
│                                  └────────┬─────────┘                        │
│                                           │                                  │
│                                           ↓                                  │
│                                  ┌──────────────────┐                        │
│                                  │ 先改华为云       │                        │
│                                  └────────┬─────────┘                        │
│                                           │                                  │
│                                           ↓                                  │
│                                  ┌──────────────────┐                        │
│                                  │ 再改本地DB       │                        │
│                                  └──────────────────┘                        │
│                                                                              │
│   ┌──────────────────┐           ┌──────────────────┐                        │
│   │ 删除设备         │──────────→│ 先删华为云       │                        │
│   └──────────────────┘           └────────┬─────────┘                        │
│                                           │                                  │
│                                           ↓                                  │
│                                  ┌──────────────────┐                        │
│                                  │ 再删本地DB       │                        │
│                                  └──────────────────┘                        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

**业务流程总结**：

```
完整业务流程：

1. 产品同步
   调用华为云API → 获取产品列表 → 缓存到Redis

2. 设备注册
   三重校验 → 调用华为云API → 生成密钥 → 保存本地数据库

3. 数据接收
   AMQP连接 → 消息监听 → 线程池处理 → 批量入库 → 更新Redis缓存

4. 数据展示
   查询基础数据 → 从Redis获取最新数据 → 组装返回

5. 设备修改
   校验唯一性 → 先改华为云 → 再改本地数据库

6. 设备删除
   校验设备存在 → 先删华为云 → 再删本地数据库
```

**面试思维链**：

```
面试官问：IoT模块的整体架构是怎样的？

思维链：
1. 先说整体架构：华为云IoTDA + 本地系统 + Redis缓存
2. 再说核心流程：同步 → 注册 → 接收 → 展示
3. 重点说设计考虑：数据一致性、性能优化

回答要点：
"IoT模块整体架构：
- 华为云IoTDA：设备管理、数据流转
- 本地系统：业务数据维护、数据入库
- Redis：产品列表缓存、设备最新数据缓存

核心流程：
1. 产品同步：定时/手动同步华为云产品列表到Redis
2. 设备注册：三重校验后调用华为云API，本地保存设备信息
3. 数据接收：AMQP异步接收设备上报数据，批量入库
4. 数据展示：查询基础数据 + Redis获取最新数据

设计考虑：
- 数据一致性：先云后库，需补偿机制
- 性能优化：Redis缓存减少API调用
- 可扩展性：多连接AMQP提高吞吐
"

追问应对：
Q: 如果需要接入其他云平台的IoT设备怎么办？
A: 1. 抽象设备接口，支持多平台适配
   2. 配置化云平台参数
   3. 统一数据格式，屏蔽平台差异

Q: 设备数据入库和Redis更新的一致性怎么保证？
A: 1. 先入库再更新Redis
   2. Redis更新失败不影响主流程
   3. 可通过定时任务补偿Redis数据
```

---

**最后更新时间**：2026-06-16
**适用项目**：智颐养老系统
**适用场景**：Java后端面试项目实战练习
