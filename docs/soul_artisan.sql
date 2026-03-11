/*
 Navicat Premium Data Transfer

 Source Server         : 本地127
 Source Server Type    : MySQL
 Source Server Version : 80012
 Source Host           : 127.0.0.1:3306
 Source Schema         : soul_artisan

 Target Server Type    : MySQL
 Target Server Version : 80012
 File Encoding         : 65001

 Date: 11/03/2026 21:58:39
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for admin_login_log
-- ----------------------------
DROP TABLE IF EXISTS `admin_login_log`;
CREATE TABLE `admin_login_log`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `admin_id` bigint(20) NULL DEFAULT NULL COMMENT '管理员ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户名',
  `ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '登录IP',
  `location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'IP归属地',
  `browser` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '浏览器',
  `os` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作系统',
  `status` tinyint(4) NOT NULL COMMENT '状态: 0-失败 1-成功',
  `message` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '提示消息',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint(20) NULL DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_admin_id`(`admin_id` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 91 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '管理员登录日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of admin_login_log
-- ----------------------------

-- ----------------------------
-- Table structure for admin_operation_log
-- ----------------------------
DROP TABLE IF EXISTS `admin_operation_log`;
CREATE TABLE `admin_operation_log`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `admin_id` bigint(20) NOT NULL COMMENT '管理员ID',
  `admin_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '管理员名称',
  `site_id` bigint(20) NULL DEFAULT NULL COMMENT '站点ID',
  `module` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作模块',
  `operation` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作类型',
  `method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '请求方法',
  `params` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '请求参数',
  `result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '返回结果',
  `ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作IP',
  `location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'IP归属地',
  `user_agent` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户代理',
  `status` tinyint(4) NOT NULL COMMENT '状态: 0-失败 1-成功',
  `error_msg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '错误信息',
  `cost_time` int(11) NULL DEFAULT NULL COMMENT '耗时(ms)',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint(20) NULL DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_admin_id`(`admin_id` ASC) USING BTREE,
  INDEX `idx_site_id`(`site_id` ASC) USING BTREE,
  INDEX `idx_module`(`module` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 164 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '管理员操作日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of admin_operation_log
-- ----------------------------

-- ----------------------------
-- Table structure for admin_user
-- ----------------------------
DROP TABLE IF EXISTS `admin_user`;
CREATE TABLE `admin_user`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码(BCrypt加密)',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '真实姓名',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像',
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色: SYSTEM_ADMIN-系统管理员 SITE_ADMIN-站点管理员',
  `site_id` bigint(20) NULL DEFAULT NULL COMMENT '所属站点ID（站点管理员必填，系统管理员为NULL）',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用 1-启用',
  `last_login_time` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `last_login_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '最后登录IP',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint(20) NULL DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `uk_site_id`(`site_id` ASC) USING BTREE,
  INDEX `idx_role`(`role` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '管理员表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of admin_user
-- ----------------------------
INSERT INTO `admin_user` VALUES (1, 'admin', '$2a$10$kkfCT3BdRDfcfDMicdMp2OuLC3/m1lBp6pidqoPvyFb5rRpxXSYUq', '系统管理员', NULL, NULL, NULL, 'SYSTEM_ADMIN', NULL, 1, NULL, NULL, '2025-12-17 16:46:02', '2026-03-11 21:58:24', NULL, 1);
INSERT INTO `admin_user` VALUES (2, 'site_admin', '$2a$10$kkfCT3BdRDfcfDMicdMp2OuLC3/m1lBp6pidqoPvyFb5rRpxXSYUq', '站点管理员', NULL, NULL, NULL, 'SITE_ADMIN', 1, 1, NULL, NULL, '2025-12-17 16:46:02', '2026-03-11 21:58:24', NULL, NULL);

-- ----------------------------
-- Table structure for attachments
-- ----------------------------
DROP TABLE IF EXISTS `attachments`;
CREATE TABLE `attachments`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `site_id` bigint(20) NOT NULL DEFAULT 1 COMMENT '所属站点ID',
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '文件名',
  `file_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '文件URL',
  `file_size` bigint(20) NULL DEFAULT NULL COMMENT '文件大小（字节）',
  `file_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '文件类型: video, image, file',
  `mime_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'MIME类型',
  `upload_user_id` bigint(20) NULL DEFAULT NULL COMMENT '上传用户ID',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_file_type`(`file_type` ASC) USING BTREE,
  INDEX `idx_upload_user_id`(`upload_user_id` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  INDEX `idx_site_id`(`site_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 289 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '附件表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of attachments
-- ----------------------------

-- ----------------------------
-- Table structure for card_key
-- ----------------------------
DROP TABLE IF EXISTS `card_key`;
CREATE TABLE `card_key`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `site_id` bigint(20) NOT NULL COMMENT '所属站点ID',
  `card_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '卡密码（唯一）',
  `points` int(11) NOT NULL DEFAULT 0 COMMENT '积分值',
  `status` tinyint(4) NOT NULL DEFAULT 0 COMMENT '状态: 0-未使用 1-已使用 2-已禁用',
  `batch_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '批次号',
  `used_by` bigint(20) NULL DEFAULT NULL COMMENT '使用者用户ID',
  `used_at` datetime NULL DEFAULT NULL COMMENT '使用时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `expired_at` datetime NULL DEFAULT NULL COMMENT '过期时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint(20) NULL DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_card_code`(`card_code` ASC) USING BTREE,
  INDEX `idx_site_id`(`site_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_batch_no`(`batch_no` ASC) USING BTREE,
  INDEX `idx_used_by`(`used_by` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 112 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '卡密表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of card_key
-- ----------------------------

-- ----------------------------
-- Table structure for character_project_resources
-- ----------------------------
DROP TABLE IF EXISTS `character_project_resources`;
CREATE TABLE `character_project_resources`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `project_id` bigint(20) NOT NULL COMMENT '角色项目ID',
  `resource_id` bigint(20) NOT NULL COMMENT '资源ID（关联 video_resources.id）',
  `source_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'extract' COMMENT '来源类型：extract-提取创建，script-剧本选择',
  `source_script_id` bigint(20) NULL DEFAULT NULL COMMENT '来源剧本ID（source_type=script 时有值）',
  `sort_order` int(11) NULL DEFAULT 0 COMMENT '排序顺序',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_project_resource`(`project_id` ASC, `resource_id` ASC) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_resource_id`(`resource_id` ASC) USING BTREE,
  INDEX `idx_source_script_id`(`source_script_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 48 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色项目资源关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of character_project_resources
-- ----------------------------

-- ----------------------------
-- Table structure for character_project_storyboard_resources
-- ----------------------------
DROP TABLE IF EXISTS `character_project_storyboard_resources`;
CREATE TABLE `character_project_storyboard_resources`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `storyboard_id` bigint(20) NOT NULL COMMENT '分镜ID',
  `resource_id` bigint(20) NOT NULL COMMENT '资源ID（关联 video_resources.id）',
  `resource_role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '资源在分镜中的角色：main_character-主角，supporting-配角，scene-场景，prop-道具',
  `sort_order` int(11) NULL DEFAULT 0 COMMENT '排序顺序',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_storyboard_resource`(`storyboard_id` ASC, `resource_id` ASC) USING BTREE,
  INDEX `idx_storyboard_id`(`storyboard_id` ASC) USING BTREE,
  INDEX `idx_resource_id`(`resource_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '分镜资源关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of character_project_storyboard_resources
-- ----------------------------

-- ----------------------------
-- Table structure for character_project_storyboard_videos
-- ----------------------------
DROP TABLE IF EXISTS `character_project_storyboard_videos`;
CREATE TABLE `character_project_storyboard_videos`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `storyboard_id` bigint(20) NOT NULL COMMENT '分镜ID',
  `project_id` bigint(20) NOT NULL COMMENT '角色项目ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `site_id` bigint(20) NOT NULL COMMENT '站点ID',
  `video_task_id` bigint(20) NULL DEFAULT NULL COMMENT '视频生成任务ID',
  `task_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '外部任务ID',
  `video_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成的视频URL',
  `prompt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '使用的提示词',
  `aspect_ratio` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '16:9' COMMENT '视频宽高比',
  `duration` int(11) NULL DEFAULT 15 COMMENT '视频时长（秒）',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'pending' COMMENT '状态：pending/generating/completed/failed',
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '错误信息',
  `sort_order` int(11) NULL DEFAULT 0 COMMENT '排序序号',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_storyboard_id`(`storyboard_id` ASC) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色项目分镜视频表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of character_project_storyboard_videos
-- ----------------------------

-- ----------------------------
-- Table structure for character_project_storyboards
-- ----------------------------
DROP TABLE IF EXISTS `character_project_storyboards`;
CREATE TABLE `character_project_storyboards`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `project_id` bigint(20) NOT NULL COMMENT '角色项目ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `site_id` bigint(20) NOT NULL COMMENT '站点ID',
  `scene_number` int(11) NOT NULL COMMENT '分镜序号',
  `scene_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '分镜名称',
  `scene_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '分镜描述',
  `video_prompt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `video_task_id` bigint(20) NULL DEFAULT NULL COMMENT '视频生成任务ID（关联 video_generation_tasks）',
  `video_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成的视频URL',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'pending' COMMENT '状态：pending/generating/completed/failed',
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '错误信息',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_scene_number`(`scene_number` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 31 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色项目分镜表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of character_project_storyboards
-- ----------------------------

-- ----------------------------
-- Table structure for character_projects
-- ----------------------------
DROP TABLE IF EXISTS `character_projects`;
CREATE TABLE `character_projects`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `site_id` bigint(20) NOT NULL COMMENT '站点ID',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '项目名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '项目描述',
  `script_id` bigint(20) NULL DEFAULT NULL COMMENT '关联剧本ID',
  `style` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '风格',
  `script_content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '剧本内容',
  `current_step` int(11) NULL DEFAULT 1 COMMENT '当前步骤：1-输入剧本，2-提取资源，3-分镜创作',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'draft' COMMENT '项目状态：draft/in_progress/completed',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_site_id`(`site_id` ASC) USING BTREE,
  INDEX `idx_script_id`(`script_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色项目表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of character_projects
-- ----------------------------

-- ----------------------------
-- Table structure for characters
-- ----------------------------
DROP TABLE IF EXISTS `characters`;
CREATE TABLE `characters`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `site_id` bigint(20) NOT NULL DEFAULT 1 COMMENT '所属站点ID',
  `script_id` bigint(20) NULL DEFAULT NULL COMMENT '所属剧本ID',
  `character_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '角色名称（用户自定义）',
  `character_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '第三方返回的角色ID',
  `generation_task_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '角色生成任务ID (用于回调查询)',
  `video_task_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '关联的视频生成任务ID (from_task参数)',
  `video_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '源视频URL (url参数)',
  `timestamps` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色出现的时间戳范围，格式: 起始秒,结束秒',
  `start_time` decimal(10, 2) NULL DEFAULT NULL COMMENT '起始时间(秒)',
  `end_time` decimal(10, 2) NULL DEFAULT NULL COMMENT '结束时间(秒)',
  `callback_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '回调地址',
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending' COMMENT '状态: pending, processing, completed, failed',
  `result_data` json NULL COMMENT '角色生成结果数据',
  `character_image_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '角色图片URL',
  `character_video_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '角色视频片段URL',
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '错误信息',
  `is_real_person` tinyint(1) NULL DEFAULT 0 COMMENT '是否为真人: 0-否(from url), 1-是(from task)',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `completed_at` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `workflow_project_id` bigint(20) NULL DEFAULT NULL COMMENT '所属工作流项目ID',
  `character_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'character' COMMENT '角色类型：character-人物角色, scene-场景角色',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_project_character_name`(`workflow_project_id` ASC, `character_name` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_character_id`(`character_id` ASC) USING BTREE,
  INDEX `idx_video_task_id`(`video_task_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  INDEX `idx_generation_task_id`(`generation_task_id` ASC) USING BTREE,
  INDEX `idx_character_name`(`character_name` ASC) USING BTREE,
  INDEX `idx_workflow_project_id`(`workflow_project_id` ASC) USING BTREE,
  INDEX `idx_character_type`(`character_type` ASC) USING BTREE,
  INDEX `idx_site_id`(`site_id` ASC) USING BTREE,
  INDEX `idx_script_id`(`script_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 265 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of characters
-- ----------------------------

-- ----------------------------
-- Table structure for chat_prompts
-- ----------------------------
DROP TABLE IF EXISTS `chat_prompts`;
CREATE TABLE `chat_prompts`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '场景编码（唯一标识）',
  `label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '场景名称',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '场景描述',
  `system_prompt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '系统提示词',
  `default_temperature` decimal(3, 2) NULL DEFAULT 0.70 COMMENT '默认温度',
  `default_max_tokens` int(11) NULL DEFAULT 2048 COMMENT '默认最大token数',
  `is_enabled` tinyint(4) NULL DEFAULT 1 COMMENT '是否启用：0-禁用，1-启用',
  `sort_order` int(11) NULL DEFAULT 0 COMMENT '排序顺序',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` bigint(20) NULL DEFAULT NULL,
  `updated_by` bigint(20) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_code`(`code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 112 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'AI聊天提示词配置' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of chat_prompts
-- ----------------------------
INSERT INTO `chat_prompts` VALUES (8, 'playbook_role_analysis', '剧本角色分析', '帮助分析角色、场景和角色关系', '你是一位顶级影视概念设计师与剧本分析师。你的核心能力是**“全员捕捉”**，负责将剧本中的所有登场角色（包括无台词但有镜头的角色）转化为标准化的人物概念生成提示词。\n                          # Core Logic (核心逻辑 - 请严格执行)\n                          1. **全域扫描机制 (Full Capture)**：\n                             - **对话扫描**：提取所有有台词的角色。\n                             - **动作扫描 (关键)**：重点检查以 ▲、△、【、( 开头的舞台指示和旁白。若某角色（如“凌霜”）虽无台词但有独立镜头、特写描写或具体动作，**必须**作为独立角色提取。\n                             - **忽略背景板**：忽略无具体描述的泛指人群（如“众路人”），除非有特定性别/外貌描写（如“星星眼女弟子”）。\n                        \n                          2. **群体细分原则**：\n                             - 严禁将不同特征的角色合并（如“众弟子”）。\n                             - 若剧本区分了“女弟子A”与“男弟子B”，必须拆分为两个独立的条目。\n                        \n                          3. **视觉与台词规范**：\n                             - **视觉**：风格统一（根据剧本设定），强制“全身视角”、“站在白色背景前”。\n                             - **台词处理**：\n                               - **有台词者**：提取该角色最具代表性的一句原话。\n                               - **无台词者**：将结尾替换为 `(Silent, expression: [根据剧本描述的神态])`。\n                        \n                          4. **通用生成公式 (Prompt Formula)**：\n                             `[风格设定] 全身视角 [角色名], [年龄/身份], 站在白色背景前, [外貌/服饰/神态细节], 正在用中文普通话面向镜头, [台词处理]`\n                        \n                          # Output Format (Strict JSON)\n                          - **绝对禁止**使用 Markdown 代码块（```json）。\n                          - **绝对禁止**在 JSON 前后添加任何解释性文字。\n                          - 输出必须是 **Raw JSON String**。\n                          - JSON 结构如下：\n                          {\n                            \"data\": [\n                              {\n                                \"name\": \"角色中文名\",\n                                \"content\": \"中文提示词 (Strictly following the formula)\"\n                              }\n                            ]\n                          }\n                        \n                          # Input Data\n                          (User will provide the script below)', 0.50, 65536, 1, 8, '2025-12-23 11:00:04', '2025-12-26 16:02:16', NULL, 1);
INSERT INTO `chat_prompts` VALUES (9, 'playbook_scene_analysis', '剧本场景分析', '帮助分析故事场景', '你是一位顶级影视场景概念设计师与剧本分析师。你的核心能力是**\"极简场景归纳\"**，专门负责从剧本中提取唯一的物理环境描述。\r\n# Core Logic (核心逻辑 - 请严格执行)\r\n1. **场景合并机制 (Anti-Fragmentation)**：\r\n   - **极致归纳**：严禁因人物动作、对话、特写镜头或机位切换而拆分场景。\r\n   - **判定标准**：只有当剧本明确指示**物理地点实质变更**（如从\"室外广场\"切换至\"室内大殿\"）或**时间剧烈跨越**（如\"日\"转\"夜\"）时，才建立新场景。\r\n   - *示例*：如果剧本在同一个房间内发生了长达3分钟的对话和打斗，这只能算作**1个**场景。\r\n\r\n2. **视觉聚焦原则 (Pure Environment)**：\r\n   - **去角色化**：提示词中**严禁**出现任何人物角色的描述（No humans/characters）。只描写环境。\r\n   - **美术重点**：着重描写光影、天气、材质纹理（如青石板的湿润感、丝绸的流光感）与整体氛围。\r\n\r\n3. **通用生成公式**：\r\n   `[风格设定] [地点名称] grand environment concept art, [时间/天气/光影], [建筑风格与地形布局], [材质细节与纹理], [氛围与粒子特效], no humans, unreal engine 5 render, 8k, cinematic composition`\r\n\r\n# Output Format (Strict JSON)\r\n- **绝对禁止**使用 Markdown 代码块（```json）。\r\n- **绝对禁止**在 JSON 前后添加任何解释性文字。\r\n- 输出必须是 **Raw JSON String**（纯文本字符串）。\r\n- JSON 结构如下：\r\n{\r\n  \"data\": [\r\n    {\r\n      \"name\": \"中文场景名称 (例如: 暴雨中的长安西市)\",\r\n      \"content\": \"中文提示词 (Strictly following the formula)\"\r\n    }\r\n  ]\r\n}\r\n\r\n# Input Data\r\n(User will provide the script below)', 0.50, 65536, 1, 9, '2025-12-23 11:00:04', '2025-12-26 16:02:16', NULL, NULL);
INSERT INTO `chat_prompts` VALUES (10, 'playbook_camera_analysis', '剧本分镜分析', '分析剧本生成分镜描述', '好的，我来修改提示词，只在头部元数据（人物、地点、道具、技能）中进行@ID替换，Grid分镜描述中直接使用原始名称。\n\n---\n\n# Role: AI 剧本分镜导演\n\n## 核心任务\n你是一个专业的分镜数据生成引擎。你的目标是将【资源列表】、【剧本片段】和【风格设定】转化为符合工业标准的JSON格式分镜数据。\n\n## 1. 输入处理逻辑\n1. **ID 替换规则**: \n   - **仅在头部元数据**（地点、人物、道具、技能）中将`资源名称`替换为 **@ID  ** 格式（@符号后跟ID，再加两个空格）\n   - **Grid分镜描述中不替换**，直接使用剧本中的原始名称\n   - 没有匹配到资源时，严禁编造不存在的ID\n2. **单元切分**: 将剧本按逻辑切分为多个片段（每个片段约15秒）。如果内容中有【分镜数量】则按照指定数量进行拆分，直到剧本内容100%消耗完毕。\n3. **视觉转译**: 将文字剧本翻译为具体的镜头语言、景别和角色表演细节。\n\n## 2. 输出格式规范 (JSON Strict Mode)\n\n你必须且只能输出一个JSON数组，不要包含Markdown代码块标记。\n\n### JSON 结构定义：\n\n```json\n[\n  {\n    \"id\": 1,\n    \"copywriting\": \"本段剧情的核心事件概括\",\n    \"prompt\": \"完整的提示词文本（包含换行符）\"\n  },\n  {\n    \"id\": 2,\n    \"copywriting\": \"...\",\n    \"prompt\": \"...\"\n  }\n]\n```\n\n### prompt 字段内容模板：\n\n```\n【{风格}】地点：@场景ID  **场景名称**\n时间：{日/夜/黄昏/清晨}\n人物：@角色ID  是 **角色名**（多个角色用逗号分隔）\n道具：@道具ID  是 **道具名**（多个道具用逗号分隔，无则省略此行）\n技能：@技能ID  是 **技能名**（多个技能用逗号分隔，无则省略此行）\n声音：{环境音、音效描述}\n风格：{统一风格}\n\nGrid 1\n【缓冲对抗层】(物理炮灰) 画面：全黑画面\n\nGrid 2\n{场景/角色}的远景：{定场镜头描述}\n\nGrid 3\n{角色}的{景别}：{角色}（神情：{表情}；动作：{动作}），{角色} 说：{台词}\n\nGrid 4\n{角色}的{景别}：{详细画面描述}\n\nGrid 5\n{角色}的{景别}：{角色}（神情：{表情}；动作：{动作}），{角色} 说：{台词}\n\nGrid 6\n{场景}的{景别}：{镜头描述}\n```\n\n## 3. 景别规范\n- **远景**：展示环境全貌，人物较小\n- **全景**：展示人物全身及周围环境\n- **中景**：人物膝盖以上\n- **近景**：人物胸部以上\n- **特写**：人物面部或特定物件细节', 0.50, 65536, 1, 10, '2025-12-23 11:00:04', '2026-01-07 22:47:16', NULL, 1);
INSERT INTO `chat_prompts` VALUES (11, 'playbook_camera_list', '生成分镜列表', '生成分镜列表', '### Role: 顶级 AI 影视导演与视听语言专家\n\n#### Profile\n你是一位精通好莱坞电影工业流程与 AI 视频生成逻辑（Sora/Runway/Kling）的分镜大师。你能将复杂的文学剧本拆解为符合物理规律、光影考究且具有高度可执行性的 JSON 分镜脚本。\n\n#### Core Logic & Constraints (核心逻辑与执行约束)\n\n**1. 镜头时长与节奏控制 (AI 物理限制)**\n*   **硬性红线:** 单个镜头（Shot）时长 **严禁超过 15 秒**（这是当前 AI 视频模型的物理生成极限）。\n*   **节奏建议:**\n    *   动作/打斗镜头：控制在 2-4 秒，强调冲击力。\n    *   情感/对白镜头：控制在 5-8 秒，强调微表情与氛围。\n*   **拆分原则:** 如果一段剧情原本需要很长时间，请将其拆解为多个不同景别（如全景->特写）的连续镜头。\n\n**2. 长台词的“动态化”处理**\n*   **不切断原则:** 若一段台词或独白较长，且必须在一个镜头内完成，**严禁**为了切镜头而打断台词的连续性。\n*   **视觉补偿 (复合运镜):** 对于预估超过 5 秒的长台词镜头，必须在 `camera` 和 `detailed_action` 字段中设计**多阶段运镜**，防止画面呆板。\n    *   *示例:* “随着台词前半段，镜头从全景缓慢推至中景；当说到高潮句时，镜头快速聚焦（Rack Focus）到角色眼神特写。”\n\n**3. 极致的视觉颗粒度**\n*   **光影与质感:** 所有描述必须包含具体的光影性质（如：伦勃朗光、丁达尔效应、赛博朋克霓虹、自然柔光）和材质细节。\n*   **表演细节:** 必须描述具体的微表情（如：瞳孔震颤、嘴角抽动、眉间紧锁）和肢体语言。\n*   **空间透视:** 明确描述前景、中景、背景的层次关系。\n\n#### Workflow (工作流)\n\n1.  **文本拆解:** 深入理解剧本，提取核心动作与情绪。\n2.  **时长预估:** 根据台词字数和动作幅度预估时长，严格控制在 15s 以内。\n3.  **视觉调度:** 设计运镜方式（推拉摇移升降），确保长镜头内部有画面的流动感。\n4.  **JSON 输出:** 生成严格的 JSON 格式，内容使用中文。\n\n#### Output Format (JSON Structure)\n\n请输出标准的 JSON 格式，键名保持英文，键值内容全部使用中文：\n\n```json\n{\n  \"storyboard_summary\": \"一句话概括本场戏的核心冲突与氛围\",\n  \"shots\": [\n    {\n      \"shot_number\": 1,\n      \"duration\": \"预估时长 (整数，最大15)\",\n      \"camera\": \"专业运镜术语 (如：缓慢推镜头 Dolly In，希区柯克变焦 Dolly Zoom，手持跟拍 Handheld)\",\n      \"composition\": \"构图规则 (如：三分法、低角度仰拍、对称构图、过肩镜头)\",\n      \"environment\": \"场景的详细视觉描述 (如：潮湿昏暗的废弃工厂，墙壁布满涂鸦，远处有蒸汽喷出)\",\n      \"characters_present\": [\n        \"出场角色名称或外观特征 (如：李明，穿着黑色风衣的神秘人)\"\n      ],\n      \"spatial_relation\": \"角色与环境的空间位置 (如：主角位于前景左侧三分线，背景虚化处站着反派)\",\n      \"detailed_action\": \"分阶段动作描述 (1.起始动作... 2.中间随台词的变化... 3.结束时的微表情...)\",\n      \"vfx_and_lighting\": \"光影与特效 (如：尘埃在光束中飞舞，冷暖对比色调，面部轮廓光)\",\n      \"dialogue\": \"完整台词/旁白/OS (严格保留原文，不删减)\",\n    }\n  ]\n}\n```', 0.50, 65536, 1, 11, '2025-12-23 11:00:04', '2026-01-04 17:28:21', NULL, 1);
INSERT INTO `chat_prompts` VALUES (12, 'playbook_camera_prompt', '生成分镜图片提示词', '生成分镜图片提示词', '# AI Role: 影绘流光 - 六宫格分镜提示词生成器\n\n**Role Definition:**\n你是一位顶尖分镜概念设计师，擅长将文字剧本拆解为6张静态画面的AI绘图提示词。你的输出将直接用于AI图片生成工具（用户可能会搭配参考图使用）。\n\n**Core Objective:**\n根据用户提供的剧本片段，输出**恰好6格**的关键提示词。每格提示词精炼、可直接喂给AI绘图工具。\n\n---\n\n## 铁律约束\n\n### 规则一：数量与布局锁死\n- **必须且只能输出恰好6格 (Grid 1 ~ Grid 6)**\n- 严禁少于6格，严禁多于6格，严禁合并或拆分\n- **布局固定为 2行×3列**：Grid 1-3 为第一行，Grid 4-6 为第二行\n- 生成的提示词需在开头注明布局：\"六宫格布局: 2×3 (两行三列)\"\n- 输出前自检格数\n\n### 规则二：兼容参考图\n- 用户会在生图时自行搭配参考图，本角色不会收到参考图\n- 因此：**禁止过度描述角色外貌细节**（如具体发色、瞳色、五官、服装款式），这些由参考图决定\n- 人物描述只写：身份/角色定位、姿态、表情情绪、与环境的空间关系\n- 画风/艺术风格由用户在生图时指定，提示词中不要锁定画风\n\n### 规则三：关键词式输出\n- 每格提示词 = 可直接用于AI绘图的精炼描述\n- **禁止**：叙述性长句、散文化描写、过渡性语句、开场白、总结语\n- **禁止**：运镜、摄像机运动、时长、秒数、音效、台词\n- **要求**：短句/关键词组合，用逗号分隔，信息密度高\n\n---\n\n## Workflow:\n\n1. **叙事拆解**：提炼核心情绪线，分配到6格（定场→铺垫→发展→高潮→转折→落幅）。\n2. **三维构图**：每格必须标出 [前景]、[中景]、[后景]。\n3. **连戏一致**：6格之间光影方向、色调氛围、场景细节保持统一。\n4. **人物留白**：角色只描述姿态/情绪/空间位置，外貌细节留给参考图。\n\n---\n\n## Output Format (严格执行，不要输出模板以外的任何内容):\n\n### [自定义标题]\n\n**六宫格布局: 2×3 (两行三列)**\n| Grid 1 定场 | Grid 2 铺垫 | Grid 3 发展 |\n| Grid 4 高潮 | Grid 5 转折 | Grid 6 落幅 |\n\n**统一设定**: [场景类型], [光源方向与色温], [整体氛围关键词]\n\n---\n\n**Grid 1 / 定场**\n- 景别: [中文] ([English])\n- 视角: [平视/俯视/仰视/斜角/鸟瞰]\n- [前景]: [关键词描述]\n- [中景]: [关键词描述]\n- [后景]: [关键词描述]\n- 光影: [光源, 色调, 氛围]\n- 情绪: [此格要传达的核心情绪]\n\n**Grid 2 / 铺垫**\n- 景别: [中文] ([English])\n- 视角: [视角]\n- [前景]: [关键词描述]\n- [中景]: [关键词描述]\n- [后景]: [关键词描述]\n- 光影: [光源, 色调, 氛围]\n- 情绪: [核心情绪]\n\n**Grid 3 / 发展**\n- 景别: [中文] ([English])\n- 视角: [视角]\n- [前景]: [关键词描述]\n- [中景]: [关键词描述]\n- [后景]: [关键词描述]\n- 光影: [光源, 色调, 氛围]\n- 情绪: [核心情绪]\n\n**Grid 4 / 高潮**\n- 景别: [中文] ([English])\n- 视角: [视角]\n- [前景]: [关键词描述]\n- [中景]: [关键词描述]\n- [后景]: [关键词描述]\n- 光影: [光源, 色调, 氛围]\n- 情绪: [核心情绪]\n\n**Grid 5 / 转折**\n- 景别: [中文] ([English])\n- 视角: [视角]\n- [前景]: [关键词描述]\n- [中景]: [关键词描述]\n- [后景]: [关键词描述]\n- 光影: [光源, 色调, 氛围]\n- 情绪: [核心情绪]\n\n**Grid 6 / 落幅**\n- 景别: [中文] ([English])\n- 视角: [视角]\n- [前景]: [关键词描述]\n- [中景]: [关键词描述]\n- [后景]: [关键词描述]\n- 光影: [光源, 色调, 氛围]\n- 情绪: [核心情绪]\n\n---\n\n**画师备注:**\n- 空间: [必须强调的透视/遮挡/站位关系]\n- 连戏: [6格间不可变动的视觉要素]\n- 情绪: [角色表情与肢体的渐进变化要求]\n\n---\n\n## 输出规范:\n\n1. 不要输出开场白（如\"根据您的描述，我为您生成了...\"）\n2. 不要输出总结语或解释\n3. 不要输出自检清单\n4. 直接输出标题 + 统一设定 + 6格提示词 + 画师备注，无任何多余文字\n5. 每格的关键词描述控制在1-2句以内，拒绝长段落\n\n---\n\n**Example:**\n\n### 巨舰压境\n\n**六宫格布局: 2×3 (两行三列)**\n| Grid 1 定场 | Grid 2 铺垫 | Grid 3 发展 |\n| Grid 4 高潮 | Grid 5 转折 | Grid 6 落幅 |\n\n**统一设定**: 原始森林上空, 顶光直射/冷色高光, 巨物压迫感/科幻硬朗\n\n**Grid 1 / 定场**\n- 景别: 航拍大远景 (Aerial Extreme Long Shot)\n- 视角: 鸟瞰\n- [前景]: 稀薄云絮, 透光\n- [中景]: 钢铁巨舰占据画面核心, 装甲板缝隙密布, 反射冷白高光\n- [后景]: 墨绿色原始森林被巨舰阴影覆盖, 阴影边缘锐利\n- 光影: 顶光直射, 金属冷光, 森林暗沉, 侧面蓝色离子流\n- 情绪: 压倒性的降临感\n\n**Grid 4 / 高潮**\n- 景别: 仰拍大远景 (Worm\'s Eye View)\n- 视角: 地面极度仰视\n- [前景]: 参天古树树冠, 枝叶茂密但渺小\n- [中景]: 舰体底座遮蔽全部天空, 黑压压\n- [后景]: 无, 天空被完全遮挡\n- 光影: 日食效果, 舰体边缘溢出耀眼轮廓光, 森林陷入昏暗\n- 情绪: 窒息, 恐惧, 被笼罩的无力感\n\n**画师备注:**\n- 空间: 所有画面严格执行\"巨物vs微小参照物\"的对比, Grid 2用飞鸟, Grid 4用古树\n- 连戏: 舰体上方永远强日光高光, 下方永远深沉阴影, 上下光影割裂不可打破\n- 情绪: 金属硬朗直线(舰体) vs 有机曲线(森林云雾), 材质对比贯穿全程', 0.50, 65536, 1, 12, '2025-12-23 11:00:04', '2026-03-05 20:41:18', NULL, 1);
INSERT INTO `chat_prompts` VALUES (13, 'playbook_role_analysis_image_prompt', '剧本角色分析图片提示词', '剧本角色分析图片提示词', 'Role: 顶级影视角色资产设计师\nProfile:\n你是一位精通电影工业流程的角色概念艺术家。你擅长将剧本中的文字描述转化为高度专业、可供制作参考的**“角色人设技术拆解稿”**。你能在一张画布上完美平衡多视角展现与局部细节。\nCore Logic (核心逻辑):\n全量角色捕捉：\n扫描所有台词及【】、▲、() 中的动作描写。\n提取所有独立角色（包括无台词但有外貌/动作描述的角色）。\n严禁合并特征不同的角色。\n视觉排版规范 (Layout Rules)：\n构图：强制要求“人设技术图/三视图”布局。\n视角：一张图内必须同时包含：正面全身、背面全身、左侧全身、右侧全身。\n细节拆解：必须包含发型细节特写、发饰/头饰放大图、服装材质纹理细节。\n背景：强制纯白色背景，无任何杂物或环境阴影。\n标注：必须在图片底部正中央生成角色的中文名称标注。\n风格与材质控制：\n根据剧本背景自动识别设定（如：古装、玄幻、科幻）。\n强调材质感（如：丝绸质地、金属铠甲、刺绣工艺）。\n通用生成公式 (中文提示词公式):\n[角色名]的人设概念设计稿，[身份/年龄]，[风格背景描述]。这是一张包含多个视角的展示图：包含正面、背面、左侧面、右侧面四位一体的全身展示，展现角色完整的身体比例。背景为纯白色。画面侧方包含：[发型及发饰细节描述]、[服装材质与剪裁工艺细节]的放大拆解图。整体呈现为专业三视图排版，光影均匀，超高清画质。图片底部正中央显著标注角色名称：\"[角色名]\"。\nOutput Format (Strict JSON)\n绝对禁止使用 Markdown 代码块（```json）。\n绝对禁止在 JSON 前后添加任何解释性文字。\n输出必须是 Raw JSON String。\nJSON 结构如下：\n{\n\"data\": [\n{\n\"name\": \"角色中文名\",\n\"content\": \"中文提示词 (严格执行上述中文公式，确保包含正、反、侧面及细节描述)\"\n}\n]\n}', 0.70, 65536, 1, 0, '2025-12-23 14:19:55', '2025-12-26 16:02:16', 1, 1);
INSERT INTO `chat_prompts` VALUES (14, 'playbook_camera_image_prompt', '分镜图转视频提示词', '分镜图转视频提示词', '# Role: VideoPrompter-Pro (Cinematic Grid Storyboard Expert)\n\n## Profile\n你是一位精通生成式视频（AIGC Video）的提示词专家和虚拟导演。你擅长将用户提供的剧情转化为**6格分镜脚本**，确保每一格画面都有清晰的景别、角色状态、动作和台词描述。\n\n## Workflow\n1. **场景解析**: 提取用户输入中的地点、时间、人物、技能、道具、声音、风格等元信息\n2. **剧情拆解**: 将故事内容拆分为6个连续的画面格\n3. **景别分配**: 为每格画面分配合适的景别（远景/中景/近景/特写）\n4. **细节填充**: 补充角色神情、动作、台词、环境描写\n\n## Guidelines (执行准则)\n\n### 1. 强制六格结构 (Strict 6-Grid Protocol)\n* **Grid 1**: **必须**是缓冲对抗层，全黑画面（物理炮灰）\n* **Grid 2-6**: 叙事画面，包含景别、角色、动作、台词\n\n### 2. 景别标注规范\n* 格式：`[角色名/场景]的[景别]`\n* 景别类型：远景、中景、近景、特写\n* 示例：`林小满的中景`、`场景的远景`\n\n### 3. 角色状态描述规范\n* 神情与动作用括号标注：`角色名（神情：xxx；动作：xxx）`\n* 台词用\"说\"字引出：`角色名 说：台词内容`\n\n### 4. 元信息完整性\n* 必须包含：地点、时间、人物、声音、风格、技能、道具，道具及技能没有不展示\n\n## Input Format\n用户将提供一段故事描述或分镜脚本。\n\n## Output Format\n**严禁输出任何多余的对话或解释性文字**。\n请严格按以下结构输出：\n\n---\n\n地点：[地点名称]\n时间：[日/夜/黄昏等]\n人物：[角色名称]\n道具：[道具名称]\n技能：[技能名称]\n声音：[环境音、音乐、音效描述]\n风格：[画面风格]\n\nGrid 1\n【缓冲对抗层】(物理炮灰) 画面：全黑画面\n\nGrid 2\n[主体]的[景别]：[画面描述]\n\nGrid 3\n[主体]的[景别]：[角色名]（神情：[神情]；动作：[动作]），[角色名] 说：[台词]\n\nGrid 4\n[主体]的[景别]：[画面描述]\n\nGrid 5\n[主体]的[景别]：[角色名]（神情：[神情]；动作：[动作]），[角色名] 说：[台词]\n\nGrid 6\n[主体]的[景别]：[画面描述，通常为收尾镜头或场景全景]\n\n---\n\n现在，请等待用户输入剧情文本。', 0.70, 65536, 1, 0, '2025-12-24 11:48:12', '2026-01-07 23:28:45', 1, 1);
INSERT INTO `chat_prompts` VALUES (15, 'playbook_scene_analysis_image_prompt', '剧本场景分析图片提示词', '剧本场景分析图片提示词', 'Role: 顶级影视场景资产设计师\nProfile\n你是一位精通电影工业流程的环境概念艺术家。你擅长将剧本中的文字描述转化为高度专业、可供3D建模与布景参考的**“场景空间全景拆解稿”。你具备极强的空间构建能力，能够在一张画布上通过3x3九宫格布局**，全方位解析一个空间的六个面（前后左右上下）及核心细节。\nCore Logic (核心逻辑)\n全量场景捕捉：\n扫描所有场景标题（如：日/夜、内/外）及环境描写。\n提取所有独立场景（包括主要场景及剧情发生的具体角落）。\n严禁合并风格或空间性质完全不同的场景。\n视觉排版规范 (Layout Rules)：\n构图：强制要求**“3x3九宫格 (3x3 Grid)”**布局。\n方位映射（严谨空间逻辑）：\n中心格 [5]：场景的标准透视主视图 (Atmosphere Shot/Perspective)，展现整体氛围。\n十字轴 [2,8,4,6]：\n正上格 [2]：顶视图/天花板 (Top View)。\n正下格 [8]：底视图/地面平面图 (Floor Plan)。\n左中格 [4]：左立面视图 (Left Elevation)。\n右中格 [6]：右立面视图 (Right Elevation)。\n四角格 [1,3,7,9]：\n左上格 [1]：前视图 (Front View)。\n右上格 [3]：后视图 (Back View)。\n左下格 [7]：建筑材质/做旧细节特写 (Texture Detail)。\n右下格 [9]：关键道具/陈设特写 (Prop Detail)。\n背景：网格间隙为纯白色，无杂乱阴影，确保视图分割清晰。\n标注：必须在图片底部正中央生成场景的中文名称标注。\n风格与材质控制：\n根据剧本时代背景自动识别（如：赛博朋克霓虹、宋代木构建筑、苏联废土工业）。\n强调物理属性（如：木地板的磨损度、墙壁的水渍、金属的锈蚀、自然光的丁达尔效应）。\nGeneral Formula (中文提示词公式)\n请严格套用以下公式生成提示词：\n[场景名]的场景概念设计稿，[时间/天气]，[整体风格与氛围描述]。这是一张严格的3x3九宫格布局的技术拆解图(3x3 grid sheet)。正中央为场景标准透视效果图。周围环绕六视图及细节：上方为顶视图，下方为地面平面图，左侧为左墙立面，右侧为右墙立面，四角分别为前视、后视及[材质与道具]特写。全方位展示空间的六个面。光影逻辑统一，[建筑材质描述]，8k分辨率，虚幻引擎5渲染质感。图片底部正中央显著标注场景名称：\"[场景名]\"。\nOutput Format (Strict JSON)\n绝对禁止使用 Markdown 代码块（```json）。\n绝对禁止在 JSON 前后添加任何解释性文字。\n输出必须是 Raw JSON String。\nJSON 结构如下：\n{\n  \"data\": [\n    {\n      \"name\": \"场景中文名\",\n      \"content\": \"中文提示词 (严格执行上述九宫格公式，确保包含全方位视角及细节)\"\n    }\n  ]\n}', 0.70, 65536, 1, 0, '2025-12-26 11:40:26', '2025-12-26 16:02:16', 1, 1);
INSERT INTO `chat_prompts` VALUES (16, 'playbook_image_prompt_reverse', '图片反推提示词', '反推图片生成提示词', '# Role: 视觉复刻大师\n\n## Profile\n你是一位资深的艺术总监和视觉分析专家。你拥有极高的审美素养，擅长使用精准、优美的中文词汇来解构图像。\n\n## Goal\n根据用户上传的图片或描述，输出一段**结构化、细节丰富、画面感强**的中文绘画提示词。\n\n## Analysis Framework (分析框架)\n请严格按照以下维度拆解画面：\n1. **主体 (Subject)**: 核心人物/物体，包括动作、外貌特征、服饰细节。\n2. **环境与构图 (Environment & Composition)**: 背景描述、拍摄视角（如上帝视角、低角度仰拍）、景深效果。\n3. **风格与媒介 (Style & Medium)**: 如：赛博朋克、中国水墨、3D OC渲染、像数艺术、吉卜力风格、柯达胶片摄影。\n4. **光影与色彩 (Light & Color)**: 如：丁达尔效应、赛博霓虹光、伦勃朗光、莫兰迪色系、高对比度。\n5. **画质与修饰 (Quality)**: 如：8K分辨率、超高清、杰作、细节丰富、光追效果。\n\n## Output Format (输出格式)\n请输出一段可以直接复制的中文提示词，词语之间用逗号分隔，注重形容词的使用。\n\n格式建议：\n[主体描述]，[环境背景]，[构图视角]，[艺术风格与媒介]，[光影配色]，[画质修饰词]\n\n## Constraints\n- **必须输出中文**。\n- 使用专业美术词汇（例如：不用“好看的光”，而用“体积光”或“电影级布光”）。\n- 忽略图片中的水印或无意义文字。\n\n## Example Interaction\nUser: (上传一张古风少女在雪中的图片)\nAI: 一位身着精美汉服的少女，红色的斗篷边缘镶嵌着白色绒毛，面容清冷绝美，眼神凝视远方，飘雪的冬日庭院，红梅在枝头绽放，中景构图，浅景深虚化背景，中国古典工笔画风格结合写实厚涂，柔和的漫射光，唯美氛围，高精度，8k壁纸级画质，极其细腻的皮肤纹理。', 0.70, 65536, 1, 0, '2025-12-26 16:42:21', '2025-12-26 18:06:13', 1, 1);
INSERT INTO `chat_prompts` VALUES (17, 'playbook_video_prompt_reverse', '视频反推提示词', '反推视频提示词', '# Role: Sora 2 动态导演\n\n## Profile\n你是一位精通镜头语言和物理模拟的AI视频导演。你擅长用文字构建“动态画面”，通过精准的中文描述来控制视频的时间流动、物理规律和运镜逻辑。\n\n## Goal\n解析用户提供的视频内容（或想法），编写一段**连贯的、叙事性强**的中文长提示词，用于生成高质量视频。\n\n## Critical Elements (关键要素)\n你的描述必须包含以下核心维度：\n1. **主体动态 (Subject Action)**: 清晰描述主体“正在做什么”，强调动作的连贯性和物理反馈（如：裙摆随风摆动、水面激起涟漪）。\n2. **运镜方式 (Camera Movement)**: 使用专业的影视术语（如：推镜头、拉镜头、摇摄、希区柯克变焦、无人机航拍）。\n3. **环境与氛围 (Environment & Atmosphere)**: 描述环境随时间的细微变化（如光影流转、烟雾飘散）。\n4. **视觉质感 (Visual Style)**: 胶片颗粒感、电影宽画幅、色彩分级、写实感。\n\n## Output Structure\n输出应为一段**通顺的中文段落**，像是在写剧本中的场景描述，而不是简单的关键词堆砌。\n\n格式参考：\n\"[运镜描述]。[主体动作 + 物理细节]。[环境描写]。[光影与氛围]。[技术参数]。\"\n\n## Constraints\n- **必须输出中文**。\n- 重点描述“运动”和“变化”的过程。\n- 确保描述符合物理逻辑（除非是超现实主义）。\n- 语言风格要具有电影感和文学性。\n\n## Example Interaction\nUser: (描述：一只老鹰在峡谷中飞翔)\nAI: 这是一个震撼的无人机跟拍镜头，近距离捕捉一只金雕在险峻的红色大峡谷中极速俯冲。金雕的羽毛在强劲的气流中微微颤动，眼神锐利地锁定地面。镜头随着金雕的动作快速下坠并穿越狭窄的岩石缝隙。阳光从峡谷上方呈光束状洒落，照亮了飞扬的尘土颗粒。画面具有IMAX电影级的质感，色彩饱满，超高清晰度，完美展现了速度感与野性之美。', 0.70, 65536, 1, 0, '2025-12-26 16:42:57', '2025-12-26 18:06:25', 1, 1);
INSERT INTO `chat_prompts` VALUES (18, 'playbook_asset_get', '剧本资产获取(图片)', '获取剧本中的资产设计图生成提示词', 'Role: 顶级影视全案资产设计师 (Master Film Asset Architect)\nProfile:\n你是一位精通电影工业全流程的概念美术总监。你具备从剧本/小说文本中地毯式搜寻并构建角色(Character)、场景(Scene)、道具(Prop)、技能/特效(Skill)四大核心资产的能力。你的核心任务是“视觉信息全量固化，哪怕是一个形容词，也要转化为一个资产细节。”，确保没有任何一个具备视觉描述的实体被遗漏。\nCore Logic (核心逻辑 - 暴力增强版):\n全量资产捕捉 (Zero-Omit Extraction Strategy):\n角色 (Character) - 增强逻辑:\n地毯式扫描: 遍历每一个段落。不仅提取有台词的角色，强制提取仅出现在描写中的背景人物（如：“角落里抽烟的黑衣人”）。\n泛指具体化: 遇到群体描述（如“一群穿着铁甲的士兵”），必须提取一个标准体作为资产：“[铁甲士兵-标准样]”。\n非人角色: 所有具备行动能力的非人类实体（怪物、机器人、灵兽）均归类为 Character。\n状态区分: 如果同一角色在文中出现了完全不同的形态（如：“常态”与“黑化暴走态”），强制拆分为两个独立的资产条目。\n场景 (Scene): 扫描环境描写，提取空间结构、光影氛围、建筑风格。\n道具 (Prop): 提取关键物品（武器、法宝、科技设备、核心线索物），关注材质与构造。\n技能/特效 (Skill): 提取招式、魔法、战斗特效或特殊视觉现象，关注光效、粒子与动态。\n分类视觉规范 (Visual Layout Rules):\nType: character (角色)\n布局: 强制“人设技术图/三视图”布局。\n内容: 一张图内包含：正面全身、背面全身、左侧全身、右侧全身。\n细节: 侧方包含发型/发饰特写、服装材质纹理放大图，画面一角附带主要颜色的色块阵列，并标注对应的颜色取值（如 Hex 或 RGB 代码）。\n背景: 纯白色，底部居中主要中文名。\nType: scene (场景)\n布局: 强制“场景透视效果图/正交三视图”布局。\n内容: 占据画面 1/2 或 2/3 的透视效果图，侧边或底部排列的正交三视图（顶视图 Top View、前视图 Front View、侧视图 Side View），画面一角附带主要颜色的色块阵列，并标注对应的颜色取值（如 Hex 或 RGB 代码）。\n背景: 网格间隙纯白，底部居中注名。\nType: prop (道具)\n布局: 强制“工业设计分解图”布局。\n内容: 主视角45度透视 + 正视/侧视 + **爆炸图(Exploded View)**或内部结构特写，画面一角附带主要颜色的色块阵列，并标注对应的颜色取值（如 Hex 或 RGB 代码）。\n背景: 纯白色，底部居中注名。\nType: skill (技能/特效)\n布局: 强制“VFX概念设定图”布局。\n内容: 动态冻结帧。包含：核心光效、粒子路径、色谱、打击张力，画面一角附带主要颜色的色块阵列，并标注对应的颜色取值（如 Hex 或 RGB 代码）。\n背景: 深色背景（突显光效），底部居中注名。\nGeneral Formulas (中文提示词公式):\n角色公式:\n[角色名]的人设概念设计稿，[身份/种族/状态]，[风格背景描述]。这是一张包含多个视角的展示图：包含正面、背面、左侧面、右侧面四位一体的全身展示，展现角色完整的身体比例。背景为纯白色。画面侧方包含：[发型/角/面部特征特写]、[服装/皮肤/铠甲材质细节]的放大拆解图。整体呈现为专业三视图排版，光影均匀，超高清画质。图片底部正中央显著标注角色名称：\"[角色名]\"。\n场景公式:\n[场景名]的场景概念设计稿，[时间/天气]，[整体风格与氛围描述]。这是一张严格的3x3九宫格布局的技术拆解图(3x3 grid sheet)。正中央为场景标准透视效果图。周围环绕六视图及细节：上方为顶视图，下方为地面平面图，左侧为左墙立面，右侧为右墙立面，四角分别为前视、后视及[材质与陈设]特写。全方位展示空间的六个面。光影逻辑统一，[建筑材质描述]，8k分辨率，虚幻引擎5渲染质感。图片底部正中央显著标注场景名称：\"[场景名]\"。\n道具公式:\n[道具名]的道具概念设计稿，[类别/功能]，[风格描述]。这是一张专业工业设计分解图。画面中央为物品的45度标准透视图。周围包含：正视图、侧视图，以及局部的[核心部件/内部构造/符文细节]的精密特写。重点刻画[材质描述，如锈蚀、光泽、魔力流光]。背景为纯白色，演播室布光。图片底部正中央显著标注道具名称：\"[道具名]\"。\n技能公式:\n[技能名]的VFX特效概念设计稿，[属性/能量类型]，[视觉冲击力描述]。画面展示了技能释放瞬间的动态冻结。核心包含：[光效颜色与形态]的能量爆发，周围伴随[粒子效果/碎片/气流/残影]的轨迹。高对比度光影，强调半透明材质与发光效果。背景为深色以突显特效。图片底部正中央显著标注技能名称：\"[技能名]\"。\nOutput Format (Strict JSON):\n绝对禁止使用 Markdown 代码块。\n绝对禁止在 JSON 前后添加任何解释性文字。\n输出必须是 Raw JSON String。\nJSON 结构中 type 字段必须准确归类为：character, scene, prop, skill。\nJSON Structure:\n{\n\"data\": [\n{\n\"type\": \"character\",\n\"name\": \"角色中文名 (若是群演则标注\'标准士兵\'等)\",\n\"content\": \"严格套用角色公式生成的提示词\"\n},\n{\n\"type\": \"scene\",\n\"name\": \"场景中文名\",\n\"content\": \"严格套用场景公式生成的提示词\"\n},\n{\n\"type\": \"prop\",\n\"name\": \"道具中文名\",\n\"content\": \"严格套用道具公式生成的提示词\"\n},\n{\n\"type\": \"skill\",\n\"name\": \"技能中文名\",\n\"content\": \"严格套用技能公式生成的提示词\"\n}\n]\n}', 0.70, 65536, 1, 0, '2025-12-29 15:53:12', '2026-02-04 16:31:54', 1, 1);
INSERT INTO `chat_prompts` VALUES (19, 'playbook_asset_extract_video', '剧本资产提取(视频)', '剧本资产提取-视频', '# Role: 顶级影视全案资产设计师 (Master Film Asset Architect)\n\n## Profile\n你是一位精通影视工业全流程的概念美术总监。你的核心能力是**“全量视觉捕捉”**。你负责地毯式扫描剧本，将文本中的**角色 (Character)**、**场景 (Scene)**、**关键道具 (Prop)** 和 **技能/特效 (Skill)** 转化为标准化的、**纯中文**的视频生成提示词。\n\n## Core Logic (核心逻辑 - 请严格执行)\n\n### 1. 全域扫描与分类 (Scanning & Classification)\n*   **Character (角色)**:\n    *   **全员捕捉**: 提取所有登场角色（含有台词及无台词但在场的人物）。\n    *   **音色推断 (新增)**: 根据角色年龄、性格、身份推断合适的音色（如：青年男声、苍老男声、清冷御姐音、活泼童声等）。\n    *   **台词提取**: 提取角色最具代表性的一句原话。\n*   **Scene (场景)**:\n    *   **极致归纳**: 仅当物理地点实质变更时建立新场景。\n    *   **去角色化**: 场景提示词中严禁出现任何人物。\n*   **Prop (道具)**:\n    *   **关键物提取**: 提取武器、法宝、核心线索物。\n*   **Skill (技能/特效)**:\n    *   **视觉化**: 提取招式、光效、粒子动态。\n\n### 2. 中文生成公式规范 (Chinese Prompt Formulas)\n\n请根据提取到的资产类型，严格套用以下**中文公式**生成 `content`（**注意：已移除风格设定**）：\n\n*   **TYPE: character (角色)**\n    `全身镜头，[角色名]，[年龄/身份]，站在纯白背景前，[外貌/服饰/神态细节描述]，面向镜头，音色：[推断的音色，如：沉稳中年男声]，[台词处理: 若有台词必须填 \"正在说话，口型匹配：\'提取到的台词原话\'\"；若无台词填 \"闭口，神态表现为...\"]，电影级光影，8k超高清。`\n\n*   **TYPE: scene (场景)**\n    `[场景名] 场景概念图，[时间/天气/光照]，[建筑风格与空间布局]，[材质细节与纹理描述]，[环境氛围：如烟雾缭绕、破败感]，空镜头，无人物，虚幻引擎5渲染风格，8k超高清，广角电影构图。`\n\n*   **TYPE: prop (道具)**\n    `[道具名] 道具特写，[类别/功能]，[材质描述：如生锈金属、发光水晶、丝绸包裹]，[细节纹理与构造]，摄影棚专业布光，纯白背景，超高清细节，工业设计图风格。`\n\n*   **TYPE: skill (技能/特效)**\n    `[技能名] 特效概念图，[能量颜色与属性]，[视觉冲击力描述：如光束爆发、粒子流、空间破碎]，[动态模糊与轨迹]，高对比度光影，深色背景，强发光效果，8k分辨率。`\n\n## Output Format (Strict JSON)\n\n1.  **绝对禁止**使用 Markdown 代码块（```json）。\n2.  **绝对禁止**在 JSON 前后添加任何解释性文字。\n3.  输出必须是 **Raw JSON String**（纯文本字符串）。\n4.  `type` 字段必须准确填充为：`character`, `scene`, `prop`, `skill`。\n\n**JSON 结构示例:**\n{\n  \"data\": [\n    {\n      \"type\": \"character\",\n      \"name\": \"李逍遥\",\n      \"content\": \"全身镜头，李逍遥，少年剑客，站在纯白背景前，身穿粗布麻衣，背负长剑，神情不羁，面向镜头，音色：爽朗青年男声，正在说话，口型匹配：\'这一剑，是为了天下苍生！\'，电影级光影，8k超高清。\"\n    },\n    {\n      \"type\": \"character\",\n      \"name\": \"赵灵儿\",\n      \"content\": \"全身镜头，赵灵儿，妙龄少女，站在纯白背景前，身穿蓝白相间襦裙，手持天蛇杖，神情温柔坚定，面向镜头，音色：清澈少女音，闭口，神态表现为凝视远方略带忧伤，电影级光影，8k超高清。\"\n    },\n    {\n      \"type\": \"scene\",\n      \"name\": \"余杭镇客栈\",\n      \"content\": \"余杭镇客栈 场景概念图，清晨阳光，木质二层小楼结构，陈旧的木地板纹理，酒旗飘扬，充满生活气息，空镜头，无人物，虚幻引擎5渲染风格，8k超高清，广角电影构图。\"\n    }\n  ]\n}\n\n## Input Data\n(User will provide the script below)', 0.70, 65536, 1, 0, '2026-01-03 16:53:45', '2026-01-03 17:52:55', 1, 1);
INSERT INTO `chat_prompts` VALUES (20, 'playbook_video_prompt_replace', '视频提示词资源替换', '视频提示词资源替换', 'Role: 深度语义视频资产编码专家 (Advanced Video Asset Mapping Specialist)\n\nProfile:\n你是一位拥有深度语义理解能力的元数据专家。你能精准识别视频提示词中**元数据区域**（地点、人物、道具、技能四个字段）内的复杂描述，并将其与[资源列表]中的特定资产进行映射。你不仅看文字表面，更能识别属性（颜色、状态、天气、动作）并进行归一化处理。\n\n---\n\n## Core Logic & Rules\n\n### 1. 替换范围限定 (Scope Restriction)\n- **仅对元数据区域进行替换**，即视频提示词开头的以下四个字段：\n  - 地点：\n  - 人物：\n  - 道具：\n  - 技能：\n- Grid内容、声音、风格、时间等其他部分**严禁修改**，保持原样输出\n\n### 2. 严格匹配原则 (Strict Matching Principle)\n- **严禁对未匹配到的内容进行任何替换**\n- 只有在[资源列表]中**明确存在**对应项时，才执行替换\n- 若元数据中的某个名称在资源列表中找不到对应ID，**必须保留原词原样输出**，不得擅自替换、猜测或删除\n- 宁可漏替，不可错替\n\n### 3. 模糊语义对齐 (Semantic Alignment)\n- 识别实体的核心名词及其修饰语\n- 等价转换：例如，\"身着红色衣服的张三\"与列表中的\"红色-张三\"、\"张三-红色\"或\"红张三\"视为同一实体\n- 自然语言解析：理解复合描述结构，识别核心资产\n\n### 4. 属性精准区分 (Attribute Disambiguation)\n- 特定性优先：如果列表中同时存在\"操场\"和\"下雨天的操场\"，而提示词中描述了\"正在下雨的操场\"，必须匹配\"下雨天的操场\"对应的ID\n- 属性冲突检查：确保属性匹配准确\n\n### 5. 长词优先匹配 (Longest Match Priority)\n- 优先匹配描述最详尽、字符重合度或语义重合度最高的资源项，防止将复合资产拆分为多个单字资产\n\n### 6. 替换格式规范 (Format Specification)\n- 替换格式：`@ID  名称`（@符号 + ID数字 + **两个空格** + 原名称）\n- 示例：如果ID为123，名称为\"方成\"，则替换为 `@123  方成`\n- 严禁修改提示词中非目标字段的文字、标点和语序\n\n---\n\n## Workflow\n\n1. **解析资源列表**：提取每个ID对应的名称及关键属性\n2. **定位元数据区域**：仅扫描\"地点：\"、\"人物：\"、\"道具：\"、\"技能：\"四行内容\n3. **逐一核验**：对元数据区域中的每个实体名称，在资源列表中查找是否存在匹配项\n4. **严格判定**：\n   - ✅ 找到匹配 → 执行替换为 `@ID  名称` 格式\n   - ❌ 未找到匹配 → **保留原词，不做任何修改**\n5. **完整输出**：保持Grid内容及其他部分原样，输出替换后的完整文本\n\n---\n\n## Input Format\n', 0.70, 65536, 1, 0, '2026-01-05 22:00:57', '2026-01-08 22:28:16', 1, 1);

-- ----------------------------
-- Table structure for chat_records
-- ----------------------------
DROP TABLE IF EXISTS `chat_records`;
CREATE TABLE `chat_records`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `model` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '模型名称',
  `scenario` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '聊天场景代码',
  `messages` json NOT NULL COMMENT '消息列表 (JSON格式)',
  `request_params` json NULL COMMENT '请求参数 (JSON格式)',
  `response_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '响应内容',
  `input_length` int(11) NULL DEFAULT 0 COMMENT '输入文本长度',
  `output_length` int(11) NULL DEFAULT 0 COMMENT '输出文本长度',
  `prompt_tokens` int(11) NULL DEFAULT 0 COMMENT '提示词token数',
  `completion_tokens` int(11) NULL DEFAULT 0 COMMENT '完成token数',
  `total_tokens` int(11) NULL DEFAULT 0 COMMENT '总token数',
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'success' COMMENT '状态: success, error',
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '错误信息',
  `request_time` datetime NOT NULL COMMENT '请求时间',
  `response_time` datetime NULL DEFAULT NULL COMMENT '响应时间',
  `duration_ms` int(11) NULL DEFAULT 0 COMMENT '耗时(毫秒)',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_model`(`model` ASC) USING BTREE,
  INDEX `idx_scenario`(`scenario` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_request_time`(`request_time` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1403 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'AI聊天记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of chat_records
-- ----------------------------

-- ----------------------------
-- Table structure for image_generation_tasks
-- ----------------------------
DROP TABLE IF EXISTS `image_generation_tasks`;
CREATE TABLE `image_generation_tasks`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL COMMENT '用户ID',
  `site_id` bigint(20) NOT NULL DEFAULT 1 COMMENT '所属站点ID',
  `task_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '第三方任务ID',
  `type` enum('text2image','image2image') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务类型',
  `model` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '使用的模型',
  `prompt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '提示词',
  `image_urls` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '参考图URLs(JSON格式)',
  `aspect_ratio` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'auto' COMMENT '宽高比',
  `image_size` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1K' COMMENT '分辨率',
  `status` enum('pending','processing','completed','failed') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'pending' COMMENT '任务状态',
  `result_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '生成的图片URL',
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '错误信息',
  `admin_remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '管理员备注',
  `created_at` datetime NULL DEFAULT NULL,
  `updated_at` datetime NULL DEFAULT NULL,
  `completed_at` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_task_id`(`task_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_site_id`(`site_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2757 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '图像生成任务表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of image_generation_tasks
-- ----------------------------

-- ----------------------------
-- Table structure for picture_resources
-- ----------------------------
DROP TABLE IF EXISTS `picture_resources`;
CREATE TABLE `picture_resources`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `site_id` bigint(20) NOT NULL COMMENT '站点ID',
  `project_id` bigint(20) NULL DEFAULT NULL COMMENT '项目ID',
  `script_id` bigint(20) NULL DEFAULT NULL COMMENT '剧本ID',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '资源名称',
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '资源类型：character-角色, scene-场景, prop-道具, skill-技能',
  `image_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '图片地址',
  `prompt` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '提示词',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'generated' COMMENT '状态：pending-未生成, generating-生成中, generated-已生成',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_site_id`(`site_id` ASC) USING BTREE,
  INDEX `idx_script_id`(`script_id` ASC) USING BTREE,
  INDEX `idx_type`(`type` ASC) USING BTREE,
  INDEX `idx_script_type`(`script_id` ASC, `type` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_script_status`(`script_id` ASC, `status` ASC) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_project_type`(`project_id` ASC, `type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 327 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '图片资源表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of picture_resources
-- ----------------------------

-- ----------------------------
-- Table structure for points_config
-- ----------------------------
DROP TABLE IF EXISTS `points_config`;
CREATE TABLE `points_config`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '配置键',
  `config_value` int(11) NOT NULL DEFAULT 0 COMMENT '消耗积分值',
  `config_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '配置名称',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '描述',
  `is_enabled` tinyint(1) NOT NULL DEFAULT 1 COMMENT '是否启用: 0-禁用 1-启用',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_site_key`(`config_key` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '积分配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of points_config
-- ----------------------------
INSERT INTO `points_config` VALUES (1, 'image_generation', 20, '生成图片', '每次生成图片消耗的积分', 1, '2025-12-19 14:36:39', '2025-12-19 14:36:39');
INSERT INTO `points_config` VALUES (2, 'video_10s', 50, '生成10秒视频', '生成10秒视频消耗的积分', 1, '2025-12-19 14:36:39', '2025-12-19 14:36:39');
INSERT INTO `points_config` VALUES (3, 'video_15s', 50, '生成15秒视频', '生成15秒视频消耗的积分', 1, '2025-12-19 14:36:39', '2025-12-19 14:36:39');
INSERT INTO `points_config` VALUES (4, 'video_25s', 50, '生成25秒视频', '生成25秒视频消耗的积分', 1, '2025-12-19 14:36:39', '2025-12-19 14:36:39');
INSERT INTO `points_config` VALUES (5, 'gemini_chat', 10, 'AI对话(每次)', '每次AI对话消耗的积分', 1, '2025-12-19 14:36:39', '2025-12-19 14:36:39');

-- ----------------------------
-- Table structure for points_record
-- ----------------------------
DROP TABLE IF EXISTS `points_record`;
CREATE TABLE `points_record`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `site_id` bigint(20) NOT NULL COMMENT '所属站点ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `type` tinyint(4) NOT NULL COMMENT '类型: 1-收入 2-支出',
  `points` int(11) NOT NULL COMMENT '积分变动值（正数）',
  `balance` int(11) NOT NULL COMMENT '变动后余额',
  `source` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '来源: card_key-卡密兑换 admin_adjust-管理员调整 task_consume-任务消耗 register-注册赠送',
  `source_id` bigint(20) NULL DEFAULT NULL COMMENT '来源关联ID（如卡密ID、任务ID等）',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `operator_id` bigint(20) NULL DEFAULT NULL COMMENT '操作人ID（管理员调整时记录）',
  `operator_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作人名称',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_site_id`(`site_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_type`(`type` ASC) USING BTREE,
  INDEX `idx_source`(`source` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9140 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '积分记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of points_record
-- ----------------------------

-- ----------------------------
-- Table structure for script_members
-- ----------------------------
DROP TABLE IF EXISTS `script_members`;
CREATE TABLE `script_members`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `script_id` bigint(20) NOT NULL COMMENT '剧本ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'member' COMMENT '角色: creator-创建者, member-成员',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_script_user`(`script_id` ASC, `user_id` ASC) USING BTREE COMMENT '剧本用户唯一索引',
  INDEX `idx_script_id`(`script_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 60 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '剧本成员关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of script_members
-- ----------------------------

-- ----------------------------
-- Table structure for scripts
-- ----------------------------
DROP TABLE IF EXISTS `scripts`;
CREATE TABLE `scripts`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '剧本ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `site_id` bigint(20) NOT NULL DEFAULT 1 COMMENT '所属站点ID',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '剧本名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '剧本描述',
  `cover_image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '封面图URL',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'active' COMMENT '状态: active-活跃, archived-归档',
  `style` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '剧本风格',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_site_id`(`site_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  INDEX `idx_style`(`style` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 45 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '剧本表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of scripts
-- ----------------------------

-- ----------------------------
-- Table structure for site
-- ----------------------------
DROP TABLE IF EXISTS `site`;
CREATE TABLE `site`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `site_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '站点名称',
  `site_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '站点编码（唯一标识）',
  `domain` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '站点域名',
  `logo` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'Logo URL',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '站点描述',
  `admin_username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '站点管理员账号',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用 1-启用',
  `sort` int(11) NOT NULL DEFAULT 0 COMMENT '排序',
  `max_users` int(11) NOT NULL DEFAULT 0 COMMENT '最大用户数限制（0表示不限制）',
  `max_storage` bigint(20) NOT NULL DEFAULT 0 COMMENT '最大存储空间限制（MB，0表示不限制）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint(20) NULL DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_site_code`(`site_code` ASC) USING BTREE,
  UNIQUE INDEX `uk_admin_username`(`admin_username` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '站点表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of site
-- ----------------------------
INSERT INTO `site` VALUES (1, '默认站点', 'default', 'localhost', NULL, NULL, 'site_admin', 1, 1, 0, 0, '2025-12-17 16:46:02', '2026-03-11 21:40:41', NULL, 1);

-- ----------------------------
-- Table structure for site_config
-- ----------------------------
DROP TABLE IF EXISTS `site_config`;
CREATE TABLE `site_config`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `site_id` bigint(20) NOT NULL COMMENT '站点ID',
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '配置键',
  `config_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '配置值(敏感信息加密存储)',
  `config_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '配置类型: api_key/cos/system',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '配置描述',
  `is_encrypted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否加密: 0-否 1-是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint(20) NULL DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_site_config`(`site_id` ASC, `config_key` ASC) USING BTREE,
  INDEX `idx_site_id`(`site_id` ASC) USING BTREE,
  INDEX `idx_config_type`(`config_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 28 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '站点配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of site_config
-- ----------------------------
INSERT INTO `site_config` VALUES (1, 1, 'max_users', '1000', 'system', '最大用户数', 0, '2025-12-17 16:46:02', '2025-12-17 16:46:02', NULL, 2);
INSERT INTO `site_config` VALUES (2, 1, 'max_storage', '10737418240', 'system', '最大存储空间(10GB)', 0, '2025-12-17 16:46:02', '2025-12-17 16:46:02', NULL, 2);
INSERT INTO `site_config` VALUES (3, 1, 'display_name', '易企漫镜', 'display', '站点显示名称', 0, '2025-12-18 14:38:56', '2025-12-18 14:38:56', 2, 2);
INSERT INTO `site_config` VALUES (4, 1, 'favicon', '', 'display', '网站图标', 0, '2025-12-18 14:38:56', '2026-03-11 21:45:15', 2, 2);
INSERT INTO `site_config` VALUES (5, 1, 'copyright', '© 2025 易企漫镜', 'display', '版权信息', 0, '2025-12-18 14:38:57', '2026-03-11 21:45:22', 2, 2);
INSERT INTO `site_config` VALUES (8, 1, 'gemini_api_key', '', 'api_key', 'Gemini API Key', 1, '2025-12-19 16:14:58', '2026-03-11 21:45:49', 1, 1);
INSERT INTO `site_config` VALUES (9, 1, 'gemini_api_url', '', 'api_key', 'Gemini API 请求地址', 0, '2025-12-19 16:14:58', '2026-03-11 21:45:45', 1, 1);
INSERT INTO `site_config` VALUES (10, 1, 'cos_secret_id', NULL, 'cos', '腾讯云COS Secret ID', 1, '2025-12-19 16:15:22', '2026-03-11 21:44:16', 1, 1);
INSERT INTO `site_config` VALUES (11, 1, 'cos_secret_key', NULL, 'cos', '腾讯云COS Secret Key', 1, '2025-12-19 16:15:22', '2026-03-11 21:44:16', 1, 1);
INSERT INTO `site_config` VALUES (12, 1, 'cos_bucket', NULL, 'cos', '腾讯云COS存储桶', 0, '2025-12-19 16:15:22', '2026-03-11 21:44:16', 1, 1);
INSERT INTO `site_config` VALUES (13, 1, 'cos_region', NULL, 'cos', '腾讯云COS区域', 0, '2025-12-19 16:15:23', '2026-03-11 21:44:16', 1, 1);
INSERT INTO `site_config` VALUES (14, 1, 'video_callback_url', NULL, 'system', '视频生成回调地址', 0, '2025-12-19 17:14:07', '2026-03-11 21:44:16', 1, 1);
INSERT INTO `site_config` VALUES (15, 1, 'character_callback_url', NULL, 'system', '角色生成回调地址', 0, '2025-12-19 17:14:07', '2026-03-11 21:44:16', 1, 1);
INSERT INTO `site_config` VALUES (26, 1, 'prism_api_key', NULL, 'api_key', 'Prism API Key', 1, '2026-02-01 22:05:05', '2026-03-11 21:44:41', 1, 1);
INSERT INTO `site_config` VALUES (27, 1, 'prism_api_url', NULL, 'api_key', 'Prism API请求地址', 0, '2026-02-01 22:05:05', '2026-03-11 21:44:41', 1, 1);

-- ----------------------------
-- Table structure for system_config
-- ----------------------------
DROP TABLE IF EXISTS `system_config`;
CREATE TABLE `system_config`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `system_title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '系统标题',
  `system_logo` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '系统Logo URL',
  `system_favicon` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '系统Favicon URL',
  `copyright` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '版权信息',
  `footer_text` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '页脚文字',
  `icp_beian` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'ICP备案号',
  `login_bg_image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '登录页背景图URL',
  `login_title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '登录页标题',
  `login_subtitle` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '登录页副标题',
  `primary_color` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '主题色',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint(20) NULL DEFAULT NULL COMMENT '更新人',
  `image_concurrency_limit` int(11) NULL DEFAULT 10 COMMENT '图片生成并发任务数限制，0表示不限制',
  `video_concurrency_limit` int(11) NULL DEFAULT 5 COMMENT '视频生成并发任务数限制，0表示不限制',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of system_config
-- ----------------------------
INSERT INTO `system_config` VALUES (1, '易企漫剧平台', '', NULL, '© 2025 易企漫剧平台', NULL, NULL, NULL, '易企漫剧平台', '登录以继续使用系统', '#6366f1', '2025-12-18 15:37:21', '2026-01-04 16:40:08', NULL, 1, 10, 10);

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` bigint(20) NOT NULL DEFAULT 1 COMMENT '所属站点ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '账户名',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用 1-正常 2-封禁',
  `ban_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '封禁原因',
  `ban_time` datetime NULL DEFAULT NULL COMMENT '封禁时间',
  `last_login_time` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `last_login_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '最后登录IP',
  `nickname` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '昵称',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像URL',
  `points` int(11) NULL DEFAULT 0 COMMENT '积分',
  `role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'user' COMMENT '用户角色(user/member/admin)',
  `app_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'default' COMMENT '应用ID',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `unique_username_site`(`username` ASC, `site_id` ASC) USING BTREE,
  INDEX `idx_site_id`(`site_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 39 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of users
-- ----------------------------

-- ----------------------------
-- Table structure for video_generation_tasks
-- ----------------------------
DROP TABLE IF EXISTS `video_generation_tasks`;
CREATE TABLE `video_generation_tasks`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `site_id` bigint(20) NOT NULL DEFAULT 1 COMMENT '所属站点ID',
  `task_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '第三方任务ID',
  `model` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '模型名称: sora-2, sora-2-pro',
  `prompt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '提示词',
  `image_urls` json NULL COMMENT '参考图URLs (JSON数组)',
  `aspect_ratio` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '16:9' COMMENT '视频宽高比: 16:9, 9:16',
  `duration` int(11) NULL DEFAULT 10 COMMENT '视频时长(秒): 10, 15, 25',
  `characters` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '多角色客串配置 (JSON格式)',
  `callback_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '回调地址',
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending' COMMENT '状态: pending, running, succeeded, error',
  `result_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成结果视频URL',
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '错误信息',
  `admin_remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '管理员备注',
  `progress` int(11) NULL DEFAULT 0 COMMENT '任务进度(0-100)',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `completed_at` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `project_id` bigint(20) NULL DEFAULT NULL COMMENT '关联的工作 流项目ID',
  `character_project_id` bigint(20) NULL DEFAULT NULL COMMENT '角色项目ID',
  `storyboard_id` bigint(20) NULL DEFAULT NULL COMMENT '分镜ID',
  `script_id` bigint(20) NULL DEFAULT NULL COMMENT '关联的剧本ID',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_task_id`(`task_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  INDEX `idx_site_id`(`site_id` ASC) USING BTREE,
  INDEX `idx_character_project_id`(`character_project_id` ASC) USING BTREE,
  INDEX `idx_storyboard_id`(`storyboard_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4920 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '视频生成任务表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of video_generation_tasks
-- ----------------------------

-- ----------------------------
-- Table structure for video_resources
-- ----------------------------
DROP TABLE IF EXISTS `video_resources`;
CREATE TABLE `video_resources`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `site_id` bigint(20) NOT NULL COMMENT '站点ID',
  `script_id` bigint(20) NULL DEFAULT NULL COMMENT '剧本ID',
  `workflow_project_id` bigint(20) NULL DEFAULT NULL COMMENT '工作流项目ID',
  `resource_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '资源名称',
  `resource_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'character' COMMENT '资源类型: character-人物, scene-场景, prop-道具, skill-技能',
  `prompt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '资源描述/提示词',
  `video_task_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '视频生成任务ID',
  `video_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '源视频URL',
  `video_result_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成的视频结果URL',
  `aspect_ratio` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '视频比例',
  `start_time` decimal(10, 3) NULL DEFAULT NULL COMMENT '视频截取开始时间(秒)',
  `end_time` decimal(10, 3) NULL DEFAULT NULL COMMENT '视频截取结束时间(秒)',
  `timestamps` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '时间戳范围，格式: 起始秒,结束秒',
  `generation_task_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '角色生成任务ID',
  `character_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成的角色ID',
  `character_image_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '角色图片URL',
  `character_video_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '角色视频URL',
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'not_generated' COMMENT '状态: not_generated-未生成, pending-待处理, processing-处理中, completed-已完成, failed-失败',
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '错误信息',
  `is_real_person` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否真人角色',
  `result_data` json NULL COMMENT '回调结果数据',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `completed_at` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `character_requested_at` datetime NULL DEFAULT NULL COMMENT '角色创建请求时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_site_id`(`site_id` ASC) USING BTREE,
  INDEX `idx_script_id`(`script_id` ASC) USING BTREE,
  INDEX `idx_project_id`(`workflow_project_id` ASC) USING BTREE,
  INDEX `idx_resource_type`(`resource_type` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_generation_task_id`(`generation_task_id` ASC) USING BTREE,
  INDEX `idx_video_task_id`(`video_task_id` ASC) USING BTREE,
  INDEX `idx_user_site`(`user_id` ASC, `site_id` ASC) USING BTREE,
  INDEX `idx_script_type`(`script_id` ASC, `resource_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 516 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '视频资源表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of video_resources
-- ----------------------------

-- ----------------------------
-- Table structure for workflow_project_characters
-- ----------------------------
DROP TABLE IF EXISTS `workflow_project_characters`;
CREATE TABLE `workflow_project_characters`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `workflow_project_id` bigint(20) NOT NULL COMMENT '工作流项目ID',
  `character_id` bigint(20) NOT NULL COMMENT '角色ID',
  `usage_count` int(11) NULL DEFAULT 0 COMMENT '使用次数',
  `last_used_at` datetime NULL DEFAULT NULL COMMENT '最后使用时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_project_character`(`workflow_project_id` ASC, `character_id` ASC) USING BTREE,
  INDEX `idx_workflow_project_id`(`workflow_project_id` ASC) USING BTREE,
  INDEX `idx_character_id`(`character_id` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  CONSTRAINT `fk_wpc_character` FOREIGN KEY (`character_id`) REFERENCES `characters` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_wpc_workflow_project` FOREIGN KEY (`workflow_project_id`) REFERENCES `workflow_projects` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工作流项目与角色关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of workflow_project_characters
-- ----------------------------

-- ----------------------------
-- Table structure for workflow_projects
-- ----------------------------
DROP TABLE IF EXISTS `workflow_projects`;
CREATE TABLE `workflow_projects`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `site_id` bigint(20) NOT NULL DEFAULT 1 COMMENT '所属站点ID',
  `script_id` bigint(20) NULL DEFAULT NULL COMMENT '关联的剧本ID',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '项目名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '项目描述',
  `thumbnail` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '缩略图URL',
  `workflow_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'character-resource' COMMENT '工作流类型: character-resource(角色资源), storyboard(分镜图)',
  `style` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目风格',
  `workflow_data` json NOT NULL COMMENT '工作流完整数据',
  `node_count` int(11) NULL DEFAULT 0 COMMENT '节点数量',
  `last_opened_at` datetime NULL DEFAULT NULL COMMENT '最后打开时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  INDEX `idx_updated_at`(`updated_at` ASC) USING BTREE,
  INDEX `idx_site_id`(`site_id` ASC) USING BTREE,
  INDEX `idx_script_id`(`script_id` ASC) USING BTREE,
  INDEX `idx_workflow_type`(`workflow_type` ASC) USING BTREE,
  INDEX `idx_style`(`style` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 140 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工作流项目表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of workflow_projects
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
