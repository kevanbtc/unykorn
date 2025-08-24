import os
import psycopg
from typing import Generator
from fastapi import Depends
from .security import current_user

DSN = (
    f"postgresql://{os.getenv('POSTGRES_USER','powerdrs')}:{os.getenv('POSTGRES_PASSWORD','powerdrs')}@"
    f"{os.getenv('POSTGRES_HOST','localhost')}:{os.getenv('POSTGRES_PORT','5432')}/"
    f"{os.getenv('POSTGRES_DB','powerdrs')}"
)


def get_conn(u=Depends(current_user)) -> Generator[psycopg.Connection, None, None]:
    with psycopg.connect(DSN, autocommit=True) as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT set_config('app.tenant_id', %s, true);", (u.get("tenant_id"),))
        yield conn
