> **NOTE:** This repository is an archival lab or partial prototype. It is not actively maintained and should not be used as a reference for production-grade deployments or performance benchmarks.


# Multi-Cluster GitOps Promotion Platform 🌍🔄

> **Maturity:** Lab / Reference Implementation
> _A platform-scale GitOps architecture using Argo CD ApplicationSets and Kustomize to manage environment promotion (Dev → Stage → Prod) across distinct Kubernetes clusters._

## The Problem

Deploying to a single Kubernetes cluster with GitOps is easy. Deploying across 10, 50, or 100 clusters across multiple regions and environments (Dev, Staging, Prod) is incredibly difficult. Without a declarative architecture, platform teams rely on brittle CI/CD scripts to loop through clusters, leading to configuration drift and "snowflake" environments.

## The Solution

This project demonstrates a true **Multi-Cluster GitOps Platform** using the `ApplicationSet` controller from Argo CD. 

Instead of defining individual applications, we define a single `ApplicationSet` generator that dynamically creates Argo CD `Application` objects based on the clusters registered in the Argo CD control plane.

When a developer promotes code:
1. They update the image tag in the `manifests/overlays/dev` kustomization.
2. Argo CD detects the drift and syncs it to the Dev cluster.
3. Once validated, they open a PR promoting the tag to `manifests/overlays/staging`.
4. The ApplicationSet dynamically targets the staging cluster(s) with the new state.

## Why This Over the Obvious Alternative

Most portfolios simply show "I installed Argo CD and synced one repo." This project demonstrates **Platform-Scale GitOps**. By utilizing ApplicationSets and Kustomize overlays, we decouple the *definition* of the application from the *topology* of where it is deployed. This is how enterprise platform teams manage thousands of microservices across global fleets.

## 🛠️ Tech Stack

- **GitOps Engine**: Argo CD
- **Multi-cluster Controller**: Argo CD ApplicationSets
- **Manifest Management**: Kustomize

## Decision Log

| Decision | Rationale |
|----------|-----------|
| Argo CD ApplicationSets over raw Applications | ApplicationSets use generators (like the Cluster generator) to fan out deployments dynamically. If you add a new cluster, it automatically receives the appropriate workloads without manual YAML copying. |
| Kustomize over Helm | Kustomize's patch-based overlay system is strictly declarative and fits GitOps environment promotion (dev/stage/prod) better than Helm's complex templating engine. |
| Single Repo for Manifests | Simplifies the promotion workflow into a single Pull Request moving changes from the `dev/` folder to the `prod/` folder. |

## 📁 Project Structure

```
├── argocd/
│   └── applicationsets/
│       └── cluster-gitops-generator.yaml # Dynamically targets clusters based on labels
├── manifests/
│   ├── base/                             # Base K8s manifests (Deployment, Service)
│   └── overlays/
│       ├── dev/                          # Dev patches (replicas: 1, debug mode)
│       ├── staging/                      # Staging patches (replicas: 3)
│       └── prod/                         # Prod patches (replicas: 5, strict resources)
├── docs/ARCHITECTURE.md
└── README.md
```


## 📋 Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | >= 1.28 | Kubernetes CLI |
| [kind](https://kind.sigs.k8s.io/) | Latest | Local K8s clusters |
| [Argo CD CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/) | >= 2.9 | GitOps CLI |
| [Helm](https://helm.sh/) | >= 3.x | Package manager |
| [Kustomize](https://kustomize.io/) | >= 5.x | Manifest customization |

## 🚀 Step-by-Step Setup

### Option A: Local Multi-Cluster (kind)

```bash
# 1. Clone the repository
git clone https://github.com/SumitDalavi/multi-cluster-gitops-promotion.git
cd multi-cluster-gitops-promotion

# 2. Create two clusters (simulating dev and prod)
kind create cluster --name dev-cluster
kind create cluster --name prod-cluster

# 3. Install Argo CD on the management cluster (dev)
kubectl config use-context kind-dev-cluster
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 4. Wait for Argo CD to be ready
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=120s

# 5. Register the prod cluster with Argo CD
argocd cluster add kind-prod-cluster --name prod

# 6. Apply the ApplicationSet (generates apps for both clusters)
kubectl apply -f argocd/applicationsets/cluster-gitops-generator.yaml
```

### Option B: Existing Cloud Clusters

```bash
# Ensure kubectl contexts are configured for both clusters
kubectl config get-contexts
# Follow steps 3-6 from Option A
```

## 🧪 Usage & Demo â€” Promotion Pipeline

### Step 1: Verify applications are synced
```bash
argocd app list
argocd app get dev-app
argocd app get prod-app
```

### Step 2: Promote a change from dev to prod
```bash
# Update the dev overlay (e.g., new image tag)
# Edit manifests/overlays/dev/kustomization.yaml

# Dev cluster auto-syncs the change
argocd app sync dev-app

# After validation, update prod overlay
# Edit manifests/overlays/prod/kustomization.yaml
argocd app sync prod-app
```

### Step 3: Observe the Kustomize overlays
```bash
# Preview what each environment deploys
kustomize build manifests/overlays/dev/
kustomize build manifests/overlays/prod/
```

## ✅ Verification

| Check | Command | Expected |
|-------|---------|----------|
| Argo CD running | `kubectl get pods -n argocd` | All pods running |
| Clusters registered | `argocd cluster list` | Both clusters listed |
| Apps synced | `argocd app list` | Synced & Healthy |
| Overlays differ | `kustomize build manifests/overlays/dev/` vs `prod/` | Different image tags |

```bash
# Cleanup
kind delete cluster --name dev-cluster
kind delete cluster --name prod-cluster
```

## 👨‍💻 Author

**Sumit Dalavi** — Senior DevSecOps / Platform Engineer
[GitHub](https://github.com/SumitDalavi) | [LinkedIn](https://in.linkedin.com/in/sumit-dalavi-762838129)

## 📚 Documentation

- [Architecture](docs/ARCHITECTURE.md) — System diagram and component details
- [Promotion Runbook](docs/PROMOTION-RUNBOOK.md) — Step-by-step promotion guide
- [Runbook](docs/runbook.md) — Setup, commands, and expected outputs
- [Decisions](docs/decisions.md) — ADRs for multi-cluster routing
- [Changelog](docs/changelog.md) — Change history

## Mock Boundaries (Honest Scope)

| What | Status | Details |
|---|---|---|
| Kubernetes Clusters | **Real** | Spin up `dev-cluster` and `prod-cluster` via local `kind`. |
| GitOps Sync | **Real** | ArgoCD actively pulls and syncs Kustomize manifests. |
| Pull Requests | **Simulated** | Bash script mimics the code change, PR merge, and Git push sequence. |

## 🔗 Related Projects

- [`k8s-gateway-api-platform`](../k8s-gateway-api-platform/) — Can be deployed by this ApplicationSet for cluster-specific routing rules.