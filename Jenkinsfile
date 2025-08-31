pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-cred')  // DockerHub credentials ID in Jenkins
        DOCKER_IMAGE = "deekshaganesh/bmsapp"
        KUBECONFIG = '/var/lib/jenkins/.kube/config'            // Path to your kubeconfig
    }

    stage('Debug Environment') {
    steps {
        sh 'echo $PATH'
        sh 'which docker || echo "docker not found"'
        sh 'which kubectl || echo "kubectl not found"'
        sh 'which trivy || echo "trivy not found"'
        sh 'which mvn || echo "mvn not found"'
    }
}

    stages {
        stage('Checkout') {
            steps {
                // Checkout the main branch
                git branch: 'main', url: 'https://github.com/Deeksha-Ganesh/CI-CD-BMS.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                // Make sure 'SonarQube' server is configured in Jenkins
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn clean verify sonar:sonar'
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                // Scan the project files with Trivy
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
                    // Replace BUILD_NUMBER in deployment.yaml and apply
                    sh """
                        sed 's|\\\${BUILD_NUMBER}|$BUILD_NUMBER|g' k8s/deployment.yaml | kubectl apply -f -
                        kubectl apply -f k8s/service.yaml
                    """

                    // Wait for deployment rollout to finish
                    sh "kubectl rollout status deployment/bms-deployment"
                }
            }
        }
    }

    post {
        always {
            // Cleanup Docker images locally to save space
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
