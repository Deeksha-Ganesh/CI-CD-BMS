pipeline {
    agent any

    tools {
        jdk 'jdk21'
    }

    environment {
        SCANNER_HOME     = tool 'sonar-scanner'
        DOCKER_IMAGE     = 'deeksha-ganesh/bms:latest'
        EKS_CLUSTER_NAME = 'bms-cluster'
        AWS_REGION       = 'us-east-1'
    }

    stages {

        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout from Git') {
            steps {
                git branch: 'main', url: 'https://github.com/Deeksha-Ganesh/CI-CD-BMS.git'
                sh 'ls -la'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh '''
                        $SCANNER_HOME/bin/sonar-scanner \
                            -Dsonar.projectName=BMS \
                            -Dsonar.projectKey=BMS
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('OWASP FS Scan') {
            steps {
                dependencyCheck additionalArguments: '--scan ./', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }

        stage('Trivy FS Scan') {
            steps {
                sh 'trivy fs . > trivy-fs.txt || true'
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker', toolName: 'docker') {
                        sh '''
                            echo "Building Docker image..."
                            docker build --no-cache -t $DOCKER_IMAGE .

                            echo "Pushing Docker image to Docker Hub..."
                            docker push $DOCKER_IMAGE
                        '''
                    }
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh "trivy image $DOCKER_IMAGE > trivy-image.txt || true"
            }
        }

        stage('Deploy to EKS Cluster') {
            steps {
                script {
                    sh '''
                        echo "Verifying AWS credentials..."
                        aws sts get-caller-identity

                        echo "Configuring kubectl for EKS cluster..."
                        aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --region $AWS_REGION

                        echo "Deploying application to EKS..."
                        kubectl apply -f deployment.yaml
                        kubectl apply -f service.yaml

                        echo "Verifying deployment..."
                        kubectl get pods -o wide
                        kubectl get svc
                    '''
                }
            }
        }
    }

    post {
        always {
            emailext attachLog: true,
                subject: "'${currentBuild.result}' - Build #${env.BUILD_NUMBER}",
                body: "Project: ${env.JOB_NAME}<br/>" +
                      "Build Number: ${env.BUILD_NUMBER}<br/>" +
                      "URL: ${env.BUILD_URL}<br/>",
                to: 'deekshanidhi218@gmail.com',
                attachmentsPattern: 'trivy-*.txt'
        }
    }
}
