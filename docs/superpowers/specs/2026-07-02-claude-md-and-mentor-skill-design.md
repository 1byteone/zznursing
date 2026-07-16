# 智颐养老系统 CLI 工具 - CLAUDE.md 与 Interview Mentor Skill 设计文档

## 概述

为智颐养老护理系统（zznursing）项目生成两个文件：
1. `CLAUDE.md` — 项目根目录的 AI 上下文文档，帮助 AI 助手快速理解项目结构、核心代码路径和面试考点
2. `.claude/skills/interview-mentor.md` — 交互式面试模拟器 Skill，帮助学生进行项目经历面试练习

## 目标用户

- 正在或即将面试的学生（mentor skill 消费者）
- 后续在项目中工作的 AI 助手（CLAUDE.md 消费者）

## 现有资源

项目 docs/ 目录已有丰富面试资料：
- 6 篇复习笔记（架构、健康评估、微信登录、IoT设备、入住护理、综合模拟）
- 3 个模块的复盘笔记 + 面试问题清单
- 2 分钟 / 5 分钟口述稿
- 56 个架构图（PlantUML）
- 思维导图

## 设计

### 1. CLAUDE.md

**文件位置**: `D:\code\codeJava\heima-phase4\zznursing\CLAUDE.md`

**结构**：
1. 项目概述 — 一句话定位、核心模块、技术栈（带版本号）
2. 多模块结构速查 — 每个模块一行 + 一句话职责
3. 核心职责索引（按简历描述） — 三个职责的完整代码链路、数据流、关键类、面试考点
4. 外部集成配置 — 配置项位置、配置文件路径
5. 开发启动指南 — 环境要求、启动顺序
6. 编码规范 — 本项目实际遵循的惯例

### 2. Interview Mentor Skill

**文件位置**: `D:\code\codeJava\heima-phase4\zznursing\.claude\skills\interview-mentor.md`

**交互模式**：三级模拟面试

- 第一轮：基础概念（3-4 题，每题评分 1-5）
- 第二轮：代码实现（3-4 题，涉及具体类和链路）
- 第三轮：架构设计（2-3 题，开放性问题）
- 最终输出：评估报告 + 薄弱环节标记 + 建议复习文档

**Skill 元数据**：
- name: interview-mentor
- description: 智颐养老系统面试模拟教练 — 三级递进式提问
- model: 默认（继承会话模型）
- shell: force

## 三个职责的细节覆盖要求

### 健康评估
- 百度千帆 AI 调用（OpenAI SDK 兼容模式）
- PDF 提取（Apache PDFBox）+ OSS 上传
- Redis 缓存策略（Hash, 24h TTL, 身份证号 field）
- 8秒→1秒优化：缓存 PDF 文本避免重复解析
- 结构化输出映射：HealthReportVo（八大系统、五级风险、异常数据）
- AI Prompt 设计要点

### 设备管理
- 华为云 IoTDA SDK 调用
- 产品列表同步 Redis（3分钟→10秒优化）
- 设备注册双写（云端+本地）
- 位置绑定（locationType / physicalLocationType）
- AMQP 数据消费（AmqpClient + ApplicationRunner）
- 设备数据批量入库 + Redis 缓存

### 微信小程序登录
- 登录链路：code → openId → 手机号 → 注册/更新 → JWT
- MemberInterceptor 拦截 /member/**
- UserThreadLocal: set/get/remove
- ThreadLocal 内存泄漏防护
- 为什么用 ThreadLocal 而非参数传递