-- Add up migration script here
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. 首先创建不依赖其他表的基础表

-- 管理角色
CREATE TABLE IF NOT EXISTS roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by UUID NULL
);

-- 部门
CREATE TABLE IF NOT EXISTS departments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    parent_id UUID REFERENCES departments(id),
    created_by UUID NULL
);

-- 管理员
CREATE TABLE IF NOT EXISTS administrator (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    role_id UUID REFERENCES roles(id)
); 

-- 更新roles表的外键
ALTER TABLE roles
    ADD CONSTRAINT fk_roles_created_by
    FOREIGN KEY (created_by)
    REFERENCES administrator(id);

-- 更新departments表的外键
ALTER TABLE departments
    ADD CONSTRAINT fk_departments_created_by
    FOREIGN KEY (created_by)
    REFERENCES administrator(id);

-- acl
CREATE TABLE IF NOT EXISTS acl (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    action SMALLINT NOT NULL,
    target TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by UUID REFERENCES administrator(id)
);

-- 卡类型
CREATE TABLE IF NOT EXISTS card_type (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by UUID REFERENCES administrator(id)
);

-- 员工
CREATE TABLE IF NOT EXISTS employees (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    work_id TEXT UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by UUID REFERENCES administrator(id),
    department_id UUID REFERENCES departments(id)
);

-- 虚拟卡
CREATE TABLE IF NOT EXISTS virtual_card (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by UUID REFERENCES administrator(id),
    card_type_id UUID REFERENCES card_type(id),
    employee_id UUID REFERENCES employees(id)
);

-- 2. 创建关联表

-- role_acl - 角色与权限的关联表
CREATE TABLE IF NOT EXISTS role_acl (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_id UUID REFERENCES roles(id),
    acl_id UUID REFERENCES acl(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by UUID REFERENCES administrator(id)
);

CREATE INDEX on role_acl (role_id, acl_id); -- 加速查询

-- admin_department - 管理员与部门的关联表
CREATE TABLE IF NOT EXISTS admin_dept (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id UUID REFERENCES administrator(id),
    dept_id UUID REFERENCES departments(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by UUID REFERENCES administrator(id)
);

CREATE INDEX on admin_dept (admin_id, dept_id); -- 加速查询

-- department_employee - 部门与员工的关联表
CREATE TABLE IF NOT EXISTS dept_employee (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    dept_id UUID REFERENCES departments(id),
    employee_id UUID REFERENCES employees(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by UUID REFERENCES administrator(id)
);

CREATE INDEX on dept_employee (dept_id, employee_id); -- 加速查询