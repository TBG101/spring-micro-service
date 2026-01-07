#!/bin/bash
# Deploy all Kubernetes resources

echo "Creating ConfigMap..."
kubectl apply -f app-configmap.yaml

echo "Deploying MySQL..."
kubectl apply -f mysql-deployment.yaml
kubectl apply -f mysql-service.yaml

echo "Waiting for MySQL to be ready..."
sleep 15

echo "Deploying Discovery Service..."
kubectl apply -f discovery-service-deployment.yaml
kubectl apply -f discovery-service-service.yaml

echo "Waiting for Discovery Service to be ready..."
sleep 10

echo "Deploying Gateway Service..."
kubectl apply -f gateway-service-deployment.yaml
kubectl apply -f gateway-service-service.yaml

echo "Deploying Auth Service..."
kubectl apply -f auth-service-deployment.yaml
kubectl apply -f auth-service-service.yaml

echo "Deploying Product Service..."
kubectl apply -f product-service-deployment.yaml
kubectl apply -f product-service-service.yaml

echo "Deploying Stock Service..."
kubectl apply -f stock-service-deployment.yaml
kubectl apply -f stock-service-service.yaml

echo ""
echo "✓ All services deployed successfully!"
echo ""
echo "Checking deployments status..."
kubectl get deployments
echo ""
echo "Checking services status..."
kubectl get services
echo ""
echo "Checking pods status..."
kubectl get pods
