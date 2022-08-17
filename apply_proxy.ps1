# Setup ingress-nginx
#[CmdletBinding()]
#param (
#    [Parameter(Mandatory=$false)] [string] $InstallationDNSName='node0.siccar.dev' 
#    )

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.2.1/deploy/static/provider/cloud/deploy.yaml


(Get-Content ./sourceyaml/siccar-ingress.yaml) | `
    ForEach-Object { $_.replace("{{INSTALLATIONDNS}}", "$env:InstallationDNSName")   } | `
    Out-File ./deployments/siccar-ingress.yaml

"Waiting for proxy service to start, 30secs"
start-sleep -seconds 30    
kubectl apply -f ./deployments/siccar-ingress.yaml
