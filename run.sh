#!/bin/bash
echo "Starting minikube CI/CD setup..."

echo "Starting minikube..."
minikube start
minikube addons enable ingress

echo "Installing ArgoCD..."
kubectl create namespace argocd || true
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

echo "Deploying infrastructure and applications..."
kubectl apply -f argocd-apps/

IP=$(minikube ip)
echo ""
echo "Add these to /etc/hosts (if not already):"
echo "$IP boilerplate-dev.local grafana.local prometheus.local"
echo ""

echo "ArgoCD password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo ""

echo "Setup complete!"
echo "ArgoCD (port-forward):  kubectl port-forward -n argocd svc/argocd-server 8080:443  # https://localhost:8080"
echo "App via Ingress:       http://boilerplate-dev.local"
echo "Prometheus via Ingress: http://prometheus.local"
echo "Grafana via Ingress:    http://grafana.local (admin/admin)"
