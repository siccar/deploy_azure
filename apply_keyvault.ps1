# Create and store a Kuberenetes Secret for Azure Key Vault Access
# Would be nice if it could read/get/set some of these values 
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
az keyvault set-policy -n $kvName --object-id $managesServiceId --key-permissions get unwrapKey wrapKey

kubectl delete secret local-secret-store
# Paramaters:
#  KeyVault Connection URL String
#  KeyVault Connection Id
#  KeyVault Client Secret
#  KeyVault Tenant Id
#  Wallet Encryption Key

kubectl create secret generic local-secret-store `
--from-literal=keyVaultConnectionString=$KeyVaultConnection `
--from-literal=siccarV3ClientId=$siccarV3ClientId `
--from-literal=siccarV3ClientSecret=$siccarV3ClientSecret `
--from-literal=siccarV3ClientTenant=$siccarV3ClientTenant `
--from-literal=walletEncryptionKey=$walletEncryptionKey

az keyvault set-policy -n MyVault --object-id <application_id> --key-permissions get unwrapKey wrapKey