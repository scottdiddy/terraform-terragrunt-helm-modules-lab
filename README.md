# Terraform + Terragrunt + Helm + child modules: hands-on lab

A complete **local Kind lab** with one shared Helm provider configuration and two independent Helm **releases**, implemented as two Terraform **child modules**.

> **What is installed:** ArgoCD (external Helm chart) and `hello-helm` (a small nginx app with an included local Helm chart). You can read every template in the second chart. There are no Datadog credentials to set up.

## Architecture: notice each keyword

```text
live/dev/platform/terragrunt.hcl                 live/prod/platform/terragrunt.hcl
        | Terragrunt terraform.source                     |
        +---------------------+---------------------------+
                              |
                modules/platform/ (ROOT MODULE)
                versions.tf: required_providers helm
                providers.tf: ONE provider "helm" config
                main.tf:
                  module "argocd"   --> modules/argocd/
                                        resource "helm_release" "argocd"
                  module "demo_app"--> modules/demo-app/
                                        resource "helm_release" "demo"
                                            chart/ (YOUR OWN Helm chart)
                              |
                 Helm provider talks to selected
                     Kind Kubernetes cluster
```

- `provider "helm"`: **how to talk to a Kubernetes cluster**. Configured **once** in `modules/platform/providers.tf`.
- `required_providers`: **which plugin type/version a module needs**. Yes, each child module repeats a small requirement declaration. This is good Terraform module design, **not** downloading or configuring Helm twice: Terraform resolves provider dependencies centrally for the root configuration.
- `module "argocd"`: **call** reusable Terraform code from the `argocd` directory.
- `resource "helm_release"`: **manage** one concrete Helm release in Kubernetes.
- `terraform.source` in Terragrunt: **select a Terraform ROOT module** (`platform`). It does not replace the two child `module` blocks inside it.
- `values = [templatefile(...)]` in ArgoCD: turn `.tftpl` text into Helm YAML.
- `values = [yamlencode(...)]` in demo-app: turn a Terraform object into Helm YAML.
- `remote_state` in `live/root.hcl`: generate `backend.tf` and save dev/prod state separately.

## Directory map

```text
modules/
  platform/        <- ROOT Terraform module: provider, module calls, inputs, outputs
  argocd/          <- CHILD Terraform module: external chart via helm_release
  demo-app/        <- CHILD Terraform module: our own chart via helm_release
    chart/
      Chart.yaml
      values.yaml
      templates/{configmap,deployment,service}.yaml
live/
  root.hcl         <- shared Terragrunt local backend config
  dev/platform/terragrunt.hcl  <- dev context / values / dev state
  prod/platform/terragrunt.hcl <- prod context / values / prod state
scripts/
  create-clusters.sh
  validate.sh
  check-dev.sh
```

## Prerequisites (Mac)

Docker Desktop or another running Docker engine; `kind`, `kubectl`, `helm`, `terraform`, and `terragrunt`. Your Mac must have working internet access to download Helm charts, provider plugins, and container images.

Install with Homebrew as appropriate (check your installed versions):

```bash
brew install kind kubectl helm terraform terragrunt
```

For recent Terragrunt versions, use `terragrunt plan` and `terragrunt apply`. Consult `terragrunt --help` if your installed version differs.

## Run it

From the unzipped repository root:

```bash
# 1. Create both Kind clusters (can create dev only to start)
bash scripts/create-clusters.sh

# 2. Optional: inspect the LOCAL demo chart without deploying anything
helm lint modules/demo-app/chart
helm template hello-helm modules/demo-app/chart --set greeting='Hello from Helm'

# 3. Deploy DEV (Terragrunt downloads module package + Terraform handles Helm)
cd live/dev/platform
terragrunt init
terragrunt plan
terragrunt apply

# 4. Inspect what got installed
kubectl --context kind-helm-lab-dev get pods -n argocd
kubectl --context kind-helm-lab-dev get pods -n hello
helm list --kube-context kind-helm-lab-dev -n argocd
helm list --kube-context kind-helm-lab-dev -n hello
helm get values hello-helm --kube-context kind-helm-lab-dev -n hello

# 5. See the web page (leave this running; use a second terminal for curl)
kubectl --context kind-helm-lab-dev -n hello port-forward svc/hello-helm 8081:80
# In another terminal: curl http://localhost:8081
```

To open ArgoCD locally, use a separate terminal:

```bash
kubectl --context kind-helm-lab-dev -n argocd port-forward svc/argocd-server 8080:80
# ArgoCD: http://localhost:8080
# Admin password is in a secret; do not commit or share it.
kubectl --context kind-helm-lab-dev -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

**Production-like exercise:** From repository root, go to `live/prod/platform`, run `terragrunt init`, `terragrunt plan`, `terragrunt apply`. It targets `kind-helm-lab-prod`, uses two demo replicas, and keeps an independent state file. It is **not** production hardening.

**Experiment:** Change `greeting` in `live/dev/platform/terragrunt.hcl`; run `terragrunt plan` then `terragrunt apply` from that directory. Only the demo release's values should change. Change `demo_replicas` to observe a Deployment replica update. Change `argocd_domain` to see `templatefile()` change chart values.

## Why the `//` matters

`source = "../../..//modules/platform"` in Terragrunt is intentionally *not* the same as `"../../../modules/platform"`.

The portion before `//` identifies the repository **package root**. Terragrunt copies the package to its cache, then uses the subdirectory `modules/platform`. When Terraform evaluates `module "argocd" { source = "../argocd" }`, the sibling child module is available. Without copying the package, Terraform may not find siblings inside the cache. This is a key detail of using Terragrunt with local multi-module repositories.

## Why is `required_providers` repeated?

`required_providers` is a declaration of **dependency**, not `provider` configuration. Child modules should state their own provider source/version requirements. One version satisfying all module constraints is selected for the root execution (and recorded in a `.terraform.lock.hcl` lockfile). The **one actual `provider "helm"` configuration** in platform/providers.tf is shared by the children through their `providers` mappings. No separate Helm binary is installed by these declarations; the Helm provider is a Terraform plugin implementing Helm operations.

## What is NOT included

- No ArgoCD Applications or GitOps sync loop; ArgoCD is installed, but hasn't been told which Git repository to watch.
- No production-grade TLS, ingress, SSO, persistent remote state, secrets management, or Datadog Agent configuration.
- No guarantee of cloud/container compatibility until you actually run it; pinned chart versions can age. If `10.10.3` is missing from your repo, run `helm repo add argo https://argoproj.github.io/argo-helm && helm repo update && helm search repo argo/argo-cd --versions` and replace the chart version in both Terragrunt units.

## Check state and clean up

`live/root.hcl` stores dev state under `live/.state/dev/platform/terraform.tfstate`, prod under `live/.state/prod/platform/terraform.tfstate`. **Do not delete state before running destroy.**

```bash
# From live/dev/platform:
terragrunt destroy
# From live/prod/platform:
terragrunt destroy
# After both are destroyed, from repo root:
kind delete cluster --name helm-lab-dev
kind delete cluster --name helm-lab-prod
```

## Official references

- Terraform modules: https://developer.hashicorp.com/terraform/language/modules
- Terraform provider requirements: https://developer.hashicorp.com/terraform/language/providers/requirements
- Terragrunt unit source: https://docs.terragrunt.com/features/units/
- Argo Helm chart: https://github.com/argoproj/argo-helm
