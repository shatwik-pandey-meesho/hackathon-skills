# Final Checklist

The project is ready when these pass:

- Source is saved in GitHub.
- No obvious secrets are committed.
- `Dockerfile` exists.
- One image builds successfully.
- The image starts with `docker run --rm -p 9080:9080 -p 8090:8090 IMAGE`.
- Browser loads `http://localhost:9080`.
- Backend health returns success at `http://localhost:8090/health`.
- SQLite initializes inside the image.
- Final image is pushed or ready to push to Artifact Registry.
- README includes the final run command and image URL when available.

If one check fails, fix that before calling the project ready.
