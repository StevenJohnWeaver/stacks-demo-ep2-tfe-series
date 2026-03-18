# Cloudability Run Task Setup

## Overview

IBM Cloudability is already connected at the **HCP Terraform organization level**.  
This guide shows how to assign it to the **Episode 2 Stack** workspace to gate plans between Plan and Apply.

> **What it does:** After every `terraform plan`, Cloudability receives the resource changes, estimates cost impact, and returns a pass/advisory/fail result before the apply can proceed.

---

## Prerequisites

- IBM Cloudability account with the HCP Terraform integration enabled (already done at org level)
- HCP Terraform organization admin or workspace admin access

---

## Step 1: Verify the Org-Level Run Task Integration

1. Go to **HCP Terraform** → **Organization Settings** → **Integrations** → **Run Tasks**
2. Confirm that `IBM Cloudability` appears in the list
3. Note the **Run Task name** (you'll reference this in Step 2)

---

## Step 2: Assign the Run Task to the Episode 2 Stack Workspace

> [!NOTE]
> For a Stack, the Run Task is assigned to the **Stack's associated workspace**, not to individual deployment workspaces directly. HCP Terraform propagates it to all deployments.

1. Navigate to **Projects & Workspaces** → find the `stacks-demo-ep2` Stack
2. Click **Settings** → **Run Tasks**
3. Click **+ Add Run Task**
4. Select **IBM Cloudability** from the dropdown
5. Set the enforcement level:
   - **Advisory** — cost estimate is shown, apply is never blocked (recommended to start)
   - **Mandatory** — cost threshold violation blocks the apply

---

## Step 3: Demo Script (Advisory Mode)

This sequence shows the Run Task firing and surfacing cost data — a key lightboard moment:

1. Make a change that increases compute (e.g., bump `kubernetes_version` or a node count) and push
2. Open HCP Terraform → the Stack plan begins
3. After the plan completes, observe the **Run Task** checkpoint between Plan and Apply:
   - Status: `Passed` or `Advisory: cost increase detected`
   - Cloudability shows the estimated monthly cost delta
4. Approve the apply — demonstrating that cost visibility is now embedded in the governance pipeline, not bolted on after

---

## Step 4: Demo Script (Mandatory Mode — Policy Trip)

To demonstrate a hard cost block for the recording:

1. Switch the Run Task enforcement to **Mandatory**
2. Set a low cost threshold in Cloudability (e.g., flag any apply that adds > $50/month)
3. Temporarily scale up a node group to a large instance type
4. Observe the apply being **blocked** with the Cloudability cost reason
5. Revert the change and re-apply to show the pass path

---

## Notes

- Cloudability Run Task results are included in the **HCP Terraform audit log** — demonstrating the full compliance trail from Ep 2's policy story
- Cost thresholds and budgets are configured in the Cloudability UI, not in Terraform HCL
- The Run Task fires for every plan — including speculative plans on PRs if VCS is connected
