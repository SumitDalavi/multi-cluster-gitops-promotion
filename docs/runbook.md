# Runbook — multi-cluster-gitops-promotion
> Last updated: 2026-08-29

## Quick Start
```bash
# Bring up 2 clusters and deploy ArgoCD
kind create cluster --name dev-cluster
kind create cluster --name prod-cluster
kubectl config use-context kind-dev-cluster
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

## Run Tests / Demos
```bash
bash scripts/demo_multi_cluster_promotion.sh
```

## Failure Modes
| Symptom | Cause | Fix |
|---|---|---|
| ApplicationSet not generating apps | Target cluster secret missing labels | Ensure the secret registering `prod-cluster` has the correct `env=prod` labels |
