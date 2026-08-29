# Decisions

## ADR-001: Kustomize over Helm for Environment Patches
**Date:** 2026-08-29  
**Status:** Accepted

**Context:**  
We need a way to customize deployments between Dev and Prod without maintaining duplicate YAML.

**Decision:**  
We chose Kustomize overlays over Helm templates.

**Consequences:**  
- ✅ Strictly declarative overlays (`kustomization.yaml`) are easier to audit in a GitOps workflow.
- ✅ Prevents the "spaghetti template" problem of Helm charts with hundreds of `if/else` statements.
- ⚠️ Less dynamic than Helm for complex chart composition.
