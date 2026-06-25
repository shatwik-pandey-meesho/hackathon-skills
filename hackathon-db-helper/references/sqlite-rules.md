# SQLite Rules

## Schema

- Keep tables small and obvious.
- Add `id INTEGER PRIMARY KEY AUTOINCREMENT` unless the project already uses UUIDs.
- Add `created_at TEXT DEFAULT CURRENT_TIMESTAMP`.
- Use `TEXT` for strings and descriptions.
- Use `INTEGER` for counts and booleans.
- Use `REAL` or integer cents for money-like values; prefer integer cents when accuracy matters.

## Queries

- Always use parameterized SQL.
- Do not string-concatenate user input into SQL.
- Return predictable JSON from APIs.
- Use transactions when multiple writes must succeed together.

## Files

- Store the database under `data/`, for example `data/hackathon.db`.
- Ensure the Docker image creates the `data/` directory before the app starts.
- Keep `db/init.sql` runnable from scratch for judges.

## Changes

- Prefer additive changes.
- Before destructive changes, ask the participant directly and explain what will be lost.
