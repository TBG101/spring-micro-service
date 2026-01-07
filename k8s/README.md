# Kubernetes Deployment Guide

## Overview
This folder contains Kubernetes YAML files for deploying a microservices architecture with:
- MySQL (database)
- Discovery Service (Eureka)
- Gateway Service (API Gateway)
- Auth Service
- Product Service
- Stock Service

## Prerequisites
- Kubernetes cluster running (Docker Desktop with K8s enabled or Minikube)
- `kubectl` installed and configured
- Docker images pushed to Docker Hub

## Setup Instructions

### 1. Update Docker Hub Images
Before deploying, update all image references in the deployment files:
- Replace `youruser` with your Docker Hub username in:
  - `auth-service-deployment.yaml`
  - `discovery-service-deployment.yaml`
  - `gateway-service-deployment.yaml`
  - `product-service-deployment.yaml`
  - `stock-service-deployment.yaml`

### 2. Verify Kubernetes Cluster
```bash
kubectl cluster-info
kubectl get nodes
```

### 3. Deploy All Services
Make the scripts executable and run:
```bash
chmod +x deploy.sh
./deploy.sh
```

Or manually apply files:
```bash
kubectl apply -f app-configmap.yaml
kubectl apply -f mysql-deployment.yaml
kubectl apply -f mysql-service.yaml
kubectl apply -f discovery-service-deployment.yaml
kubectl apply -f discovery-service-service.yaml
kubectl apply -f gateway-service-deployment.yaml
kubectl apply -f gateway-service-service.yaml
kubectl apply -f auth-service-deployment.yaml
kubectl apply -f auth-service-service.yaml
kubectl apply -f product-service-deployment.yaml
kubectl apply -f product-service-service.yaml
kubectl apply -f stock-service-deployment.yaml
kubectl apply -f stock-service-service.yaml
```

### 4. Check Deployment Status
```bash
chmod +x status.sh
./status.sh
```

Or manually:
```bash
kubectl get deployments
kubectl get pods
kubectl get services
```

## Service Communication

Services communicate using Kubernetes DNS:
- MySQL: `mysql-service:3306`
- Discovery Service: `discovery-service:8761`
- Gateway Service: `gateway-service:8080`
- Auth Service: `auth-service:8081`
- Product Service: `product-service:8082`
- Stock Service: `stock-service:8083`

These URLs are configured in the ConfigMap and automatically injected into all services.

## Accessing the Application

### Docker Desktop
Gateway Service is accessible at:
```
http://localhost:<nodePort>
```
Check the actual port with:
```bash
kubectl get service gateway-service
```

### Minikube
Get the service URL:
```bash
minikube service gateway-service --url
```

## Scaling Services

To scale a deployment:
```bash
kubectl scale deployment gateway-service-deployment --replicas=5
kubectl scale deployment product-service-deployment --replicas=3
```

## Updating Services

To update a service image:
1. Update the image in the deployment file
2. Apply the changes:
```bash
kubectl apply -f service-deployment.yaml
```

Or directly update:
```bash
kubectl set image deployment/gateway-service-deployment gateway-service=youruser/gateway-service:v2
```

## View Logs

```bash
# All pods of a service
kubectl logs -l app=gateway-service

# Specific pod
kubectl logs <pod-name>

# Follow logs
kubectl logs -f <pod-name>
```

## Cleanup

Remove all resources:
```bash
chmod +x delete.sh
./delete.sh
```

Or manually:
```bash
kubectl delete -f app-configmap.yaml
kubectl delete -f mysql-deployment.yaml
kubectl delete -f mysql-service.yaml
kubectl delete -f discovery-service-deployment.yaml
kubectl delete -f discovery-service-service.yaml
kubectl delete -f gateway-service-deployment.yaml
kubectl delete -f gateway-service-service.yaml
kubectl delete -f auth-service-deployment.yaml
kubectl delete -f auth-service-service.yaml
kubectl delete -f product-service-deployment.yaml
kubectl delete -f product-service-service.yaml
kubectl delete -f stock-service-deployment.yaml
kubectl delete -f stock-service-service.yaml
```

## ConfigMap Variables

The `app-configmap.yaml` contains:
- `SPRING_DATASOURCE_URL`: MySQL connection string
- `SPRING_DATASOURCE_USERNAME`: MySQL username (root)
- `SPRING_DATASOURCE_PASSWORD`: MySQL password (root)
- `SPRING_JPA_HIBERNATE_DDL_AUTO`: Hibernate DDL mode (update)
- `AUTH_SERVICE_URL`: Auth service URL for inter-service communication
- `DISCOVERY_SERVICE_URL`: Eureka discovery service URL
- `GATEWAY_SERVICE_URL`: Gateway service URL
- `PRODUCT_SERVICE_URL`: Product service URL
- `STOCK_SERVICE_URL`: Stock service URL
- Port configurations for each service

## Troubleshooting

### Pods not starting
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Service not accessible
```bash
kubectl get endpoints
kubectl describe service gateway-service
```

### MySQL connection issues
Ensure MySQL pod is running:
```bash
kubectl get pods -l app=mysql
kubectl logs -l app=mysql
```

### Service discovery issues
Check Discovery Service logs:
```bash
kubectl logs -l app=discovery-service
```
