#!/bin/bash

# Minikube Setup for Arch Linux
# Complete guide for running DevOps pipeline with Minikube

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "   Minikube Setup for Spring Exam DevOps Pipeline"
echo "═══════════════════════════════════════════════════════════════"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Step 1: Install Minikube (if not already installed)
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 1: Check Minikube Installation${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

if ! command -v minikube &> /dev/null; then
    echo -e "${YELLOW}Minikube not found. Installing...${NC}"
    curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64
else
    echo -e "${GREEN}✓ Minikube is installed${NC}"
    minikube version
fi

# Step 2: Check Docker
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 2: Check Docker Installation${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Docker not found. Installing...${NC}"
    sudo pacman -S docker docker-compose
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
    echo -e "${YELLOW}Please log out and log back in for group changes to take effect${NC}"
else
    echo -e "${GREEN}✓ Docker is installed${NC}"
    docker --version
fi

# Step 3: Start Minikube
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 3: Starting Minikube${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

echo ""
echo -e "${BLUE}Starting Minikube with Docker driver...${NC}"
minikube start --driver=docker --cpus=4 --memory=8192 --disk-size=40g

# Alternative drivers (uncomment one):
# minikube start --driver=kvm2 --cpus=4 --memory=8192  # For KVM/QEMU
# minikube start --driver=virtualbox --cpus=4 --memory=8192  # For VirtualBox

echo -e "${GREEN}✓ Minikube started${NC}"

# Step 4: Configure Docker to use Minikube
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 4: Configure Docker for Minikube${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

echo ""
echo -e "${BLUE}Setting up Docker environment to use Minikube...${NC}"
eval $(minikube docker-env)

echo -e "${GREEN}✓ Docker configured for Minikube${NC}"
echo "To make this permanent, add to ~/.bashrc or ~/.zshrc:"
echo "  eval \$(minikube docker-env)"

# Step 5: Verify Kubernetes
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 5: Verify Kubernetes Cluster${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

echo ""
kubectl cluster-info
kubectl get nodes

echo -e "${GREEN}✓ Kubernetes cluster verified${NC}"

# Step 6: Enable required addons
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ STEP 6: Enable Minikube Addons${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

echo ""
echo -e "${BLUE}Enabling dashboard...${NC}"
minikube addons enable dashboard

echo -e "${BLUE}Enabling metrics-server...${NC}"
minikube addons enable metrics-server

echo -e "${GREEN}✓ Addons enabled${NC}"

# Step 7: Important notes
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo -e "${YELLOW}📝 IMPORTANT NOTES FOR MINIKUBE${NC}"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "1. Docker commands must be run from this shell (or add to ~/.bashrc):"
echo "   eval \$(minikube docker-env)"
echo ""
echo "2. When building Docker images, they will be built in Minikube's Docker:"
echo "   cd service && docker build -t service:latest ."
echo "   (No need to push to Docker Hub during development)"
echo ""
echo "3. Update helm-charts/*/values.yaml to use local images:"
echo "   FROM: image.repository: youruser/service-name"
echo "   TO:   image.repository: service-name"
echo "   AND:  image.pullPolicy: Never"
echo ""
echo "4. Access services via Minikube:"
echo "   minikube service <service-name>"
echo ""
echo "5. Port forwarding works too:"
echo "   kubectl port-forward svc/<service-name> <port>:<targetPort>"
echo ""
echo "6. Dashboard:"
echo "   minikube dashboard"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo -e "${GREEN}✓ Minikube is ready!${NC}"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo "1. Add to ~/.bashrc or ~/.zshrc (for persistent Docker env):"
echo "   eval \$(minikube docker-env)"
echo ""
echo "2. Source the file:"
echo "   source ~/.bashrc  # or source ~/.zshrc"
echo ""
echo "3. Run the deployment:"
echo "   cd /path/to/spring-exam"
echo "   ./minikube-deploy.sh"
echo ""
