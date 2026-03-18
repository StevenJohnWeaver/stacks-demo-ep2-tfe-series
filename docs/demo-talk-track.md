# Episode 2 Demo Talk Track
## "Guarding the Estate — Identity, Policy, and Cost"
**Format:** Screen recording | **Target Duration:** 5 minutes

> **Before you record:** Ensure all prerequisites are wired up (Vault JWT auth, KV secrets, Sentinel policy set attached, Cloudability Run Task assigned). Have the HCP Terraform UI open on the Stack's overview page.

---

## 0:00 – 0:30 | Setup (30 sec)

**On screen:** HCP Terraform — the Ep1 Stack overview (`stacks-demo-ep2-tfe-series`), showing all three deployments (dev, staging, prod) healthy and green.

**Say:**
> "In Episode 1 we built a Terraform Stack — one blueprint, three environments, all wired together through the dependency graph. Today we're adding the governance layer: policy-as-code, dynamic secrets, and cost guardrails. Let's see it all fire in a single apply."

---

## 0:30 – 1:45 | Sentinel: The Normal Path (75 sec)

**On screen:** Make a trivial change — open `deployments.tfdeploy.hcl`, bump the `cluster_name` tag value or add a comment, commit and push. Switch to HCP Terraform and watch the plan begin.

**Say:**
> "I've pushed a small change. As soon as it lands, HCP Terraform kicks off a plan across all three deployments."

*[Wait for the plan to reach the policy evaluation checkpoint]*

> "Right here — between Plan and Apply — Sentinel runs. Two policies: one hard, one soft. `allowed-instance-types` is hard-mandatory — if we're using an unapproved instance family, this apply stops cold. `require-tags` is soft-mandatory — a violation surfaces as a warning an admin can override, but it gets logged either way."

*[Point to or highlight the policy results in the UI]*

> "Both pass. Green across the board. The apply proceeds — and every resource that lands carries the right tags and the right instance family. Governance didn't slow us down. It just ran."

---

## 1:45 – 2:45 | Sentinel: The Hard Block (60 sec)

**On screen:** Switch to VS Code / editor. In `modules/cluster/variables.tf` or wherever instance types are set, briefly show (or narrate) that you'd add `p3.2xlarge` to the node group config. Better: have a branch ready with this change already committed. Switch to that branch in HCP Terraform (or trigger via a workspace variable override for the demo).

> **Demo tip:** Rather than committing a bad instance type live, use a pre-staged branch or a Terraform variable override in the HCP Terraform workspace to trigger the violation quickly. This keeps the demo clean.

**Say:**
> "Now watch what happens when someone tries to use an instance type that isn't on the approved list — say, a GPU instance. I'll trigger this via a workspace variable override."

*[Apply triggers; plan runs; Sentinel fires]*

> "The plan runs. Sentinel evaluates. And right here — hard stop. `allowed-instance-types` failed. The apply is blocked. Not slowed down, not warned — *blocked*. No human had to catch this. The policy caught it, automatically, before a single resource was created."

*[Leave the failed policy result visible for a moment]*

> "That's the difference between a governance document in a wiki and governance-as-code in Sentinel."

*[Revert or remove the override — plan passes again]*

---

## 2:45 – 3:45 | Vault: Zero Static Secrets (60 sec)

**On screen:** Trigger an apply (or use the previous passing one). Navigate to the **run logs** for the `secrets` component in one of the deployment workspaces.

**Say:**
> "Let's look at how this Stack handles credentials. Open the run log for the `secrets` component."

*[Scroll to the Vault auth section in the log]*

> "You'll see the Vault provider authenticate using a JWT — an OIDC token issued by HCP Terraform itself, valid for this run only. No Vault token in the config. No environment variable. No secret stored in HCP Terraform. The token is issued, used, and expired — all within the span of a single apply."

*[Point to the KV read in the logs]*

> "It reads the app config secret from HCP Vault's KV store and surfaces the version number as a Stack output — proving the read happened, without leaking the value. Zero static secrets, end to end."

> "And because each deployment — dev, staging, prod — has its own scoped Vault role, a compromised dev credential can't touch production. That's zero-trust applied to the automation layer, not just the humans."

---

## 3:45 – 4:30 | Cloudability: Cost Guardrail (45 sec)

**On screen:** Navigate back to the main apply run. Show the **Run Tasks** checkpoint between Plan and Apply.

**Say:**
> "The third guardrail runs here — between Plan and Apply. IBM Cloudability received the plan output and returned a cost estimate."

*[Show the Cloudability result — cost delta, pass/advisory status]*

> "For this apply, it's advisory — the cost is within range, and the apply can proceed. But if we'd scaled up our node groups beyond the budget threshold — or added infrastructure that pushed the monthly estimate past a defined limit — Cloudability can block the apply entirely, the same way Sentinel does."

> "Cost visibility is now part of the pipeline. It's not a spreadsheet someone reviews after the fact. It's a gate."

---

## 4:30 – 5:00 | Close (30 sec)

**On screen:** Return to the Stack overview — all deployments healthy, policy checkpoints green, Vault auth logged, cost gate passed.

**Say:**
> "One Stack, three environments, three governance layers — all running automatically on every apply. Policy, identity, cost. That's the guarded estate.

> In Episode 3, we'll add the next layer: continuous drift detection at the Stack level, so the estate doesn't just deploy correctly — it *stays* correct. See you there."

---

## Timing Reference

| Section | Duration |
|---|---|
| Setup | 0:30 |
| Sentinel pass | 1:15 |
| Sentinel hard block | 1:00 |
| Vault zero-trust | 1:00 |
| Cloudability gate | 0:45 |
| Close | 0:30 |
| **Total** | **~5:00** |

---

## Recording Tips

- **Record at 1920×1080** — HCP Terraform's UI is dense; you want the real estate
- **Use a browser zoom of ~90%** to fit the full run log without scrolling mid-sentence
- **Pre-stage the hard-block scenario** using a workspace variable override — don't live-edit code on camera if you can avoid it
- **Pause briefly after each policy result appears** — give the viewer time to read it before narrating over it
- **Vault log timing:** The JWT auth + KV read is fast (~2 sec). Pause the recording or slow your scroll so the audience can see it register
