param(
  [string]$ProjectId,
  [string]$Region,
  [string]$Repository,
  [string]$LocalImage,
  [string]$FinalImageName,
  [switch]$CreateRepo,
  [switch]$Help
)

if ($Help -or -not $ProjectId -or -not $Region -or -not $Repository -or -not $LocalImage -or -not $FinalImageName) {
  @"
Usage: .\push_to_gcp_registry.ps1 -ProjectId PROJECT_ID -Region REGION -Repository REPOSITORY -LocalImage LOCAL_IMAGE -FinalImageName IMAGE[:TAG] [-CreateRepo]

Example:
  .\push_to_gcp_registry.ps1 -ProjectId my-project -Region asia-south1 -Repository hackathon -LocalImage hackathon-app:final -FinalImageName team-17:final

Outputs the final Artifact Registry image URL.
"@
  exit 0
}

$ErrorActionPreference = "Stop"

foreach ($cmd in @("gcloud", "docker")) {
  if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
    Write-Host "$cmd is not installed or not on PATH."
    exit 1
  }
}

$registryHost = "$Region-docker.pkg.dev"
$finalUrl = "$registryHost/$ProjectId/$Repository/$FinalImageName"

docker image inspect $LocalImage | Out-Null
gcloud config set project $ProjectId | Out-Null
gcloud auth list
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
