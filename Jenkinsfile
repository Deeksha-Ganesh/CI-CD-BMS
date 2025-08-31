pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-cred')
        DOCKER_IMAGE = "deekshaganesh/bmsapp"
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
        PATH = "/usr/local/bin:/usr/bin:/bin:$PATH"  // Ensure Jenkins sees docker/kubectl/mvn/trivy/npm/node
    }

    stages {
        stage('Debug Environment') {
            steps {
                sh 'echo "PATH=$PATH"'
                sh 'which docker || echo "docker not found"'
                sh 'which kubectl || echo "kubectl not found"'
                sh 'which trivy || echo "trivy not found"'
                sh 'which mvn || echo "mvn not found"'
                sh 'which npm || echo "npm not found"'
                sh 'which node || echo "node not found"'
            }
        }

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Deeksha-Ganesh/CI-CD-BMS.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                dir('webapp') {
                    sh 'pwd && ls -la'
                    script {
                        try {
                            withSonarQubeEnv('SonarQube') {
                                sh '/usr/bin/mvn clean verify sonar:sonar'
                            }
                        } catch (err) {
                            echo "SonarQube analysis failed: ${err}"
                        }
                    }
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                dir('webapp') {
                    script {
                        try {
                            sh 'trivy fs . > trivy-report.txt || true'
                        } catch (err) {
                            echo "Trivy scan failed: ${err}"
                        }
                        archiveArtifacts artifacts: 'trivy-report.txt', allowEmptyArchive: true
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    try {
                        // Build Docker image with frontend build inside Dockerfile
                        sh 'docker build -t $DOCKER_IMAGE:$BUILD_NUMBER .'
                    } catch (err) {
                        echo "Docker build failed: ${err}"
                        error("Stopping pipeline because Docker build failed")
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                sh """
                    echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                    docker push $DOCKER_IMAGE:$BUILD_NUMBER
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh """
                        sed 's|\\\${BUILD_NUMBER}|$BUILD_NUMBER|g' k8s/deployment.yaml | kubectl apply -f -
                        kubectl apply -f k8s/service.yaml
                    """
                    sh "kubectl rollout status deployment/bms-deployment"
                }
            }
        }
    }

    post {
        always {
            sh "docker rmi $DOCKER_IMAGE:$BUILD_NUMBER || true"
        }
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed. Check logs for errors."
        }
    }
}
