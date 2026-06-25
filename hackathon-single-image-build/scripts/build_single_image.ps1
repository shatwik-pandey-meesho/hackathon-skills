param(
  [string]$Image = "hackathon-app:final",
  [int]$Port = $(if ($env:PORT) { [int]$env:PORT } else { 8080 }),
  [switch]$Help
)

if ($Help) {
  @"
Usage: .\build_single_image.ps1 [-Image hackathon-app:final] [-Port 8080]

Builds the final single Docker image and smoke-tests it.
"@
  exit 0
}

$ErrorActionPreference = "Stop"
$container = "hackathon-smoke-$([System.Guid]::NewGuid().ToString('N').Substring(0,8))"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  Write-Host "Docker is not installed or not on PATH."
  exit 1
}

if (-not (Test-Path "Dockerfile")) {
  Write-Host "Dockerfile not found in current directory."
  exit 1
}

try {
  Write-Host "Building $Image"
  docker build -t $Image .

  Write-Host "Starting smoke test container"
  docker run -d --name $container -p "${Port}:8080" $Image | Out-Null

  Write-Host "Waiting for app on http://localhost:$Port"
  for ($i = 0; $i -lt 45; $i++) {
    try {
      curl.exe -fsS "http://localhost:$Port/health" | Out-Null
      Write-Host "Health check passed."
      Write-Host "Image ready: $Image"
      Write-Host "Run command: docker run --rm -p 8080:8080 $Image"
      exit 0
    } catch {
      try {
        curl.exe -fsS "http://localhost:$Port/" | Out-Null
        Write-Host "Root page responded."
        Write-Host "Image ready: $Image"
        Write-Host "Run command: docker run --rm -p 8080:8080 $Image"
        exit 0
      } catch {
        Start-Sleep -Seconds 2
      }
    }
  }

  Write-Host "Smoke test failed. Recent container logs:"
  docker logs --tail=200 $container
  exit 1
} finally {
  docker rm -f $container *> $null
}
