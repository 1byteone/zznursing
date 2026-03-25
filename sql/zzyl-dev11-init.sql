CREATE TABLE "family_member" (
                                 "id" bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
                                 "phone" varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '手机号',
                                 "name" varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '名称',
                                 "avatar" varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '头像',
                                 "open_id" varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'OpenID',
                                 "gender" int DEFAULT NULL COMMENT '性别(0:男，1:女)',
                                 "create_time" timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                 "update_time" timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                 "create_by" bigint DEFAULT NULL COMMENT '创建人',
                                 "update_by" bigint DEFAULT NULL COMMENT '更新人',
                                 "remark" varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
                                 PRIMARY KEY ("id") USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='老人家属';