param(
  [string]$Image = $env:IMAGE,
  [int]$Port = $(if ($env:PORT) { [int]$env:PORT } else { 8080 }),
  [switch]$Help
)

if ($Help) {
  @"
Usage: .\start_local_preview.ps1 [-Image hackathon-app:local] [-Port 8080]

Runs the current project locally and prints the browser URL.
"@
  exit 0
}

$ErrorActionPreference = "Stop"
if (-not $Image) { $Image = "hackathon-app:local" }

if ((Get-Command docker -ErrorAction SilentlyContinue) -and (Test-Path "Dockerfile")) {
  Write-Host "Building Docker image: $Image"
  docker build -t $Image .
  Write-Host "Starting preview container on http://localhost:$Port"
  docker run --rm -p "${Port}:8080" $Image
  exit 0
}

if ((Test-Path "docker-compose.yml") -or (Test-Path "compose.yml")) {
  Write-Host "Starting Docker Compose preview on http://localhost:$Port"
  docker compose up --build
  exit 0
}

if ((Test-Path "package.json") -and (Get-Command npm -ErrorAction SilentlyContinue)) {
  Write-Host "Starting npm preview. Check the terminal output for the URL."
  npm install
  npm run dev --if-present
  exit 0
}

Write-Host "Could not find a Dockerfile, Compose file, or npm project to preview."
exit 1
