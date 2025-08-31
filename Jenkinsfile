pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-cred')
        DOCKER_IMAGE = "deekshaganesh/bmsapp"
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
        PATH = "/usr/local/bin:/usr/bin:/bin:$PATH"  // Ensure Jenkins sees docker/kubectl/mvn/trivy
    }

    stages {
        stage('Debug Environment') {
            steps {
                sh 'echo $PATH'
                sh 'which docker || echo "docker not found"'
                sh 'which kubectl || echo "kubectl not found"'
                sh 'which trivy || echo "trivy not found"'
                sh 'which mvn || echo "mvn not found"'
            }
        }

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Deeksha-Ganesh/CI-CD-BMS.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn clean verify sonar:sonar'
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                sh 'trivy fs . > trivy-report.txt || true'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE:$BUILD_NUMBER .'
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
