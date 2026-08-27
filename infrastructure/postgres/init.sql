-- Apereo CAS Lab - local identity store
--
-- DEMO CREDENTIALS ONLY. Never reuse these credentials outside this lab.
--   admin / cas-admin-demo
--   user  / cas-user-demo

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS cas_user (
    id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username      VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(100) NOT NULL,
    email         VARCHAR(320) NOT NULL UNIQUE,
    display_name  VARCHAR(200) NOT NULL,
    enabled       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS cas_role (
    id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS cas_user_role (
    user_id BIGINT NOT NULL REFERENCES cas_user(id) ON DELETE CASCADE,
    role_id BIGINT NOT NULL REFERENCES cas_role(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

INSERT INTO cas_role (name)
VALUES ('ROLE_ADMIN'), ('ROLE_USER')
ON CONFLICT (name) DO NOTHING;

INSERT INTO cas_user (username, password_hash, email, display_name)
VALUES
    ('admin', crypt('cas-admin-demo', gen_salt('bf', 12)), 'admin@example.test', 'CAS Lab Administrator'),
    ('user',  crypt('cas-user-demo',  gen_salt('bf', 12)), 'user@example.test',  'CAS Lab User')
ON CONFLICT (username) DO NOTHING;

INSERT INTO cas_user_role (user_id, role_id)
SELECT u.id, r.id
FROM cas_user u
JOIN cas_role r ON r.name = 'ROLE_ADMIN'
WHERE u.username = 'admin'
ON CONFLICT DO NOTHING;

INSERT INTO cas_user_role (user_id, role_id)
SELECT u.id, r.id
FROM cas_user u
JOIN cas_role r ON r.name = 'ROLE_USER'
WHERE u.username IN ('admin', 'user')
ON CONFLICT DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_cas_user_enabled ON cas_user (enabled);
CREATE INDEX IF NOT EXISTS idx_cas_user_role_role_id ON cas_user_role (role_id);
