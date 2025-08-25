pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "deekshaganesh/bmswebsite"
    }
    stages {
        stage('Clone code') {
            steps {
                git branch: 'main', url: 'https://github.com/Deeksha-Ganesh/CI-CD-BMS.git'
            }
        }
        stage('Build docker image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE:latest .'
            }
        }
        stage('Login to docker hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub_cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
            }
        }
        stage('Push Docker image to docker hub') {
            steps {
                sh 'docker push $DOCKER_IMAGE:latest'
            }
        }
        stage('Deployment in kubernetes') {
            steps {
                withAWS(credentials: 'aws_cred', region: 'ap-south-1') {
                    sh '''
                        aws eks update-kubeconfig --name my-eks-cluster --region ap-south-1
                        kubectl set image deployment/bms-deployment bms-container=$DOCKER_IMAGE:latest
                        kubectl apply -f deployment.yaml
                        kubectl apply -f service.yaml
                    '''
                }
            }
        }
    }
}
