CREATE TABLE "health_assessment" (
                                     "id" bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
                                     "elder_name" varchar(255) DEFAULT NULL COMMENT '老人姓名',
                                     "id_card" varchar(255) DEFAULT NULL COMMENT '身份证号',
                                     "birth_date" datetime DEFAULT NULL COMMENT '出生日期',
                                     "age" int DEFAULT NULL COMMENT '年龄',
                                     "gender" int DEFAULT NULL COMMENT '性别(0:男，1:女)',
                                     "health_score" varchar(255) DEFAULT NULL COMMENT '健康评分',
                                     "risk_level" varchar(255) DEFAULT NULL COMMENT '危险等级(健康, 提示, 风险, 危险, 严重危险)',
                                     "suggestion_for_admission" int DEFAULT NULL COMMENT '是否建议入住(0:建议，1:不建议)',
                                     "nursing_level_name" varchar(255) DEFAULT NULL COMMENT '推荐护理等级',
                                     "admission_status" int DEFAULT NULL COMMENT '入住情况(0:已入住，1:未入住)',
                                     "total_check_date" varchar(64) DEFAULT NULL COMMENT '总检日期',
                                     "physical_exam_institution" varchar(255) DEFAULT NULL COMMENT '体检机构',
                                     "physical_report_url" varchar(255) DEFAULT NULL COMMENT '体检报告URL链接',
                                     "assessment_time" datetime DEFAULT NULL COMMENT '评估时间',
                                     "report_summary" text COMMENT '报告总结',
                                     "disease_risk" text COMMENT '疾病风险',
                                     "abnormal_analysis" text COMMENT '异常分析',
                                     "system_score" varchar(255) DEFAULT NULL COMMENT '健康系统分值',
                                     "create_by" varchar(255) DEFAULT NULL COMMENT '创建者',
                                     "create_time" datetime DEFAULT NULL COMMENT '创建时间',
                                     "update_by" varchar(255) DEFAULT NULL COMMENT '更新者',
                                     "update_time" datetime DEFAULT NULL COMMENT '更新时间',
                                     "remark" text COMMENT '备注',
                                     PRIMARY KEY ("id")
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='健康评估表';

INSERT INTO `health_assessment`(`system_score`,`nursing_level_name`,`gender`,`total_check_date`,`create_time`,`disease_risk`,`birth_date`,`health_score`,`id_card`,`abnormal_analysis`,`physical_exam_institution`,`create_by`,`risk_level`,`assessment_time`,`suggestion_for_admission`,`admission_status`,`physical_report_url`,`elder_name`,`id`,`age`,`report_summary`) VALUES ('{"breathingSystem":100,"digestiveSystem":85,"endocrineSystem":90,"immuneSystem":95,"circulatorySystem":80,"urinarySystem":90,"motionSystem":100,"senseSystem":90}','一级护理等级',0,'2023-10-10','2024-10-10T01:07:42','{"healthy":60,"caution":30,"risk":10,"danger":0,"severeDanger":0}','1960-01-26T00:00','80.5','210102196001267626','[{"conclusion":"心率略快","examinationItem":"心率","result":"92 次/分","referenceValue":"< 140","unit":"次/分","interpret":"心率稍高于理想范围，可能与情绪、活动或轻度心脏负担有关。","advice":"建议心电图检查及定期监测心率，保持情绪稳定，适量运动。"},{"conclusion":"轻度脂肪肝可能","examinationItem":"肝","result":"形态大小正常，实质回声略粗糙","referenceValue":"-","unit":"-","interpret":"肝脏实质回声略粗糙，提示可能有轻度脂肪肝，与饮食习惯、生活方式或遗传因素有关。","advice":"建议调整饮食结构，减少高脂食物摄入，增加运动，定期检查肝脏情况。"},{"conclusion":"慢性胆囊炎可能","examinationItem":"胆","result":"胆囊壁毛糙","referenceValue":"-","unit":"-","interpret":"胆囊壁毛糙，可能表示有慢性胆囊炎，可能与胆囊结石、感染或长期饮食不规律有关。","advice":"建议进一步检查胆囊情况，保持规律饮食，避免高脂食物。"},{"conclusion":"脾轻度增大","examinationItem":"脾","result":"轻度增大","referenceValue":"-","unit":"-","interpret":"脾脏轻度增大，可能与感染、血液系统疾病或自身免疫性疾病有关。","advice":"建议进一步检查脾脏，以确定增大的原因，并采取相应的治疗措施。"},{"conclusion":"右肾小囊肿可能","examinationItem":"肾","result":"右肾下极见一大小约 5mm 的无回声区","referenceValue":"-","unit":"mm","interpret":"右肾小囊肿，一般为良性病变，可能与肾小管憩室增多有关。","advice":"建议定期监测囊肿大小，若无症状且囊肿不增大，可暂不处理。"},{"conclusion":"前列腺形态略增大","examinationItem":"前列腺","result":"形态略增大","referenceValue":"-","unit":"-","interpret":"前列腺形态略增大，可能与前列腺增生有关，是老年男性常见病变。","advice":"建议进行PSA检查以排除前列腺肿瘤，并定期检查前列腺情况。"}]','中州体检','1','caution','2024-10-10T01:07:42',0,1,'https://java110-ai.oss-cn-beijing.aliyuncs.com/2024/10/af59dc76-0c01-4043-9706-b9ed1ec08984.pdf','刘爱国',9,64,'体检报告中心率、肝脏、胆囊、脾脏、肾脏、前列腺共6项指标提示异常，综合这些临床指标和数据分析：循环系统、消化系统存在隐患，其中循环系统有“中危”风险；消化系统部位有“低危”风险。');