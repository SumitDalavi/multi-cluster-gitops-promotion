#!/usr/bin/env bash
# Validate that an application is healthy in a given environment before promotion
set -euo pipefail

ENV="${1:?Usage: $0 <environment> <app-name>}"
APP="${2:?}"
ARGO_NAMESPACE="${ARGO_NAMESPACE:-argocd}"
TIMEOUT="${HEALTH_TIMEOUT:-120}"

log() { echo "[validate] $*"; }

log "Checking health of $APP in $ENV..."

# Wait for Argo CD app to be Synced and Healthy
kubectl wait application "${APP}-${ENV}"     -n "$ARGO_NAMESPACE"     --for=jsonpath='{.status.health.status}'=Healthy     --timeout="${TIMEOUT}s" 2>/dev/null || {
    log "WARNING: Argo CD health check timed out — checking pod readiness..."
    READY=$(kubectl get deployment "$APP" -n "$ENV"         -o jsonpath='{.status.availableReplicas}' 2>/dev/null || echo "0")
    DESIRED=$(kubectl get deployment "$APP" -n "$ENV"         -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "1")
    [[ "$READY" -ge "$DESIRED" ]] || { log "FAIL: $APP in $ENV is not healthy ($READY/$DESIRED ready)"; exit 1; }
}

# Check error rate (requires Prometheus)
if command -v curl &>/dev/null && [[ -n "${PROMETHEUS_URL:-}" ]]; then
    ERROR_RATE=$(curl -sf "${PROMETHEUS_URL}/api/v1/query"         --data-urlencode "query=rate(http_requests_total{app="${APP}",namespace="${ENV}",status=~"5.."}[5m]) / rate(http_requests_total{app="${APP}",namespace="${ENV}"}[5m])"         | python3 -c "import json,sys; r=json.load(sys.stdin)['data']['result']; print(r[0]['value'][1] if r else '0')" 2>/dev/null || echo "0")
    MAX_ERROR_RATE="${MAX_ERROR_RATE:-0.01}"
    python3 -c "import sys; sys.exit(1 if float('$ERROR_RATE') > float('$MAX_ERROR_RATE') else 0)" || {
        log "FAIL: Error rate ${ERROR_RATE} exceeds threshold ${MAX_ERROR_RATE}"
        exit 1
    }
fi

log "PASS: $APP in $ENV is healthy"
