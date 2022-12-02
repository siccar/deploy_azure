kubectl rollout restart deployment/adminui
kubectl rollout restart deployment/action-service
kubectl rollout restart deployment/blueprint-service
kubectl rollout restart deployment/peer-service
kubectl rollout restart deployment/tenant-service
kubectl rollout restart deployment/register-service
kubectl rollout restart deployment/validator-service
kubectl rollout restart deployment/wallet-service
kubectl get pods
