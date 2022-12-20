# Create and apply a share disk for DataProtection Key persistence
[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)] [string] $InstallationName='node0',
    [Parameter(Mandatory=$false)] [string] $ResourceGroup='node0',
    [Parameter(Mandatory=$false)] [string] $serilog_level='Information'
)
Write-Host "Setting up Persistent Volume"
$AKS_PERS_STORAGE_ACCOUNT_NAME = $env:InstallationName + "sa"
$AKS_PERS_SHARE_NAME = $env:InstallationName + "disk"
# Create a storage account
$bin = az storage account create -n $AKS_PERS_STORAGE_ACCOUNT_NAME -g $env:ResourceGroup -l $env:ResourceLocation --sku Standard_LRS

# Export the connection string as an environment variable, this is used when creating the Azure file share
$AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string -n $AKS_PERS_STORAGE_ACCOUNT_NAME -g $env:ResourceGroup -o tsv)

# Create wallet service container for the storage account
Write-Host "Creating wallet-service container in storage account"
$bin = az storage container create -n wallet-service --account-name $AKS_PERS_STORAGE_ACCOUNT_NAME --connection-string $AZURE_STORAGE_CONNECTION_STRING

# Create tenant service container for the storage account
Write-Host "Creating tenant-service container in storage account"
$bin = az storage container create -n tenant-service --account-name $AKS_PERS_STORAGE_ACCOUNT_NAME --connection-string $AZURE_STORAGE_CONNECTION_STRING

# Generate Secure Access Token for service account
Write-Host "Generating wallet-service shared access signature for storage account"
$WALLET_SHARED_ACCESS_SIGNATURE=$(az storage container generate-sas --connection-string $AZURE_STORAGE_CONNECTION_STRING --account-name $AKS_PERS_STORAGE_ACCOUNT_NAME --name wallet-service --permissions rwdlac --expiry ((Get-Date).AddYears(1) | Get-Date -Format "yyyy-MM-dd"))
$env:WALLET_SHARED_ACCESS_SIGNATURE_CONNECTION_STRING="BlobEndpoint=https://" + $AKS_PERS_STORAGE_ACCOUNT_NAME + ".blob.core.windows.net/;SharedAccessSignature=" + $WALLET_SHARED_ACCESS_SIGNATURE.replace('"',"")

# Generate Secure Access Token for service account
Write-Host "Generating tenant-service shared access signature for storage account"
$TENANT_SHARED_ACCESS_SIGNATURE=$(az storage container generate-sas --connection-string $AZURE_STORAGE_CONNECTION_STRING --account-name $AKS_PERS_STORAGE_ACCOUNT_NAME --name tenant-service --permissions rwdlac --expiry ((Get-Date).AddYears(1) | Get-Date -Format "yyyy-MM-dd"))
$env:TENANT_SHARED_ACCESS_SIGNATURE_CONNECTION_STRING="BlobEndpoint=https://" + $AKS_PERS_STORAGE_ACCOUNT_NAME + ".blob.core.windows.net/;SharedAccessSignature=" + $TENANT_SHARED_ACCESS_SIGNATURE.replace('"',"")


# Create the file share
$bin = az storage share create -n $AKS_PERS_SHARE_NAME --connection-string $AZURE_STORAGE_CONNECTION_STRING
$STORAGE_KEY=$(az storage account keys list --resource-group $env:ResourceGroup --account-name $AKS_PERS_STORAGE_ACCOUNT_NAME --query "[0].value" -o tsv)

Write-Host "Connecting Storage : " $AKS_PERS_STORAGE_ACCOUNT_NAME

Copy-Item ./sourceyaml/azure-file-pv.yaml ./components/azure-file-pv.yaml
Copy-Item ./sourceyaml/azure-file-pvc.yaml ./components/azure-file-pvc.yaml
(Get-Content ./sourceyaml/azure-file-sc.yaml) | `
    ForEach-Object { $_.replace("{{RESOURCEGROUP}}", " $env:ResourceGroup").
        replace("{{STORAGEACCOUNT}}", "$AKS_PERS_STORAGE_ACCOUNT_NAME") `
    } | `
    Out-File ./components/azure-file-sc.yaml

kubectl apply -f ./components/azure-file-pv.yaml
kubectl apply -f ./components/azure-file-pvc.yaml
kubectl apply -f ./components/azure-file-sc.yaml
