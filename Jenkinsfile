pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 1, unit: 'HOURS')
        timestamps()
    }

    environment {
        // Docker Hub credentials (configure in Jenkins: Manage Jenkins > Credentials)
        DOCKER_HUB_REGISTRY = 'docker.io'
        DOCKER_HUB_USERNAME = credentials('docker-hub-username')
        DOCKER_HUB_PASSWORD = credentials('docker-hub-password')
        
        // Image configuration
        REGISTRY_URL = 'docker.io'
        IMAGE_PREFIX = "${DOCKER_HUB_USERNAME}"
        BUILD_TAG = "${BUILD_NUMBER}-${GIT_COMMIT.take(7)}"
        LATEST_TAG = 'latest'
        
        // Trivy configuration
        TRIVY_SEVERITY = 'HIGH,CRITICAL'
        TRIVY_EXIT_CODE = '0'
        
        // Services to build
        SERVICES = 'auth-service,discovery-service,gateway-service,product-service,stock-service'
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    echo "Checking out source code..."
                    checkout scm
                    echo "Git Commit: ${GIT_COMMIT}"
                    echo "Git Branch: ${GIT_BRANCH}"
                }
            }
        }

        stage('Pre-build Validation') {
            steps {
                script {
                    echo "Validating environment and dependencies..."
                    sh '''
                        echo "Docker version:"
                        docker --version
                        echo "Trivy version:"
                        trivy --version || echo "Trivy not installed, will be used via Docker"
                        echo "Jenkins workspace: ${WORKSPACE}"
                    '''
                }
            }
        }

        stage('Build Docker Images') {
            parallel {
                stage('Build Auth Service') {
                    steps {
                        script {
                            buildService('auth-service')
                        }
                    }
                }
                stage('Build Discovery Service') {
                    steps {
                        script {
                            buildService('discovery-service')
                        }
                    }
                }
                stage('Build Gateway Service') {
                    steps {
                        script {
                            buildService('gateway-service')
                        }
                    }
                }
                stage('Build Product Service') {
                    steps {
                        script {
                            buildService('product-service')
                        }
                    }
                }
                stage('Build Stock Service') {
                    steps {
                        script {
                            buildService('stock-service')
                        }
                    }
                }
            }
        }

        stage('Security Scan with Trivy') {
            parallel {
                stage('Scan Auth Service') {
                    steps {
                        script {
                            scanImage('auth-service')
                        }
                    }
                }
                stage('Scan Discovery Service') {
                    steps {
                        script {
                            scanImage('discovery-service')
                        }
                    }
                }
                stage('Scan Gateway Service') {
                    steps {
                        script {
                            scanImage('gateway-service')
                        }
                    }
                }
                stage('Scan Product Service') {
                    steps {
                        script {
                            scanImage('product-service')
                        }
                    }
                }
                stage('Scan Stock Service') {
                    steps {
                        script {
                            scanImage('stock-service')
                        }
                    }
                }
            }
        }

        stage('Login to Docker Hub') {
            steps {
                script {
                    echo "Logging in to Docker Hub..."
                    sh '''
                        echo "${DOCKER_HUB_PASSWORD}" | docker login -u "${DOCKER_HUB_USERNAME}" --password-stdin ${DOCKER_HUB_REGISTRY}
                        echo "Successfully authenticated with Docker Hub"
                    '''
                }
            }
        }

        stage('Push to Docker Hub') {
            parallel {
                stage('Push Auth Service') {
                    steps {
                        script {
                            pushImage('auth-service')
                        }
                    }
                }
                stage('Push Discovery Service') {
                    steps {
                        script {
                            pushImage('discovery-service')
                        }
                    }
                }
                stage('Push Gateway Service') {
                    steps {
                        script {
                            pushImage('gateway-service')
                        }
                    }
                }
                stage('Push Product Service') {
                    steps {
                        script {
                            pushImage('product-service')
                        }
                    }
                }
                stage('Push Stock Service') {
                    steps {
                        script {
                            pushImage('stock-service')
                        }
                    }
                }
            }
        }

        stage('Generate Scan Reports') {
            steps {
                script {
                    echo "Generating Trivy scan reports..."
                    sh '''
                        mkdir -p ${WORKSPACE}/trivy-reports
                        for service in ${SERVICES//,/ }; do
                            if [ -f "${WORKSPACE}/trivy-${service}.json" ]; then
                                cp "${WORKSPACE}/trivy-${service}.json" "${WORKSPACE}/trivy-reports/"
                                echo "Generated report for ${service}"
                            fi
                        done
                    '''
                }
            }
        }
    }

    post {
        always {
            script {
                echo "Performing cleanup..."
                sh '''
                    # Logout from Docker Hub
                    docker logout ${DOCKER_HUB_REGISTRY} || true
                    
                    # Clean up dangling images
                    docker image prune -f || true
                '''
                
                // Archive Trivy reports
                archiveArtifacts artifacts: 'trivy-reports/*.json', allowEmptyArchive: true
            }
        }

        success {
            script {
                echo "Build completed successfully!"
                // Send success notification (configure as needed)
                sh '''
                    echo "All services built, scanned, and pushed successfully!"
                    echo "Images are available at: ${REGISTRY_URL}/${IMAGE_PREFIX}/<service>:${BUILD_TAG}"
                    echo "Images are available at: ${REGISTRY_URL}/${IMAGE_PREFIX}/<service>:${LATEST_TAG}"
                '''
            }
        }

        failure {
            script {
                echo "Build failed! Check logs for details."
                // Send failure notification (configure as needed)
            }
        }

        unstable {
            script {
                echo "Build is unstable. Review Trivy scan results."
            }
        }

        cleanup {
            deleteDir()
        }
    }
}

// Function to build Docker image for a service
def buildService(String serviceName) {
    echo "Building Docker image for ${serviceName}..."
    sh '''
        cd ${WORKSPACE}/${serviceName}
        docker build \
            --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
            --build-arg VCS_REF=${GIT_COMMIT} \
            --build-arg VERSION=${BUILD_TAG} \
            -t ${REGISTRY_URL}/${IMAGE_PREFIX}/${serviceName}:${BUILD_TAG} \
            -t ${REGISTRY_URL}/${IMAGE_PREFIX}/${serviceName}:${LATEST_TAG} \
            -f Dockerfile .
        echo "Successfully built ${serviceName}:${BUILD_TAG}"
    '''
}

// Function to scan image with Trivy
def scanImage(String serviceName) {
    echo "Scanning ${serviceName} with Trivy..."
    sh '''
        docker run --rm \
            -v /var/run/docker.sock:/var/run/docker.sock \
            -v ${WORKSPACE}/trivy-reports:/root/.cache/trivy \
            aquasec/trivy:latest image \
            --severity ${TRIVY_SEVERITY} \
            --format json \
            --output ${WORKSPACE}/trivy-${serviceName}.json \
            ${REGISTRY_URL}/${IMAGE_PREFIX}/${serviceName}:${BUILD_TAG}
        
        # Display scan results
        echo "=== Scan results for ${serviceName} ==="
        docker run --rm \
            -v /var/run/docker.sock:/var/run/docker.sock \
            aquasec/trivy:latest image \
            --severity ${TRIVY_SEVERITY} \
            ${REGISTRY_URL}/${IMAGE_PREFIX}/${serviceName}:${BUILD_TAG}
    '''
}

// Function to push image to Docker Hub
def pushImage(String serviceName) {
    echo "Pushing ${serviceName} to Docker Hub..."
    sh '''
        echo "Pushing ${serviceName}:${BUILD_TAG}..."
        docker push ${REGISTRY_URL}/${IMAGE_PREFIX}/${serviceName}:${BUILD_TAG}
        
        echo "Pushing ${serviceName}:${LATEST_TAG}..."
        docker push ${REGISTRY_URL}/${IMAGE_PREFIX}/${serviceName}:${LATEST_TAG}
        
        echo "Successfully pushed ${serviceName} to Docker Hub"
    '''
}
