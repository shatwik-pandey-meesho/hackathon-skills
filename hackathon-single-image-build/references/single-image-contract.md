# Single Image Contract

The final image must include everything judges need to start the project.

## Required

- React production build copied into the runtime image.
- Node.js server or Go binary in the runtime image.
- SQLite runtime support installed in the image only if the backend needs the `sqlite3` CLI at runtime.
- Database initialization from `db/init.sql` or equivalent.
- Startup script that creates the SQLite database file before starting the app.
- App listens on port `8080`.
- `/health` succeeds after startup.

## Recommended Runtime Pattern

- Use a multi-stage Dockerfile.
- Build frontend in a Node stage.
- Build backend in a Node or Go stage.
- Use a simple entrypoint script when database initialization must happen before the app starts.

## Not Allowed For Final Submission

- Requiring Docker Compose.
- Requiring a separate database container.
- Requiring a managed cloud database.
- Requiring local source files mounted into the container.
