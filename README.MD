# minikube-cicd-boilerplate

A simple CI/CD setup using minikube, GitHub Actions, and ArgoCD. Nothing fancy, just works.

## What this does

- Pushes code to GitHub
- GitHub Actions builds a Docker image and pushes it to GitHub Container Registry
- ArgoCD watches the repo and deploys to minikube automatically
- You get a working web app at localhost:3000

## Prerequisites

You'll need these installed:

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

### 1. Start minikube

```bash
minikube start
minikube addons enable ingress
```

### 2. Install ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready (takes a few minutes)
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
```

### 3. Get ArgoCD password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 4. Access ArgoCD UI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Go to https://localhost:8080

- Username: admin
- Password: (the one you got from step 3)

### 5. Deploy the app

```bash
kubectl apply -f cd/argo-cd.yaml
```

### 6. Access your app

```bash
kubectl port-forward service/boilerplate-web 3000:80
```

Open http://localhost:3000 in your browser.

## How it works

The `app/` directory is a git submodule pointing to the actual application code. When you push changes:

1. GitHub Actions builds a Docker image
2. Pushes it to GitHub Container Registry
3. ArgoCD detects the change
4. Deploys the new image to minikube

## Troubleshooting

### Port already in use

```bash
lsof -i :8080
lsof -i :3000
# Kill the process if needed
```

### ArgoCD not syncing

```bash
kubectl get applications -n argocd
kubectl describe application boilerplate-web -n argocd
```

### App not working

```bash
kubectl get pods
kubectl logs -l app=boilerplate-web
kubectl describe service boilerplate-web
```

## Files

- `ci/github-action-workflow.yaml` - GitHub Actions workflow
- `cd/argo-cd.yaml` - ArgoCD application config
- `app/manifests/` - Kubernetes manifests (git submodule)
- `manifests/ingress.yaml` - Ingress config for external access

That's it. Pretty straightforward.
