# Create and store a Kuberenetes Secrets for MySQL Access
  
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)] [string] $MySQLConnection='Server=siccardevdb.mysql.database.azure.com;UserID=siccaradmin;Password=_pass_;Database=Wallets'
)


"Create and Initialize MySQL Connection Secret"

kubectl create secret generic walletrepository --from-literal=token=$MySQLConnection -n default
