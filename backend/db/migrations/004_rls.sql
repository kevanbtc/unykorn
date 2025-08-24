-- Enable row level security for tenant isolation
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON projects
USING (tenant_id = current_setting('app.tenant_id', true)::uuid);
