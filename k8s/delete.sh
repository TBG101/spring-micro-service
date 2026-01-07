#!/bin/bash
# Delete all Kubernetes resources

echo "Deleting all services..."
kubectl delete -f gateway-service-service.yaml || true
kubectl delete -f auth-service-service.yaml || true
kubectl delete -f product-service-service.yaml || true
kubectl delete -f stock-service-service.yaml || true
kubectl delete -f discovery-service-service.yaml || true
kubectl delete -f mysql-service.yaml || true

echo "Deleting all deployments..."
kubectl delete -f stock-service-deployment.yaml || true
kubectl delete -f product-service-deployment.yaml || true
kubectl delete -f auth-service-deployment.yaml || true
kubectl delete -f gateway-service-deployment.yaml || true
kubectl delete -f discovery-service-deployment.yaml || true
kubectl delete -f mysql-deployment.yaml || true

echo "Deleting ConfigMap..."
kubectl delete -f app-configmap.yaml || true

echo ""
echo "✓ All resources deleted!"
echo ""
echo "Remaining resources:"
kubectl get all
