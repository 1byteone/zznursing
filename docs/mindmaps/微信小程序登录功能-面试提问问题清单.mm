<map version="1.0.1">
<!-- 微信小程序登录功能-面试提问问题清单 -->

<node ID="root" TEXT="微信小程序登录功能-面试提问问题清单">
    <!-- 业务理解类 -->
    <node ID="business" TEXT="一、业务理解类" POSITION="right">
        <node TEXT="Q1: 请介绍一下微信小程序登录的整体流程？">
            <node TEXT="小程序调用wx.login()获取临时code"/>
            <node TEXT="后端调用jscode2session获取openid"/>
            <node TEXT="根据openid查询/创建用户"/>
            <node TEXT="获取微信绑定的手机号完善信息"/>
            <node TEXT="生成JWT Token返回给前端"/>
        </node>
        <node TEXT="Q2: 微信登录和传统登录有什么区别？">
            <node TEXT="认证方式: openid+手机号 vs 用户名+密码"/>
            <node TEXT="用户标识: openid vs 用户名"/>
            <node TEXT="自动注册: 微信登录支持"/>
            <node TEXT="安全性: 微信背书较安全"/>
        </node>
    </node>

    <!-- ThreadLocal核心类 -->
    <node ID="threadlocal" TEXT="二、ThreadLocal核心类" POSITION="right">
        <node TEXT="Q3: 为什么使用ThreadLocal存储用户ID？">
            <node TEXT="每个请求在独立线程中处理"/>
            <node TEXT="ThreadLocal保证线程内数据隔离"/>
            <node TEXT="避免参数层层传递"/>
            <node TEXT="方便在任意位置获取用户信息"/>
        </node>
        <node TEXT="Q4: ThreadLocal的原理是什么？">
            <node TEXT="每个Thread对象内部维护ThreadLocalMap"/>
            <node TEXT="Key是ThreadLocal对象Value是存储的值"/>
            <node TEXT="不同线程获取各自线程的值"/>
            <node TEXT="ThreadLocalMap是Thread的内部类"/>
        </node>
        <node TEXT="Q5: 为什么必须调用remove()方法？">
            <node TEXT="Tomcat使用线程池线程会被复用"/>
            <node TEXT="ThreadLocal数据不会自动清理"/>
            <node TEXT="导致内存泄漏可能OOM"/>
            <node TEXT="数据污染: 用户A看到用户B数据"/>
        </node>
        <node TEXT="Q6: ThreadLocal为什么要用static final修饰？">
            <node TEXT="static: 所有实例共享同一个ThreadLocal对象"/>
            <node TEXT="final: 防止被重新赋值保证一致性"/>
            <node TEXT="节省内存: 避免每个实例创建新的"/>
        </node>
    </node>

    <!-- 拦截器设计类 -->
    <node ID="interceptor" TEXT="三、拦截器设计类" POSITION="right">
        <node TEXT="Q7: 拦截器的执行流程是怎样的？">
            <node TEXT="请求 → preHandle → Controller → postHandle → afterCompletion"/>
            <node TEXT="preHandle: 请求处理前执行返回true放行"/>
            <node TEXT="afterCompletion: 请求完成后执行无论是否异常"/>
        </node>
        <node TEXT="Q8: 为什么在afterCompletion中清理ThreadLocal？">
            <node TEXT="afterCompletion无论成功失败都会执行"/>
            <node TEXT="保证ThreadLocal一定会被清理"/>
            <node TEXT="避免线程池复用导致数据污染"/>
        </node>
        <node TEXT="Q9: 拦截器和过滤器有什么区别？">
            <node TEXT="拦截器属于Spring MVC过滤器属于Servlet"/>
            <node TEXT="拦截器在Controller前后过滤器在DispatcherServlet前后"/>
            <node TEXT="拦截器可获取Controller信息过滤器更底层"/>
            <node TEXT="过滤器适合编码过滤拦截器适合认证授权"/>
        </node>
    </node>

    <!-- JWT Token类 -->
    <node ID="jwt" TEXT="四、JWT Token类" POSITION="right">
        <node TEXT="Q10: JWT Token由哪几部分组成？">
            <node TEXT="Header: 算法和类型"/>
            <node TEXT="Payload: 存储的数据(userId, nickName)"/>
            <node TEXT="Signature: 签名防止篡改"/>
        </node>
        <node TEXT="Q11: JWT Token存储在客户端安全吗？">
            <node TEXT="不要存储敏感信息"/>
            <node TEXT="设置合理的过期时间"/>
            <node TEXT="使用HTTPS传输"/>
            <node TEXT="Token绑定设备信息"/>
            <node TEXT="敏感操作需要二次验证"/>
        </node>
        <node TEXT="Q12: 如何处理Token过期？">
            <node TEXT="JWT设置exp字段过期时间"/>
            <node TEXT="拦截器检查过期时间"/>
            <node TEXT="过期返回401前端跳转登录"/>
            <node TEXT="可实现refreshToken刷新机制"/>
        </node>
    </node>

    <!-- 微信API类 -->
    <node ID="wechat" TEXT="五、微信API类" POSITION="right">
        <node TEXT="Q13: code的作用是什么？有效期多长？">
            <node TEXT="临时登录凭证5分钟有效"/>
            <node TEXT="只能使用一次"/>
            <node TEXT="用于换取openid和session_key"/>
        </node>
        <node TEXT="Q14: openid的作用是什么？和unionid有什么区别？">
            <node TEXT="openid: 用户在当前小程序的唯一标识"/>
            <node TEXT="unionid: 用户在同一开放平台下的唯一标识"/>
            <node TEXT="不同小程序的openid不同unionid相同"/>
        </node>
        <node TEXT="Q15: 获取手机号需要哪些步骤？">
            <node TEXT="小程序获取phoneCode"/>
            <node TEXT="后端获取access_token"/>
            <node TEXT="调用getPhoneNumber API"/>
            <node TEXT="解析返回的手机号"/>
        </node>
    </node>

    <!-- 深度追问类 -->
    <node ID="deep" TEXT="六、深度追问类" POSITION="right">
        <node TEXT="Q16: ThreadLocal和Synchronized的区别？">
            <node TEXT="ThreadLocal: 数据隔离每个线程独立数据"/>
            <node TEXT="Synchronized: 数据共享多线程访问共享资源"/>
            <node TEXT="ThreadLocal无锁性能高Synchronized可能阻塞"/>
            <node TEXT="ThreadLocal用于用户请求等独立数据"/>
        </node>
        <node TEXT="Q17: 如何防止Token被盗用？">
            <node TEXT="HTTPS传输加密"/>
            <node TEXT="Token绑定设备信息"/>
            <node TEXT="Token设置较短有效期"/>
            <node TEXT="敏感操作二次验证"/>
            <node TEXT="异常登录检测"/>
        </node>
        <node TEXT="Q18: 新用户自动注册时昵称是如何生成的？">
            <node TEXT="随机前缀(如'生活更美好'、'大桔大利'等)"/>
            <node TEXT="加上手机号后四位"/>
            <node TEXT="生成唯一且友好的昵称"/>
        </node>
    </node>

    <!-- 扩展思考类 -->
    <node ID="extend" TEXT="七、扩展思考类" POSITION="right">
        <node TEXT="Q19: 如果让你优化登录功能你会怎么做？">
            <node TEXT="Token过期机制和刷新机制"/>
            <node TEXT="openid缓存减少微信API调用"/>
            <node TEXT="用户信息缓存"/>
            <node TEXT="安全增强: IP绑定、异常检测"/>
        </node>
        <node TEXT="Q20: ThreadLocal在项目中还有哪些应用场景？">
            <node TEXT="用户上下文: 存储当前用户信息"/>
            <node TEXT="请求上下文: 存储请求相关信息"/>
            <node TEXT="数据库连接: 每个线程独立连接"/>
            <node TEXT="事务管理: Spring事务使用ThreadLocal"/>
            <node TEXT="日期格式化: SimpleDateFormat线程不安全"/>
        </node>
    </node>
</node>
</map>
