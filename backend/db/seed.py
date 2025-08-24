import os
import psycopg
from backend.app.security import hash_password


def dsn() -> str:
    user = os.getenv("POSTGRES_USER", "powerdrs")
    pw = os.getenv("POSTGRES_PASSWORD", "powerdrs")
    host = os.getenv("POSTGRES_HOST", "localhost")
    port = os.getenv("POSTGRES_PORT", "5432")
    db = os.getenv("POSTGRES_DB", "powerdrs")
    return f"postgresql://{user}:{pw}@{host}:{port}/{db}"


def main() -> None:
    with psycopg.connect(dsn(), autocommit=True) as conn:
        cur = conn.cursor()
        cur.execute("CREATE EXTENSION IF NOT EXISTS pgcrypto;")
        cur.execute("CREATE EXTENSION IF NOT EXISTS vector;")

        cur.execute(
            """
            INSERT INTO tenants (id,name,theme)
            VALUES (gen_random_uuid(), 'Eagle Eye Construction', '{}'::jsonb)
            RETURNING id;
            """
        )
        tenant_id = cur.fetchone()[0]

        cur.execute(
            """
            INSERT INTO users (id,email,password_hash)
            VALUES (gen_random_uuid(), %s, %s)
            RETURNING id;
            """,
            ("admin@unykorn.org", hash_password("ChangeMe123!")),
        )
        user_id = cur.fetchone()[0]

        cur.execute(
            """
            INSERT INTO memberships (user_id, tenant_id, role)
            VALUES (%s, %s, 'Owner')
            ON CONFLICT DO NOTHING;
            """,
            (user_id, tenant_id),
        )

        print("✅ Seed complete")
        print("  tenant_id:", tenant_id)
        print("  admin:", "admin@unykorn.org / ChangeMe123!")


if __name__ == "__main__":
    main()

