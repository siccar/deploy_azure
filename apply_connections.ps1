# You can get the connection strings from teh Azure Portal / Under the Settings \Connection String item 

[CmdletBinding()]
param (
    # i.e. ='mongodb://n1siccardevmdb:b.=@n1siccardevmdb.mongo.cosmos.azure.com'
    [Parameter(Mandatory=$true)] [string] $MongoDBConnectionString,
    # ='"Server=name.mysql.database.azure.com;Database={your_database};Uid=mysql_test@mysql-test;Pwd={your_password};Database=Wallets"'
    [Parameter(Mandatory=$true)] [string] $WalletRepositoryConnectionString
)

Write-Host "Creating and storing Storage Connection Secrets"
kubectl delete secret registerrepository --ignore-not-found
kubectl delete secret tenantrepository --ignore-not-found
kubectl create secret generic registerrepository --from-literal=repo=$MongoDBConnectionString -n default
kubectl create secret generic tenantrepository --from-literal=repo=$MongoDBConnectionString -n default

$hostDomain = $MongoDBConnectionString.split("@")[1].split("/")[0]
$username = $hostDomain.split(".")[0]
$split = $MongoDBConnectionString.split(":")
$key = $split[2].split("@")[0]
$params = $split[3].split("/")[1]
kubectl delete secret blueprintstore --ignore-not-found
kubectl create secret generic blueprintstore --from-literal=hostDomain=$hostDomain -n default
kubectl create secret generic blueprintstore --from-literal=username=$username -n default
kubectl create secret generic blueprintstore --from-literal=key=$key -n default
kubectl create secret generic blueprintstore --from-literal=params=$params -n default

#create an empty secret for appinsights - to prevent the system from not starting
#this is reset latter in the instrumentation script
kubectl create secret generic appinsights --from-literal=instrumentationkey=0

kubectl apply -f ./components/secret-wallet-kube.yaml

"Create and Initialize MySQL Connection Secret"
kubectl delete secret walletrepository --ignore-not-found
kubectl create secret generic walletrepository --from-literal=repo=$WalletRepositoryConnectionString -n default

Write-Host "Storing SSL Certificate"
$keyFile = $env:InstallationName + ".key"
$crtFile = $env:InstallationName + ".crt"
kubectl delete secret aks-ingress-tls --ignore-not-found
kubectl create secret tls aks-ingress-tls --key ./certificates/$keyFile --cert ./certificates/$crtFile