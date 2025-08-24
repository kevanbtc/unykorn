CREATE TABLE materials (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    unit_cost NUMERIC NOT NULL
);

CREATE TABLE labor_rates (
    id SERIAL PRIMARY KEY,
    role TEXT NOT NULL,
    hourly_rate NUMERIC NOT NULL
);

CREATE TABLE assemblies (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE estimate_items (
    id SERIAL PRIMARY KEY,
    estimate_id UUID,
    code TEXT,
    description TEXT,
    qty NUMERIC,
    unit_cost NUMERIC
);
