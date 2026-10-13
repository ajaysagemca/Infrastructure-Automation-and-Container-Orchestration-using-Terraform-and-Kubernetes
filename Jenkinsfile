
pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        DOCKER_IMAGE_NAME = 'infrastructure-automation-kubernetes'

        // Replace with your Terraform EC2 public IP
        K8S_HOST = '172.31.41.245'

        // Replace with your Docker Hub username
        DOCKERHUB_USER = 'ajaysahu176'

        // Jenkins credential containing the matching EC2 private key
        SSH_CREDENTIAL_ID = 'k8s-ec2-key'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Python Unit Tests') {
            steps {
                sh '''
                    python3 -m venv .venv
                    .venv/bin/pip install -r app/requirements.txt
                    .venv/bin/pip install pytest
                    .venv/bin/python -m pytest app/test_app.py -v
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    env.IMAGE_TAG =
                        "${env.DOCKERHUB_USER}/${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                }

                sh '''
                    docker build -t "$IMAGE_TAG" ./app
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DH_USER',
                        passwordVariable: 'DH_TOKEN'
                    )
                ]) {
                    sh '''
                        echo "$DH_TOKEN" |
                            docker login -u "$DH_USER" --password-stdin

                        docker push "$IMAGE_TAG"

                        docker logout
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    if (env.K8S_HOST == 'REPLACE_WITH_EC2_PUBLIC_IP') {
                        error('Set K8S_HOST to your Terraform EC2 public IP')
                    }

                    if (env.DOCKERHUB_USER ==
                        'REPLACE_WITH_DOCKERHUB_USERNAME') {
                        error('Set DOCKERHUB_USER in Jenkinsfile')
                    }
                }

                sshagent(credentials: [env.SSH_CREDENTIAL_ID]) {
                    sh '''
                        set -eu

                        ssh -o StrictHostKeyChecking=no \
                            ubuntu@"$K8S_HOST" \
                            'mkdir -p ~/app'

                        sed "s|DOCKERHUB_USERNAME/infrastructure-automation-kubernetes:latest|$IMAGE_TAG|g" \
                            kubernetes/deployment.yaml > deployment-rendered.yaml

                        scp -o StrictHostKeyChecking=no \
                            deployment-rendered.yaml \
                            kubernetes/service.yaml \
                            ubuntu@"$K8S_HOST":~/app/

                        ssh -o StrictHostKeyChecking=no \
                            ubuntu@"$K8S_HOST" \
                            'kubectl apply -f ~/app/deployment-rendered.yaml &&
                             kubectl apply -f ~/app/service.yaml &&
                             kubectl rollout status deployment/flask-app --timeout=180s'

                        rm -f deployment-rendered.yaml
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'CI/CD pipeline completed successfully.'
            echo "Application: http://${K8S_HOST}:30080"
        }

        failure {
            echo 'Pipeline failed. Check the stage logs.'
        }

        always {
            sh 'rm -rf .venv || true'
        }
    }
}
