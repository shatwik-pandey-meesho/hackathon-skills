param(
  [string]$FinalImageUrl,
  [string]$ServiceName,
  [int]$HostPort = 8080,
  [switch]$Help
)

if ($Help -or -not $FinalImageUrl -or -not $ServiceName) {
  @"
Usage: .\print_swarm_deploy_command.ps1 -FinalImageUrl FINAL_IMAGE_URL -ServiceName SERVICE_NAME [-HostPort 8080]

Prints Docker Swarm commands for judges. It does not execute them.
"@
  exit 0
}

Write-Host "Create a new Swarm service:"
Write-Host "docker service create --name $ServiceName --publish ${HostPort}:8080 $FinalImageUrl"
Write-Host ""
Write-Host "Update an existing Swarm service:"
Write-Host "docker service update --image $FinalImageUrl $ServiceName"
