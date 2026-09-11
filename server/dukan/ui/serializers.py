"""DTO -> JSON-ready dict serializers shared by the routers."""

from __future__ import annotations

from dukan.application.dto import AuthenticatedUser, AuthResult, AuthTokens


def profile_dict(p: AuthenticatedUser) -> dict:
    return {
        "id": p.id,
        "username": p.username,
        "display_name": p.display_name,
        "default_branch_id": p.default_branch_id,
        "branches": [
            {
                "branch_id": b.branch_id,
                "branch_name": b.branch_name,
                "role_name": b.role_name,
            }
            for b in p.branches
        ],
    }


def tokens_dict(t: AuthTokens) -> dict:
    return {
        "access_token": t.access_token,
        "refresh_token": t.refresh_token,
        "token_type": t.token_type,
    }


def auth_result(r: AuthResult) -> dict:
    return {"user": profile_dict(r.user), "tokens": tokens_dict(r.tokens)}
