
####################
##  device
####################
DROP TABLE IF EXISTS `device`;

####################
##  table device ddl
####################
CREATE TABLE "device" (
  "id" bigint NOT NULL AUTO_INCREMENT,
  "iot_id" varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '物联网设备ID',
  "secret" varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '设备秘钥',
  "binding_location" varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '绑定位置',
  "location_type" int DEFAULT NULL COMMENT '位置类型 0：随身设备 1：固定设备',
  "physical_location_type" int DEFAULT NULL COMMENT '物理位置类型 0楼层 1房间 2床位',
  "device_name" varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '设备名称',
  "product_key" varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '产品key',
  "product_name" varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '产品名称',
  "device_description" varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '位置备注',
  "have_entrance_guard" int NOT NULL DEFAULT '0' COMMENT '产品是否包含门禁，0：否，1：是',
  "create_time" datetime DEFAULT NULL COMMENT '创建时间',
  "update_time" datetime DEFAULT NULL COMMENT '更新时间',
  "create_by" bigint DEFAULT NULL COMMENT '创建人id',
  "node_id" varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '节点id',
  "update_by" bigint DEFAULT NULL COMMENT '更新人id',
  "remark" varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY ("id") USING BTREE,
  UNIQUE KEY "binding_location_location_type_physical_location_type_product_id" ("binding_location","location_type","physical_location_type","product_key") USING BTREE,
  KEY "device_id" ("iot_id") USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

####################
##  device_data
####################
DROP TABLE IF EXISTS `device_data`;

####################
##  table device_data ddl
####################
CREATE TABLE "device_data" (
  "id" bigint NOT NULL AUTO_INCREMENT COMMENT '告警规则ID，自增主键',
  "device_name" varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '设备名称',
  "iot_id" varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '设备ID',
  "product_key" varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '所属产品的key',
  "product_name" varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '产品名称',
  "function_id" varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '功能名称',
  "access_location" varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '接入位置',
  "location_type" int DEFAULT NULL COMMENT '位置类型 0：随身设备 1：固定设备',
  "physical_location_type" int DEFAULT NULL COMMENT '物理位置类型 0楼层 1房间 2床位',
  "device_description" varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '位置备注',
  "data_value" varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '数据值',
  "alarm_time" datetime DEFAULT NULL COMMENT '数据上报时间',
  "create_time" datetime NOT NULL COMMENT '创建时间',
  "update_time" datetime DEFAULT NULL COMMENT '更新时间',
  "create_by" bigint DEFAULT NULL COMMENT '创建人id',
  "update_by" bigint DEFAULT NULL COMMENT '更新人id',
  "remark" varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY ("id") USING BTREE,
  KEY "idx_iot_id_product_key" ("iot_id","product_key")
) ENGINE=InnoDB AUTO_INCREMENT=22950 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

####################
##  alert_rule
####################
DROP TABLE IF EXISTS `alert_rule`;

####################
##  table alert_rule ddl
####################
CREATE TABLE "alert_rule" (
  "id" bigint NOT NULL AUTO_INCREMENT,
  "product_key" varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '所属产品的key',
  "product_name" varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '产品名称',
  "module_id" varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '模块的key',
  "module_name" varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '模块名称',
  "function_name" varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '功能名称',
  "function_id" varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '功能标识',
  "iot_id" varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '物联网设备id',
  "device_name" varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '设备名称',
  "alert_data_type" int DEFAULT NULL COMMENT '报警数据类型，0：老人异常数据，1：设备异常数据',
  "alert_rule_name" varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '告警规则名称',
  "operator" varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '运算符',
  "value" float DEFAULT NULL COMMENT '阈值',
  "duration" int DEFAULT NULL COMMENT '持续周期',
  "alert_effective_period" varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '报警生效时段',
  "alert_silent_period" int DEFAULT NULL COMMENT '报警沉默周期',
  "status" int DEFAULT NULL COMMENT '0 禁用 1启用',
  "create_time" datetime NOT NULL COMMENT '创建时间',
  "update_time" datetime DEFAULT NULL COMMENT '更新时间',
  "create_by" bigint DEFAULT NULL COMMENT '创建人id',
  "update_by" bigint DEFAULT NULL COMMENT '更新人id',
  "remark" varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY ("id") USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

####################
##  alert_data
####################
DROP TABLE IF EXISTS `alert_data`;

####################
##  table alert_data ddl
####################
CREATE TABLE "alert_data" (
  "id" bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  "iot_id" varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '物联网设备id',
  "device_name" varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '设备名称',
  "product_key" varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '所属产品key',
  "product_name" varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '产品名称',
  "function_id" varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '功能标识符',
  "access_location" varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '接入位置',
  "location_type" int DEFAULT NULL COMMENT '位置类型 0：随身设备 1：固定设备',
  "physical_location_type" int DEFAULT NULL COMMENT '物理位置类型 0楼层 1房间 2床位',
  "device_description" varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '位置备注',
  "data_value" varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '数据值',
  "alert_rule_id" bigint NOT NULL COMMENT '报警规则id',
  "alert_reason" varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '报警原因，格式：功能名称+运算符+阈值+持续周期+聚合周期',
  "processing_result" varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '处理结果',
  "processor_id" bigint DEFAULT NULL COMMENT '处理人id',
  "processor_name" varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '处理人名称',
  "processing_time" datetime DEFAULT NULL COMMENT '处理时间',
  "type" int NOT NULL COMMENT '报警数据类型，0：老人异常数据，1：设备异常数据',
  "status" int NOT NULL COMMENT '状态，0：待处理，1：已处理',
  "user_id" bigint DEFAULT '0' COMMENT '接收人id',
  "create_time" datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  "update_time" datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  "create_by" bigint DEFAULT NULL COMMENT '创建人id',
  "update_by" bigint DEFAULT NULL COMMENT '更新人id',
  "remark" varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY ("id") USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='报警数据';
