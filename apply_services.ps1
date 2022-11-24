# Register the Microservices within Kubernetes
"Registering Services"
kubectl apply -f ./components/dapr-config.yaml
kubectl apply -f ./services/service-microservice-action.yaml
kubectl apply -f ./services/service-adminui.yaml
kubectl apply -f ./services/service-microservice-blueprint.yaml
kubectl apply -f ./services/service-microservice-blueprint.yaml
kubectl apply -f ./services/service-microservice-peer.yaml
kubectl apply -f ./services/service-microservice-register.yaml
kubectl apply -f ./services/service-microservice-tenant.yaml
kubectl apply -f ./services/service-microservice-validator.yaml
kubectl apply -f ./services/service-microservice-wallet.yaml