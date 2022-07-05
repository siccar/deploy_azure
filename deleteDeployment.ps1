# Are you sure
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, HelpMessage="Must enter YES to delete deployment")] [string] $confim='no'
)

if ($confim -eq 'YES')
{
kubectl delete deployment action-service
kubectl delete deployment blueprint-service
kubectl delete deployment wallet-service
kubectl delete deployment register-service
kubectl delete deployment peer-service
kubectl delete deployment validator-service
kubectl delete deployment tenant-service

# Any secrets that might be created
kubectl delete secret app-api-token
kubectl delete secret daprsecret

# Service bus takes a while so do it last
$serviceBusName = $env:InstallationName + "sb"
az servicebus namespace delete --resource-group $env:ResourceGroup --name $serviceBusName
kubectl delete secret pubsubsecret

# Remove Storage


}