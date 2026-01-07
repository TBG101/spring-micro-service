# Helm Charts for Spring Exam Microservices

Complete Helm Charts for deploying a Spring Boot microservices application with Kubernetes and ArgoCD.

## Directory Structure

```
helm-charts/
├── mysql/                    # Database chart
├── discovery-service/        # Eureka discovery service
├── gateway-service/          # API Gateway
├── auth-service/            # Authentication service
├── product-service/         # Product service
├── stock-service/           # Stock service
├── microservice/            # Generic microservice template
└── argocd-app.yaml         # ArgoCD application manifest
```

## Prerequisites

- Kubernetes cluster (Docker Desktop or Minikube)
- `kubectl` installed and configured
- `helm` installed (version 3+)
- Docker Hub account with images pushed

## Quick Start

### 1. Update Docker Hub Images

Update all `values.yaml` files with your Docker Hub username:

```bash
# Replace 'youruser' in all values.yaml files
sed -i 's/youruser/<your-docker-username>/g' */values.yaml
```

### 2. Install Helm Charts Locally

Test the charts:
```bash
helm lint mysql discovery-service gateway-service auth-service product-service stock-service
```

Deploy using Helm:
```bash
helm install exam-db mysql/
helm install discovery-svc discovery-service/
helm install gateway-svc gateway-service/
helm install auth-svc auth-service/
helm install product-svc product-service/
helm install stock-svc stock-service/
```

Or deploy all with a single command:
```bash
for chart in mysql discovery-service gateway-service auth-service product-service stock-service; do
  helm install $chart $chart/
done
```

### 3. Verify Installation

```bash
kubectl get all
kubectl get services
helm list
```

## ArgoCD Setup

### Install ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### Access ArgoCD UI

Port forward to access the web interface:
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Access at: `https://localhost:8080`

### Get ArgoCD Admin Password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

### Push Charts to Git

Initialize Git repository with Helm charts:

```bash
cd ..  # Go to spring-exam root
git init
git add helm-charts/
git commit -m "Add Helm charts for microservices"
git remote add origin https://github.com/youruser/spring-exam.git
git branch -M main
git push -u origin main
```

### Create ArgoCD Application

Update `helm-charts/argocd-app.yaml` with your Git repository URL:

```bash
sed -i 's|https://github.com/youruser/spring-exam|<your-repo-url>|g' helm-charts/argocd-app.yaml
```

Apply the ArgoCD application:

```bash
kubectl apply -f helm-charts/argocd-app.yaml
```

Or create manually via ArgoCD UI:
1. Click **New App**
2. Set:
   - **Name**: exam-app
   - **Project**: default
   - **Repo URL**: Your Git repository URL
   - **Path**: helm-charts
   - **Cluster**: https://kubernetes.default.svc
   - **Namespace**: default
3. Click **Create**

## Managing Helm Charts

### Update Replica Count

Modify `*/values.yaml`:
```yaml
replicaCount: 5
```

Apply changes:
```bash
helm upgrade <release-name> <chart-name>/
```

### Update Image Version

Modify `*/values.yaml`:
```yaml
image:
  tag: v2.0
```

Apply changes:
```bash
helm upgrade <release-name> <chart-name>/
```

### Uninstall Charts

```bash
helm uninstall exam-db
helm uninstall discovery-svc
helm uninstall gateway-svc
helm uninstall auth-svc
helm uninstall product-svc
helm uninstall stock-svc
```

Or with ArgoCD:
```bash
argocd app delete exam-app
```

## Service Configuration

All services are configured in their respective `values.yaml`:

### Database Connection
```yaml
env:
  - name: SPRING_DATASOURCE_URL
    value: "jdbc:mysql://mysql-service:3306/exam_db"
  - name: SPRING_DATASOURCE_USERNAME
    value: "root"
  - name: SPRING_DATASOURCE_PASSWORD
    value: "root"
```

### Service Discovery
```yaml
env:
  - name: EUREKA_CLIENT_SERVICE_URL_DEFAULTZONE
    value: "http://discovery-service:8761/eureka/"
```

## Troubleshooting

### Check Helm Release Status
```bash
helm status <release-name>
helm history <release-name>
```

### View Pod Logs
```bash
kubectl logs -l app.kubernetes.io/name=<service-name>
kubectl logs <pod-name>
```

### Describe Pods
```bash
kubectl describe pod <pod-name>
```

### ArgoCD Application Status
```bash
argocd app get exam-app
argocd app logs exam-app
```

### Helm Template Testing
```bash
helm template <release-name> <chart-name>/
helm diff upgrade <release-name> <chart-name>/  # Requires helm-diff plugin
```

## Continuous Deployment Workflow

1. **Make changes** to `helm-charts/*/values.yaml`
2. **Push to Git**:
   ```bash
   git add helm-charts/
   git commit -m "Update chart configuration"
   git push origin main
   ```
3. **ArgoCD automatically detects** the changes
4. **Application status** changes from `Synced` to `OutOfSync`
5. **Auto-sync enabled** - ArgoCD automatically applies changes
6. **Monitor** in ArgoCD UI

## Access Application

The Gateway Service is exposed via NodePort.

Get the service port:
```bash
kubectl get svc gateway-service -o jsonpath='{.spec.ports[0].nodePort}'
```

Access at: `http://localhost:<nodePort>`

## Chart Values Reference

### Common Values Structure

Each chart supports:
- `replicaCount`: Number of replicas
- `image.repository`: Docker image repository
- `image.tag`: Image tag
- `image.pullPolicy`: Pull policy (IfNotPresent, Always)
- `service.type`: Service type (ClusterIP, NodePort, LoadBalancer)
- `service.port`: Service port
- `service.targetPort`: Target port in pod
- `resources.requests`: Resource requests
- `resources.limits`: Resource limits
- `env`: Array of environment variables

### Customization

Override values during installation:
```bash
helm install my-service auth-service/ \
  --set replicaCount=3 \
  --set image.tag=v2.0
```

Or with a custom values file:
```bash
helm install my-service auth-service/ -f custom-values.yaml
```

## Next Steps

1. ✅ Create Helm charts
2. ✅ Push to Git repository
3. ✅ Install ArgoCD
4. ✅ Create ArgoCD Application
5. Monitor and manage deployments via ArgoCD UI
6. Use GitOps workflow for continuous deployment
