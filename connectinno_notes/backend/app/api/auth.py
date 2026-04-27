from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import create_access_token, hash_password, verify_password
from app.db.session import get_db
from app.models.user import User
from app.schemas.user import TokenResponse, UserCreate

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/signup", response_model=TokenResponse)
async def signup(
    body: UserCreate,
    db: AsyncSession = Depends(get_db),
) -> TokenResponse:
    existing = await db.execute(select(User).where(User.email == body.email))
    if existing.scalar_one_or_none() is not None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered",
        )
    user = User(
        email=body.email,
        hashed_password=hash_password(body.password),
    )
    db.add(user)
    await db.flush()
    await db.refresh(user)
    token = create_access_token(str(user.id))
    return TokenResponse(
        access_token=token,
        user_id=user.id,
    )


@router.post("/login", response_model=TokenResponse)
async def login(
    body: UserCreate,
    db: AsyncSession = Depends(get_db),
) -> TokenResponse:
    r = await db.execute(select(User).where(User.email == body.email))
    user = r.scalar_one_or_none()
    if user is None or not verify_password(body.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )
    token = create_access_token(str(user.id))
    return TokenResponse(
        access_token=token,
        user_id=user.id,
    )
