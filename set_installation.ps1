[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, HelpMessage="Resource Group")] [string] $ResourceGroup='node0',
    [Parameter(Mandatory=$true, HelpMessage="Installation Name")] [string] $InstallationName='node0',
    [Parameter(Mandatory=$true, HelpMessage="Fully Qualified DNS Name")] [string] $InstallationDNSName='node0.siccar.dev',
    [Parameter(Mandatory=$true, HelpMessage="Resource Location, i.e. uksouth, westeurope")] [string] $ResourceLocation='WestEurope'
)

$env:NAMESPACE = 'default'
$env:InstallationName = $InstallationName
$env:InstallationDNSName = $InstallationDNSName
$env:ResourceLocation = $ResourceLocation
$env:ResourceGroup = $ResourceGroup

az aks Get-Credentials -n $env:InstallationName -g $env:ResourceGroup 