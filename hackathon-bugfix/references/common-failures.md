# Common Failures

## Blank Page

- Check browser console or build output.
- Check React build base path and API URL.
- Verify backend serves the built frontend from `/`.

## Button Does Nothing

- Check click handler exists.
- Check network request path.
- Check backend route method matches frontend request.
- Check JSON body parsing in backend.

## Data Does Not Save

- Check the SQLite database file exists or can be created.
- Check env vars match backend config.
- Check SQL table and column names.
- Check backend uses parameterized insert/update queries.

## Docker Build Fails

- Check `.dockerignore` is not excluding required files.
- Check frontend and backend install commands.
- Check the Dockerfile matches Node.js or Go backend.

## Container Starts Then Exits

- Check entrypoint logs.
- Check SQLite database initialization path and file permissions.
- Check app process is foregrounded or supervised.
- Check frontend port `9080` and backend port `8090` are exposed and not already used by another program.

## GCP Push Fails

- Check `gcloud auth list`.
- Check Docker is authenticated for `REGION-docker.pkg.dev`.
- Check Artifact Registry repository exists.
- Check user has write permission.
