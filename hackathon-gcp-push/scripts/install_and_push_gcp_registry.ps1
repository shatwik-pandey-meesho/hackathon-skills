param(
  [string]$ProjectId,
  [string]$Region,
  [string]$Repository,
  [string]$LocalImage,
  [string]$FinalImageName,
  [switch]$InstallGcloud,
  [switch]$CreateRepo,
  [switch]$Help
)

if ($Help -or -not $ProjectId -or -not $Region -or -not $Repository -or -not $LocalImage -or -not $FinalImageName) {
  @"
Usage: .\install_and_push_gcp_registry.ps1 -ProjectId PROJECT_ID -Region REGION -Repository REPOSITORY -LocalImage LOCAL_IMAGE -FinalImageName IMAGE[:TAG] [-InstallGcloud] [-CreateRepo]

Installs or verifies the Google Cloud CLI, authenticates Docker for Artifact
Registry, tags a local image, and pushes it.

Example:
  .\install_and_push_gcp_registry.ps1 -InstallGcloud -CreateRepo -ProjectId my-project -Region asia-south1 -Repository hackathon -LocalImage hackathon-app:final -FinalImageName team-17:final
"@
  exit 0
}

$ErrorActionPreference = "Stop"

function Test-Command($Name) {
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Install-GcloudCli {
  if (-not (Test-Command "winget")) {
    Write-Host "winget is required to install gcloud automatically on Windows."
    Write-Host "Manual install: https://cloud.google.com/sdk/docs/install"
    exit 1
  }

  winget install --id Google.CloudSDK -e --accept-package-agreements --accept-source-agreements
}

if (-not (Test-Command "docker")) {
  Write-Host "Docker is not installed or not on PATH."
  exit 1
}

if (-not (Test-Command "gcloud")) {
  if (-not $InstallGcloud) {
    Write-Host "Google Cloud CLI gcloud is not installed."
    Write-Host "Rerun with -InstallGcloud after the participant or organizer approves installing it."
    exit 1
  }
  Install-GcloudCli
}

if (-not (Test-Command "gcloud")) {
  Write-Host "gcloud still is not available on PATH after installation."
  Write-Host "Restart PowerShell or install manually: https://cloud.google.com/sdk/docs/install"
  exit 1
}

$registryHost = "$Region-docker.pkg.dev"
$finalUrl = "$registryHost/$ProjectId/$Repository/$FinalImageName"

docker image inspect $LocalImage | Out-Null

$activeAccount = (& gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>$null)
if ([string]::IsNullOrWhiteSpace($activeAccount)) {
  Write-Host "No active GCP login found. Starting browser login."
  gcloud auth login
}

gcloud config set project $ProjectId | Out-Null
gcloud auth configure-docker $registryHost --quiet

if ($CreateRepo) {
  gcloud artifacts repositories describe $Repository --location=$Region *> $null
  if ($LASTEXITCODE -ne 0) {
    gcloud artifacts repositories create $Repository --repository-format=docker --location=$Region
  }
}

docker tag $LocalImage $finalUrl
docker push $finalUrl

Write-Host "Final image URL:"
Write-Host $finalUrl
