# You can get the connection strings from teh Azure Portal / Under the Settings \Connection String item 

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)] [string] $MongoDBConnectionString='mongodb://n1siccardevmdb:bR1v2TcBnSK5tPkQ==@n1siccardevmdb.mongo.cosmos.azure.com:10255/?ssl=true',
    [Parameter(Mandatory=$true)] [string] $WalletRepositoryConnectionString='"Server=name.mysql.database.azure.com;Database={your_database};Uid=mysql_test@mysql-test;Pwd={your_password};"'
)

Write-Host "Creating and storing Storage Connection Secrets"

kubectl create secret generic registerrepository --from-literal=repo=$MongoDBConnectionString -n default
kubectl create secret generic tenantrepository --from-literal=repo=$MongoDBConnectionString -n default

kubectl apply -f ./components/secret-wallet-kube.yaml
$walRepo = "Server=n1siccardev.mysql.database.azure.com;UserID=siccaradmin;Password=####;Database=Wallets"
kubectl create secret generic walletrepository --from-literal=repo=$walRepo -n default

Write-Host "Storing SSL Certificate"
$keyFile = $env:InstallationName + ".key"
$crtFile = $env:InstallationName + ".crt"
kubectl create secret tls aks-ingress-tls --key ./certificates/$keyFile --cert ./certificates/$crtFile