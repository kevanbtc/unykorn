from datetime import datetime, timedelta
from typing import Literal
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer
from passlib.context import CryptContext
import jwt, os

JWT_SECRET = os.getenv("SECRET_KEY", "CHANGE_ME")
JWT_ALGO = "HS256"
TOKEN_TTL_MIN = 60 * 24  # 24h

pwd = CryptContext(schemes=["bcrypt"], deprecated="auto")
auth = HTTPBearer(auto_error=False)

Role = Literal["Owner","PM","Estimator","Adjuster","Viewer"]

def hash_password(p: str) -> str:
    return pwd.hash(p)

def verify_password(p: str, h: str) -> bool:
    return pwd.verify(p, h)

def issue_token(user_id: str, tenant_id: str, role: Role) -> str:
    now = datetime.utcnow()
    payload = {
        "sub": user_id,
        "tenant_id": tenant_id,
        "role": role,
        "iat": int(now.timestamp()),
        "exp": int((now + timedelta(minutes=TOKEN_TTL_MIN)).timestamp()),
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGO)

def decode_token(token: str) -> dict:
    try:
        return jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGO])
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token expired")
    except Exception:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")

def current_user(creds=Depends(auth)):
    if not creds:
        raise HTTPException(status_code=401, detail="Missing credentials")
    return decode_token(creds.credentials)

def require_role(*roles: Role):
    def wrapper(u=Depends(current_user)):
        if u.get("role") not in roles:
            raise HTTPException(status_code=403, detail="Forbidden")
        return u
    return wrapper
