#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${1:?Usage: $0 <app-name> <target-env> <image-tag>}"
TARGET_ENV="${2:?Target environment required (dev|staging|prod)}"
IMAGE_TAG="${3:?Image tag required (e.g. v0.2.0)}"

echo "=== Promoting ${APP_NAME} to ${TARGET_ENV} with tag ${IMAGE_TAG} ==="

# Dynamically resolve overlay directory (Hub vs App repo)
if [[ -d "clusters/${TARGET_ENV}/${APP_NAME}" ]]; then
  OVERLAY_DIR="clusters/${TARGET_ENV}/${APP_NAME}"
elif [[ -d "deploy/k8s/overlays/${TARGET_ENV}" ]]; then
  OVERLAY_DIR="deploy/k8s/overlays/${TARGET_ENV}"
else
  echo "Error: Neither clusters/${TARGET_ENV}/${APP_NAME} nor deploy/k8s/overlays/${TARGET_ENV} exists."
  exit 1
fi

echo "Target overlay directory: ${OVERLAY_DIR}"

# 1. Update Kustomize image tag
cd "${OVERLAY_DIR}"
kustomize edit set image "ghcr.io/sumitdalavi/${APP_NAME}=ghcr.io/sumitdalavi/${APP_NAME}:${IMAGE_TAG}"

# 2. Validate Kustomize build
kustomize build . > /dev/null
echo "Kustomize build validation passed."

# 3. Display promotion diff
git status --short

echo "=== Promotion staged successfully for ${APP_NAME} (${TARGET_ENV} -> ${IMAGE_TAG}) ==="
