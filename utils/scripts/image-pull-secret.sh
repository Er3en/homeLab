#!/bin/bash
set -e

SECRET_NAME="regcred"
NAMESPACE="default"
REGION="eu-central-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGISTRY="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

echo "[+] Logging into ECR..."
aws ecr get-login-password --region $REGION | \
  docker login --username AWS --password-stdin $REGISTRY

echo "[+] Creating Kubernetes imagePullSecret..."
kubectl delete secret $SECRET_NAME --namespace $NAMESPACE --ignore-not-found
kubectl create secret generic $SECRET_NAME \
  --from-file=.dockerconfigjson=$HOME/.docker/config.json \
  --type=kubernetes.io/dockerconfigjson \
  --namespace $NAMESPACE

echo "[+] Done. Secret '$SECRET_NAME' refreshed in namespace '$NAMESPACE'."

### OR
aws ecr get-login-password --region eu-central-1 | \
kubectl create secret docker-registry regcred \
  --docker-server=<aws_account_id>.dkr.ecr.eu-central-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password-stdin

