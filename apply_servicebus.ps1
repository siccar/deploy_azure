# Create and use an Azure Service Bus

$serviceBusName = $env:InstallationName + "sb"

Write-Host "Creating and attaching Service Bus :" $serviceBusName
Write-Host " ...this might take a while"
$bin = az servicebus namespace create --resource-group $env:ResourceGroup --name $serviceBusName --location $env:ResourceLocation

$connectStr = az servicebus namespace authorization-rule keys list --resource-group $env:ResourceGroup --namespace-name $serviceBusName `
  --name RootManageSharedAccessKey --query primaryConnectionString --output tsv

#Componentes dont currently appear to use Secrets  
kubectl create secret generic pubsubsecret --from-literal=connectionstring=$connectStr -n default

(Get-Content ./sourceyaml/pubsub.yaml) | `
    ForEach-Object { $_.replace("{{pubsubconnection}}", "$connectStr") } | `
    Out-File ./deployments/pubsub.yaml

kubectl apply -f ./deployments/pubsub.yaml
