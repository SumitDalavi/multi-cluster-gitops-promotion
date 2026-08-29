#!/bin/bash
set -e

echo "================================================="
echo "🌍 Running Multi-Cluster GitOps Promotion Demo"
echo "================================================="

echo "1. Code Change: Updating image tag in Dev environment..."
echo "✅ Modified manifests/overlays/dev/kustomization.yaml (image: v2.0)"
echo "✅ Pushed to Git."

echo "2. ArgoCD Auto-Sync (Dev Cluster)..."
echo "✅ Detected drift on 'dev-app'. Auto-syncing..."
echo "✅ Dev Cluster is now running v2.0."

echo "3. Opening PR for Prod Promotion..."
echo "✅ PR Created: Promote v2.0 to Prod"
echo "✅ PR Merged to Main."

echo "4. ArgoCD Auto-Sync (Prod Cluster)..."
echo "✅ Detected drift on 'prod-app'. Auto-syncing..."
echo "✅ Prod Cluster is now running v2.0."

echo "5. Simulating Configuration Drift (Manual kubectl edit)..."
echo "✅ Manually changing replica count in Prod..."
echo "❌ ArgoCD detected OutOfSync (Drift detected)."

echo "6. Automated Drift Rollback..."
echo "✅ ArgoCD self-healed Prod cluster back to desired Git state (replicas: 5)."

echo "✅ Multi-Cluster GitOps Promotion pipeline simulated successfully."
