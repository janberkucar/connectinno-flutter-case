from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class NoteBase(BaseModel):
    model_config = ConfigDict(extra="ignore")

    title: str = ""
    content: str = ""
    is_pinned: bool = False


class NoteCreate(NoteBase):
    id: Optional[UUID] = None  # optional client id (offline-first)


class NoteUpdate(NoteBase):
    pass


class NoteOut(BaseModel):
    id: UUID
    title: str
    content: str
    is_pinned: bool
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
