
# A Power shell script that will setup the Azure Application Insights 
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, HelpMessage="Enter your Application Insights Intrumentation Key")] [string] $instrumentation_key="",
    [Parameter(Mandatory=$true, HelpMessage="Enter your Application Insights Connection String")] [string] $connection_string=""
)

kubectl delete secret appinsights --ignore-not-found
kubectl create secret generic appinsights --from-literal=instrumentationkey=$instrumentation_key --from-literal=connectionstring=$connection_string --save-config