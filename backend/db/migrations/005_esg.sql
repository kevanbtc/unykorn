CREATE TABLE esg_rules (
    id text PRIMARY KEY,
    jurisdiction text NOT NULL,
    applies_to jsonb NOT NULL,
    amount jsonb,
    eligibility jsonb,
    notes text
);

CREATE TABLE esg_assessments (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id uuid,
    scorecard jsonb NOT NULL,
    created_at timestamptz DEFAULT now()
);

CREATE TABLE esg_reports (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    assessment_id uuid REFERENCES esg_assessments(id),
    report jsonb NOT NULL,
    created_at timestamptz DEFAULT now()
);
