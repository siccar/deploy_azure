# Copy the runtime images from the SiccarDev ACR, 
# this will move to a public source when we can controll releases
# PAT tokens timeout/change often

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, Position=0, HelpMessage="Local Registry Name")] [string] $Registry ,
    [Parameter(Mandatory=$true, Position=1, HelpMessage="Source ACR User")] [string] $AcrUsr ,
    [Parameter(Mandatory=$true, Position=2, HelpMessage="Source ACR Personal Access Token")] [string] $AcrPAT,
    [Parameter(Mandatory=$false, Position=3, HelpMessage="release or latest")] [string] $build = "release"
)

# default repo user is  d202cc08-06a1-418f-9041-d7d201aff4a3  - install@siccar.net
az acr login -n $Registry

az acr import `
  --name $Registry `
  --source action-service:$build `
  --image action-service:latest `
  --username $AcrUsr `
  --password $AcrPAT `
  --force `
  --registry /subscriptions/63a27db5-9ba5-4d6b-b534-1f6b60b5c1ca/resourceGroups/siccarv3-dev/providers/Microsoft.ContainerRegistry/registries/siccardev
"Imported Action-Service"

az acr import `
  --name $Registry `
  --source adminui:$build `
  --image adminui:latest `
  --username $AcrUsr `
  --password $AcrPAT `
  --force `
  --registry /subscriptions/63a27db5-9ba5-4d6b-b534-1f6b60b5c1ca/resourceGroups/siccarv3-dev/providers/Microsoft.ContainerRegistry/registries/siccardev
"Imported AdminUI"

az acr import `
  --name $Registry `
  --source blueprint-service:$build `
  --image blueprint-service:latest `
  --username $AcrUsr `
  --password $AcrPAT `
  --force `
  --registry /subscriptions/63a27db5-9ba5-4d6b-b534-1f6b60b5c1ca/resourceGroups/siccarv3-dev/providers/Microsoft.ContainerRegistry/registries/siccardev
"Imported Blueprint-Service"

az acr import `
  --name $Registry `
  --source wallet-service:$build `
  --image wallet-service:latest `
  --username $AcrUsr `
  --password $AcrPAT `
  --force `
  --registry /subscriptions/63a27db5-9ba5-4d6b-b534-1f6b60b5c1ca/resourceGroups/siccarv3-dev/providers/Microsoft.ContainerRegistry/registries/siccardev
"Imported Wallet-Service"

az acr import `
  --name $Registry `
  --source register-service:$build `
  --image register-service:latest `
  --username $AcrUsr `
  --password $AcrPAT `
  --force `
  --registry /subscriptions/63a27db5-9ba5-4d6b-b534-1f6b60b5c1ca/resourceGroups/siccarv3-dev/providers/Microsoft.ContainerRegistry/registries/siccardev
 "Imported Register-Service"

az acr import `
  --name $Registry `
  --source peer-service:$build `
  --image peer-service:latest `
  --username $AcrUsr `
  --password $AcrPAT `
  --force `
  --registry /subscriptions/63a27db5-9ba5-4d6b-b534-1f6b60b5c1ca/resourceGroups/siccarv3-dev/providers/Microsoft.ContainerRegistry/registries/siccardev
"Imported Peer-Service"

az acr import `
  --name $Registry `
  --source validator-service:$build `
  --image validator-service:latest `
  --username $AcrUsr `
  --password $AcrPAT `
  --force `
  --registry /subscriptions/63a27db5-9ba5-4d6b-b534-1f6b60b5c1ca/resourceGroups/siccarv3-dev/providers/Microsoft.ContainerRegistry/registries/siccardev
"Imported Validator-Service"

az acr import `
  --name $Registry `
  --source tenant-service:$build `
  --image tenant-service:latest `
  --username $AcrUsr `
  --password $AcrPAT `
  --force `
  --registry /subscriptions/63a27db5-9ba5-4d6b-b534-1f6b60b5c1ca/resourceGroups/siccarv3-dev/providers/Microsoft.ContainerRegistry/registries/siccardev
"Imported Tenant-Service"