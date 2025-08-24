from time import time
from fastapi import Request, HTTPException

BUCKET = {}

def throttle_login(max_per_min: int = 10):
    def wrapper(request: Request):
        ip = request.client.host
        now = int(time() // 60)
        key = (ip, now)
        BUCKET[key] = BUCKET.get(key, 0) + 1
        if BUCKET[key] > max_per_min:
            raise HTTPException(status_code=429, detail="Too many attempts")
    return wrapper
