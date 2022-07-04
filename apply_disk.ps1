# Create and apply a share disk for DataProtection Key persistence

$AKS_PERS_STORAGE_ACCOUNT_NAME = $env:InstallationName + "sa"
$AKS_PERS_SHARE_NAME = $env:InstallationName + "disk"
# Create a storage account
$bin = az storage account create -n $AKS_PERS_STORAGE_ACCOUNT_NAME -g $env:ResourceGroup -l $env:ResourceLocation --sku Standard_LRS

# Export the connection string as an environment variable, this is used when creating the Azure file share
$AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string -n $AKS_PERS_STORAGE_ACCOUNT_NAME -g $env:ResourceGroup -o tsv)

# Create the file share
$bin = az storage share create -n $AKS_PERS_SHARE_NAME --connection-string $AZURE_STORAGE_CONNECTION_STRING
$STORAGE_KEY=$(az storage account keys list --resource-group $env:ResourceGroup --account-name $AKS_PERS_STORAGE_ACCOUNT_NAME --query "[0].value" -o tsv)

Write-Host "Store : " $AKS_PERS_STORAGE_ACCOUNT_NAME
Write-Host "Key   : " $STORAGE_KEY

kubectl apply -f .\components\azure-file-pv.yaml
kubectl apply -f .\components\azure-file-pvc.yaml
kubectl apply -f .\components\azure-file-sc.yaml

