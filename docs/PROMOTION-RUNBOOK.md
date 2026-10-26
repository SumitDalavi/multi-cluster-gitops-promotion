# GitOps Promotion Runbook (v0.2.1)

## Normal Promotion Flow
```
dev → staging: Automated on main branch push via ArgoCD selfHeal
staging → production: Gated PR promotion with manual review & approval gate
```

## Catalog Automated Promotion CLI
Use the standardized promotion script to promote any catalog microservice between cluster tiers:
```bash
# Promote a specific microservice from staging to production
APP=rate-limiter-service bash scripts/promote.sh staging prod v0.2.0

# Promote an OCI Helm platform component
APP=k8s-golden-path-provisioner bash scripts/promote.sh dev staging v0.2.0
```

## Centralized Overlay Structure
Overlays are centrally maintained in `clusters/{dev,staging,prod}/<service-name>/`:
```
clusters/
├── dev/        # kubernetes.default.svc (automated selfHeal)
├── staging/    # staging-k8s:6443 (automated selfHeal)
└── prod/       # prod-k8s:6443 (manual sync / gated PR)
```

## Rollback Procedure
```bash
# Update the target service overlay image tag to previous stable version
cd clusters/prod/<service-name>
kustomize edit set image ghcr.io/sumitdalavi/<service-name>=ghcr.io/sumitdalavi/<service-name>:<previous-tag>
git commit -am "revert: rollback <service-name> in prod to <previous-tag>"
git push origin master
# Argo CD synchronizes and verifies zero-drift
```

## Promotion Verification Gates
- Source environment Application status is `Healthy` and `Synced`
- HTTP 5xx error budget consumption < 0.5% over 5-minute window
- All Spoke pods report 100% Ready status
