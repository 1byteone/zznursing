<map version="1.0.1">
<!-- 微信小程序登录功能-项目复盘笔记 -->

<node ID="root" TEXT="微信小程序登录功能-项目复盘">
    <!-- 功能概述 -->
    <node ID="overview" TEXT="一、功能概述" POSITION="right">
        <node TEXT="业务背景">
            <node TEXT="养老院管理系统需要为老人家属提供微信小程序端访问入口"/>
            <node TEXT="小程序端与后台管理端用户体系不同"/>
            <node TEXT="需要独立实现小程序登录认证机制"/>
        </node>
        <node TEXT="核心功能">
            <node TEXT="微信授权登录 - 通过微信code获取openid"/>
            <node TEXT="手机号绑定 - 获取微信绑定的手机号"/>
            <node TEXT="JWT Token - 生成token用于后续认证"/>
            <node TEXT="ThreadLocal存储 - 线程内用户信息存储"/>
            <node TEXT="内存泄漏防护 - 请求结束后清理ThreadLocal"/>
        </node>
        <node TEXT="技术栈">
            <node TEXT="微信开放平台API - 获取openid和手机号"/>
            <node TEXT="JWT (JJWT) - Token生成与解析"/>
            <node TEXT="ThreadLocal - 线程内用户信息存储"/>
            <node TEXT="Spring Interceptor - 请求拦截与认证"/>
            <node TEXT="Hutool - HTTP请求和JSON处理"/>
        </node>
    </node>

    <!-- 核心业务流程 -->
    <node ID="flow" TEXT="二、核心业务流程" POSITION="right">
        <node TEXT="整体流程图">
            <node TEXT="微信小程序端">
                <node TEXT="wx.login() → 获取code → 获取手机号"/>
            </node>
            <node TEXT="后端服务">
                <node TEXT="获取openid(微信API) → 查询用户(MySQL) → 获取手机号(微信API) → 生成Token(JWT)"/>
            </node>
            <node TEXT="后续请求">
                <node TEXT="拦截器 → 解析Token → ThreadLocal存储 → 业务处理 → 清理资源"/>
            </node>
        </node>
        <node TEXT="登录流程详解">
            <node TEXT="小程序调用wx.login()"/>
            <node TEXT="↓"/>
            <node TEXT="获取临时code(5分钟有效)"/>
            <node TEXT="↓"/>
            <node TEXT="调用后端登录接口/member/user/login"/>
            <node TEXT="↓"/>
            <node TEXT="调用微信API获取openid"/>
            <node TEXT="↓"/>
            <node TEXT="根据openid查询本地用户表"/>
            <node TEXT="↓"/>
            <node TEXT="用户存在→更新信息 / 用户不存在→新建用户"/>
            <node TEXT="↓"/>
            <node TEXT="生成JWT Token返回前端"/>
        </node>
    </node>

    <!-- 核心代码实现 -->
    <node ID="code" TEXT="三、核心代码实现" POSITION="right">
        <node TEXT="ThreadLocal工具类">
            <node TEXT="UserThreadLocal.java"/>
            <node TEXT="private static final ThreadLocal&lt;Long&gt; LOCAL = new ThreadLocal&lt;&gt;()"/>
            <node TEXT="set(Long) - 放入用户ID"/>
            <node TEXT="get() - 获取用户ID"/>
            <node TEXT="remove() - 清除数据防止内存泄漏"/>
            <node TEXT="面试要点">
                <node TEXT="每个请求在独立线程中处理"/>
                <node TEXT="ThreadLocal保证线程内数据隔离"/>
                <node TEXT="避免参数层层传递"/>
                <node TEXT="static final保证一致性"/>
            </node>
        </node>
        <node TEXT="会员拦截器">
            <node TEXT="MemberInterceptor.java"/>
            <node TEXT="preHandle() - 解析Token存储用户ID到ThreadLocal">
                <node TEXT="检查HandlerMethod类型"/>
                <node TEXT="获取header中的authorization"/>
                <node TEXT="token为空响应401"/>
                <node TEXT="解析token获取claims"/>
                <node TEXT="获取userId放入ThreadLocal"/>
            </node>
            <node TEXT="afterCompletion() - 清理ThreadLocal防止内存泄漏"/>
            <node TEXT="面试要点">
                <node TEXT="执行流程: preHandle → Controller → afterCompletion"/>
                <node TEXT="afterCompletion无论成功失败都执行"/>
                <node TEXT="避免线程池复用导致数据污染"/>
            </node>
        </node>
        <node TEXT="拦截器注册配置">
            <node TEXT="ResourcesConfig.java"/>
            <node TEXT="EXCLUDE_PATH_PATTERNS排除登录接口"/>
            <node TEXT="addPathPatterns('/member/**')拦截路径"/>
            <node TEXT="面试要点">
                <node TEXT="拦截器属于Spring MVC"/>
                <node TEXT="过滤器属于Servlet"/>
                <node TEXT="拦截器可获取Controller信息"/>
            </node>
        </node>
        <node TEXT="微信服务实现">
            <node TEXT="WechatServiceImpl.java"/>
            <node TEXT="getOpenid(String code)">
                <node TEXT="封装请求参数(appid, secret, js_code)"/>
                <node TEXT="调用jscode2session API"/>
                <node TEXT="解析返回openid"/>
            </node>
            <node TEXT="getPhone(String detailCode)">
                <node TEXT="获取access_token"/>
                <node TEXT="调用getPhoneNumber API"/>
                <node TEXT="返回手机号"/>
            </node>
            <node TEXT="面试要点">
                <node TEXT="code有效期5分钟只能用一次"/>
                <node TEXT="openid是用户在小程序的唯一标识"/>
                <node TEXT="获取手机号需要access_token"/>
            </node>
        </node>
        <node TEXT="登录业务实现">
            <node TEXT="FamilyMemberServiceImpl.java"/>
            <node TEXT="login()方法">
                <node TEXT="调用微信API获取openId"/>
                <node TEXT="根据openId查询用户"/>
                <node TEXT="用户为空则创建新用户对象"/>
                <node TEXT="调用微信API获取手机号"/>
                <node TEXT="保存或更新用户"/>
                <node TEXT="生成JWT Token"/>
            </node>
            <node TEXT="自动注册机制">
                <node TEXT="随机前缀 + 手机号后四位"/>
                <node TEXT="生成唯一友好昵称"/>
            </node>
            <node TEXT="面试要点">
                <node TEXT="登录即注册设计"/>
                <node TEXT="Token只存userId和nickName"/>
                <node TEXT="不存储敏感信息"/>
            </node>
        </node>
        <node TEXT="Token服务">
            <node TEXT="TokenService.java"/>
            <node TEXT="createToken(Map&lt;String, Object&gt; claims)">
                <node TEXT="Jwts.builder().setClaims(claims)"/>
                <node TEXT="signWith(SignatureAlgorithm.HS512, secret)"/>
            </node>
            <node TEXT="parseToken(String token)">
                <node TEXT="Jwts.parser().setSigningKey(secret)"/>
                <node TEXT="返回Claims"/>
            </node>
            <node TEXT="面试要点">
                <node TEXT="JWT组成: Header.Payload.Signature"/>
                <node TEXT="无状态服务端不需要存储"/>
                <node TEXT="可携带用户信息跨服务共享"/>
            </node>
        </node>
        <node TEXT="Controller中使用ThreadLocal">
            <node TEXT="MemberReservationController.java"/>
            <node TEXT="UserThreadLocal.getUserId()直接获取"/>
            <node TEXT="无需从Request解析Token"/>
            <node TEXT="无需方法参数传递userId"/>
        </node>
    </node>

    <!-- 数据模型设计 -->
    <node ID="data" TEXT="四、数据模型设计" POSITION="right">
        <node TEXT="FamilyMember实体">
            <node TEXT="id - 主键"/>
            <node TEXT="phone - 手机号"/>
            <node TEXT="name - 昵称"/>
            <node TEXT="avatar - 头像URL"/>
            <node TEXT="openId - 微信openid"/>
            <node TEXT="gender - 性别(0:男 1:女)"/>
        </node>
        <node TEXT="UserLoginRequestDto">
            <node TEXT="nickName - 昵称"/>
            <node TEXT="code - 登录临时凭证"/>
            <node TEXT="phoneCode - 手机号临时凭证"/>
        </node>
        <node TEXT="LoginVo">
            <node TEXT="token - JWT token"/>
            <node TEXT="nickName - 昵称"/>
        </node>
    </node>

    <!-- ThreadLocal深度解析 -->
    <node ID="threadlocal" TEXT="五、ThreadLocal深度解析" POSITION="right">
        <node TEXT="原理图">
            <node TEXT="Thread对象内部维护ThreadLocalMap"/>
            <node TEXT="Key是ThreadLocal对象"/>
            <node TEXT="Value是存储的值"/>
            <node TEXT="不同线程获取各自线程的值"/>
        </node>
        <node TEXT="内存泄漏问题">
            <node TEXT="Entry继承WeakReference Key是弱引用"/>
            <node TEXT="Value是强引用不会自动回收"/>
            <node TEXT="线程池复用ThreadLocalMap不清理"/>
            <node TEXT="解决方案: afterCompletion中remove()"/>
        </node>
        <node TEXT="为什么用static final">
            <node TEXT="static: 所有实例共享同一个ThreadLocal对象"/>
            <node TEXT="final: 防止被重新赋值"/>
            <node TEXT="节省内存: 避免每个实例创建新的"/>
        </node>
    </node>

    <!-- 面试常见问题 -->
    <node ID="qa" TEXT="六、面试常见问题" POSITION="right">
        <node TEXT="Q1: ThreadLocal和Synchronized的区别？">
            <node TEXT="ThreadLocal: 数据隔离无锁性能高"/>
            <node TEXT="Synchronized: 数据共享有锁可能阻塞"/>
            <node TEXT="ThreadLocal用于独立数据"/>
            <node TEXT="Synchronized用于共享资源保护"/>
        </node>
        <node TEXT="Q2: 为什么必须调用remove()？">
            <node TEXT="线程池复用线程不会销毁"/>
            <node TEXT="ThreadLocal数据不会自动清理"/>
            <node TEXT="导致内存泄漏可能OOM"/>
            <node TEXT="数据污染: 用户A看到用户B数据"/>
        </node>
        <node TEXT="Q3: JWT Token存储在客户端安全吗？">
            <node TEXT="不要存储敏感信息"/>
            <node TEXT="设置合理过期时间"/>
            <node TEXT="使用HTTPS传输"/>
            <node TEXT="重要操作需要二次验证"/>
        </node>
        <node TEXT="Q4: 微信登录和传统登录的区别？">
            <node TEXT="认证方式: openid+手机号 vs 用户名+密码"/>
            <node TEXT="用户标识: openid vs 用户名"/>
            <node TEXT="自动注册: 支持 vs 不支持"/>
            <node TEXT="安全性: 微信背书较安全"/>
        </node>
        <node TEXT="Q5: 如何处理Token过期？">
            <node TEXT="JWT设置exp字段"/>
            <node TEXT="拦截器检查过期时间"/>
            <node TEXT="过期返回401前端跳转登录"/>
            <node TEXT="可实现refreshToken刷新机制"/>
        </node>
        <node TEXT="Q6: 如何防止Token被盗用？">
            <node TEXT="HTTPS传输加密"/>
            <node TEXT="Token绑定设备信息"/>
            <node TEXT="Token设置较短有效期"/>
            <node TEXT="敏感操作二次验证"/>
        </node>
        <node TEXT="Q7: ThreadLocal在项目中的其他应用？">
            <node TEXT="用户上下文存储当前用户信息"/>
            <node TEXT="请求上下文存储请求相关信息"/>
            <node TEXT="数据库连接每个线程独立连接"/>
            <node TEXT="事务管理Spring事务使用ThreadLocal"/>
        </node>
    </node>

    <!-- 项目亮点总结 -->
    <node ID="highlight" TEXT="七、项目亮点总结" POSITION="right">
        <node TEXT="技术亮点">
            <node TEXT="ThreadLocal应用">
                <node TEXT="线程内用户信息存储"/>
                <node TEXT="多线程数据隔离"/>
                <node TEXT="避免参数层层传递"/>
            </node>
            <node TEXT="内存泄漏防护">
                <node TEXT="拦截器afterCompletion清理"/>
                <node TEXT="保证资源释放"/>
                <node TEXT="避免线程池复用问题"/>
            </node>
            <node TEXT="微信登录集成">
                <node TEXT="openid识别用户"/>
                <node TEXT="手机号绑定完善信息"/>
                <node TEXT="自动注册机制"/>
            </node>
            <node TEXT="JWT认证">
                <node TEXT="无状态认证"/>
                <node TEXT="携带用户信息"/>
                <node TEXT="前后端分离友好"/>
            </node>
        </node>
        <node TEXT="业务亮点">
            <node TEXT="无感登录微信静默授权"/>
            <node TEXT="自动注册减少用户操作"/>
            <node TEXT="安全认证拦截器统一处理"/>
        </node>
    </node>

    <!-- 代码文件索引 -->
    <node ID="files" TEXT="八、代码文件索引" POSITION="right">
        <node TEXT="核心业务代码">
            <node TEXT="FamilyMemberController.java - 登录接口"/>
            <node TEXT="FamilyMemberServiceImpl.java - 登录业务实现"/>
            <node TEXT="WechatServiceImpl.java - 微信API调用"/>
            <node TEXT="MemberReservationController.java - ThreadLocal使用示例"/>
        </node>
        <node TEXT="拦截器相关">
            <node TEXT="MemberInterceptor.java - 会员拦截器"/>
            <node TEXT="ResourcesConfig.java - 拦截器注册配置"/>
        </node>
        <node TEXT="工具类">
            <node TEXT="UserThreadLocal.java - ThreadLocal工具类"/>
            <node TEXT="TokenService.java - Token服务"/>
        </node>
        <node TEXT="DTO/VO">
            <node TEXT="UserLoginRequestDto.java - 登录请求参数"/>
            <node TEXT="LoginVo.java - 登录响应"/>
            <node TEXT="FamilyMember.java - 用户实体"/>
        </node>
    </node>

    <!-- 扩展思考 -->
    <node ID="extend" TEXT="九、扩展思考" POSITION="right">
        <node TEXT="可优化方向">
            <node TEXT="Token过期机制和刷新机制"/>
            <node TEXT="openid缓存减少微信API调用"/>
            <node TEXT="用户信息缓存"/>
            <node TEXT="安全增强: IP绑定、异常检测"/>
        </node>
        <node TEXT="面试加分项">
            <node TEXT="ThreadLocal原理: ThreadLocalMap/WeakReference"/>
            <node TEXT="JWT原理: 三部分组成/签名验证"/>
            <node TEXT="微信登录原理: OAuth2.0流程/openid和unionid"/>
        </node>
    </node>

    <!-- 配置示例 -->
    <node ID="config" TEXT="附录：配置示例" POSITION="left">
        <node TEXT="微信小程序配置">
            <node TEXT="wechat.appId: wx8359fa91908675d8"/>
            <node TEXT="wechat.appSecret: ede7b63201bf2986b43dfd7103dd5d56"/>
        </node>
        <node TEXT="Token配置">
            <node TEXT="token.header: Authorization"/>
            <node TEXT="token.secret: abcdefghijklmnopqrstuvwxyz"/>
            <node TEXT="token.expireTime: 30"/>
        </node>
        <node TEXT="微信API说明">
            <node TEXT="获取openid: jscode2session"/>
            <node TEXT="获取access_token: cgi-bin/token"/>
            <node TEXT="获取手机号: getuserphonenumber"/>
        </node>
    </node>
</node>
</map>
