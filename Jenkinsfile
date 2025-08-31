pipeline {
    agent any

    tools {
        jdk 'jdk21'
        nodejs 'nodejs23'
    }

    environment {
        SCANNER_HOME = tool 'Sonar-Scanner'
        DOCKER_IMAGE = 'deekshaganesh/bms:latest'
        EKS_CLUSTER_NAME = 'bms-cluster'
        AWS_REGION = 'us-east-1'
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
                sh 'ls -la'  // Verify files after checkout
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube-Server') {
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
                    waitForQualityGate abortPipeline: true, credentialsId: 'SonarQube'
                }
            }
        }

        stage('Install Dependencies') {
            steps {
