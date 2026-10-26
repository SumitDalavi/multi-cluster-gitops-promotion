# Architecture: Multi-Cluster GitOps Promotion
> Maturity: Lab / Reference Implementation

## System Diagram
The following Mermaid.js sequence diagram maps the core workflow and interactions:

```mermaid
sequenceDiagram
    CI->>DevRepo: Push Image
ArgoCD_Dev->>DevCluster: Deploy
QA->>ProdRepo: Merge PR
ArgoCD_Prod->>ProdCluster: Deploy
```


## Environment Promotion via Pull Requests
In this architecture, promoting a release from `staging` to `prod` doesn't involve running `kubectl apply` or clicking a button in Jenkins. 

Instead, a developer opens a Pull Request that modifies `manifests/overlays/prod/kustomization.yaml` (e.g., updating the image tag from `v1.2.0` to `v1.3.0`). Once the PR is approved and merged, Argo CD detects the change and synchronizes the production cluster.

## The ApplicationSet Controller
The `ApplicationSet` is the core of the multi-cluster strategy. Instead of defining 50 different Argo CD `Application` YAMLs for 50 different clusters, we define a single `ApplicationSet` using the **Cluster Generator**.

### How it works:
1. You register a new Kubernetes cluster to Argo CD and label it with `environment: prod`.
2. The ApplicationSet generator detects the new cluster.
3. It dynamically generates an `Application` resource, setting the destination to the new cluster and the source path to `manifests/overlays/prod` (utilizing the `{{metadata.labels.environment}}` variable).
4. The new cluster immediately begins syncing the production state.

This makes cluster bootstrapping a zero-touch operation.

## Verification & Deployment Architecture (v0.2.0)

This repository follows a progressive verification architecture designed for zero-trust cloud native environments:

```mermaid
graph TD
    A[Local Authoring] -->|Static Lint & Schema Validation| B[Tier 1: Offline Gate]
    B -->|Kind / Sandbox Cluster Apply| C[Tier 2: Emulation Sandbox]
    C -->|GitOps PR & Merge| D[Tier 3: Production GitOps]
    D --> E[Live Cluster / Cloud State]
```

- **Tier 1 (Offline Validation):** Syntax validation, static policy checks (`opa test`, `kyverno test`, `terraform fmt -check`), and schema verification without cloud dependencies.
- **Tier 2 (Sandbox Emulation):** Automated testing against local Kind clusters or isolated development namespaces.
- **Tier 3 (Production GitOps):** Automated deployment via GitOps controllers (ArgoCD / Flux) or infrastructure pipelines with cryptographically signed release manifests and SPDX SBOMs.

## Enterprise Multi-Cluster Catalog Architecture (v0.2.1)

```mermaid
graph TD
    Root[Master App-of-Apps: root-application.yaml] --> AppSet1[platform-services-appset]
    Root --> AppSet2[platform-helm-services-appset]
    Root --> AppSet3[distributed-services-appset]
    Root --> AppSet4[ai-services-appset]
    
    AppSet1 -->|Matrix| DevCluster[Dev: in-cluster]
    AppSet1 -->|Matrix| StagingCluster[Staging: staging-k8s:6443]
    AppSet1 -->|Matrix| ProdCluster[Prod: prod-k8s:6443]
    
    AppSet3 -->|Matrix| DevCluster
    AppSet3 -->|Matrix| StagingCluster
    AppSet3 -->|Matrix| ProdCluster
```

### Key Catalog Features
1. **Root App-of-Apps:** Single master declaration (`root-application.yaml`) synchronizing all four domain ApplicationSets.
2. **Matrix Generation:** Cartesian product of target microservices × cluster environments (`dev`, `staging`, `prod`).
3. **templatePatch Gating:** Automatically injects `automated: {prune: true, selfHeal: true}` for non-production tiers, strictly requiring manual PR approvals for production.
4. **Dual-Engine Reconciliation:** Reconciles OCI Helm charts directly from `oci://ghcr.io/sumitdalavi` alongside Git-tracked Kustomize overlays.
