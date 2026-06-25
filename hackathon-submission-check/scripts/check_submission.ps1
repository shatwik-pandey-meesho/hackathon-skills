param(
  [string]$Image = "hackathon-app:final",
  [int]$Port = $(if ($env:PORT) { [int]$env:PORT } else { 8080 }),
  [switch]$Help
)

if ($Help) {
  @"
Usage: .\check_submission.ps1 [-Image hackathon-app:final] [-Port 8080]

Builds and smoke-tests the final single image, checks GitHub remote status,
and scans committed files for obvious secrets.
"@
  exit 0
}

$ErrorActionPreference = "Continue"
$failed = $false

function Pass($msg) { Write-Host "PASS  $msg" }
function Fail($msg) { Write-Host "FAIL  $msg"; $script:failed = $true }
function Warn($msg) { Write-Host "WARN  $msg" }

if (Test-Path "Dockerfile") { Pass "Dockerfile exists" } else { Fail "Dockerfile missing" }
if (Test-Path "README.md") { Pass "README exists" } else { Warn "README missing" }
if (Test-Path ".git") { Pass "git repo exists" } else { Warn "git repo missing" }

if (Test-Path ".git") {
  git remote get-url origin *> $null
  if ($LASTEXITCODE -eq 0) {
    Pass "GitHub remote configured: $(git remote get-url origin)"
  } else {
    Warn "GitHub remote not configured"
  }

  $secretPattern = 'BEGIN (RSA|OPENSSH) PRIVATE KEY|AIza[0-9A-Za-z_-]{35}|ghp_[0-9A-Za-z_]{30,}|password *= *[^ ]+'
  $matches = git grep -n -E $secretPattern HEAD -- . 2>$null
  if ($matches) {
    $matches | Out-File -FilePath "$env:TEMP\hackathon-secret-scan.txt" -Encoding utf8
    Fail "possible secret found in committed files; inspect $env:TEMP\hackathon-secret-scan.txt"
  } else {
    Pass "no obvious committed secrets found"
  }
}

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  Fail "Docker missing"
  if ($failed) { exit 1 }
}

if (Test-Path "Dockerfile") {
  Write-Host "Building image $Image"
  docker build -t $Image .
  if ($LASTEXITCODE -eq 0) { Pass "image builds" } else { Fail "image build failed"; exit 1 }
}

$container = "hackathon-final-check-$([System.Guid]::NewGuid().ToString('N').Substring(0,8))"
try {
  docker run -d --name $container -p "${Port}:8080" $Image | Out-Null
  if ($LASTEXITCODE -eq 0) { Pass "container starts" } else { Fail "container failed to start"; exit 1 }

  $ready = $false
  for ($i = 0; $i -lt 45; $i++) {
    try {
      curl.exe -fsS "http://localhost:$Port/health" | Out-Null
      Pass "health endpoint responds"
      $ready = $true
      break
    } catch {
      try {
        curl.exe -fsS "http://localhost:$Port/" | Out-Null
        Pass "root page responds"
        $ready = $true
        break
      } catch {
        Start-Sleep -Seconds 2
      }
    }
  }

  if (-not $ready) {
    Fail "app did not respond on http://localhost:$Port"
    docker logs --tail=100 $container
  }
} finally {
  docker rm -f $container *> $null
}

if (Get-Command gcloud -ErrorAction SilentlyContinue) {
  Warn "gcloud is installed; registry URL still needs to be confirmed from push output"
} else {
  Warn "gcloud missing; cannot verify Artifact Registry push from this machine"
}

if ($failed) { exit 1 }
