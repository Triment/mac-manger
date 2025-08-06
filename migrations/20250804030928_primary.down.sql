-- Add down migration script here

-- 1. 首先删除关联表

-- 删除部门与员工的关联表索引
DROP INDEX IF EXISTS dept_employee_dept_id_employee_id_idx;

-- 删除部门与员工的关联表
DROP TABLE IF EXISTS dept_employee;

-- 删除管理员与部门的关联表索引
DROP INDEX IF EXISTS admin_dept_admin_id_dept_id_idx;

-- 删除管理员与部门的关联表
DROP TABLE IF EXISTS admin_dept;

-- 删除角色与权限的关联表索引
DROP INDEX IF EXISTS role_acl_role_id_acl_id_idx;

-- 删除角色与权限的关联表
DROP TABLE IF EXISTS role_acl;

-- 2. 删除依赖其他表的基础表

-- 删除虚拟卡表
DROP TABLE IF EXISTS virtual_card;

-- 删除员工表
DROP TABLE IF EXISTS employees;

-- 删除卡类型表
DROP TABLE IF EXISTS card_type;

-- 删除acl表
DROP TABLE IF EXISTS acl;

-- 3. 删除有循环引用的表

-- 删除departments表的外键约束
ALTER TABLE IF EXISTS departments DROP CONSTRAINT IF EXISTS fk_departments_created_by;

-- 删除roles表的外键约束
ALTER TABLE IF EXISTS roles DROP CONSTRAINT IF EXISTS fk_roles_created_by;

-- 删除管理员表
DROP TABLE IF EXISTS administrator;

-- 删除部门表
DROP TABLE IF EXISTS departments;

-- 删除角色表
DROP TABLE IF EXISTS roles;

-- 删除uuid扩展（如果不需要的话）
-- DROP EXTENSION IF EXISTS "uuid-ossp";