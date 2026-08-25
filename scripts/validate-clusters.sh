#!/bin/bash
set -e

echo "Validating Dev cluster manifests..."
kubectl kustomize clusters/dev > /dev/null

echo "Validating Staging cluster manifests..."
kubectl kustomize clusters/staging > /dev/null

echo "Validating Prod cluster manifests..."
kubectl kustomize clusters/prod > /dev/null

echo "✅ All cluster manifests build successfully via Kustomize!"
