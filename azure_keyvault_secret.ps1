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
"Create and Initialize Azure Key Vault Secret"

kubectl delete secret local-secret-store
# Paramaters:
#  KeyVault Connection String
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
