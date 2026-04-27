# Connectinno Notes — FastAPI backend

Production-style API: JWT auth, async SQLAlchemy, PostgreSQL (Neon), owner-scoped notes.

## Setup

1. **Python 3.10+** recommended (3.9+ supported with `typing` compatibility in code).
2. Create a virtual environment and install dependencies:

```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

3. Copy [`.env.example`](.env.example) to `.env` and set `DATABASE_URL` to your Neon (or local) PostgreSQL **async** URL using the `asyncpg` driver, for example:

```env
DATABASE_URL=postgresql+asyncpg://user:pass@ep-xxx.region.aws.neon.tech/neondb?sslmode=require
```

4. Run the API (from the `backend` directory, with `app` on `PYTHONPATH`):

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

- Open API docs: `http://127.0.0.1:8000/docs`

## Endpoints (required by case study)

| Method | Path            | Description              |
|--------|-----------------|--------------------------|
| `POST` | `/auth/signup`  | Register, returns JWT   |
| `POST` | `/auth/login`   | Login, returns JWT      |
| `GET`  | `/notes`        | List current user’s notes (Bearer token) |
| `POST` | `/notes`        | Create note (optional client `id` in body) |
| `PUT`  | `/notes/{id}`   | Update note             |
| `DELETE` | `/notes/{id}` | Delete note            |

## Environment variables

See [`.env.example`](.env.example) for `SECRET_KEY`, `DATABASE_URL`, and CORS.

## More documentation

- Short pointer: [`../docs/backend.md`](../docs/backend.md).
