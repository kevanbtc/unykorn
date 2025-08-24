from fastapi import Depends, HTTPException
from .security import current_user


def tenant_scope(u=Depends(current_user)) -> str:
    tid = u.get("tenant_id")
    if not tid:
        raise HTTPException(status_code=400, detail="Missing tenant_id")
    return tid
