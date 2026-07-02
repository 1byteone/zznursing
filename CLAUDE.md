# 智颐养老护理系统 (zznursing)

> 面向养老院的综合管理平台，基于 RuoYi-Vue v3.8.9 二次开发。
> 包含后台管理系统（养老院工作人员使用）和微信小程序端（老人家属使用）。

## 技术栈

| 层级 | 技术 | 版本 |
|------|------|------|
| 后端框架 | Spring Boot | 2.5.15 |
| ORM | MyBatis-Plus | 3.5.2 |
| 数据库 | MySQL (Druid 连接池 1.2.23) | - |
| 缓存 | Redis (Spring Data Redis) | - |
| 安全 | Spring Security + JWT (0.9.1) | 5.7.12 |
| 前端(管理端) | Vue 3 + ElementPlus | - |
| 前端(小程序) | 微信小程序原生 | - |
| JDK | OpenJDK | 11 |
| 构建 | Maven | - |

## 外部集成

| 外部服务 | 用途 | 配置前缀/类 |
|---------|------|------------|
| 百度千帆大模型 | 健康评估-分析体检报告 | `baidu.qianfan` / `BaiduAIProperties` |
| 华为云 IoTDA | 设备管理-注册/同步/数据接收 | `huaweicloud` / `HuaWeiIotConfigProperties` |
| 阿里云 OSS | 体检报告 PDF 文件存储 | `aliyun.oss` / `AliyunOSSProperties` |
| 微信开放平台 | 小程序登录 (jscode2session / 手机号) | `wechat.appId` / `wechat.appSecret` |
| Apache Qpid JMS | 华为云 IoT AMQP 消息消费 | 硬编码在 `AmqpClient` 中 |

## 多模块结构

```
zzyl-nursing-platform    养老核心业务: 老人/入住/健康评估/设备/护理/预约/合同
zzyl-admin               管理后台 Web 入口: Controller + 启动类 + 测试
zzyl-common              公共: AI调用/Redis操作/ThreadLocal/PDF解析/工具类
zzyl-framework           框架: Security/拦截器/IoT配置/全局异常/RBAC
zzyl-system              系统管理: 用户/角色/菜单/字典/配置/日志
zzyl-oss                 阿里云 OSS 文件存储
zzyl-quartz              定时任务调度
zzyl-generator           代码生成器
zzyl-ui                  Vue 3 前端
```

---

## 核心职责索引

### 1. 健康评估 — 百度千帆 AI + 体检报告分析 + Redis 缓存

**简历亮点:** 使用百度千帆AI大模型分析体检报告获取老人的身体健康状态和健康建议，使用 Redis 缓存分析结果，提高系统响应速度。分析响应时间从 8 秒降低到 1 秒，护理人员使用效率提升约 30%。

**数据流:**
```
护理人员上传PDF → AliyunOSSOperator.upload() → OSS 存储
                 → PDFUtil.pdfToString() → 提取文本
                 → Redis Hash(healthReport, idCard, content) ← 缓存24h
                                                      ↓
护理人员提交评估 → HealthAssessmentServiceImpl.insertHealthAssessment()
                 → getPrompt(idCard) 从 Redis 取文本
                 → 拼装 JSON 结构化输出的 Prompt
                 → AIModelInvoker.qianfanInvoker(prompt)
                    → OpenAI SDK (兼容百度千帆) → baidu.qianfan.apiKey/baseUrl/model
                 → JSON.parseObject → HealthReportVo (结构化)
                 → saveHealthAssessment: 健康分/风险等级/建议入住/护理等级/八大系统
                 → insert 到 health_assessment 表
```

**关键类:**
| 类 | 路径 | 职责 |
|---|------|------|
| `HealthAssessmentController` | `zzyl-nursing-platform/.../controller/HealthAssessmentController.java` | REST 入口: upload 上传PDF, add 提交评估 |
| `HealthAssessmentServiceImpl` | `zzyl-nursing-platform/.../service/impl/HealthAssessmentServiceImpl.java` | 核心业务: getPrompt 拼装Prompt, insertHealthAssessment 调AI+落库 |
| `AIModelInvoker` | `zzyl-common/.../ai/AIModelInvoker.java` | 调用千帆: OpenAI SDK, responseFormat=json_object |
| `BaiduAIProperties` | `zzyl-common/.../ai/BaiduAIProperties.java` | 配置: apiKey, baseUrl(含access_token), model |
| `PDFUtil` | `zzyl-common/.../utils/PDFUtil.java` | Apache PDFBox 提取PDF文本 |
| `HealthReportVo` | `zzyl-nursing-platform/.../vo/health/HealthReportVo.java` | AI返回的结构化VO: totalCheckDate/healthAssessment/riskDistribution/abnormalData/systemScore/summarize |
| `HealthAssessment` | `zzyl-nursing-platform/.../domain/HealthAssessment.java` | 实体: healthScore/riskLevel/suggestionForAdmission/nursingLevelName/systemScore |

**Redis 缓存策略:**
- Key: `"healthReport"` (Hash 类型)
- Field: 老人身份证号
- Value: PDF 解析后的文本内容
- TTL: 24 小时
- 优化效果: 上传时一次解析 → 提交时直接从 Redis 取，避免重复解析 PDF 和重新上传文件

**AI Prompt 设计要点:**
- 角色设定: 专业医生视角
- 输出六项: 总检日期 / 风险等级+健康指数 / 五级风险分布 / 异常数据(7字段:结论/项目/结果/参考值/单位/解读/建议) / 八大系统评分(呼吸/消化/内分泌/免疫/循环/泌尿/运动/感官) / 总结
- 强制 JSON 输出: `responseFormat` 设置为 `json_object`，减少解析错误
- 健康指数映射护理等级: ≥90→四级, ≥80→三级, ≥70→二级, ≥60→一级, <60→特级
- 建议入住判断: healthScore ≥ 60 → 0(建议), else → 1(不建议)

**性能优化收益量化:**
- AI 分析耗时约 8 秒，但缓存 PDF 文本避免了每次提交都重复上传和解析
- 优化后整体响应 1 秒内
- 护理人员评估效率提升约 30%（原来人工翻阅纸质报告约 15 分钟，AI 辅助缩短到 1-2 分钟）

---

### 2. 设备管理 — 华为云 IoT + 设备同步 + Redis 缓存

**简历亮点:** 对接华为云 IoT 平台完成产品列表同步至 Redis，并调用接口维护本地设备数据。完成设备与位置绑定，保证数据一致性。设备列表同步时间从 3 分钟缩短至 10 秒，同时支持大批量设备高效管理。

**数据流 — 产品同步:**
```
管理后台触发 syncProductList()
  → IoTDAClient.listProducts() → 华为云 IoTDA (最多50条/次)
  → Redis String(iot:all_product_list, JSON)
  → allProduct() → 从 Redis 读取并反序列化返回

优化: 全量同步到 Redis → 后续查询走 Redis (3分钟→10秒)
```

**数据流 — 设备注册:**
```
管理后台 registerDevice(DeviceDto)
  → 校验: 设备名唯一 / 节点ID唯一 / 同位置同产品不重复
  → 生成随机 secret (UUID随机串)
  → IoTDAClient.addDevice() → 华为云 IoTDA 注册
  → 本地 MySQL device 表保存 (含 iotId/secret/bindingLocation)
```

**数据流 — 设备数据消费(AMQP):**
```
应用启动 → AmqpClient.run() → 建立 AMQP 连接(默认4个连接)
IoT设备上报 → 华为云 IoTDA → AMQP Queue
  → MessageListener → executorService.submit(processMessage)
  → JSON 解析 → IotMsgNotifyData
  → DeviceDataServiceImpl.batchInsertDeviceData()
    → 根据 iotId 查本地 device 表
    → Map<functionId, value> 遍历 → 批量插入 device_data 表
    → 同时写入 Redis Hash(iot:device_last_data, iotId, JSON)
```

**关键类:**
| 类 | 路径 | 职责 |
|---|------|------|
| `DeviceController` | `zzyl-nursing-platform/.../controller/DeviceController.java` | REST: syncProduct/allProduct/registerDevice/queryDetail/queryProperty/update/delete |
| `DeviceServiceImpl` | `zzyl-nursing-platform/.../service/impl/DeviceServiceImpl.java` | 核心: syncProductList/allProduct/registerDevice/queryDeviceDetail/queryServiceProperties |
| `DeviceDataServiceImpl` | `zzyl-nursing-platform/.../service/impl/DeviceDataServiceImpl.java` | batchInsertDeviceData: AMQP 消息处理, 批量入库+Redis缓存 |
| `AmqpClient` | `zzyl-nursing-platform/.../job/AmqpClient.java` | ApplicationRunner: 启动时建立AMQP连接, MessageListener消费消息 |
| `IotClientConfig` | `zzyl-framework/.../config/IotClientConfig.java` | IoTDAClient Bean: AK/SK/Region/Endpoint |
| `HuaWeiIotConfigProperties` | `zzyl-framework/.../config/properties/HuaWeiIotConfigProperties.java` | 全部配置: ak/sk/regionId/endpoint/amqp host/amqp凭证/连接数/重连 |
| `Device` | `zzyl-nursing-platform/.../domain/Device.java` | 实体: iotId/secret/bindingLocation/locationType/productKey |

**Redis Key 常量:**
- `iot:all_product_list` (String) — 产品列表缓存
- `iot:device_last_data` (Hash) — 设备最新数据, field=iotId

**设备位置绑定逻辑:**
- `locationType`: 0=随身设备(如智能手表), 1=固定设备(如床位传感器)
- `physicalLocationType`: 0=楼层, 1=房间, 2=床位
- `bindingLocation`: 绑定位置 ID
- 注册时校验: `productKey + bindingLocation + locationType + physicalLocationType` 组合唯一

**性能优化收益量化:**
- 全量同步从华为云拉到 Redis 一次(约 3 分钟)，后续所有查询直接走 Redis
- 设备列表查询响应时间从 3 分钟(每次调华为云接口)缩短到 10 秒(读缓存)
- 支持大批量设备高效管理（分页查缓存+本地数据库）

---

### 3. 微信小程序登录 — 拦截器 + ThreadLocal + JWT

**简历亮点:** 在拦截器中使用 ThreadLocal 存储微信小程序用户的 ID，保证多线程请求下数据隔离和安全，避免内存泄漏问题。

**数据流 — 登录:**
```
小程序 wx.login() → 获取 code
  → POST /member/user/login { code, phoneCode }
  → FamilyMemberServiceImpl.login()
    → WechatServiceImpl.getOpenid(code) → jscode2session → openId
    → 查库: FamilyMember.openId == openId
    → WechatServiceImpl.getPhone(phoneCode) → getuserphonenumber → 手机号
    → 新用户: 随机昵称(词组+手机号后4位) + 保存
    → 老用户: 更新手机号
    → 生成 JWT: { userId, nickName }
    → 返回 { token, nickName }
```

**数据流 — 请求认证:**
```
每次请求 /member/** 路径
  → MemberInterceptor.preHandle()
    → 从 header "authorization" 取 token
    → TokenService.parseToken(token) → Claims
    → 提取 userId → UserThreadLocal.set(userId)
    → 放行
  → 业务代码通过 UserThreadLocal.getUserId() 获取当前用户
  → MemberInterceptor.afterCompletion()
    → UserThreadLocal.remove()  ← 防止内存泄漏
```

**关键类:**
| 类 | 路径 | 职责 |
|---|------|------|
| `FamilyMemberController` | `zzyl-nursing-platform/.../controller/FamilyMemberController.java` | `/member/user/login` 登录入口 |
| `FamilyMemberServiceImpl` | `zzyl-nursing-platform/.../service/impl/FamilyMemberServiceImpl.java` | login 核心: 获取openId/手机号/自动注册/JWT |
| `WechatServiceImpl` | `zzyl-nursing-platform/.../service/impl/WechatServiceImpl.java` | 微信API: getOpenid/getPhone/getToken |
| `MemberInterceptor` | `zzyl-framework/.../interceptor/MemberInterceptor.java` | 拦截 → 解析token → ThreadLocal set → afterCompletion remove |
| `UserThreadLocal` | `zzyl-common/.../utils/UserThreadLocal.java` | ThreadLocal<Long> 封装: set/get/getUserId/remove |
| `TokenService` | `zzyl-framework/.../web/service/TokenService.java` | JWT 生成/解析/校验 |

**ThreadLocal 实现细节:**
```java
// UserThreadLocal.java — 核心实现
private static final ThreadLocal<Long> LOCAL = new ThreadLocal<>();

public static void set(Long userId) { LOCAL.set(userId); }
public static Long get() { return LOCAL.get(); }
public static Long getUserId() { return LOCAL.get(); }
public static void remove() { LOCAL.remove(); }

// MemberInterceptor.java — 拦截器使用
@Override
public boolean preHandle(...) {
    String token = request.getHeader("authorization");
    Claims claims = tokenService.parseToken(token);
    Long userId = MapUtil.get(claims, "userId", Long.class);
    UserThreadLocal.set(userId);
    return true;
}

@Override
public void afterCompletion(...) {
    UserThreadLocal.remove();  // 关键：防止内存泄漏
}
```

---

## 外部依赖配置

| 服务 | 配置类 | 配置项前缀 | 关键配置 |
|------|--------|-----------|---------|
| 百度千帆 | `BaiduAIProperties` | `baidu.qianfan` | apiKey, baseUrl, model |
| 华为云 IoT | `HuaWeiIotConfigProperties` | `huaweicloud` | ak, sk, regionId, endpoint, host, accessKey, accessCode |
| 阿里云 OSS | `AliyunOSSProperties` | `aliyun.oss` | endpoint, accessKeyId, accessKeySecret, bucketName |
| 微信开放平台 | 在 `WechatServiceImpl` 中读取 `@Value` | `wechat` | appId, appSecret |

配置文件路径: `zzyl-admin/src/main/resources/application.yml` (或 application-*.yml)

---

## 开发启动指南

1. **环境要求**: JDK 11+, Maven 3.6+, MySQL 8.0+, Redis 6+, Node 16+
2. **导入SQL**: 依次执行 `sql/ry_20250417.sql` (基础表) → `sql/zzyl-dev06-init.sql` (养老业务数据) → 增量SQL
3. **后端配置**: 在 `application.yml` 中配置 MySQL 连接、Redis 连接、百度千帆 AK、华为云 IoT AK、微信 appId/appSecret
4. **后端启动**: 运行 `zzyl-admin` 模块的 `com.zzyl.RuoYiApplication.java`
5. **管理端前端**: `cd zzyl-ui && npm install && npm run dev`
6. **小程序端**: 使用微信开发者工具打开小程序项目，配置 appId

---

## 编码规范

- **分层**: Controller → Service(接口+Impl) → Mapper(MyBatis-Plus), 无独立的 Manager 层
- **VO/DTO**: Controller 入参用 DTO, 出参用 VO, Domain 作为实体不入 Controller
- **Redis Key 命名**: 集中在 `CacheConstants` 中定义, 小写+下划线+冒号命名空间 (如 `iot:all_product_list`, `iot:device_last_data`)
- **异常**: 业务异常使用 `com.zzyl.common.exception.base.BaseException`, `GlobalExceptionHandler` 统一处理返回 `AjaxResult`
- **分页**: Controller 调用 `startPage()` + Service 返回 `List`, Controller 调用 `getDataTable(list)` 自动封装 `TableDataInfo`
- **权限(管理端)**: `@PreAuthorize("@ss.hasPermi('模块:功能:操作')")`, 配合 Spring Security + JWT Authentication Filter
- **认证(小程序端)**: `MemberInterceptor` 拦截 `/member/**`, JWT 解析 → `UserThreadLocal`
- **数据填充**: `MyMetaObjectHandler` 自动填充 createTime/updateTime/createBy/updateBy
- **单元测试**: 位于对应模块的 `src/test/java/` 下, 如 `zzyl-admin/.../test/IoTDeviceTest.java`

---

## 更多面试准备资料

项目 `docs/` 目录包含完整的面试复习文档:

| 文件 | 适用场景 |
|------|---------|
| `docs/review/01-项目架构与设计篇.md` ~ `06-综合实战与面试模拟篇.md` | 六篇系统复习 |
| `docs/健康评估功能-面试提问问题清单.md` | 健康评估专项 |
| `docs/设备管理功能-面试提问问题清单.md` | 设备管理专项 |
| `docs/微信小程序登录功能-面试提问问题清单.md` | 微信登录专项 |
| `docs/智颐养老系统-项目复盘口述稿（2分钟+5分钟）.md` | 面试话术练习 |
| `docs/智颐养老系统-项目复盘笔记（面试专用）.md` | 面试复盘精华 |

> 💡 交互式面试练习: 在终端输入 `/mentor` 可启动面试模拟教练。