#!/bin/bash


kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.14.4


kubectl create ns actions-runner-system
helm upgrade --install actions-runner-controller actions-runner-controller/actions-runner-controller \
  --namespace actions-runner-system \
  --set syncPeriod=1m \
  --set githubWebhookServer.enabled=false \
  --set metrics.serviceMonitor.enabled=true


kubectl create secret generic controller-manager \
  -n actions-runner-system \
  --from-literal=github_token=<YOUR_GITHUB_PAT>

kubectl apply -f runner-deployment.yaml

kubectl get pods -n actions-runner-system
