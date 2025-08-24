CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE tenants (id uuid PRIMARY KEY DEFAULT gen_random_uuid(), name text NOT NULL, theme jsonb DEFAULT '{}'::jsonb);
CREATE TABLE users (id uuid PRIMARY KEY DEFAULT gen_random_uuid(), email text UNIQUE NOT NULL, password_hash text NOT NULL);
CREATE TABLE memberships (user_id uuid REFERENCES users(id), tenant_id uuid REFERENCES tenants(id), role text NOT NULL, PRIMARY KEY(user_id, tenant_id));
ALTER TABLE projects ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES tenants(id);
