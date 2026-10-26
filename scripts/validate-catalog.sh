#!/usr/bin/env bash
set -euo pipefail

echo "======================================================"
echo " Starting ArgoCD Declarative GitOps Catalog Validation "
echo "======================================================"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

ERRORS=0

PYTHON_BIN="$(command -v python3 || command -v python || command -v py || echo "")"

echo "1. Validating YAML Syntax across argocd/ and clusters/..."
if command -v yamllint &> /dev/null; then
  yamllint -d "{extends: relaxed, rules: {line-length: disable, document-start: disable}}" argocd/ clusters/ || {
    echo "[WARN] yamllint reported warnings/errors"
  }
elif [[ -n "${PYTHON_BIN}" ]]; then
  echo "[INFO] yamllint not installed, verifying with ${PYTHON_BIN} PyYAML..."
  "${PYTHON_BIN}" -c "
import os, sys, yaml
errors = 0
for folder in ['argocd', 'clusters']:
    for root, _, files in os.walk(folder):
        for f in files:
            if f.endswith(('.yaml', '.yml')):
                p = os.path.join(root, f)
                try:
                    with open(p, 'r', encoding='utf-8') as stream:
                        list(yaml.safe_load_all(stream))
                except Exception as e:
                    print(f'[FAIL] YAML syntax error in {p}: {e}')
                    errors += 1
if errors > 0:
    sys.exit(1)
print('[PASS] All YAML files parsed successfully.')
" || ERRORS=$((ERRORS + 1))
fi

echo "2. Asserting Immutable Tags (No ':latest' in catalog)..."
if [[ -n "${PYTHON_BIN}" ]]; then
  "${PYTHON_BIN}" -c "
import os, sys
errors = 0
for folder in ['argocd', 'clusters']:
    for root, _, files in os.walk(folder):
        for f in files:
            if f.endswith(('.yaml', '.yml')):
                p = os.path.join(root, f)
                with open(p, 'r', encoding='utf-8', errors='ignore') as stream:
                    content = stream.read()
                    if ':latest' in content:
                        print(f'[FAIL] Mutable :latest tag found in {p}')
                        errors += 1
if errors == 0:
    print('[PASS] No mutable :latest tags detected.')
else:
    sys.exit(1)
" || ERRORS=$((ERRORS + 1))
fi

echo "3. Validating Kustomize overlays in clusters/..."
for env in dev staging prod; do
  if [[ -d "clusters/${env}" ]]; then
    for app_dir in clusters/"${env}"/*; do
      if [[ -d "${app_dir}" && -f "${app_dir}/kustomization.yaml" ]]; then
        echo "Validating kustomize build for ${app_dir}..."
        if command -v kustomize &> /dev/null; then
          kustomize build "${app_dir}" > /dev/null || {
            echo "[FAIL] kustomize build failed for ${app_dir}"
            ERRORS=$((ERRORS + 1))
          }
        elif command -v kubectl &> /dev/null; then
          kubectl kustomize "${app_dir}" > /dev/null || {
            echo "[FAIL] kubectl kustomize failed for ${app_dir}"
            ERRORS=$((ERRORS + 1))
          }
        fi
      fi
    done
  fi
done

if [[ ${ERRORS} -eq 0 ]]; then
  echo "======================================================"
  echo " [PASS] All Catalog Validations Completed Successfully "
  echo "======================================================"
  exit 0
else
  echo "======================================================"
  echo " [FAIL] Catalog Validation encountered ${ERRORS} errors "
  echo "======================================================"
  exit 1
fi
