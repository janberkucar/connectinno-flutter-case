from datetime import datetime, timedelta, timezone
from typing import Any, Optional
from uuid import UUID

from jose import JWTError, jwt
from passlib.context import CryptContext
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.models.user import User

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)


def hash_password(plain: str) -> str:
    return pwd_context.hash(plain)


def create_access_token(
    subject: str,
    expires_delta: Optional[timedelta] = None,
) -> str:
    settings = get_settings()
    expire = datetime.now(timezone.utc) + (
        expires_delta
        or timedelta(minutes=settings.access_token_expire_minutes)
    )
    to_encode: dict[str, Any] = {"sub": subject, "exp": expire}
    return jwt.encode(
        to_encode, settings.secret_key, algorithm=settings.algorithm
    )


def decode_user_id_from_token(token: str) -> Optional[UUID]:
    settings = get_settings()
    try:
        payload = jwt.decode(
            token, settings.secret_key, algorithms=[settings.algorithm]
        )
        sub = payload.get("sub")
        if not sub:
            return None
        return UUID(str(sub))
    except (JWTError, ValueError, TypeError):
        return None


async def fetch_user_by_id(db: AsyncSession, user_id: UUID) -> Optional[User]:
    r = await db.execute(select(User).where(User.id == user_id))
    return r.scalar_one_or_none()
