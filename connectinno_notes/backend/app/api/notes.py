import uuid
from datetime import datetime, timezone
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.note import Note
from app.models.user import User
from app.schemas.note import NoteCreate, NoteOut, NoteUpdate

router = APIRouter(prefix="/notes", tags=["notes"])


@router.get("", response_model=list[NoteOut])
async def list_notes(
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> list[Note]:
    r = await db.execute(
        select(Note)
        .where(Note.user_id == user.id)
        .order_by(Note.is_pinned.desc(), Note.updated_at.desc())
    )
    return list(r.scalars().all())


@router.post("", response_model=NoteOut, status_code=status.HTTP_201_CREATED)
async def create_note(
    body: NoteCreate,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> Note:
    now = datetime.now(timezone.utc)
    note = Note(
        id=body.id or uuid.uuid4(),
        user_id=user.id,
        title=body.title,
        content=body.content,
        is_pinned=body.is_pinned,
        created_at=now,
        updated_at=now,
    )
    db.add(note)
    await db.flush()
    await db.refresh(note)
    return note


@router.put("/{note_id}", response_model=NoteOut)
async def update_note(
    note_id: UUID,
    body: NoteUpdate,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> Note:
    r = await db.execute(
        select(Note).where(Note.id == note_id, Note.user_id == user.id)
    )
    note = r.scalar_one_or_none()
    if note is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Note not found",
        )
    note.title = body.title
    note.content = body.content
    note.is_pinned = body.is_pinned
    note.updated_at = datetime.now(timezone.utc)
    return note


@router.delete("/{note_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_note(
    note_id: UUID,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> None:
    r = await db.execute(
        select(Note).where(Note.id == note_id, Note.user_id == user.id)
    )
    note = r.scalar_one_or_none()
    if note is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Note not found",
        )
    await db.delete(note)
