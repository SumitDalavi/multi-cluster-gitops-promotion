# Changelog

## [0.2.1] - 2026-10-27
### Added
- **Master Root App-of-Apps:** Added `argocd/root-application.yaml` managing all catalog ApplicationSets.
- **Dynamic ApplicationSet Matrices:** Added 4 ApplicationSets (`platform-services`, `platform-helm-services`, `distributed-services`, `ai-services`) utilizing `goTemplate: true` and `templatePatch`.
- **45 Centralized Cluster Overlays:** Configured overlays across `clusters/{dev,staging,prod}` for 15 microservices with per-environment replica counts and resource bounds.
- **Direct Application CRDs:** Added 15 standalone application manifests in `argocd/apps/`.
- **Zero-Drift Promotion CLI:** Modernized `scripts/promote.sh` with dynamic overlay resolution, native `kustomize edit set image`, and dry-run validation.
- **Catalog Conformance Validator:** Added `scripts/validate-catalog.sh` testing YAML syntax, immutable tags, and Kustomize builds.
- **Local Kind Bootstrap:** Added `scripts/setup-hub-kind.sh` for single-command ArgoCD Kind cluster provisioning.


## [0.2.0] - 2026-10-20
### Added
- **Multi-Tier Verification:** Staged validation architecture (local static linting, sandbox cluster testing, GitOps production rollout).
- **Supply Chain Security:** Integrated Trivy vulnerability scanning, SPDX JSON SBOM generation, and SHA256 checksums on all release assets.
- **Developer Documentation:** Standardized 3-tier execution instructions and environment configuration templates (`.env.example`).

## [0.1.0] - 2026-10-18
### Added
- Initial catalog release with verified baseline policies, manifests, and automated CI pipelines.

## [2026-08-29] — Phase 2 Evidence
### Added
- Created `scripts/demo_multi_cluster_promotion.sh` to demonstrate code → PR → promote → drift → rollback pipeline across Dev and Prod clusters.
- Standardized documentation (`runbook.md`, `decisions.md`, `ARCHITECTURE.md`).
- Added maturity badge and mock boundaries to `README.md`.


---

## [v0.1.0] — 2026-10-20
### Added
- **Release Automation:** Added `.github/workflows/release.yml` with automated catalog validation, tarball packaging, and SPDX SBOM generation.
- **Supply Chain Security:** Generated Anchore Syft SPDX JSON SBOM and cryptographic SHA-256 checksums.
- **Release Verification:** Added release verification documentation, badges, and operational runbook.
