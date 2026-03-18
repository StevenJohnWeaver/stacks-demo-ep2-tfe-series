# Episode 2 Demo: Guarding the Estate — Identity, Policy, and Cost

This repo extends the Ep 1 Stacks demo with three layers of enterprise governance:

- **Sentinel** — Hard and soft-mandatory policy-as-code
- **Vault** — Dynamic credentials via OIDC; zero static secrets
- **Cloudability** — Cost guardrails as a Run Task gate between Plan and Apply

The underlying Stack (VPC → EKS → Kubernetes App across dev/staging/prod) is unchanged from Ep 1. Every addition is purely at the governance layer.

---

## What's New vs Episode 1

| Layer | What it adds |
|---|---|
| `sentinel/allowed-instance-types.sentinel` | Hard block: EKS nodes must use approved instance families |
| `sentinel/require-tags.sentinel` | Soft block: every AWS resource must carry `environment` + `owner` tags |
| `modules/secrets/` | Vault KV read via OIDC JWT — no static tokens anywhere |
| `deployments.tfdeploy.hcl` | Second `identity_token` block for Vault (same OIDC issuer, scoped audience) |
| `docs/run-task-setup.md` | Step-by-step Cloudability Run Task setup |
| `output "config_facts"` | Stack-level output powering the Ep 5 Ansible handshake |

---

## Prerequisites

- Terraform CLI 1.14+ (optional — can run entirely in HCP Terraform UI)
- HCP Terraform org with **Stacks** and **Sentinel** enabled
- AWS OIDC trust for HCP Terraform (same as Ep 1)
- **HCP Vault cluster** with JWT auth method enabled
- **IBM Cloudability** connected at the HCP Terraform org level

---

## Quick Start

### 1. Connect the Stack

1. Create a Stack in HCP Terraform, connected to this repo
2. Update `deployments.tfdeploy.hcl`:
   - Replace `YOUR-VAULT-CLUSTER` with your HCP Vault cluster URL
   - Verify the `role_arn` values match your AWS account

### 2. Configure Vault JWT Auth

In your HCP Vault cluster, enable JWT auth and create a role trusted by HCP Terraform:

```shell
vault auth enable jwt

vault write auth/jwt/config \
  oidc_discovery_url="https://app.terraform.io" \
  bound_issuer="https://app.terraform.io"

# One role per environment (or a single role with env claim binding)
vault write auth/jwt/role/hcp-terraform-ep2-dev \
  role_type="jwt" \
  bound_audiences="vault.workload.identity" \
  user_claim="terraform_workspace_name" \
  policies="ep2-dev" \
  ttl="1h"
```

Create a KV v2 secret for the demo:

```shell
vault secrets enable -path=secret kv-v2
vault kv put secret/ep2-demo/dev/app-config db_host="demo-db.internal" api_key="DEMO"
vault kv put secret/ep2-demo/staging/app-config db_host="demo-db-stg.internal" api_key="DEMO"
vault kv put secret/ep2-demo/prod/app-config db_host="demo-db-prd.internal" api_key="DEMO"
```

### 3. Attach Sentinel Policies

1. In HCP Terraform → **Policies** → **Policy Sets** → **Create Policy Set**
2. Connect this repo, set the path to `sentinel/`
3. Scope to this Stack's workspace(s)

### 4. Set Up the Cloudability Run Task

Follow `docs/run-task-setup.md` — the integration is already at org level, so this is just a workspace assignment.

---

## Demo Sequence (Recording Guide)

1. **Sentinel Pass** — Apply as normal → both policies pass → annotate the policy checkpoint in the UI
2. **Sentinel Fail (hard)** — Change an instance type to `p3.2xlarge` → `allowed-instance-types` hard-blocks the plan
3. **Sentinel Override (soft)** — Remove a tag → `require-tags` soft-blocks → demonstrate the admin override flow
4. **Vault Zero-Trust** — Show the run logs: Vault auth via JWT → KV read → no static token anywhere in the config
5. **Cloudability Gate** — Show cost estimate between Plan and Apply; flip to Mandatory and demonstrate a cost block

## Structure

```
.
├── components.tfcomponent.hcl   # Stack components (network, cluster, auth, app, secrets)
├── deployments.tfdeploy.hcl     # Three deployments + two OIDC identity tokens
├── providers.tfcomponent.hcl    # AWS, Kubernetes, Vault providers
├── variables.tfcomponent.hcl    # All Stack input variables
├── modules/
│   ├── network/                 # VPC (unchanged from Ep1)
│   ├── cluster/                 # EKS (unchanged from Ep1)
│   ├── app_auth/                # EKS auth (unchanged from Ep1)
│   ├── app/                     # Kubernetes app (unchanged from Ep1)
│   └── secrets/                 # NEW: Vault KV read via OIDC
├── sentinel/
│   ├── sentinel.hcl             # Policy set config
│   ├── allowed-instance-types.sentinel
│   └── require-tags.sentinel
└── docs/
    └── run-task-setup.md        # Cloudability Run Task setup guide
```
