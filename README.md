# Spring Boot Microservices DevOps Project

This project demonstrates a complete DevOps lifecycle for a Spring Boot microservices application, including containerisation, CI/CD, Kubernetes deployment, and monitoring.

## Architecture
The application consists of the following microservices:
- **Discovery Service** (Eureka)
- **Gateway Service** (Spring Cloud Gateway)
- **Auth Service** (Authentication & JWT)
- **Product Service**
- **Stock Service**
- **MySQL Database**

## Prerequisites
- Java 17
- Maven 3.8+
- Docker & Docker Compose
- Kubernetes Cluster (Docker Desktop, Minikube, etc.)
- Helm 3+
- Jenkins (for CI/CD)
- ArgoCD (optional, for GitOps)

## Build & Run Locally (Docker Compose)
1. **Build the project:**
   ```bash
   mvn clean package -DskipTests
   ```
2. **Run with Docker Compose:**
   ```bash
   docker-compose up --build
   ```
3. **Access the application:**
   - Gateway: http://localhost:8888
   - Discovery Server: http://localhost:8761

## CI/CD Pipeline (Jenkins)
A `Jenkinsfile` is provided in the root directory.

### 1. Configure Credentials
1. Go to **Manage Jenkins** > **Credentials**.
2. Add a new **Username with password** credential.
3. **ID**: `docker-hub-credentials` (Must match the ID in `Jenkinsfile`).
4. **Username**: `tbg101`
5. **Password**: Your Docker Hub password or access token.

### 2. Create Pipeline Job
1. Click **New Item**.
2. Enter name: `spring-microservices`.
3. Select **Pipeline** and click **OK**.
4. Scroll to **Pipeline** section.
5. **Definition**: Select `Pipeline script from SCM`.
6. **SCM**: Select `Git`.
7. **Repository URL**: `https://github.com/TBG101/spring-micro-service.git`
8. **Branch Specifier**: `*/main` (or `*/master` depending on your default branch).
9. **Script Path**: `Jenkinsfile`.
10. Click **Save** and **Build Now**.

## Kubernetes Deployment
### Option 1: Plain Manifests
Deploy using standard Kubernetes manifests:
```bash
kubectl apply -f k8s/mysql.yaml
kubectl apply -f k8s/discovery-service.yaml
kubectl apply -f k8s/gateway-service.yaml
kubectl apply -f k8s/auth-service.yaml
kubectl apply -f k8s/product-service.yaml
kubectl apply -f k8s/stock-service.yaml
```

### Option 2: Helm Chart
Deploy using the custom Helm chart:
```bash
helm install spring-microservices ./helm/spring-microservices
```

### Option 3: ArgoCD (GitOps)
1. Install ArgoCD.
2. Apply the Application manifest:
   ```bash
   kubectl apply -f argocd/application.yaml
   ```

## Monitoring & Observability
Deploy Prometheus and Grafana:
```bash
kubectl apply -f monitoring/prometheus.yaml
kubectl apply -f monitoring/grafana.yaml
```
- **Prometheus**: http://localhost:30090
- **Grafana**: http://localhost:30000 (Default login: admin/admin)

## Testing
- Verify pods are running: `kubectl get pods`
- Check logs: `kubectl logs -f <pod-name>`
- Access endpoints via Gateway or NodePorts.
