#!/bin/bash
set -euxo pipefail

exec > >(tee -a /var/log/user-data.log) 2>&1

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  git \
  docker.io

systemctl enable --now docker

usermod -aG docker ubuntu

# Install kubectl
KUBECTL_VERSION=$(curl -fsSL \
  https://dl.k8s.io/release/stable.txt)

curl -fsSLo /usr/local/bin/kubectl \
  "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

chmod +x /usr/local/bin/kubectl

# Install Kind
curl -fsSLo /usr/local/bin/kind \
  https://kind.sigs.k8s.io/dl/v0.29.0/kind-linux-amd64

chmod +x /usr/local/bin/kind

# Wait for Docker
for i in $(seq 1 30); do
  if docker info >/dev/null 2>&1; then
    break
  fi
  sleep 5
done

# Configure Kind NodePort access
cat > /home/ubuntu/kind-config.yaml <<'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 30080
        hostPort: 30080
        protocol: TCP
EOF

chown ubuntu:ubuntu /home/ubuntu/kind-config.yaml

# Create the Kubernetes cluster as ubuntu
sudo -u ubuntu -H bash -c '
  kind create cluster \
    --name devops \
    --config /home/ubuntu/kind-config.yaml
'

# Verify cluster access
sudo -u ubuntu -H kubectl \
  --context kind-devops \
  get nodes

echo "Docker, kubectl and Kind setup completed."