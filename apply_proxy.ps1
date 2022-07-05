# Setup ingress-nginx
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)] [string] $InstallationDNSName='node0.siccar.dev' 
    )

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.2.1/deploy/static/provider/cloud/deploy.yaml



(Get-Content ./sourceyaml/siccar-ingress.yaml) | `
    ForEach-Object { $_.replace("{{INSTALLATIONDNS}}", "$InstallationDNSName")   } | `
    Out-File ./components/siccar-ingress.yaml
