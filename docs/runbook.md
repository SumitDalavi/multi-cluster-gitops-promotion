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


---

## Release Runbook

### Release Trigger
Tag push matching `v*.*.*` (e.g., `v0.1.0`).

### Automated Pipeline Stages
1. **Quality & Validation Gate:** Validates policy syntax, manifest schemas, and configuration integrity.
2. **Distribution Packaging:** Bundles clean production manifests into `multi-cluster-gitops-promotion-<tag>.tar.gz` and calculates SHA256 checksums.
3. **Syft Source SBOM:** Generates `sbom.spdx.json` adhering to SPDX 2.3 standard.
4. **GitHub Release:** Publishes release assets and release notes.

### Verification
```bash
gh release view v0.1.0 --repo SumitDalavi/multi-cluster-gitops-promotion
gh release download v0.1.0 --repo SumitDalavi/multi-cluster-gitops-promotion --pattern "checksums.txt"
```

### Failure Modes & Remediation
- **Linter / Test Failure:** Inspect policy syntax, configurations, or module arguments locally before tagging.
- **Checksum Mismatch:** Ensure file was completely downloaded without network truncation.
