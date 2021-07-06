/*
 Navicat Premium Data Transfer

 Source Server         : 本地mysql
 Source Server Type    : MySQL
 Source Server Version : 50712
 Source Host           : localhost:3306
 Source Schema         : blog

 Target Server Type    : MySQL
 Target Server Version : 50712
 File Encoding         : 65001

 Date: 09/02/2020 12:24:03
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for bl_about
-- ----------------------------
DROP TABLE IF EXISTS `bl_about`;
CREATE TABLE `bl_about`  (
  `about_id` varchar(31) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '帖子id',
  `about_title` varchar(63) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '标题',
  `about_content` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '帖子内容',
  `about_read` int(11) NOT NULL DEFAULT 0 COMMENT '阅读数',
  `created_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `version` int(11) NOT NULL DEFAULT 1 COMMENT '乐观锁',
  `deleted` int(1) NOT NULL DEFAULT 0 COMMENT '是否删除，0否1是',
  PRIMARY KEY (`about_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '关于闲言表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for bl_admin
-- ----------------------------
DROP TABLE IF EXISTS `bl_admin`;
CREATE TABLE `bl_admin`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '管理员id',
  `name` varchar(31) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '姓名',
  `header` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '头像',
  `signature` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '签名',
  `comment` varchar(511) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '介绍',
  `username` varchar(31) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '账号',
  `password` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '密码',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '管理员表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for bl_blog
-- ----------------------------
DROP TABLE IF EXISTS `bl_blog`;
CREATE TABLE `bl_blog`  (
  `blog_id` varchar(31) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '帖子id',
  `blog_title` varchar(63) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '标题',
  `blog_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '封面',
  `blog_content` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '帖子内容',
  `blog_goods` int(11) NOT NULL DEFAULT 0 COMMENT '点赞数',
  `blog_read` int(11) NOT NULL DEFAULT 0 COMMENT '阅读数',
  `blog_collection` int(11) NOT NULL DEFAULT 0 COMMENT '收藏数',
  `blog_type` int(11) NOT NULL COMMENT '博客分类',
  `blog_remark` varchar(127) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '简介',
  `blog_comment` int(11) NOT NULL DEFAULT 0 COMMENT '评论数',
  `blog_source` varchar(127) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '文章来源（爬虫时使用）',
  `created_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `version` int(11) NOT NULL DEFAULT 1 COMMENT '乐观锁',
  `deleted` int(1) NOT NULL DEFAULT 0 COMMENT '是否删除，0否1是',
  PRIMARY KEY (`blog_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '博客表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for bl_collection
-- ----------------------------
DROP TABLE IF EXISTS `bl_collection`;
CREATE TABLE `bl_collection`  (
  `collection_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '收藏id',
  `blog_id` varchar(31) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '帖子id',
  `user_id` int(11) NOT NULL COMMENT '用户id',
  `collection_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '收藏时间',
  PRIMARY KEY (`collection_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '收藏时间' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for bl_comment
-- ----------------------------
DROP TABLE IF EXISTS `bl_comment`;
CREATE TABLE `bl_comment`  (
  `comment_id` varchar(31) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '评论id',
  `comment_content` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '评论内容',
  `comment_user` int(11) NOT NULL COMMENT '评价人',
  `comment_blog` varchar(31) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '评论帖子id',
  `comment_good` int(11) NOT NULL DEFAULT 0 COMMENT '点赞数',
  `created_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '评论时间',
  `deleted` int(1) NOT NULL COMMENT '是否删除，0否1是',
  PRIMARY KEY (`comment_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '评论表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for bl_link
-- ----------------------------
DROP TABLE IF EXISTS `bl_link`;
CREATE TABLE `bl_link`  (
  `link_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '链接id',
  `link_name` varchar(63) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称',
  `link_url` varchar(511) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '链接地址',
  `created_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `version` int(11) NOT NULL DEFAULT 1 COMMENT '乐观锁',
  `deleted` int(1) NOT NULL DEFAULT 0 COMMENT '是否删除，0否1是',
  PRIMARY KEY (`link_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '友情链接表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for bl_log
-- ----------------------------
DROP TABLE IF EXISTS `bl_log`;
CREATE TABLE `bl_log`  (
  `log_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '日志id',
  `log_url` varchar(127) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '请求路径',
  `log_params` varchar(4095) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '参数',
  `log_status` int(1) NOT NULL DEFAULT 1 COMMENT '访问状态，1正常0异常',
  `log_message` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '异常信息',
  `log_method` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '请求方式，get、post等',
  `log_time` bigint(20) NOT NULL DEFAULT 0 COMMENT '响应时间',
  `log_result` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '返回值',
  `log_ip` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '请求ip',
  `created_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `created_by` varchar(31) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  PRIMARY KEY (`log_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '接口访问日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for bl_music
-- ----------------------------
DROP TABLE IF EXISTS `bl_music`;
CREATE TABLE `bl_music`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '音乐id',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '歌曲名',
  `artist` varchar(127) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '佚名' COMMENT '歌手',
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '歌曲链接',
  `cover` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '封面',
  `lrc` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '歌词',
  `created_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `enable` int(1) NOT NULL DEFAULT 1 COMMENT '是否启用，0否1是',
  `deleted` int(1) NOT NULL DEFAULT 0 COMMENT '是否删除，0否1是',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '歌曲表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for bl_type
-- ----------------------------
DROP TABLE IF EXISTS `bl_type`;
CREATE TABLE `bl_type`  (
  `type_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '分类id',
  `type_name` varchar(31) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '分类名称',
  `type_blog_count` int(11) NOT NULL DEFAULT 0 COMMENT '帖子数',
  `enable` int(1) NOT NULL DEFAULT 1 COMMENT '是否启用，0否1是',
  `deleted` int(1) NOT NULL DEFAULT 0 COMMENT '是否删除，0否1是',
  PRIMARY KEY (`type_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '帖子类型表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for bl_user
-- ----------------------------
DROP TABLE IF EXISTS `bl_user`;
CREATE TABLE `bl_user`  (
  `user_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '用户id',
  `username` varchar(31) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户名',
  `password` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '密码',
  `name` varchar(31) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '姓名',
  `sex` int(1) NULL DEFAULT NULL COMMENT '性别。1男2女',
  `header` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '头像',
  `nickname` varchar(31) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '鲜肉' COMMENT '昵称',
  `user_email` varchar(31) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '邮箱',
  `created_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `version` int(11) NOT NULL DEFAULT 1 COMMENT '乐观锁',
  `deleted` int(1) NOT NULL DEFAULT 0 COMMENT '是否删除。0否1是',
  PRIMARY KEY (`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户表' ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
