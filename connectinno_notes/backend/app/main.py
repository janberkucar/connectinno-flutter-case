from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api import auth, notes
from app.core.config import get_settings
from app.db.session import Base, get_engine
from app.models import note as _note  # noqa: F401
from app.models import user as _user  # noqa: F401


@asynccontextmanager
async def lifespan(app: FastAPI):
    engine = get_engine()
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield


def create_app() -> FastAPI:
    settings = get_settings()
    app = FastAPI(title="Connectinno Notes API", lifespan=lifespan)
    if settings.cors_allow_all:
        app.add_middleware(
            CORSMiddleware,
            allow_origins=["*"],
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )
    app.include_router(auth.router)
    app.include_router(notes.router)
    return app


app = create_app()
