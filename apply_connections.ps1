# You can get the connection strings from teh Azure Portal / Under the Settings \Connection String item 

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)] [string] $MongoDBConnectionString='mongodb://n1siccardevmdb:bR1v2TcBnSK5tPkQ==@n1siccardevmdb.mongo.cosmos.azure.com:10255/?ssl=true',
    [Parameter(Mandatory=$true)] [string] $WalletRepositoryConnectionString='"Server=name.mysql.database.azure.com;Database={your_database};Uid=mysql_test@mysql-test;Pwd={your_password};Database=Wallets"'
)

Write-Host "Creating and storing Storage Connection Secrets"
kubectl delete secret registerrepository --ignore-not-found
kubectl delete secret tenantrepository --ignore-not-found
kubectl create secret generic registerrepository --from-literal=repo=$MongoDBConnectionString -n default
kubectl create secret generic tenantrepository --from-literal=repo=$MongoDBConnectionString -n default

kubectl apply -f ./components/secret-wallet-kube.yaml
$walRepo = "Server=n1siccardev.mysql.database.azure.com;UserID=siccaradmin;Password=####;Database=Wallets"
# we are now setting the walletrepository in apply_mysql; until we move to Cosmos SQL
#kubectl create secret generic walletrepository --from-literal=repo=$walRepo -n default

Write-Host "Storing SSL Certificate"
$keyFile = $env:InstallationName + ".key"
$crtFile = $env:InstallationName + ".crt"
kubectl delete secret aks-ingress-tls --ignore-not-found
kubectl create secret tls aks-ingress-tls --key ./certificates/$keyFile --cert ./certificates/$crtFile