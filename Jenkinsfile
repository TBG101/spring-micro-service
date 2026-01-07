pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = 'tbg101'
        // Make sure to configure this credential in Jenkins
        DOCKER_CREDENTIALS_ID = 'docker-hub-credentials'
    }

    stages {
        stage('Build Maven') {
            steps {
                sh 'chmod +x mvnw'
                sh './mvnw clean package -DskipTests'
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    def services = ['discovery-service', 'gateway-service', 'auth-service', 'product-service', 'stock-service']
                    services.each { service ->
                        echo "Building ${service}..."
                        sh "docker build -t ${DOCKER_HUB_REPO}/${service}:latest ./${service}"
                    }
                }
            }
        }

        stage('Vulnerability Scan (Trivy)') {
            steps {
                script {
                    def services = ['discovery-service', 'gateway-service', 'auth-service', 'product-service', 'stock-service']
                    services.each { service ->
                        echo "Scanning ${service}..."
                        // Using aquasec/trivy image to scan
                        sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image --no-progress --exit-code 0 --severity HIGH,CRITICAL ${DOCKER_HUB_REPO}/${service}:latest"
                    }
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                        def services = ['discovery-service', 'gateway-service', 'auth-service', 'product-service', 'stock-service']
                        services.each { service ->
                            echo "Pushing ${service}..."
                            sh "docker push ${DOCKER_HUB_REPO}/${service}:latest"
                        }
                    }
                }
            }
        }
    }

}
