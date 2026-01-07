#!/bin/bash

# Minikube Deployment Script
# Builds and deploys everything locally with Minikube (no Docker Hub push needed)

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "   Spring Exam - Minikube Deployment"
echo "═══════════════════════════════════════════════════════════════"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
REGISTRY=${1:-"localhost"}  # Local registry or Docker Hub
GIT_REPO=${2:-"https://github.com/youruser/spring-exam"}
DEV_MODE=${3:-"true"}  # true = build locally, false = use Docker Hub

# Ensure Docker environment is set for Minikube
echo -e "${BLUE}Setting up Docker environment for Minikube...${NC}"
eval $(minikube docker-env)
echo -e "${GREEN}✓ Docker configured for Minikube${NC}"

# Step 1: Check Minikube status
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 1: Checking Minikube Status${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

if ! minikube status | grep -q "Running"; then
    echo -e "${YELLOW}Minikube is not running. Starting...${NC}"
    minikube start --driver=docker --cpus=4 --memory=8192
fi

echo -e "${GREEN}✓ Minikube is running${NC}"
kubectl cluster-info

# Step 2: Build Docker images locally
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 2: Building Docker Images Locally${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

SERVICES=("auth-service" "discovery-service" "gateway-service" "product-service" "stock-service")

for service in "${SERVICES[@]}"; do
  if [ -d "$service" ]; then
    echo ""
    echo -e "${BLUE}📦 Building $service...${NC}"
    cd "$service"
    docker build -t "$service:latest" .
    cd ..
    echo -e "${GREEN}✓ $service built (local image)${NC}"
  fi
done

echo -e "${GREEN}✓ All images built in Minikube Docker daemon${NC}"

# Step 3: Update Helm values for local images
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 3: Updating Helm Values for Local Images${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

echo ""
echo -e "${BLUE}Updating Helm values to use local images...${NC}"

# For each service, update the values.yaml
for service in "${SERVICES[@]}"; do
  values_file="helm-charts/$service/values.yaml"
  if [ -f "$values_file" ]; then
    # Use local image repository without username
    sed -i "s|repository: youruser/$service|repository: $service|g" "$values_file"
    sed -i "s|pullPolicy: IfNotPresent|pullPolicy: Never|g" "$values_file"
    echo -e "${GREEN}✓ Updated $values_file${NC}"
  fi
done

echo -e "${GREEN}✓ Helm values updated for local deployment${NC}"

# Step 4: Deploy with Helm
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 4: Deploying with Helm${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

cd helm-charts

echo ""
echo -e "${BLUE}Deploying MySQL...${NC}"
helm install exam-mysql mysql/ --namespace default 2>/dev/null || helm upgrade exam-mysql mysql/ --namespace default
sleep 10

echo -e "${BLUE}Deploying Discovery Service...${NC}"
helm install exam-discovery discovery-service/ --namespace default 2>/dev/null || helm upgrade exam-discovery discovery-service/ --namespace default
sleep 10

echo -e "${BLUE}Deploying microservices...${NC}"
for service in gateway-service auth-service product-service stock-service; do
  release_name=$(echo $service | sed 's/-service//')
  helm install "exam-$release_name" "$service/" --namespace default 2>/dev/null || helm upgrade "exam-$release_name" "$service/" --namespace default
done

echo -e "${GREEN}✓ All services deployed${NC}"

cd ..

# Step 5: Verify deployment
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 5: Verifying Deployment${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

echo ""
echo -e "${BLUE}Checking Helm releases...${NC}"
helm list -n default

echo ""
echo -e "${BLUE}Checking Kubernetes resources...${NC}"
kubectl get all -n default

echo ""
echo -e "${BLUE}Waiting for pods to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=exam-mysql --timeout=300s -n default 2>/dev/null || echo "MySQL pod not ready yet"
sleep 5

echo -e "${GREEN}✓ Deployment verification complete${NC}"

# Step 6: Install ArgoCD (optional for local dev)
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 6: Setting Up ArgoCD (Optional)${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

echo ""
read -p "Install ArgoCD? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Creating ArgoCD namespace...${NC}"
    kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
    
    echo -e "${BLUE}Installing ArgoCD...${NC}"
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    
    echo -e "${BLUE}Waiting for ArgoCD...${NC}"
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server --timeout=300s -n argocd 2>/dev/null || true
    
    echo -e "${GREEN}✓ ArgoCD installed${NC}"
else
    echo -e "${YELLOW}Skipping ArgoCD${NC}"
fi

# Summary
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo -e "${GREEN}   ✓ DEPLOYMENT COMPLETE!${NC}"
echo "═══════════════════════════════════════════════════════════════"

echo ""
echo -e "${YELLOW}📝 NEXT STEPS:${NC}"
echo ""
echo "1. Access services via Minikube:"
echo "   minikube service gateway-service"
echo ""
echo "2. Check service status:"
echo "   kubectl get all -n default"
echo "   kubectl logs -l app.kubernetes.io/name=gateway-service"
echo ""
echo "3. Dashboard:"
echo "   minikube dashboard"
echo ""
echo "4. Port forward for local development:"
echo "   kubectl port-forward svc/gateway-service 8080:8080"
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "5. Access ArgoCD:"
    echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
    echo "   Then: https://localhost:8080"
    echo ""
    echo "   Get password:"
    echo "   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d; echo"
    echo ""
fi

echo -e "${YELLOW}📊 Useful Commands:${NC}"
echo ""
echo "Minikube:"
echo "  minikube status              # Check Minikube status"
echo "  minikube dashboard           # Open Kubernetes dashboard"
echo "  minikube docker-env          # Show Docker environment"
echo "  eval \$(minikube docker-env) # Configure Docker for Minikube"
echo ""
echo "Kubernetes:"
echo "  kubectl get all              # View all resources"
echo "  kubectl logs -f <pod>        # Follow pod logs"
echo "  kubectl port-forward svc/<svc> 8080:8080  # Port forward"
echo ""
echo "Helm:"
echo "  helm list                    # List releases"
echo "  helm upgrade exam-gateway helm-charts/gateway-service/  # Update"
echo ""
echo "═══════════════════════════════════════════════════════════════"
