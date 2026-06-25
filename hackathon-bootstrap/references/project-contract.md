# Project Contract

Use this contract when creating or repairing a participant project.

## Required Shape

- `frontend/`: React.js app.
- `backend/`: Node.js or Go API/server.
- `db/`: SQLite schema and seed files, normally `db/init.sql`.
- `Dockerfile`: builds and runs the final single image.
- `.dockerignore`: excludes dependencies, build outputs, git metadata, env files, and local database files.
- `.env.example`: documents configurable values without secrets.
- `README.md`: gives local preview, build, run, and final image commands.

## Runtime Contract

- Container listens on port `8080`.
- Root path `/` serves the React app.
- `/health` returns a simple successful response after backend and SQLite are ready.
- Backend reads and writes a local SQLite file, normally `data/hackathon.db` or `app.db`.
- Database path defaults to `data/hackathon.db`.
- Credentials are local-only defaults unless the organizer supplies registry/runtime secrets.

## Single Image Rule

The final submission must not require Docker Compose, a separate database container, local source files, local `node_modules`, or a cloud database. Compose is acceptable only for local development.
