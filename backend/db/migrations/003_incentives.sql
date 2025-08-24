CREATE TABLE incentive_rules (
    id TEXT PRIMARY KEY,
    jurisdiction TEXT,
    rule JSONB
);

CREATE TABLE incentive_results (
    id SERIAL PRIMARY KEY,
    project_id UUID,
    rule_id TEXT,
    amount NUMERIC
);
