#!/bin/bash

# Complete DevOps Pipeline Setup Guide
# Build → Jenkins → Kubernetes → Helm → ArgoCD

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "   SPRING EXAM - Complete DevOps Pipeline Setup"
echo "═══════════════════════════════════════════════════════════════"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DOCKER_USERNAME=${1:-"youruser"}
DOCKER_PASSWORD=${2:-""}
GIT_REPO=${3:-"https://github.com/youruser/spring-exam.git"}

if [ "$DOCKER_USERNAME" = "youruser" ]; then
  echo -e "${YELLOW}⚠️  Please provide your Docker Hub username as first argument${NC}"
  echo "Usage: ./complete-setup.sh <docker-username> <docker-password> <git-repo-url>"
  exit 1
fi

# Step 1: Build Docker Images
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 1: Building Docker Images${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

SERVICES=("auth-service" "discovery-service" "gateway-service" "product-service" "stock-service" "ai-agent-service")

for service in "${SERVICES[@]}"; do
  if [ -d "$service" ]; then
    echo ""
    echo -e "${BLUE}📦 Building $service...${NC}"
    cd "$service"
    docker build -t "$DOCKER_USERNAME/$service:latest" .
    cd ..
    echo -e "${GREEN}✓ $service built${NC}"
  fi
done

# Step 2: Push to Docker Hub
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 2: Pushing to Docker Hub${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

if [ -z "$DOCKER_PASSWORD" ]; then
  echo -e "${YELLOW}Enter Docker Hub password (or press Enter to skip push):${NC}"
  read -s DOCKER_PASSWORD
fi

if [ ! -z "$DOCKER_PASSWORD" ]; then
  echo ""
  echo "Logging into Docker Hub..."
  echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
  
  for service in "${SERVICES[@]}"; do
    if [ -d "$service" ]; then
      echo -e "${BLUE}Pushing $DOCKER_USERNAME/$service:latest...${NC}"
      docker push "$DOCKER_USERNAME/$service:latest"
      echo -e "${GREEN}✓ Pushed${NC}"
    fi
  done
  
  docker logout
else
  echo -e "${YELLOW}Skipping Docker Hub push${NC}"
fi

# Step 3: Setup Kubernetes
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 3: Setting Up Kubernetes${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

echo ""
echo "Checking Kubernetes cluster..."
if kubectl cluster-info &> /dev/null; then
  echo -e "${GREEN}✓ Kubernetes cluster is running${NC}"
  kubectl get nodes
else
  echo -e "${YELLOW}⚠️  Kubernetes cluster not found!${NC}"
  echo "Please enable Kubernetes in Docker Desktop or start Minikube:"
  echo "  Docker Desktop: Enable in settings → Kubernetes"
  echo "  Minikube: minikube start"
  exit 1
fi

# Step 4: Update Configuration Files
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 4: Updating Configuration Files${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

echo ""
echo -e "${BLUE}Updating Helm values with Docker Hub username...${NC}"
sed -i.bak "s/youruser/$DOCKER_USERNAME/g" helm-charts/*/values.yaml
sed -i.bak "s|https://github.com/youruser/spring-exam|$GIT_REPO|g" helm-charts/argocd-app.yaml
echo -e "${GREEN}✓ Configuration updated${NC}"

# Step 5: Deploy with Helm
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 5: Deploying with Helm${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

echo ""
echo -e "${BLUE}Deploying services...${NC}"

cd helm-charts

# Deploy MySQL first
echo "Deploying MySQL database..."
helm install exam-mysql mysql/ --namespace default || helm upgrade exam-mysql mysql/ --namespace default
sleep 10

# Deploy Discovery Service
echo "Deploying Discovery Service..."
helm install exam-discovery discovery-service/ --namespace default || helm upgrade exam-discovery discovery-service/ --namespace default
sleep 10

# Deploy other services
for service in gateway-service auth-service product-service stock-service; do
  release_name=$(echo $service | sed 's/-service//')
  echo "Deploying $service..."
  helm install "exam-$release_name" "$service/" --namespace default || helm upgrade "exam-$release_name" "$service/" --namespace default
done

echo -e "${GREEN}✓ All services deployed${NC}"

cd ..

# Step 6: Verify Deployment
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 6: Verifying Deployment${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

echo ""
echo "Checking Helm releases..."
helm list -n default

echo ""
echo "Checking Kubernetes resources..."
kubectl get all -n default

echo ""
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=exam-mysql --timeout=300s -n default || true
sleep 5

echo ""
echo -e "${GREEN}✓ Deployment verification complete${NC}"

# Step 7: Install ArgoCD
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 7: Installing ArgoCD${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

echo ""
echo "Creating ArgoCD namespace..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

echo "Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server --timeout=300s -n argocd || true

echo -e "${GREEN}✓ ArgoCD installed${NC}"

# Step 8: Configure ArgoCD Application
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 8: Configuring ArgoCD Application${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

echo ""
echo "Applying ArgoCD application manifest..."
kubectl apply -f helm-charts/argocd-app.yaml

echo -e "${GREEN}✓ ArgoCD application configured${NC}"

# Summary
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo -e "${GREEN}   ✓ SETUP COMPLETE!${NC}"
echo "═══════════════════════════════════════════════════════════════"

echo ""
echo -e "${YELLOW}📝 NEXT STEPS:${NC}"
echo ""
echo "1. Access ArgoCD UI:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "   Then visit: https://localhost:8080"
echo ""
echo "2. Get ArgoCD Admin Password:"
echo "   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d; echo"
echo ""
echo "3. Check Application Status:"
echo "   argocd app list"
echo "   argocd app get exam-app"
echo ""
echo "4. Access Gateway Service:"
export GATEWAY_PORT=$(kubectl get svc gateway-service -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "30001")
echo "   http://localhost:$GATEWAY_PORT"
echo ""
echo "5. View Logs:"
echo "   kubectl logs -f -l app.kubernetes.io/name=gateway-service -n default"
echo ""
echo -e "${YELLOW}📊 Useful Commands:${NC}"
echo ""
echo "Helm Management:"
echo "  helm list                                    # List releases"
echo "  helm status <release>                        # Check status"
echo "  helm upgrade <release> <chart>               # Update deployment"
echo ""
echo "Kubernetes:"
echo "  kubectl get all                              # All resources"
echo "  kubectl describe pod <pod-name>              # Pod details"
echo "  kubectl logs <pod-name>                      # Pod logs"
echo "  kubectl port-forward svc/<service> <port>:port  # Port forward"
echo ""
echo "ArgoCD:"
echo "  argocd app list                              # List apps"
echo "  argocd app logs exam-app                     # View logs"
echo "  argocd app sync exam-app                     # Manual sync"
echo ""
echo "═══════════════════════════════════════════════════════════════"
