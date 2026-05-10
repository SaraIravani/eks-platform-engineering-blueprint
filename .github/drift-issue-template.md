Terraform drift was detected during scheduled drift detection.

## Required actions
- Review cloud-side manual changes.
- Compare against desired Terraform state.
- Reconcile by either:
  - committing desired changes to code, or
  - reverting out-of-band cloud changes.

## Severity
Treat production drift as a high-priority operational event.
