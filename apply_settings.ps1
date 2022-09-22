# A Power shell script that will setup the deployment YAML files with the chosen configuration
# its looking for its variables from the environment
[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)] [string] $serilog_level='Information'
)

$acrName = $env:InstallationName + "cr"
$issuer = "https://" + $env:InstallationDNSName
Write-Host "Generating Deployment YAML for "$issuer

# ActionService 
(Get-Content ./sourceyaml/deployment-microservice-action.yaml) | `
    ForEach-Object { $_.replace("{{ACR}}", "$acrName.azurecr.io").
        replace("{{SERILOG__MINIMUMLEVEL}}", "$serilog_level").
        replace("{{TENANTISSUER}}", "$issuer") `
    } | `
    Out-File ./deployments/deployment-microservice-action.yaml

# AdminUI 
(Get-Content ./sourceyaml/deployment-adminui.yaml) | `
ForEach-Object { $_.replace("{{ACR}}", "$acrName.azurecr.io").
    replace("{{TENANTISSUER}}", "$issuer") `
} | `
Out-File ./deployments/deployment-adminui.yaml

# BlueprintService 
(Get-Content ./sourceyaml/deployment-microservice-blueprint.yaml) | `
    ForEach-Object { $_.replace("{{ACR}}", "$acrName.azurecr.io").
        replace("{{SERILOG__MINIMUMLEVEL}}", "$serilog_level").
        replace("{{TENANTISSUER}}", "$issuer")  `
    } | `
    Out-File ./deployments/deployment-microservice-blueprint.yaml

# WalletService 
(Get-Content ./sourceyaml/deployment-microservice-wallet.yaml) | `
    ForEach-Object { $_.replace("{{ACR}}", "$acrName.azurecr.io").
        replace("{{SERILOG__MINIMUMLEVEL}}", "$serilog_level").
        replace("{{TENANTISSUER}}", "$issuer")  `
    } | `
    Out-File ./deployments/deployment-microservice-wallet.yaml

# RegisterService 
(Get-Content ./sourceyaml/deployment-microservice-register.yaml) | `
    ForEach-Object { $_.replace("{{ACR}}", "$acrName.azurecr.io").
        replace("{{SERILOG__MINIMUMLEVEL}}", "$serilog_level").
        replace("{{TENANTISSUER}}", "$issuer")  `
    } | `
    Out-File ./deployments/deployment-microservice-register.yaml

# TenantService 
(Get-Content ./sourceyaml/deployment-microservice-tenant.yaml) | `
    ForEach-Object { $_.replace("{{ACR}}", "$acrName.azurecr.io").
        replace("{{SERILOG__MINIMUMLEVEL}}", "$serilog_level").
        replace("{{TENANTISSUER}}", "$issuer").  `
        replace("{{ISSUERNAME}}", "$issuer")  `
    } | `
    Out-File ./deployments/deployment-microservice-tenant.yaml

# PeerService  

$ipAddressResource = az aks show -g $env:ResourceGroup -n $env:InstallationName --query networkProfile.loadBalancerProfile.effectiveOutboundIPs[].id -o tsv
$ipaddress = az network public-ip show --ids $ipAddressResource --query ipAddress -o tsv
(Get-Content ./sourceyaml/deployment-microservice-peer.yaml) | `
    ForEach-Object { $_.replace("{{ACR}}", "$acrName.azurecr.io").
        replace("{{SERILOG__MINIMUMLEVEL}}", "$serilog_level").
        replace("{{TENANTISSUER}}", "$issuer").
        replace("{{PEER__IPENDPOINT}}","$ipaddress"). 
        replace("{{PEER__SEED}}","https://n0.siccar.dev").
        replace("{{PEER__NAME}}","$env:InstallationDNSName") `
    } | `
    Out-File ./deployments/deployment-microservice-peer.yaml

# ValidatorService 
(Get-Content ./sourceyaml/deployment-microservice-validator.yaml) | `
    ForEach-Object { $_.replace("{{ACR}}", "$acrName.azurecr.io").
        replace("{{SERILOG__MINIMUMLEVEL}}", "$serilog_level").
        replace("{{TENANTISSUER}}", "$issuer")  `
    } | `
    Out-File ./deployments/deployment-microservice-validator.yaml

