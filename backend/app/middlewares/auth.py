import httpx
from fastapi import Header, HTTPException, status

from app.configs import settings

_SUPABASE_USER_ENDPOINT = "/auth/v1/user"


def _extract_bearer_token(authorization: str) -> str:
    if not authorization:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authorization header wajib ada.",
        )

    scheme, _, token = authorization.partition(" ")
    if scheme.lower() != "bearer" or not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Format Authorization tidak valid.",
        )

    return token.strip()


async def verify_supabase_token(authorization: str = Header(...)) -> dict:
    """Memastikan token Supabase valid dengan memanggil endpoint Auth."""
    token = _extract_bearer_token(authorization)

    try:
        async with httpx.AsyncClient(
            base_url=settings.SUPABASE_URL, timeout=10.0
        ) as client:
            response = await client.get(
                _SUPABASE_USER_ENDPOINT,
                headers={
                    "Authorization": f"Bearer {token}",
                    "apikey": settings.SUPABASE_KEY,
                },
            )
    except httpx.HTTPError as exc:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Gagal menghubungi layanan Supabase Auth: {exc}",
        ) from exc

    if response.status_code != status.HTTP_200_OK:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token Supabase tidak valid atau kedaluwarsa.",
        )

    user_data = response.json()

    return {
        "user_id": user_data["id"],
        "email": user_data.get("email"),
        "raw": user_data,
    }
