#Initialize the deployment environment for Siccar Services
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, HelpMessage="Resource Group")] [string] $ResourceGroup='node0',
    [Parameter(Mandatory=$true, HelpMessage="Installation Name")] [string] $InstallationName='node0',
    [Parameter(Mandatory=$true, HelpMessage="Fully Qualified DNS Name")] [string] $InstallationDNSName='node0.siccar.dev',
    [Parameter(Mandatory=$true, HelpMessage="Resource Location, i.e. uksouth, westeurope")] [string] $ResourceLocation='WestEurope',
    [Parameter(Mandatory=$true, HelpMessage="Source Repo PAT")] [string] $AcrPAT='hlaquoruwmp25rdfssldldvzn7nhousbnhhdltprvvobzwujts3q' # this PAT will expire soon
)
# firstly set some defaults and store parameters for later
Write-Host "Setting Defaults"
# locations can be listed by az account list-locations
az configure --defaults location=$ResourceLocation resource-group=$ResourceGroup installation-name=$InstallationName installation-dns-name=$InstallationDNSName

$env:NAMESPACE = 'default'
$env:InstallationName = $InstallationName
$env:InstallationDNSName = $InstallationDNSName
$env:ResourceLocation = $ResourceLocation
$env:ResourceGroup = $ResourceGroup

# Check we have the tools we need, if not get them
Write-Host "Checking tooling..."
$bin = az feature register --namespace "Microsoft.ContainerService" --name "AKS-ExtensionManager" --only-show-errors 
$bin = az feature register --namespace "Microsoft.ContainerService" --name "AKS-Dapr" --only-show-errors
$bin = az provider register -n Microsoft.ContainerService

$bin = az extension add --name acrtransfer --only-show-errors

$bin = dotnet tool restore

# Get connected to our home kubernetes cluster 
az aks get-credentials --admin -n $InstallationName -g $ResourceGroup

# Verify Dapr  - dapr status -k if nothing dapr init -k
Write-Host "Checking / Installing DAPR"
& dapr init -k

Write-Host "Cloning Runtime Images"
$RepoName = $InstallationName + "cr"
$repoUser = "d202cc08-06a1-418f-9041-d7d201aff4a3"
$bin = az acr create --resource-group $ResourceGroup --name $RepoName --sku Basic --location $ResourceLocation
$bin = az aks update -n $InstallationName -g $ResourceGroup --attach-acr $RepoName
& .\copy_dev_acr.ps1 $RepoName $repoUser $AcrPAT

# "Registering Service"
& .\apply_services.ps1

# Create and setup Shared Disk
& .\apply_disk.ps1

# Create and setup Service Bus
& .\apply_servicebus.ps1

# Create and setup Dapr Secrets
& .\apply_secrets.ps1

# Apply the common settings
& .\apply_settings.ps1