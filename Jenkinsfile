pipeline {
    agent any

    triggers {
        pollSCM('H/5 * * * *')
    }

    environment {
        IMAGE_AUTH = 'tbg101/auth-service'
        IMAGE_DISCOVERY = 'tbg101/discovery-service'
        IMAGE_GATEWAY = 'tbg101/gateway-service'
        IMAGE_PRODUCT = 'tbg101/product-service'
        IMAGE_STOCK = 'tbg101/stock-service'
        GIT_REPO = 'git@gitlab.com/yourgroup/yourrepo.git' // ToChange - Update with your GitLab repo
        DOCKER_USERNAME = 'tbg101'
        HELM_NAMESPACE = 'default'
        KUBE_CONTEXT = 'minikube'  // Change if using different K8s context
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: '${GIT_REPO}',
                    credentialsId: 'gitlab_ssh' // ToChange
            }
        }

        stage('Build + Push AUTH-SERVICE') {
            when {
                changeset 'auth-service/**'
            }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub',
                    usernameVariable: 'DH_USER',
                    passwordVariable: 'DH_PASS'
                )]) {
                    sh '''
                        echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
                        docker build -t $IMAGE_AUTH:${BUILD_NUMBER} auth-service
                        docker push $IMAGE_AUTH:${BUILD_NUMBER}
                    '''
                }
            }
        }

        stage('Build + Push DISCOVERY-SERVICE') {
            when {
                changeset 'discovery-service/**'
            }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub',
                    usernameVariable: 'DH_USER',
                    passwordVariable: 'DH_PASS'
                )]) {
                    sh '''
                        echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
                        docker build -t $IMAGE_DISCOVERY:${BUILD_NUMBER} discovery-service
                        docker push $IMAGE_DISCOVERY:${BUILD_NUMBER}
                    '''
                }
            }
        }

        stage('Build + Push GATEWAY-SERVICE') {
            when {
                changeset 'gateway-service/**'
            }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub',
                    usernameVariable: 'DH_USER',
                    passwordVariable: 'DH_PASS'
                )]) {
                    sh '''
                        echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
                        docker build -t $IMAGE_GATEWAY:${BUILD_NUMBER} gateway-service
                        docker push $IMAGE_GATEWAY:${BUILD_NUMBER}
                    '''
                }
            }
        }

        stage('Build + Push PRODUCT-SERVICE') {
            when {
                changeset 'product-service/**'
            }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub',
                    usernameVariable: 'DH_USER',
                    passwordVariable: 'DH_PASS'
                )]) {
                    sh '''
                        echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
                        docker build -t $IMAGE_PRODUCT:${BUILD_NUMBER} product-service
                        docker push $IMAGE_PRODUCT:${BUILD_NUMBER}
                    '''
                }
            }
        }

        stage('Build + Push STOCK-SERVICE') {
            when {
                changeset 'stock-service/**'
            }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub',
                    usernameVariable: 'DH_USER',
                    passwordVariable: 'DH_PASS'
                )]) {
                    sh '''
                        echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
                        docker build -t $IMAGE_STOCK:${BUILD_NUMBER} stock-service
                        docker push $IMAGE_STOCK:${BUILD_NUMBER}
                    '''
                }
            }
        }

        stage('Deploy Database') {
            when {
                anyOf {
                    changeset 'helm-charts/mysql/**'
                    expression { currentBuild.number == 1 }
                }
            }
            steps {
                sh '''
                    kubectl config use-context $KUBE_CONTEXT
                    helm upgrade --install exam-mysql helm-charts/mysql/ \
                        --namespace $HELM_NAMESPACE \
                        --wait \
                        --timeout 5m
                    echo "✓ MySQL deployed"
                '''
            }
        }

        stage('Deploy Discovery Service') {
            when {
                anyOf {
                    changeset 'discovery-service/**'
                    changeset 'helm-charts/discovery-service/**'
                }
            }
            steps {
                sh '''
                    kubectl config use-context $KUBE_CONTEXT
                    helm upgrade --install exam-discovery helm-charts/discovery-service/ \
                        --namespace $HELM_NAMESPACE \
                        --set image.tag=${BUILD_NUMBER} \
                        --wait \
                        --timeout 5m
                    echo "✓ Discovery Service deployed"
                '''
            }
        }

        stage('Deploy Auth Service') {
            when {
                anyOf {
                    changeset 'auth-service/**'
                    changeset 'helm-charts/auth-service/**'
                }
            }
            steps {
                sh '''
                    kubectl config use-context $KUBE_CONTEXT
                    helm upgrade --install exam-auth helm-charts/auth-service/ \
                        --namespace $HELM_NAMESPACE \
                        --set image.tag=${BUILD_NUMBER} \
                        --wait \
                        --timeout 5m
                    echo "✓ Auth Service deployed"
                '''
            }
        }

        stage('Deploy Gateway Service') {
            when {
                anyOf {
                    changeset 'gateway-service/**'
                    changeset 'helm-charts/gateway-service/**'
                }
            }
            steps {
                sh '''
                    kubectl config use-context $KUBE_CONTEXT
                    helm upgrade --install exam-gateway helm-charts/gateway-service/ \
                        --namespace $HELM_NAMESPACE \
                        --set image.tag=${BUILD_NUMBER} \
                        --wait \
                        --timeout 5m
                    echo "✓ Gateway Service deployed"
                '''
            }
        }

        stage('Deploy Product Service') {
            when {
                anyOf {
                    changeset 'product-service/**'
                    changeset 'helm-charts/product-service/**'
                }
            }
            steps {
                sh '''
                    kubectl config use-context $KUBE_CONTEXT
                    helm upgrade --install exam-product helm-charts/product-service/ \
                        --namespace $HELM_NAMESPACE \
                        --set image.tag=${BUILD_NUMBER} \
                        --wait \
                        --timeout 5m
                    echo "✓ Product Service deployed"
                '''
            }
        }

        stage('Deploy Stock Service') {
            when {
                anyOf {
                    changeset 'stock-service/**'
                    changeset 'helm-charts/stock-service/**'
                }
            }
            steps {
                sh '''
                    kubectl config use-context $KUBE_CONTEXT
                    helm upgrade --install exam-stock helm-charts/stock-service/ \
                        --namespace $HELM_NAMESPACE \
                        --set image.tag=${BUILD_NUMBER} \
                        --wait \
                        --timeout 5m
                    echo "✓ Stock Service deployed"
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    kubectl config use-context $KUBE_CONTEXT
                    echo "=== Helm Releases ==="
                    helm list -n $HELM_NAMESPACE
                    echo ""
                    echo "=== Kubernetes Pods ==="
                    kubectl get pods -n $HELM_NAMESPACE
                    echo ""
                    echo "=== Service Status ==="
                    kubectl get svc -n $HELM_NAMESPACE
                '''
            }
        }

        stage('Trigger ArgoCD Sync (Optional)') {
            when {
                branch 'main'
            }
            steps {
                sh '''
                    # Optional: Trigger ArgoCD to sync if installed
                    if kubectl get namespace argocd 2>/dev/null; then
                        argocd app sync exam-app --prune || true
                        echo "✓ ArgoCD sync triggered"
                    else
                        echo "ℹ ArgoCD not installed, skipping sync"
                    fi
                '''
            }
        }
    }

    post {
        always {
            sh 'docker system prune -af || true'
        }
    }
}
