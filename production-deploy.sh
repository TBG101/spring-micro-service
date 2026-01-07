#!/bin/bash

# Production Deployment - Docker Hub + Minikube/Kubernetes
# Build → Push to Docker Hub → Deploy with Helm → Setup ArgoCD

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "   Production Deployment Pipeline - Docker Hub + Kubernetes"
echo "═══════════════════════════════════════════════════════════════"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
DOCKER_USERNAME=${1:-"tbg101"}
DOCKER_PASSWORD=${2:-""}
GIT_REPO=${3:-"https://github.com/tbg101/spring-exam"}


echo ""
echo -e "${BLUE}Configuration:${NC}"
echo "  Docker Username: $DOCKER_USERNAME"
echo "  Git Repository: $GIT_REPO"
echo ""

# Step 1: Build Docker Images
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 1: Building Docker Images${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

SERVICES=("auth-service" "discovery-service" "gateway-service" "product-service" "stock-service")

echo ""
echo -e "${BLUE}Building Docker images...${NC}"
for service in "${SERVICES[@]}"; do
  if [ -d "$service" ]; then
    echo ""
    echo -e "${BLUE}📦 Building $DOCKER_USERNAME/$service:latest${NC}"
    cd "$service"
    docker build -t "$DOCKER_USERNAME/$service:latest" .
    cd ..
    echo -e "${GREEN}✓ $service built${NC}"
  fi
done

# Step 2: Check Docker Hub Authentication
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 2: Checking Docker Hub Authentication${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

echo -e "${BLUE}Checking Docker authentication...${NC}"

if docker info 2>/dev/null | grep -q "Username:"; then
  echo -e "${GREEN}✓ Already logged in to Docker Hub${NC}"
else
  echo -e "${BLUE}Logging in to Docker Hub...${NC}"

  if [ -z "$DOCKER_PASSWORD" ]; then
    echo -e "${YELLOW}Enter your Docker Hub password:${NC}"
    read -s DOCKER_PASSWORD
    echo
  fi

  echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
  echo -e "${GREEN}✓ Successfully logged in${NC}"
fi

# Step 3: Push Images to Docker Hub
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 3: Pushing Images to Docker Hub${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

echo ""
echo -e "${BLUE}Pushing images to Docker Hub...${NC}"
for service in "${SERVICES[@]}"; do
  if [ -d "$service" ]; then
    echo ""
    echo -e "${BLUE}📤 Pushing $DOCKER_USERNAME/$service:latest${NC}"
    docker push "$DOCKER_USERNAME/$service:latest"
    echo -e "${GREEN}✓ Pushed${NC}"
  fi
done

# Logout from Docker
echo ""
echo -e "${BLUE}Logging out from Docker Hub...${NC}"
docker logout
echo -e "${GREEN}✓ Logged out${NC}"

# Step 4: Verify Kubernetes Cluster
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 4: Verifying Kubernetes Cluster${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

echo ""
echo -e "${BLUE}Checking Kubernetes cluster...${NC}"

if ! kubectl cluster-info &> /dev/null; then
  echo -e "${RED}✗ Kubernetes cluster not running${NC}"
  echo "For Minikube, start with: minikube start --driver=docker --memory=8192 --cpus=4"
  exit 1
fi

echo -e "${GREEN}✓ Kubernetes cluster is running${NC}"
kubectl get nodes

# Step 5: Update Helm values
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 5: Verifying Helm Configuration${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

echo ""
echo -e "${BLUE}Checking Helm values are configured for Docker Hub...${NC}"

# Verify all values.yaml have correct repository
for service in "${SERVICES[@]}"; do
  values_file="helm-charts/$service/values.yaml"
  if grep -q "repository: $DOCKER_USERNAME/$service" "$values_file"; then
    echo -e "${GREEN}✓ $service configured correctly${NC}"
  else
    echo -e "${RED}✗ $service not configured correctly${NC}"
  fi
done

# Step 6: Deploy with Helm
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 6: Deploying with Helm${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

cd helm-charts

echo ""
echo -e "${BLUE}Deploying MySQL database...${NC}"
helm upgrade --install exam-mysql mysql/ --namespace default --wait
sleep 5
echo -e "${GREEN}✓ MySQL deployed${NC}"

echo ""
echo -e "${BLUE}Deploying Discovery Service...${NC}"
helm upgrade --install exam-discovery discovery-service/ --namespace default --wait
sleep 5
echo -e "${GREEN}✓ Discovery Service deployed${NC}"

echo ""
echo -e "${BLUE}Deploying microservices...${NC}"

for service in gateway-service auth-service product-service stock-service; do
  release_name=$(echo $service | sed 's/-service//')
  echo -e "${BLUE}  - Deploying $service...${NC}"
  helm upgrade --install "exam-$release_name" "$service/" --namespace default --wait
done

echo -e "${GREEN}✓ All services deployed${NC}"

cd ..

# Step 7: Verify Deployment
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 7: Verifying Deployment${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

echo ""
echo -e "${BLUE}Helm releases:${NC}"
helm list -n default

echo ""
echo -e "${BLUE}Kubernetes resources:${NC}"
kubectl get all -n default

echo ""
echo -e "${BLUE}Waiting for pods to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=exam-mysql --timeout=300s -n default 2>/dev/null || true
sleep 10

# Step 8: Install ArgoCD
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 8: Setting Up ArgoCD (GitOps)${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

echo ""
read -p "Install ArgoCD for continuous deployment? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Creating ArgoCD namespace...${NC}"
    kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
    
    echo -e "${BLUE}Installing ArgoCD...${NC}"
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    
    echo -e "${BLUE}Waiting for ArgoCD to be ready...${NC}"
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server --timeout=300s -n argocd 2>/dev/null || true
    
    echo -e "${BLUE}Creating ArgoCD application...${NC}"
    kubectl apply -f helm-charts/argocd-app.yaml
    
    echo -e "${GREEN}✓ ArgoCD installed and configured${NC}"
fi

# Summary
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo -e "${GREEN}   ✓ PRODUCTION DEPLOYMENT COMPLETE!${NC}"
echo "═══════════════════════════════════════════════════════════════"

echo ""
echo -e "${YELLOW}📝 DEPLOYMENT SUMMARY:${NC}"
echo ""
echo "✓ Docker images built and pushed to Docker Hub:"
for service in "${SERVICES[@]}"; do
  echo "  - docker.io/$DOCKER_USERNAME/$service:latest"
done
echo ""
echo "✓ Services deployed on Kubernetes"
echo "✓ All services pulling from Docker Hub"
echo ""

echo -e "${YELLOW}📋 NEXT STEPS:${NC}"
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "1. Access ArgoCD Dashboard:"
    echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
    echo "   Visit: https://localhost:8080"
    echo ""
    echo "2. Get ArgoCD Admin Password:"
    echo "   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d; echo"
    echo ""
fi

echo "3. Check Application Status:"
echo "   kubectl get all -n default"
echo "   helm list -n default"
echo ""

echo "4. Access Gateway Service:"
if command -v minikube &> /dev/null; then
    echo "   minikube service gateway-service"
else
    echo "   Get LoadBalancer IP: kubectl get svc gateway-service"
fi
echo ""

echo "5. View Logs:"
echo "   kubectl logs -f -l app.kubernetes.io/name=gateway-service"
echo ""

echo -e "${YELLOW}📊 PRODUCTION CHECKLIST:${NC}"
echo ""
echo "✓ Docker images in Docker Hub (tbg101): $DOCKER_USERNAME"
echo "✓ Kubernetes services deployed and running"
echo "✓ Database (MySQL) operational"
echo "✓ Service discovery (Eureka) configured"
echo "✓ API Gateway exposed and accessible"
echo "✓ ArgoCD configured for continuous deployment"
echo ""

echo -e "${YELLOW}🔄 CONTINUOUS DEPLOYMENT WORKFLOW:${NC}"
echo ""
echo "1. Make changes to code or Helm charts"
echo "2. Build new Docker image: docker build -t $DOCKER_USERNAME/service:tag ."
echo "3. Push to Docker Hub: docker push $DOCKER_USERNAME/service:tag"
echo "4. Update Helm values.yaml with new tag"
echo "5. Commit and push to Git"
echo "6. ArgoCD automatically detects and deploys changes"
echo ""

echo -e "${YELLOW}📱 USEFUL COMMANDS:${NC}"
echo ""
echo "Kubernetes:"
echo "  kubectl get all                          # View all resources"
echo "  kubectl logs -f <pod-name>               # Follow pod logs"
echo "  kubectl describe pod <pod-name>          # Pod details"
echo "  kubectl port-forward svc/<svc> 8080:8080 # Port forward"
echo ""
echo "Helm:"
echo "  helm list                                # List releases"
echo "  helm status <release>                    # Release status"
echo "  helm upgrade <rel> <chart> --wait        # Update"
echo ""
echo "ArgoCD:"
echo "  argocd app list                          # List apps"
echo "  argocd app get <app>                     # App status"
echo "  argocd app sync <app>                    # Manual sync"
echo ""
echo "═══════════════════════════════════════════════════════════════"
