#!/bin/bash
echo "Starting minikube CI/CD setup..."

echo "Starting minikube..."
minikube start
minikube addons enable ingress

echo "Installing ArgoCD..."
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

echo "Deploying infrastructure and applications..."
kubectl apply -f argocd-apps/

echo "ArgoCD password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""

echo "Setup complete!"
echo "To access ArgoCD UI: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "To access your app: kubectl port-forward service/boilerplate-web 3000:80"
