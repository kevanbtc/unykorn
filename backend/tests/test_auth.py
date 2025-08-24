import pytest
from fastapi import HTTPException
import sys, pathlib

sys.path.append(str(pathlib.Path(__file__).resolve().parents[1]))

from app.security import current_user, require_role, issue_token


class Token:
    def __init__(self, credentials: str):
        self.credentials = credentials


def test_current_user_decodes_token():
    token = issue_token("1", "t1", "Owner")
    user = current_user(Token(token))
    assert user["role"] == "Owner"
    assert user["tenant_id"] == "t1"


def test_require_role_enforces():
    token = issue_token("1", "t1", "Viewer")
    user = current_user(Token(token))
    guard = require_role("Owner")
    with pytest.raises(HTTPException):
        guard(user)
