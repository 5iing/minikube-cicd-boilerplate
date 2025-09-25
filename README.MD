# minikube-cicd-boilerplate

A simple GitOps template for minikube using ArgoCD and GitHub Actions. Nothing fancy, just works.

## What this does

- CI: GitHub Actions builds and pushes Docker images to GHCR
- CD: ArgoCD watches this repo and deploys to minikube
- Infra: Ingress and namespaces are managed under `infrastructure/`
- Apps: Business apps and monitoring (Prometheus + Grafana) are under `apps/`

## Prerequisites

- Docker
- minikube
- kubectl
- git

## Quick start

### Option 1: Run the script

```bash
./run.sh
```

### Option 2: Manual setup

1. Start minikube and enable ingress

```bash
minikube start
minikube addons enable ingress
```

2. Install ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
```

3. Apply ArgoCD applications (infra + apps)

```bash
kubectl apply -f argocd-apps/
```

## Accessing services

- Add hosts (replace with your `minikube ip`):

```
192.168.49.2 boilerplate-dev.local grafana.local prometheus.local
```

- App via ingress: http://boilerplate-dev.local
- Prometheus: http://prometheus.local
- Grafana: http://grafana.local (admin/admin on first login)

- ArgoCD (via port-forward):

```bash
kubectl port-forward -n argocd svc/argocd-server 8080:443
# open https://localhost:8080
```

Get admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
```

## Troubleshooting (ingress)

- Host mapping:

```bash
echo "$(minikube ip) boilerplate-dev.local grafana.local prometheus.local" | sudo tee -a /etc/hosts
```

- Check routes:

```bash
kubectl describe ingress -n default boilerplate-web | sed -n '1,120p'
kubectl describe ingress -n monitoring monitoring-ingress | sed -n '1,120p'
```

- Endpoints must exist:

```bash
kubectl get ep -n default boilerplate-web
kubectl get ep -n monitoring grafana prometheus
```
