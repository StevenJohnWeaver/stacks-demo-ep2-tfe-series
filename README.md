# Stacks Whiteboard Demo (Network → EKS → Kubernetes App)

This repo powers the “Beyond the Workspace — Orchestration via Stacks” demo.

It shows:
- **Components**: `network`, `cluster` (EKS), `app` (Kubernetes)
- **Centralized providers** (DRY & governance)
- **Deferred orchestration**: Kubernetes provider is wired to EKS outputs; Stacks auto‑defers planning the app until those values exist
- **Deployments**: dev, staging, prod (identical blueprint, different inputs)

## Prereqs

- Terraform CLI 1.14+ (optional if you run only in HCP Terraform UI)
- HCP Terraform organization & project with **Stacks enabled**
- AWS OIDC trust for HCP Terraform (identity-token workspace + IAM role per environment)

## Quick start (HCP Terraform UI)

1) **Create Stack** → connect this repo.  
2) Edit `deployments.tfdeploy.hcl` and paste your `role_arn` per environment; commit & push.  
3) Open **Deployments** → approve the **development** plan.  
   - You will see a brief **Deferred** status for the `app` while EKS becomes available.  
   - Stacks will continue automatically once cluster outputs are ready.  
4) Repeat for **staging** and **production**.

## Rollout example

- Change `modules/app/main.tf` → set `replicas = 3`, commit & push.
- Approve dev → staging → prod plans to roll the same change consistently.

## Structure

