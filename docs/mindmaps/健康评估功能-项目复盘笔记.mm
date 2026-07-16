<map version="1.0.1">
<!-- 健康评估功能-项目复盘笔记 -->

<node ID="root" TEXT="健康评估功能-项目复盘">
    <!-- 功能概述 -->
    <node ID="overview" TEXT="一、功能概述" POSITION="right">
        <node TEXT="业务背景">
            <node TEXT="养老院需要智能分析老人体检报告"/>
            <node TEXT="传统人工分析耗时长效率低"/>
            <node TEXT="基于AI大模型开发智能健康评估"/>
        </node>
        <node TEXT="核心价值">
            <node TEXT="响应时间：8秒→1秒"/>
            <node TEXT="护理效率提升30%"/>
            <node TEXT="自动生成健康评分/风险等级/护理建议"/>
        </node>
        <node TEXT="技术栈">
            <node TEXT="百度千帆AI大模型 - 智能分析"/>
            <node TEXT="Redis - 缓存体检报告"/>
            <node TEXT="PDFBox - PDF解析"/>
            <node TEXT="阿里云OSS - 文件存储"/>
            <node TEXT="MyBatis-Plus - 持久层"/>
            <node TEXT="Spring Boot - 后端框架"/>
        </node>
    </node>

    <!-- 核心业务流程 -->
    <node ID="flow" TEXT="二、核心业务流程" POSITION="right">
        <node TEXT="整体流程图">
            <node TEXT="上传体检报告(PDF)"/>
            <node TEXT="↓"/>
            <node TEXT="OSS存储 + PDF解析"/>
            <node TEXT="↓"/>
            <node TEXT="Redis缓存(24h有效)"/>
            <node TEXT="↓"/>
            <node TEXT="提交评估请求(身份证号)"/>
            <node TEXT="↓"/>
            <node TEXT="构建Prompt调用AI"/>
            <node TEXT="↓"/>
            <node TEXT="解析JSON响应(FastJSON)"/>
            <node TEXT="↓"/>
            <node TEXT="保存评估结果(MySQL)"/>
        </node>
        <node TEXT="步骤1：上传体检报告">
            <node TEXT="前端上传PDF + 身份证号"/>
            <node TEXT="上传到阿里云OSS获取URL"/>
            <node TEXT="PDFBox解析PDF为文本"/>
            <node TEXT="存入Redis Hash结构">
                <node TEXT="Key: healthReport"/>
                <node TEXT="Field: 身份证号"/>
                <node TEXT="Value: PDF文本内容"/>
            </node>
            <node TEXT="设置24小时过期"/>
        </node>
        <node TEXT="步骤2：提交评估请求">
            <node TEXT="从Redis获取体检报告内容"/>
            <node TEXT="构建Prompt提示词"/>
            <node TEXT="调用百度千帆AI大模型"/>
            <node TEXT="解析AI返回的JSON"/>
            <node TEXT="保存评估数据到数据库"/>
        </node>
    </node>

    <!-- 核心代码实现 -->
    <node ID="code" TEXT="三、核心代码实现" POSITION="right">
        <node TEXT="Controller层 - 上传体检报告">
            <node TEXT="HealthAssessmentController.java"/>
            <node TEXT="@PostMapping('/upload')"/>
            <node TEXT="@RequestPart接收文件和表单"/>
            <node TEXT="aliyunOSSOperator.upload()"/>
            <node TEXT="PDFUtil.pdfToString()"/>
            <node TEXT="redisTemplate.opsForHash().put()"/>
            <node TEXT="面试要点">
                <node TEXT="@RequestPart接收文件"/>
                <node TEXT="Redis Hash结构存储"/>
                <node TEXT="设置过期时间防溢出"/>
            </node>
        </node>
        <node TEXT="Service层 - 健康评估核心逻辑">
            <node TEXT="HealthAssessmentServiceImpl.java"/>
            <node TEXT="insertHealthAssessment()">
                <node TEXT="从Redis获取报告内容"/>
                <node TEXT="构建Prompt"/>
                <node TEXT="调用AI"/>
                <node TEXT="解析JSON"/>
                <node TEXT="落库保存"/>
            </node>
            <node TEXT="面试要点">
                <node TEXT="Redis缓存避免重复解析"/>
                <node TEXT="AI调用OpenAI兼容SDK"/>
                <node TEXT="FastJSON解析结构化数据"/>
            </node>
        </node>
        <node TEXT="Prompt提示词设计">
            <node TEXT="getPrompt()方法"/>
            <node TEXT="以专业医生视角分析"/>
            <node TEXT="分步骤要求">
                <node TEXT="总检日期"/>
                <node TEXT="风险等级和健康指数"/>
                <node TEXT="风险分布"/>
                <node TEXT="异常数据解读"/>
                <node TEXT="八大系统评分"/>
                <node TEXT="综合总结"/>
            </node>
            <node TEXT="输出要求：纯JSON格式"/>
            <node TEXT="面试要点">
                <node TEXT="Prompt工程重要性"/>
                <node TEXT="明确输出格式JSON"/>
                <node TEXT="错误处理友好提示"/>
            </node>
        </node>
        <node TEXT="AI模型调用">
            <node TEXT="AIModelInvoker.java"/>
            <node TEXT="OpenAIOkHttpClient.builder()"/>
            <node TEXT="ChatCompletionCreateParams"/>
            <node TEXT="responseFormat设置为JSON"/>
            <node TEXT="面试要点">
                <node TEXT="百度千帆兼容OpenAI SDK"/>
                <node TEXT="responseFormat确保JSON输出"/>
                <node TEXT="配置外部化"/>
            </node>
        </node>
        <node TEXT="PDF解析工具">
            <node TEXT="PDFUtil.java"/>
            <node TEXT="PDDocument.load()"/>
            <node TEXT="PDFTextStripper.getText()"/>
            <node TEXT="finally关闭流"/>
            <node TEXT="面试要点">
                <node TEXT="Apache PDFBox"/>
                <node TEXT="资源释放"/>
                <node TEXT="局限性：只能提取文本"/>
            </node>
        </node>
    </node>

    <!-- 数据模型设计 -->
    <node ID="data" TEXT="四、数据模型设计" POSITION="right">
        <node TEXT="HealthAssessment实体">
            <node TEXT="id - 主键"/>
            <node TEXT="elderName - 老人姓名"/>
            <node TEXT="idCard - 身份证号"/>
            <node TEXT="birthDate/age/gender - 从身份证提取"/>
            <node TEXT="healthScore - 健康评分(0-100)"/>
            <node TEXT="riskLevel - 风险等级"/>
            <node TEXT="suggestionForAdmission - 是否建议入住"/>
            <node TEXT="nursingLevelName - 推荐护理等级"/>
            <node TEXT="totalCheckDate - 总检日期"/>
            <node TEXT="physicalReportUrl - 体检报告URL"/>
            <node TEXT="diseaseRisk/abnormalAnalysis/systemScore - JSON"/>
        </node>
        <node TEXT="AI响应VO对象">
            <node TEXT="HealthReportVo(顶层响应)">
                <node TEXT="totalCheckDate"/>
                <node TEXT="healthAssessment">
                    <node TEXT="riskLevel"/>
                    <node TEXT="healthIndex"/>
                </node>
                <node TEXT="riskDistribution">
                    <node TEXT="healthy/caution/risk/danger/severeDanger"/>
                </node>
                <node TEXT="abnormalData">
                    <node TEXT="conclusion/examinationItem"/>
                    <node TEXT="result/referenceValue"/>
                    <node TEXT="interpret/advice"/>
                </node>
                <node TEXT="systemScore">
                    <node TEXT="呼吸/消化/内分泌"/>
                    <node TEXT="免疫/循环/泌尿"/>
                    <node TEXT="运动/感官系统"/>
                </node>
                <node TEXT="summarize - 综合总结"/>
            </node>
        </node>
    </node>

    <!-- Redis缓存策略 -->
    <node ID="redis" TEXT="五、Redis缓存策略" POSITION="right">
        <node TEXT="为什么使用Redis缓存">
            <node TEXT="用户上传后可能不立即评估"/>
            <node TEXT="PDF解析耗时(IO操作)"/>
            <node TEXT="AI分析耗时(网络请求)"/>
        </node>
        <node TEXT="解决方案">
            <node TEXT="上传时：解析PDF存入Redis(24h)"/>
            <node TEXT="评估时：从Redis读取调用AI"/>
        </node>
        <node TEXT="数据结构选择">
            <node TEXT="Hash结构"/>
            <node TEXT="Key: healthReport"/>
            <node TEXT="Field: 身份证号"/>
            <node TEXT="Value: PDF文本"/>
            <node TEXT="优势">
                <node TEXT="一个Key管理所有用户报告"/>
                <node TEXT="通过Field快速定位"/>
                <node TEXT="方便批量管理"/>
            </node>
        </node>
        <node TEXT="过期策略">
            <node TEXT="24小时过期"/>
            <node TEXT="用户通常当天完成评估"/>
            <node TEXT="避免长期占用内存"/>
            <node TEXT="平衡体验和资源"/>
        </node>
    </node>

    <!-- 性能优化 -->
    <node ID="optimize" TEXT="六、性能优化分析" POSITION="right">
        <node TEXT="优化前后对比">
            <node TEXT="响应时间：8秒→1秒(87.5%)"/>
            <node TEXT="PDF解析：每次→仅上传时1次"/>
            <node TEXT="用户体验显著提升"/>
        </node>
        <node TEXT="优化点">
            <node TEXT="Redis缓存PDF内容">
                <node TEXT="评估时解析：2-3秒"/>
                <node TEXT="Redis读取：&lt;100ms"/>
            </node>
            <node TEXT="可扩展方向">
                <node TEXT="异步处理：消息队列"/>
                <node TEXT="AI结果缓存：同一报告复用"/>
                <node TEXT="OCR集成：处理扫描件"/>
            </node>
        </node>
    </node>

    <!-- 面试常见问题 -->
    <node ID="qa" TEXT="七、面试常见问题" POSITION="right">
        <node TEXT="Q1：为什么选择百度千帆？">
            <node TEXT="成本考虑：免费额度"/>
            <node TEXT="中文优化：体检报告更准确"/>
            <node TEXT="OpenAI兼容：可无缝切换"/>
            <node TEXT="合规性：数据不出境"/>
        </node>
        <node TEXT="Q2：Redis缓存失效怎么办？">
            <node TEXT="代码检查缓存是否存在"/>
            <node TEXT="不存在抛友好异常"/>
            <node TEXT="记录日志排查"/>
            <node TEXT="可持久化到数据库备份"/>
        </node>
        <node TEXT="Q3：如何保证AI准确性？">
            <node TEXT="Prompt工程设计"/>
            <node TEXT="结构化JSON输出"/>
            <node TEXT="人工审核关键决策"/>
            <node TEXT="持续优化反馈"/>
        </node>
        <node TEXT="Q4：PDF解析局限性？">
            <node TEXT="只能提取文本"/>
            <node TEXT="无法识别图片表格"/>
            <node TEXT="扫描件需OCR技术"/>
        </node>
        <node TEXT="Q5：如何处理大文件上传？">
            <node TEXT="配置文件大小限制(10MB)"/>
            <node TEXT="前端压缩PDF"/>
            <node TEXT="分片上传"/>
            <node TEXT="异步处理"/>
        </node>
        <node TEXT="Q6：如何防止重复提交？">
            <node TEXT="前端防抖：按钮禁用"/>
            <node TEXT="后端幂等：身份证+日期判断"/>
            <node TEXT="Redis分布式锁"/>
        </node>
        <node TEXT="Q7：健康评分映射护理等级">
            <node TEXT="90+ → 四级护理(最轻)"/>
            <node TEXT="80-90 → 三级护理"/>
            <node TEXT="70-80 → 二级护理"/>
            <node TEXT="60-70 → 一级护理"/>
            <node TEXT="60以下 → 特级护理(最重)"/>
        </node>
    </node>

    <!-- 项目亮点总结 -->
    <node ID="highlight" TEXT="八、项目亮点总结" POSITION="right">
        <node TEXT="技术亮点">
            <node TEXT="AI大模型集成">
                <node TEXT="百度千帆"/>
                <node TEXT="OpenAI兼容SDK"/>
                <node TEXT="Prompt工程"/>
            </node>
            <node TEXT="Redis缓存优化">
                <node TEXT="Hash结构"/>
                <node TEXT="24小时过期"/>
                <node TEXT="响应时间优化87.5%"/>
            </node>
            <node TEXT="PDF解析">
                <node TEXT="Apache PDFBox"/>
                <node TEXT="流式处理"/>
            </node>
            <node TEXT="配置外部化"/>
        </node>
        <node TEXT="业务亮点">
            <node TEXT="智能化决策">
                <node TEXT="自动健康评分"/>
                <node TEXT="自动护理等级推荐"/>
            </node>
            <node TEXT="用户体验">
                <node TEXT="上传评估分离"/>
                <node TEXT="快速响应"/>
                <node TEXT="友好错误提示"/>
            </node>
            <node TEXT="数据完整性"/>
        </node>
    </node>

    <!-- 代码文件索引 -->
    <node ID="files" TEXT="九、代码文件索引" POSITION="right">
        <node TEXT="核心业务代码">
            <node TEXT="HealthAssessmentController.java - 控制器"/>
            <node TEXT="HealthAssessmentServiceImpl.java - 业务实现"/>
            <node TEXT="IHealthAssessmentService.java - 服务接口"/>
            <node TEXT="HealthAssessment.java - 实体类"/>
            <node TEXT="HealthAssessmentMapper.java/xml - 数据访问"/>
        </node>
        <node TEXT="AI相关代码">
            <node TEXT="AIModelInvoker.java - AI调用工具"/>
            <node TEXT="BaiduAIProperties.java - AI配置类"/>
        </node>
        <node TEXT="工具类">
            <node TEXT="PDFUtil.java - PDF解析"/>
            <node TEXT="IDCardUtils.java - 身份证提取"/>
            <node TEXT="RedisCache.java - Redis操作"/>
        </node>
        <node TEXT="VO对象">
            <node TEXT="HealthReportVo.java - AI响应"/>
            <node TEXT="HealthAssessmentVo.java"/>
            <node TEXT="RiskDistributionVo.java"/>
            <node TEXT="AbnormalDataVo.java"/>
            <node TEXT="SystemScore.java"/>
        </node>
    </node>

    <!-- 扩展思考 -->
    <node ID="extend" TEXT="十、扩展思考" POSITION="right">
        <node TEXT="可优化方向">
            <node TEXT="异步处理：消息队列"/>
            <node TEXT="AI结果缓存"/>
            <node TEXT="OCR集成"/>
            <node TEXT="历史数据分析"/>
        </node>
        <node TEXT="面试加分项">
            <node TEXT="AI大模型原理：Transformer/Prompt"/>
            <node TEXT="Redis高级特性：持久化/集群"/>
            <node TEXT="性能优化：JVM/索引"/>
        </node>
    </node>

    <!-- 配置示例 -->
    <node ID="config" TEXT="附录：配置示例" POSITION="left">
        <node TEXT="百度千帆配置">
            <node TEXT="apiKey: bce-v3/ALTAK-xxxxx"/>
            <node TEXT="baseUrl: https://qianfan.baidubce.com/v2/"/>
            <node TEXT="model: ernie-5.0"/>
        </node>
        <node TEXT="Redis配置"/>
        <node TEXT="阿里云OSS配置"/>
    </node>
</node>
</map>