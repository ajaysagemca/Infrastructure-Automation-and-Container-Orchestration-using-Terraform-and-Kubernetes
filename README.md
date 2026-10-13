# Infrastructure Automation and Container Orchestration

## Project Overview

This project automates AWS infrastructure provisioning using
Terraform and deploys a Python Flask application using Docker,
Jenkins, and Kubernetes.

## Technologies

- AWS EC2
- Terraform
- Linux / Ubuntu
- Python and Flask
- Pytest
- Docker
- Jenkins CI/CD
- Kubernetes
- Kind
- Git and GitHub

## Architecture

1. Terraform provisions an AWS EC2 instance.
2. EC2 user data installs Docker, kubectl, and Kind.
3. Jenkins checks out the GitHub repository.
4. Jenkins runs Python unit tests.
5. Jenkins builds and pushes a Docker image to Docker Hub.
6. Jenkins connects to EC2 over SSH.
7. Kubernetes deploys the application.
8. The application is exposed using a NodePort service.

## Prerequisites

- AWS account and configured AWS CLI credentials
- Terraform
- Git
- Docker Hub account
- Jenkins with Docker, Python, and SSH available on its agent
- Jenkins SSH Agent plugin
- Jenkins Docker Hub credentials

## Terraform

```bash
cd terraform
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply