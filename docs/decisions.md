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

## ADR-002: Multi-Tier Verification & OCI Dual Distribution
- **Context:** Declarative infrastructure and policy catalogs required robust local simulation gates without imposing cloud provider dependencies or credentials during CI/CD.
- **Decision:** Establish a strict 3-tier verification model (offline linting → sandbox cluster test → GitOps deployment) and distribute validated release packages with SBOMs and OCI container/chart registries.
- **Consequences:** 
  - *Pros:* Zero cloud credentials required for CI validation; verifiable supply-chain integrity via Syft SBOMs.
  - *Cons:* Requires maintaining local test fixtures and mock plan inputs.

## ADR-003: Hub-and-Spoke ApplicationSet Matrix & Centralized Overlays
- **Date:** 2026-10-27
- **Status:** Accepted
- **Context:** Managing continuous deployments across 15 microservices and 3 cluster tiers required an automated control plane without causing batch-push timestamp churn in application source repositories.
- **Decision:** Centralize cluster connection endpoints, matrix ApplicationSets, and environment overlays in `multi-cluster-gitops-promotion`. Use ArgoCD matrix generators with `goTemplate: true` and `templatePatch` to inject automated self-healing in `dev`/`staging` while enforcing gated PRs in `prod`.
- **Consequences:**
  - *Pros:* Decouples deployment topology from service source code; prevents timestamp pollution; provides single-pane-of-glass GitOps visibility.
  - *Cons:* Requires catalog maintainers to update centralized overlay images during promotion workflows.
