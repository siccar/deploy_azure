# Create and store a Kuberenetes Secrets for Azure Key Vault Access
  
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)] [string] $KeyVaultConnection='https://kv.vault.azure.net',
    [Parameter(Mandatory=$true)] [string] $siccarV3ClientId='clientId',
    [Parameter(Mandatory=$true)] [string] $siccarV3ClientSecret='clientSecret',
    [Parameter(Mandatory=$true)] [string] $siccarV3ClientTenant='clientTenant',
    [Parameter(Mandatory=$true)] [string] $walletEncryptionKey= 'walletKey'
)
#https://contosokeyvault.vault.azure.net/keys/dataprotection/

"Create and Initialize Azure Key Vault Secret"
$kvName = $env:InstallationName + "kv"
az keyvault create --name $kvName --resource-group $env:ResourceGroup --location $env:ResourceLocation

$vaultDetails = az keyvault key create --name SiccarV3EncryptionKey --vault-name $kvName
# what we want is the 'kid' from the returned 

az keyvault set-policy -n $kvName --object-id $managesServiceId --key-permissions get unwrapKey wrapKey

az aks enable-addons --addons azure-keyvault-secrets-provider --name $kvName --resource-group $env:ResourceGroup

kubectl delete secret local-secret-store --ignore-not-found
# Paramaters:
#  KeyVault Connection URL String - this is the 'kid' field when the actual Key Store is created in the Vault Service 
#  KeyVault Connection Id String - the ID of the Application as was created in AD i.e. SiccarV3
#  KeyVault Client Secret String - When the App ID is created you can created and access secret
#  KeyVault Tenant Id String - the GUID for the tenant Active Directory
#  Wallet Encryption Key - string - can be used to preseed cryptokeys for reliable testing

kubectl create secret generic local-secret-store `
--from-literal=keyVaultConnectionString= $KeyVaultConnection `
--from-literal=siccarV3ClientId=$siccarV3ClientId `
--from-literal=siccarV3ClientSecret=$siccarV3ClientSecret `
--from-literal=siccarV3ClientTenant=$siccarV3ClientTenant `
--from-literal=walletEncryptionKey=$walletEncryptionKey
