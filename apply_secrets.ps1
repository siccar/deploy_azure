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
kubectl apply -f .\components\secret-reader-role.yaml
