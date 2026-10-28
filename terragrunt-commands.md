# Terragrunt Commands — Quick Guide

Terragrunt is a wrapper around Terraform. Run these commands from the environment's directory, for example `live/dev/platform/`, where `terragrunt.hcl` is located.

## `terragrunt init` — Set up

```bash
terragrunt init
```

Prepares the Terraform working directory: reads the Terragrunt configuration, prepares the Terraform source, initializes the state backend, downloads required providers (such as `hashicorp/helm`), and initializes child modules. **It does not install ArgoCD or other applications.**

## `terragrunt plan` — Preview

```bash
terragrunt plan
```

Compares Terraform configuration, state, and existing infrastructure to show proposed changes **without applying them**.

- `+` create a resource
- `~` update a resource
- `-` destroy a resource
- `-/+` replace a resource

Example: `Plan: 2 to add, 0 to change, 0 to destroy.` means two resources would be created if applied.

## `terragrunt apply` — Make changes

```bash
terragrunt apply
```

Calculates a plan, asks for approval (normally), then creates, updates, or removes resources. In our lab, this installs or updates the **ArgoCD** and **demo-app** Helm releases and updates Terraform state.

A separate `plan` command is recommended for review, but `apply` normally computes its own new plan.

## Other useful commands

```bash
terragrunt output       # Show root Terraform outputs after applying
terragrunt state list   # List resources tracked in Terraform state
terragrunt destroy      # Plan and, after approval, destroy managed resources
```

`destroy` removes the Helm releases Terraform manages; it does **not** remove a Kind cluster created separately with `kind`.

## Typical workflow

```bash
cd live/dev/platform
terragrunt init     # First run, or after backend/provider/module changes
terragrunt plan     # Review changes
terragrunt apply    # Apply approved changes
terragrunt output   # See exposed outputs
```

**Remember:** `init` prepares → `plan` previews → `apply` executes. Running `apply` again with no changes should normally result in no changes.
