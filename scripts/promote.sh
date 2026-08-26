#!/usr/bin/env bash
# Promote an image tag from one environment to the next
# Usage: ./scripts/promote.sh <from-env> <to-env> <image-tag>
set -euo pipefail

FROM_ENV="${1:?Usage: $0 <from-env> <to-env> <image-tag>}"
TO_ENV="${2:?}"
IMAGE_TAG="${3:?}"
APP="${APP:-myapp}"

log() { echo "[promote] $*"; }

OVERLAY_DIR="overlays/${TO_ENV}"
[[ -d "$OVERLAY_DIR" ]] || { log "ERROR: overlay dir $OVERLAY_DIR not found"; exit 1; }

log "Promoting $APP from $FROM_ENV → $TO_ENV (tag: $IMAGE_TAG)"

# Validate image exists and health check passed in source environment
bash scripts/validate-health.sh "$FROM_ENV" "$APP" || {
    log "FAIL: Health check failed in $FROM_ENV — promotion blocked"
    exit 1
}

# Update the image tag in the target overlay's kustomization
KUSTOMIZE_FILE="$OVERLAY_DIR/kustomization.yaml"
if grep -q "newTag:" "$KUSTOMIZE_FILE"; then
    sed -i "s|newTag:.*|newTag: "$IMAGE_TAG"|g" "$KUSTOMIZE_FILE"
else
    cat >> "$KUSTOMIZE_FILE" << EOF

images:
  - name: myapp
    newTag: "$IMAGE_TAG"
EOF
fi

log "Updated $KUSTOMIZE_FILE with tag: $IMAGE_TAG"

# Commit and push (Argo CD will sync automatically)
git config user.name  "GitOps Bot"
git config user.email "gitops@example.com"
git add "$KUSTOMIZE_FILE"
git commit -m "chore: promote $APP to $TO_ENV (tag: $IMAGE_TAG)" || { log "Nothing to commit"; exit 0; }
git push origin main

log "Promotion commit pushed. Argo CD will sync $TO_ENV shortly."
log "Watch: kubectl get applications -n argocd"
