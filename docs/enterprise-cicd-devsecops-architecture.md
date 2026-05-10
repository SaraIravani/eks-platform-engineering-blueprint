# Enterprise CI/CD + DevSecOps Architecture

## 1) Target Operating Model

This repository uses a **GitHub Actions + Terraform + GitOps** operating model:

- **Pull Requests** run policy/security/quality gates (`fmt`, `validate`, `tflint`, `tfsec`, `checkov`, docs/lint checks) and produce a non-applying Terraform Plan artifact.
- **Environment promotion** is controlled and sequential: `dev -> stage -> prod`.
- **Apply** is isolated behind manual approvals via **GitHub Environments required reviewers**.
- **Drift detection** runs on a schedule and raises issues/alerts.
- **GitOps integration** (Argo CD or Flux) deploys cluster add-ons/workloads after infrastructure state converges.

---

## 2) Branching, Protection, and Ownership

### Branch strategy

- `main`: production-ready, protected, no direct pushes.
- `feature/*`: developer branches.
- `release/*`: optional stabilization branches for larger releases.

### Required branch protection (GitHub rulesets)

For `main`:

- Require pull request before merge.
- Require at least 2 reviewers.
- Require review from Code Owners.
- Require conversation resolution.
- Require status checks to pass:
  - `terraform-pr-validation`
  - `terraform-plan-dev`
  - `iac-security-gates`
- Require signed commits (optional but recommended).
- Restrict force pushes and deletions.
- Require linear history (recommended).

### CODEOWNERS model

- Platform team owns Terraform root/env/module changes.
- Security team owns security-sensitive policy and workflow files.
- SRE owns production environment definitions.

---

## 3) Security Gate Flow (Shift-left + Pre-apply)

### PR-time controls

1. `terraform fmt -check -recursive`
2. `terraform init -backend=false`
3. `terraform validate`
4. `tflint`
5. `tfsec`
6. `checkov`

All must pass before merge.

### Plan-time controls

- Plan output stored as immutable artifact.
- Optional OPA/Conftest policy checks on plan JSON.
- Sensitive data redaction for published artifacts.

### Apply-time controls

- Environment protections enforce human approvals for `stage`/`prod`.
- OIDC-based short-lived cloud credentials only (no long-lived AWS keys).
- Concurrency lock prevents simultaneous applies per environment.

---

## 4) Enterprise Deployment Workflow

### A. Pull Request Validation

Triggered on PR to `main`:

- Run full static/semantic/security checks.
- Run environment-specific plan in `dev` workspace.
- Comment plan summary on PR.
- Upload artifacts (`plan.binary`, `plan.json`, reports).

### B. Merge to `main` (Promotion kickoff)

- Re-run checks for provenance and integrity.
- Auto-apply in `dev` (or manual depending on risk model).
- Post-success: create promotion artifact metadata with commit SHA + module versions + plan fingerprint.

### C. Promotion to `stage`

- Manual dispatch or automatic upon `dev` success.
- Uses same immutable commit SHA and locked provider/module versions.
- Requires stage approver(s).

### D. Promotion to `prod`

- Requires CAB/SRE/security approvals (GitHub Environment reviewers).
- Executes apply with concurrency lock `terraform-prod`.
- Emits deployment event, changelog, and release tag.

---

## 5) Production Approval Flow

1. Pipeline creates prod plan artifact.
2. Required reviewers validate:
   - Plan diff and impact scope
   - Security gate reports
   - Drift status
   - Change window alignment
3. Reviewer approves deployment in `production` Environment.
4. Apply runs with audited identity via OIDC.
5. Post-deploy smoke checks and GitOps sync verification.

---

## 6) Promotion Flow

Promotion is **artifact-driven** (not branch-rebuild driven):

- Promote exact commit + exact plan context.
- Prevent “works in dev but rebuilt differently in prod”.
- Use release metadata (`release-manifest.json`) to track:
  - git SHA
  - module versions
  - Terraform version
  - provider lockfile checksums
  - security scan report digests

---

## 7) Drift Detection

Scheduled workflow (e.g., every 6 hours):

- Runs `terraform plan -detailed-exitcode` for each environment.
- Exit code `2` => drift detected.
- Automatically creates/updates GitHub issue and optionally sends Slack/Teams alert.
- Optional auto-remediation is disabled by default in prod.

---

## 8) Release Strategy and Module Versioning

### Release strategy

- Use SemVer tags (`vMAJOR.MINOR.PATCH`) on `main`.
- Every approved prod deployment creates a GitHub Release with artifacts:
  - Terraform plan summaries
  - Scan reports
  - Release manifest

### Module versioning

- Internal modules versioned independently via tags when split repositories are used.
- For monorepo modules:
  - keep changelog per module path,
  - pin provider versions,
  - enforce review on `modules/**` via CODEOWNERS.

---

## 9) Artifact Strategy

Artifacts retained for audit (30-180 days by policy):

- `terraform.plan` binary
- `plan.json`
- `tfsec.sarif`
- `checkov.sarif`
- `tflint.log`
- `release-manifest.json`

Use immutable artifact names including SHA and environment.

---

## 10) GitOps Integration (Argo CD / Flux)

Recommended pattern:

1. Terraform pipeline provisions/updates EKS + IAM + infra dependencies.
2. On successful infra apply, pipeline updates GitOps repo/branch with new cluster/addon manifests or version pins.
3. Argo CD/Flux reconciles workloads declaratively.
4. Health checks and sync status are fed back into deployment report.

This separates **infrastructure convergence** from **workload convergence** while preserving auditability.

---

## 11) Rollback Strategy

### Infra rollback

- Preferred: **forward-fix** via new commit + plan/apply.
- Emergency: revert commit and apply validated rollback plan.
- Keep previous release plan artifacts for quick diff and controlled revert.

### GitOps/workload rollback

- Revert GitOps commit or promote previous Helm/Kustomize version.
- Automated health checks gate completion.

---

## 12) Operational and Risk-Reduction Benefits

### Operational benefits

- Standardized deployments across environments.
- Faster feedback on infrastructure defects.
- Full audit trail (who approved, what changed, when).
- Deterministic promotion with immutable artifacts.

### Risk reduction benefits

- Early security finding detection (PR gates).
- Approval controls for high-risk environments.
- Drift detection reduces unknown config divergence.
- OIDC credentials reduce key management/security exposure.
