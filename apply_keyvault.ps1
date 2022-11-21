# Create and store a Kuberenetes Secrets for Azure Key Vault Access
  
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)] [string] $siccarV3ClientTenant='clientTenant',
    [Parameter(Mandatory=$true)] [string] $siccarV3ClientId='clientId',
    [Parameter(Mandatory=$true)] [string] $siccarV3ClientSecret='clientSecret'
)
#https://contosokeyvault.vault.azure.net/keys/dataprotection/

# should check the environment variables are set before proceeding

"Create and Initialize Azure Key Vault Secret"
$kvName = $env:InstallationName + "kv"
$vaultCreateResponse = az keyvault create --name $kvName --resource-group $env:ResourceGroup --location $env:ResourceLocation

$vaultResponse = az keyvault key create --name SiccarV3EncryptionKey --vault-name $kvName
# what we want is the 'kid' from the returned 
$vaultDetails = $vaultResponse | ConvertFrom-Json

$kid = $vaultDetails.key.kid
"kid URI : $kid"

$log = az keyvault set-policy -n $kvName --object-id $siccarV3ClientId --key-permissions get unwrapKey wrapKey

$log = az aks enable-addons --addons azure-keyvault-secrets-provider --name $kvName --resource-group $env:ResourceGroup

# set the service user to read
kubectl create clusterrole secretreader --verb=get,list,watch --resource=secrets
kubectl create clusterrolebinding secretreader-srvacct-default-binding --clusterrole=secretreader --serviceaccount=default:default

kubectl delete secret local-secret-store --ignore-not-found
# Paramaters:
#  KeyVault Connection URL String - this is the 'kid' field when the actual Key Store is created in the Vault Service 
#  KeyVault Connection Id String - the ID of the Application as was created in AD i.e. SiccarV3
#  KeyVault Client Secret String - When the App ID is created you can created and access secret
#  KeyVault Tenant Id String - the GUID for the tenant Active Directory
#  Wallet Encryption Key - string - can be used to preseed cryptokeys for reliable testing
#  Wallet Shared Access Signature - string - Used for connecting to store keys as blobs in Azure storage

kubectl create secret generic local-secret-store `
--from-literal=keyVaultConnectionString=$kid `
--from-literal=siccarV3ClientId=$siccarV3ClientId `
--from-literal=siccarV3ClientSecret=$siccarV3ClientSecret `
--from-literal=siccarV3ClientTenant=$siccarV3ClientTenant `
--from-literal=walletEncryptionKey=in_key_vault `
--from-literal=walletSharedAccessSignature=$env:SHARED_ACCESS_SIGNATURE_CONNECTION_STRING
