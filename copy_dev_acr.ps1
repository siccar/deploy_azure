# Copy the runtime images from the SiccarDev ACR, 
# this will move to a public source when we can controll releases
# PAT tokens timeout/change often

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, Position=0, HelpMessage="Registry Name")] [string] $Registry ,
    [Parameter(Mandatory=$true, Position=1, HelpMessage="Source ACR User")] [string] $AcrUsr ,
    [Parameter(Mandatory=$true, Position=2, HelpMessage="Source ACR Personal Access Token")] [string] $AcrPAT
)

az acr login -n $Registry

az acr import `
  --name $Registry `
  --source action-service:latest `
  --image action-service:latest `
  --username $AcrUsr `
  --password $AcrPAT `
  --force `
  --registry /subscriptions/63a27db5-9ba5-4d6b-b534-1f6b60b5c1ca/resourceGroups/siccarv3-dev/providers/Microsoft.ContainerRegistry/registries/siccardev
"Imported Action-Service"

az acr import `
  --name $Registry `
  --source blueprint-service:latest `
  --image blueprint-service:latest `
  --username $AcrUsr `
  --password $AcrPAT `
  --force `
  --registry /subscriptions/63a27db5-9ba5-4d6b-b534-1f6b60b5c1ca/resourceGroups/siccarv3-dev/providers/Microsoft.ContainerRegistry/registries/siccardev
"Imported Blueprint-Service"

az acr import `
  --name $Registry `
  --image wallet-service:latest `
  --source wallet-service:latest `
  --username $AcrUsr `
  --password $AcrPAT `
  --force `
  --registry /subscriptions/63a27db5-9ba5-4d6b-b534-1f6b60b5c1ca/resourceGroups/siccarv3-dev/providers/Microsoft.ContainerRegistry/registries/siccardev
"Imported Wallet-Service"

az acr import `
  --name $Registry `
  --source register-service:latest `
  --image register-service:latest `
  --username $AcrUsr `
  --password $AcrPAT `
  --force `
  --registry /subscriptions/63a27db5-9ba5-4d6b-b534-1f6b60b5c1ca/resourceGroups/siccarv3-dev/providers/Microsoft.ContainerRegistry/registries/siccardev
 "Imported Register-Service"

az acr import `
  --name $Registry `
  --source peer-service:latest `
  --image peer-service:latest `
  --username $AcrUsr `
  --password $AcrPAT `
  --force `
  --registry /subscriptions/63a27db5-9ba5-4d6b-b534-1f6b60b5c1ca/resourceGroups/siccarv3-dev/providers/Microsoft.ContainerRegistry/registries/siccardev
"Imported Peer-Service"

az acr import `
  --name $Registry `
  --source validator-service:latest `
  --image validator-service:latest `
  --username $AcrUsr `
  --password $AcrPAT `
  --force `
  --registry /subscriptions/63a27db5-9ba5-4d6b-b534-1f6b60b5c1ca/resourceGroups/siccarv3-dev/providers/Microsoft.ContainerRegistry/registries/siccardev
"Imported Validator-Service"

az acr import `
  --name $Registry `
  --source tenant-service:latest `
  --image tenant-service:latest `
  --username $AcrUsr `
  --password $AcrPAT `
  --force `
  --registry /subscriptions/63a27db5-9ba5-4d6b-b534-1f6b60b5c1ca/resourceGroups/siccarv3-dev/providers/Microsoft.ContainerRegistry/registries/siccardev
"Imported Tenant-Service"