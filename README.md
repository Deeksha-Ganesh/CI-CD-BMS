## CI-CD-BMS Project

This project demonstrates a complete CI/CD pipeline for a web application using Jenkins, Docker, Kubernetes, SonarQube, and Trivy.

## Overview

The CI/CD pipeline automates the following steps:
Checkout code from GitHub
Static code analysis with SonarQube
Security scanning using Trivy
Frontend build using Node.js and NPM
Docker image creation and push to DockerHub
Deployment to a Kubernetes cluster

## Prerequisites

Jenkins server with Docker and Kubernetes CLI installed
Node.js and NPM installed on Jenkins agent
SonarQube server accessible by Jenkins
DockerHub account
Kubernetes cluster (EKS)
Proper permissions to deploy applications in Kubernetes

## Pipeline Overview

The pipeline stages:
Debug Environment – Checks paths and tools availability (docker, kubectl, npm, node, mvn, trivy)
Checkout – Pulls the latest code from the GitHub repository
SonarQube Analysis – Runs Maven build and pushes code quality report to SonarQube
Trivy Scan – Scans project for vulnerabilities and archives the report
Build Frontend – Installs dependencies and builds the frontend using Node.js
Build Docker Image – Creates a Docker image tagged with Jenkins BUILD_NUMBER
Push Docker Image – Pushes the Docker image to DockerHub
Deploy to Kubernetes – Updates deployment and service in Kubernetes and waits for rollout

<img width="1860" height="932" alt="image" src="https://github.com/user-attachments/assets/d0acc630-b170-47d7-b26a-19138f3d030b" />


