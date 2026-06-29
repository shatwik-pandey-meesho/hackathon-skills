#!/usr/bin/env bash
set -euo pipefail

INSTALL_GCLOUD="false"
CREATE_REPO="false"

usage() {
  cat <<'USAGE'
Usage: install_and_push_gcp_registry.sh [--install-gcloud] [--create-repo] PROJECT_ID REGION REPOSITORY LOCAL_IMAGE FINAL_IMAGE_NAME[:TAG]

Installs or verifies the Google Cloud CLI, authenticates Docker for Artifact
Registry, tags a local image, and pushes it.

Examples:
  install_and_push_gcp_registry.sh my-project asia-south1 hackathon hackathon-app:final team-17:final
  install_and_push_gcp_registry.sh --install-gcloud --create-repo my-project asia-south1 hackathon hackathon-app:final team-17:final
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --install-gcloud)
      INSTALL_GCLOUD="true"
      shift
      ;;
    --create-repo)
      CREATE_REPO="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

if [[ $# -lt 5 ]]; then
  usage >&2
  exit 1
fi

PROJECT_ID="$1"
REGION="$2"
REPOSITORY="$3"
LOCAL_IMAGE="$4"
FINAL_NAME="$5"
REGISTRY_HOST="$REGION-docker.pkg.dev"
FINAL_URL="$REGISTRY_HOST/$PROJECT_ID/$REPOSITORY/$FINAL_NAME"

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

install_gcloud() {
  case "$(uname -s)" in
    Darwin)
      if ! need_cmd brew; then
        echo "Homebrew is required to install gcloud automatically on macOS."
        echo "Install Homebrew from https://brew.sh, then rerun this script."
        exit 1
      fi
      brew install --cask google-cloud-sdk || brew install google-cloud-sdk
      ;;
    Linux)
      if ! need_cmd apt-get; then
        echo "Automatic gcloud install currently supports Debian/Ubuntu with apt."
        echo "Manual install: https://cloud.google.com/sdk/docs/install"
        exit 1
      fi
      for cmd in sudo curl gpg; do
        if ! need_cmd "$cmd"; then
          echo "$cmd is required to install gcloud on Debian/Ubuntu."
          exit 1
        fi
      done
      sudo apt-get update
      sudo apt-get install -y apt-transport-https ca-certificates gnupg curl
      curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
        | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
      echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
        | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list >/dev/null
      sudo apt-get update
      sudo apt-get install -y google-cloud-cli
      ;;
    *)
      echo "Automatic gcloud install is not supported on this OS."
      echo "Manual install: https://cloud.google.com/sdk/docs/install"
      exit 1
      ;;
  esac
}

if ! need_cmd docker; then
  echo "Docker is not installed or not on PATH."
  exit 1
fi

if ! need_cmd gcloud; then
  if [[ "$INSTALL_GCLOUD" != "true" ]]; then
    echo "Google Cloud CLI gcloud is not installed."
    echo "Rerun with --install-gcloud after the participant or organizer approves installing it."
    exit 1
  fi
  install_gcloud
fi

if ! need_cmd gcloud; then
  echo "gcloud still is not available on PATH after installation."
  echo "Restart the terminal or install manually: https://cloud.google.com/sdk/docs/install"
  exit 1
fi

docker image inspect "$LOCAL_IMAGE" >/dev/null

ACTIVE_ACCOUNT="$(gcloud auth list --filter=status:ACTIVE --format='value(account)' 2>/dev/null || true)"
if [[ -z "$ACTIVE_ACCOUNT" ]]; then
  echo "No active GCP login found. Starting browser login."
  gcloud auth login
fi

gcloud config set project "$PROJECT_ID" >/dev/null
gcloud auth configure-docker "$REGISTRY_HOST" --quiet

if [[ "$CREATE_REPO" == "true" ]]; then
  gcloud artifacts repositories describe "$REPOSITORY" --location="$REGION" >/dev/null 2>&1 \
    || gcloud artifacts repositories create "$REPOSITORY" --repository-format=docker --location="$REGION"
fi

docker tag "$LOCAL_IMAGE" "$FINAL_URL"
docker push "$FINAL_URL"

echo "Final image URL:"
echo "$FINAL_URL"
