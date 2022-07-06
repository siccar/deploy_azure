# Create and store a DAPR authentication secret and bearer within your installation
# v1.0
# 20220704 - happy 4th July

Write-Host "Creating and storing DAPR Authentication"
# Start by creating a ransomised shared secret
# create the JWT

$sharedSecret = -join ((48..57) + (97..122) | Get-Random -Count 32 | % {[char]$_})
$sharedJwt = dotnet siccarcmd init encode $sharedSecret; 
# register the secrets

kubectl create secret generic app-api-token --from-literal=token=$sharedJwt -n default
kubectl create secret generic daprsecret --from-literal=secret=$sharedSecret -n default
kubectl apply -f ./components/secret-reader-role.yaml

$regRepo = "mongodb://n1siccardevmdb:bR1v2TcBnSK5tPkQ==@n1siccardevmdb.mongo.cosmos.azure.com:10255/?ssl=true" # get from Interface
#kubectl create secret generic registerrepository --from-literal=repo=$regRepo -n default

$walReop = "Server=n1siccardev.mysql.database.azure.com;UserID=siccaradmin;Password=####;Database=Wallets"
#kubectl create secret generic walletrepository --from-literal=repo=$walRepo -n default