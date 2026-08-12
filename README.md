# Multi-Cluster GitOps Promotion Platform 🌍🔄

> A platform-scale GitOps architecture using Argo CD ApplicationSets and Kustomize to manage environment promotion (Dev → Stage → Prod) across distinct Kubernetes clusters.

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

## 👨‍💻 Author

*Built to demonstrate platform-scale environment management and GitOps promotion strategies.*
