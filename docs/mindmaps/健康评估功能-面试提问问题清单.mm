<map version="1.0.1">
<!-- 健康评估功能-面试提问问题清单 -->

<node ID="root" TEXT="健康评估功能-面试提问问题清单">
    <!-- 业务理解类 -->
    <node ID="business" TEXT="一、业务理解类" POSITION="right">
        <node TEXT="Q1: 请介绍一下健康评估功能的业务背景和核心价值？">
            <node TEXT="对老人体检报告进行智能分析评估身体健康状态"/>
            <node TEXT="响应时间从人工8秒降低到AI分析1秒"/>
            <node TEXT="护理人员使用效率提升约30%"/>
            <node TEXT="自动生成健康评分、风险等级、护理等级建议"/>
        </node>
        <node TEXT="Q2: 健康评分是如何映射到护理等级的？">
            <node TEXT="分数越高健康状况越好护理等级越低"/>
            <node TEXT="90+ → 四级护理(最轻)"/>
            <node TEXT="80-90 → 三级护理"/>
            <node TEXT="70-80 → 二级护理"/>
            <node TEXT="60-70 → 一级护理"/>
            <node TEXT="60以下 → 特级护理(最重)"/>
        </node>
    </node>

    <!-- 技术实现类 -->
    <node ID="tech" TEXT="二、技术实现类" POSITION="right">
        <node TEXT="Q3: 为什么选择百度千帆大模型？">
            <node TEXT="成本考虑: 提供免费额度适合项目初期"/>
            <node TEXT="中文优化: 针对中文场景优化体检报告分析更准确"/>
            <node TEXT="OpenAI兼容: 使用标准SDK后续可无缝切换"/>
            <node TEXT="合规性: 国内服务商数据不出境"/>
        </node>
        <node TEXT="Q4: Redis缓存体检报告内容的作用是什么？">
            <node TEXT="避免重复解析PDF(耗时2-3秒)"/>
            <node TEXT="用户上传后可能不会立即评估"/>
            <node TEXT="24小时平衡用户体验和资源消耗"/>
            <node TEXT="用户通常当天完成评估"/>
        </node>
        <node TEXT="Q5: Redis存储体检报告为什么用Hash结构？">
            <node TEXT="Key: 'healthReport'(固定值)"/>
            <node TEXT="Field: 身份证号"/>
            <node TEXT="Value: PDF文本内容"/>
            <node TEXT="Hash优势: 一个Key管理所有用户报告通过Field快速定位"/>
        </node>
        <node TEXT="Q6: PDF解析使用了什么技术？有什么局限性？">
            <node TEXT="使用Apache PDFBox解析PDF"/>
            <node TEXT="PDFTextStripper提取文本内容"/>
            <node TEXT="局限性: 只能提取文本无法识别图片、表格"/>
            <node TEXT="扫描件PDF无法处理需OCR技术"/>
        </node>
    </node>

    <!-- 深度追问类 -->
    <node ID="deep" TEXT="三、深度追问类" POSITION="right">
        <node TEXT="Q7: Prompt提示词是如何设计的？">
            <node TEXT="分步骤要求: 总检日期→风险评估→异常分析→系统评分→总结"/>
            <node TEXT="明确输出格式为纯JSON便于程序解析"/>
            <node TEXT="以专业医生视角分析提高准确性"/>
            <node TEXT="结构化输出便于后续处理和存储"/>
        </node>
        <node TEXT="Q8: 如何保证AI分析结果的准确性？">
            <node TEXT="Prompt工程: 详细的提示词设计"/>
            <node TEXT="结构化输出: 要求AI返回JSON"/>
            <node TEXT="人工审核: 关键决策仍需人工确认"/>
            <node TEXT="持续优化: 根据反馈调整Prompt"/>
        </node>
        <node TEXT="Q9: Redis缓存失效了怎么办？">
            <node TEXT="代码中检查缓存是否存在"/>
            <node TEXT="不存在时抛出友好异常提示用户重新上传"/>
            <node TEXT="记录日志便于排查Redis问题"/>
            <node TEXT="可考虑持久化到数据库作为备份"/>
        </node>
        <node TEXT="Q10: 如何防止用户重复提交评估请求？">
            <node TEXT="前端防抖: 提交按钮禁用"/>
            <node TEXT="后端幂等性: 基于身份证号+日期判断是否已评估"/>
            <node TEXT="Redis分布式锁: 防止并发提交"/>
        </node>
    </node>

    <!-- 扩展思考类 -->
    <node ID="extend" TEXT="四、扩展思考类" POSITION="right">
        <node TEXT="Q11: 如果让你优化健康评估功能的性能你会怎么做？">
            <node TEXT="异步处理: 使用消息队列前端轮询结果"/>
            <node TEXT="AI结果缓存: 同一报告多次评估时复用"/>
            <node TEXT="OCR集成: 处理扫描件PDF"/>
            <node TEXT="历史数据分析: 对比历史报告健康趋势分析"/>
        </node>
        <node TEXT="Q12: 如何处理大文件上传？">
            <node TEXT="配置文件大小限制(如10MB)"/>
            <node TEXT="前端压缩PDF"/>
            <node TEXT="分片上传"/>
            <node TEXT="异步处理"/>
        </node>
    </node>

    <!-- 代码细节类 -->
    <node ID="code" TEXT="五、代码细节类" POSITION="right">
        <node TEXT="Q13: 上传体检报告接口使用了什么注解接收文件？">
            <node TEXT="使用@RequestPart接收文件和表单数据"/>
            <node TEXT="支持multipart/form-data格式"/>
            <node TEXT="区别于@RequestParam和@RequestBody"/>
        </node>
        <node TEXT="Q14: AI模型调用时responseFormat设置为什么？">
            <node TEXT="设置为JSON格式"/>
            <node TEXT="确保AI输出结构化数据"/>
            <node TEXT="便于程序解析和验证"/>
        </node>
        <node TEXT="Q15: 百度千帆API调用为什么使用OpenAI兼容SDK？">
            <node TEXT="百度千帆兼容OpenAI接口规范"/>
            <node TEXT="降低学习成本使用熟悉的SDK"/>
            <node TEXT="便于后续切换其他模型"/>
            <node TEXT="代码更简洁易维护"/>
        </node>
    </node>

    <!-- AI应用类 -->
    <node ID="ai" TEXT="六、AI应用类" POSITION="right">
        <node TEXT="Q16: 你对AI大模型在项目中的应用有什么理解？">
            <node TEXT="AI作为工具辅助决策不是替代人工"/>
            <node TEXT="Prompt工程是关键影响输出质量"/>
            <node TEXT="需要考虑成本、延迟、准确性"/>
            <node TEXT="结构化输出便于系统集成"/>
        </node>
        <node TEXT="Q17: 如果AI返回的结果格式不正确怎么办？">
            <node TEXT="JSON解析时捕获异常"/>
            <node TEXT="提供友好错误提示"/>
            <node TEXT="记录原始响应用于排查"/>
            <node TEXT="可考虑重试或降级处理"/>
        </node>
    </node>
</node>
</map>
