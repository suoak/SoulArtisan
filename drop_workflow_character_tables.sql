-- 删除工作流、工作流项目、角色、角色项目相关的所有表

-- 删除角色项目分镜视频表
DROP TABLE IF EXISTS character_project_storyboard_videos;

-- 删除角色项目分镜表
DROP TABLE IF EXISTS character_project_storyboards;

-- 删除角色项目资源关联表
DROP TABLE IF EXISTS character_project_resources;

-- 删除角色项目表
DROP TABLE IF EXISTS character_projects;

-- 删除工作流项目角色关联表
DROP TABLE IF EXISTS workflow_project_characters;

-- 删除工作流项目表
DROP TABLE IF EXISTS workflow_projects;

-- 删除角色表
DROP TABLE IF EXISTS characters;