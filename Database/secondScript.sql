-- 1. Crear extensiones y ESQUEMA (Aquí agregamos la extensión citext)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "citext"; -- <--- ¡Esta es la solución a tu error!
CREATE SCHEMA IF NOT EXISTS app;

-- 2. Limpieza de tablas y tipos (Por seguridad al re-ejecutar)
DROP TABLE IF EXISTS request_event CASCADE;
DROP TABLE IF EXISTS request CASCADE;
DROP TABLE IF EXISTS balance CASCADE;
DROP TABLE IF EXISTS user_account CASCADE;
DROP TABLE IF EXISTS employee CASCADE;
DROP TABLE IF EXISTS allowed_domain CASCADE;

DROP TYPE IF EXISTS app.request_type CASCADE;
DROP TYPE IF EXISTS app.request_status CASCADE;
DROP TYPE IF EXISTS app.request_action CASCADE;
DROP TYPE IF EXISTS app.user_role CASCADE;

-- 3. Crear Enums (para estados y tipos)
CREATE TYPE app.request_type AS ENUM ('Vacation', 'Comp Time', 'Sick Leave');
CREATE TYPE app.request_status AS ENUM ('Pending', 'Approved', 'Rejected');
CREATE TYPE app.request_action AS ENUM ('Created', 'Updated', 'Approved', 'Rejected');
CREATE TYPE app.user_role AS ENUM ('Empleado', 'Administrador');

-- 4. Creación de Tablas (Basado en el DER de tu documento SRS)

-- Dominio Permitido
CREATE TABLE allowed_domain (
    domain_id BIGSERIAL PRIMARY KEY,
    domain_name CITEXT UNIQUE NOT NULL
);

-- Empleado
CREATE TABLE employee (
    employee_id BIGSERIAL PRIMARY KEY,
    full_name TEXT NOT NULL,
    email CITEXT UNIQUE NOT NULL,
    position_title TEXT,
    manager_id BIGINT REFERENCES employee(employee_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Cuenta de Usuario
CREATE TABLE user_account (
    user_id BIGSERIAL PRIMARY KEY,
    employee_id BIGINT REFERENCES employee(employee_id) ON DELETE CASCADE,
    email CITEXT UNIQUE NOT NULL,
    external_id TEXT,
    role_name app.user_role NOT NULL DEFAULT 'Empleado',
    profile_completed BOOLEAN DEFAULT FALSE,
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Saldo (Balances)
CREATE TABLE balance (
    balance_id BIGSERIAL PRIMARY KEY,
    employee_id BIGINT REFERENCES employee(employee_id) ON DELETE CASCADE,
    vacation_available INTEGER DEFAULT 0,
    comp_time_available INTEGER DEFAULT 0,
    cutoff_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Solicitud (Request)
CREATE TABLE request (
    request_id BIGSERIAL PRIMARY KEY,
    employee_id BIGINT REFERENCES employee(employee_id) ON DELETE CASCADE,
    manager_id BIGINT REFERENCES employee(employee_id),
    type app.request_type NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    days INTEGER NOT NULL,
    justification TEXT,
    status app.request_status NOT NULL DEFAULT 'Pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Evento de Solicitud (Request Event/Auditoría)
CREATE TABLE request_event (
    event_id BIGSERIAL PRIMARY KEY,
    request_id BIGINT REFERENCES request(request_id) ON DELETE CASCADE,
    action app.request_action NOT NULL,
    user_id BIGINT REFERENCES user_account(user_id),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);