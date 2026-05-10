# Enterprise CI/CD and DevSecOps Pipeline Architecture

This document defines a complete enterprise-grade CI/CD, DevSecOps, and GitOps operating model for this Terraform-based EKS platform repository.

## 1) Target Architecture Overview

### Pipeline stages
1. **Code & policy authoring** (feature branch)
2. **Pull Request validation** (quality + security + plan)
3. **Approval gates** (CODEOWNERS + protected branch + required checks)
4. **Merge to main** (release candidate)
5. **Environment promotion workflow** (dev → stage → prod)
6. **Manual production approval** (GitHub environment protection)
7. **Terraform apply** (OIDC short-lived credentials)
8. **GitOps reconciliation** (Argo CD/Flux picks desired state)
9. **Continuous drift detection** and alerting
10. **Rollback/restore path** (artifacted plans + version tags + Git revert)

---

## 2) GitHub Actions Workflow Design

### A. `pr-validation.yml`
Runs on PRs and includes:
- `terraform fmt -check -recursive`
- `terraform init -backend=false`
- `terraform validate`
- `tflint`
- `tfsec` and `checkov`
- `terraform plan` (non-apply) with artifact upload

Purpose: fail fast, block insecure or malformed infrastructure changes before merge.

### B. `terraform-plan.yml`
Runs on push to `main` and manual dispatch.
- Creates environment-specific Terraform plans (`dev`, `stage`, `prod`)
- Saves binary plan + JSON plan artifacts
- Summarizes blast radius (add/change/destroy counts)

Purpose: deterministic, reviewable plans per environment.

### C. `terraform-apply.yml`
Runs by manual dispatch only (or via promotion workflow call).
- Uses GitHub Environments (`dev`, `stage`, `prod`)
- Requires explicit approvers for production
- Downloads the exact plan artifact and applies with locking

Purpose: approved, auditable, immutable apply execution.

### D. `drift-detection.yml`
Scheduled (e.g., every 6 hours) + manual run.
- `terraform plan -detailed-exitcode`
- Exit code `2` indicates drift
- Opens/updates GitHub issue and optionally sends Slack/webhook alert

Purpose: detect out-of-band changes and compliance drift.

### E. `release.yml`
Triggers on semantic version tags (`v*.*.*`).
- Validates modules
- Publishes module/release notes
- Optionally signs artifacts/SBOM attestation

Purpose: controlled module versioning and consumable release process.

### F. `gitops-sync.yml` (optional integration)
After successful apply/promotion:
- Updates GitOps repo version refs or environment overlays
- Creates signed PR in GitOps repo

Purpose: reconcile Terraform-managed platform + Kubernetes desired state lifecycle.

---

## 3) Branch Protection Strategy

Apply strict protection on `main` and `release/*`:
- Require pull request before merge
- Require all status checks to pass:
  - fmt, validate, tflint, tfsec, checkov, plan
- Require up-to-date branch before merge
- Require CODEOWNERS review
- Require conversation resolution
- Block force-push and deletion
- Restrict who can bypass protections
- Enable signed commits/tags (recommended)

For production-sensitive repos, also require:
- Minimum 2 reviewers
- One security reviewer for security-labeled PRs
- Dismiss stale approvals on new commits

---

## 4) CODEOWNERS Model

Ownership split should map to accountability boundaries:
- Platform team owns Terraform modules and environment stacks
- Security team owns policy, IAM, and guardrail directories
- SRE team co-owns production environment definitions

Include CODEOWNERS (provided in `.github/CODEOWNERS`) to enforce mandatory review gates.

---

## 5) Enterprise Deployment Workflow

### End-to-end flow
1. Engineer opens PR from feature branch.
2. PR workflow performs lint, static checks, security scans, and non-destructive plans.
3. Required approvers validate architecture/security impacts.
4. Merge to `main` produces versioned plan artifacts for each environment.
5. Promotion workflow applies to `dev` automatically (or with lightweight approval).
6. After validation, promote same commit SHA to `stage`.
7. Production promotion requires manual approval in GitHub Environment + change record linkage.
8. Apply in `prod` uses the reviewed plan artifact and emits audit logs.

### Production approval flow
- `terraform-apply` targets `environment: prod`
- GitHub Environment protection rules enforce designated approvers
- Optional wait timer + change window constraints
- Apply executes only after approval event

### Security gate flow
- Shift-left scanners in PR (`tfsec`, `checkov`, `tflint`)
- Policy violations fail checks (hard gate)
- Optional severity policy:
  - HIGH/CRITICAL: fail merge
  - MEDIUM: fail or require security exception label
- Post-merge drift scans ensure runtime integrity

### Promotion flow
- Promotion is **commit-based**, not branch-based: same SHA moves through environments.
- Plan artifacts are immutable per SHA.
- Promotion metadata captured in workflow outputs and release notes.

---

## 6) Plan/Apply, Manual Approvals, and Drift

### Plan/apply workflow policy
- Never apply directly from PR.
- Plan from merged commit only.
- Apply only from signed and approved workflow run.
- Use remote state + lock table (S3 + DynamoDB) to avoid concurrency corruption.

### Drift detection
- Scheduled plans with `-detailed-exitcode`
- On drift: create incident ticket/issue and optional auto-generated reconciliation PR
- Track mean-time-to-drift-detection as SRE metric

---

## 7) Release Strategy and Module Versioning

### Recommended release model
- Semantic version tags (`vMAJOR.MINOR.PATCH`) on `main`
- Changelog generated from conventional commits
- Release notes include:
  - module change matrix
  - breaking changes
  - migration notes

### Module versioning
- Version modules via Git tags and consume with:
  - `source = "git::https://...//modules/eks?ref=v1.4.0"`
- Maintain compatibility matrix per environment
- Disallow floating refs in production (`main`, `master`, or branch refs)

---

## 8) Artifact Strategy

Store auditable immutable artifacts per run:
- Terraform binary plan (`*.tfplan`)
- JSON plan (`terraform show -json`)
- Security scan SARIF/results
- Release manifests and changelog

Retention recommendations:
- PR artifacts: 14–30 days
- Main/prod artifacts: 180+ days (or policy-driven)

Cryptographic integrity:
- Sign release tags
- Optional artifact signing and provenance attestations (SLSA-aligned)

---

## 9) GitOps Integration Strategy

Terraform provisions shared platform primitives (VPC/EKS/IAM/addons).
Application deployment remains GitOps-managed:
- Argo CD/Flux watches separate app/config repo
- After infra promotion, workflow updates environment overlay versions
- GitOps controller reconciles workloads to new cluster capabilities

Benefits:
- clear separation of infra and app concerns
- audit trail in both repos
- deterministic roll-forward/rollback patterns

---

## 10) Rollback Strategy

Use layered rollback controls:
1. **Application rollback (GitOps):** revert app/config commit.
2. **Infrastructure rollback:**
   - revert Terraform commit
   - re-plan and apply previous known-good tag
3. **Disaster recovery:** state backups + module pinning + controlled re-apply.

Guardrails:
- Keep previous production plan artifact for emergency compare/reapply.
- Tag every production deployment (`prod-YYYYMMDD-HHMM-SHA`).

---

## 11) Operational Benefits

- High-confidence infrastructure changes through multi-stage validation.
- Reduced MTTR via deterministic artifacts and reproducible plans.
- Improved auditability through approvals, artifacts, and release tagging.
- Better security posture with mandatory IaC scans and drift monitoring.

## 12) Risk Reduction Benefits

- Prevents malformed IaC from reaching production.
- Prevents unauthorized or accidental production deployment.
- Detects out-of-band cloud changes early.
- Reduces blast radius by commit-based promotion and manual gates.
