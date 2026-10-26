#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${1:-gitops-hub}"
ARGOCD_VERSION="${ARGOCD_VERSION:-v2.10.0}"

echo "=== Bootstrapping ArgoCD GitOps Hub on Kind (${CLUSTER_NAME}) ==="

# 1. Create Kind cluster if not already running
if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
  cat <<EOF | kind create cluster --name "${CLUSTER_NAME}" --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 30080
        hostPort: 8080
        protocol: TCP
      - containerPort: 30443
        hostPort: 8443
        protocol: TCP
EOF
  echo "[PASS] Kind cluster ${CLUSTER_NAME} created."
else
  echo "[INFO] Kind cluster ${CLUSTER_NAME} already exists."
fi

# 2. Install ArgoCD
echo "Installing ArgoCD ${ARGOCD_VERSION}..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f "https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"

echo "Waiting for ArgoCD server deployment..."
kubectl rollout status deployment/argocd-server -n argocd --timeout=180s

# 3. Bootstrap Master Root Application
echo "Deploying Root App-of-Apps..."
kubectl apply -f argocd/root-application.yaml

echo "=== ArgoCD GitOps Hub Bootstrap Complete ==="
echo "Access UI: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "Initial admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo ""
