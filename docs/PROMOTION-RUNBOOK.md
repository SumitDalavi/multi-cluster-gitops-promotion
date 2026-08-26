# GitOps Promotion Runbook

## Normal Promotion Flow
```
dev → staging: Automated on every main branch push
staging → production: Manual via workflow_dispatch with approval gate
```

## Manual Emergency Promotion
```bash
APP=myapp bash scripts/promote.sh staging production <sha>
```

## Rollback
```bash
# Update the overlay to the previous tag
sed -i "s|newTag:.*|newTag: "<previous-tag>"|" overlays/production/kustomization.yaml
git commit -am "revert: rollback production to <previous-tag>"
git push
# Argo CD auto-syncs within 3 minutes
```

## Promotion Gates
- Source environment must be Argo CD Healthy
- HTTP error rate < 1% over 5min window
- All pods in target Ready
