---
name: hackathon-gcp-push
description: "Install or verify the Google Cloud CLI and push a final single Docker image to Google Cloud Artifact Registry for hackathon judging. Use when a participant asks to install gcloud, upload the image, push to GCP, tag the image, authenticate Docker with GCP, create or use an Artifact Registry repository, or produce the final registry URL."
---

# Hackathon GCP Push

## Overview

Handle only the GCP upload path: make sure the Google Cloud CLI is available, then publish a locally built image to the organization Artifact Registry. Do not use this skill for general laptop setup.

## Workflow

1. Confirm the local image exists. If not, use `hackathon-single-image-build`.
2. Read `references/gcp-artifact-registry.md`.
3. Check whether `gcloud` is installed. If missing, ask the participant or organizer before installing it.
4. Ask for missing project ID, region, repository, image name, or tag only when they cannot be inferred.
5. Run `scripts/install_and_push_gcp_registry.sh` with explicit arguments. Use `--install-gcloud` only after approval.
6. Report the final image URL in this form:
   `REGION-docker.pkg.dev/PROJECT_ID/REPOSITORY/IMAGE_NAME:TAG`

## Safety

- Do not change organization IAM policies.
- Do not print secrets or tokens.
- Do not delete registry images.
- Use `--create-repo` only when the participant or organizer confirms repository creation is allowed.
- Use `--install-gcloud` only when the participant or organizer confirms software installation is allowed.

## Memory

- If `.agent-memory/` exists, read `.agent-memory/state.json`, `.agent-memory/session.md`, and `.agent-memory/handoff.md` before pushing.
- After a push attempt, update `.agent-memory/state.json` with the registry URL and append the exact result to `.agent-memory/activity.md`.

## Resources

- `scripts/install_and_push_gcp_registry.sh`: install or verify the GCP CLI, tag, authenticate, optionally create repo, and push.
- `scripts/install_and_push_gcp_registry.ps1`: Windows PowerShell version of the dedicated GCP install and registry push script.
- `scripts/push_to_gcp_registry.sh`: lower-level push-only helper for machines that already have `gcloud`.
- `references/gcp-artifact-registry.md`: required inputs and URL format.
