# A Power shell script that will setup the Open Telemetry collector
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, HelpMessage="Enter your Application Insights Intrumentation Key")] [string] $instrumentation_key=""
)

kubectl create secret generic appinsights --from-literal=instrumentationkey=$instrumentation_key --save-config
$otel_yaml = (Get-Content -path ./sourceyaml/open-telemetry-collector-app-insights.yaml -Raw) -replace '<INSTRUMENTATION-KEY>', $instrumentation_key

Set-Content -Path ./sourceyaml/open-telemetry-collector-app-insights_temp.yaml -Value $otel_yaml 
(Get-Content -path ./sourceyaml/open-telemetry-collector-app-insights_temp.yaml -Raw)

kubectl apply -f ./sourceyaml/open-telemetry-collector-app-insights_temp.yaml
# Cleanup
Remove-Item ./sourceyaml/open-telemetry-collector-app-insights_temp.yaml