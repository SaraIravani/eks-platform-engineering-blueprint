# 🚀 Enterprise AWS EKS Platform Blueprint

## 1) Platform Intent

This repository describes a **production-grade, enterprise EKS platform** that optimizes for:

- high availability across Availability Zones (AZs)
- strong security boundaries and least privilege
- workload isolation by criticality and trust level
- elastic scaling with cost control (Spot + On-Demand)
- deterministic operations through GitOps and standardized workflows

The design below is aligned to the Terraform modules in this repo (`vpc`, `eks`, `node_groups`, `security`, `autoscaling`, `addons`, `storage`, `iam`, `scheduling`).

---

## 2) Target VPC and Subnet Architecture

## VPC architecture

- **One VPC per environment** (`dev`, `staging`, `prod`) to reduce blast radius.
- Recommended VPC CIDR per environment: `/16`.
- 3-AZ minimum (for example `a/b/c`) for production resilience.
- DNS hostnames and DNS support enabled.

## Subnet strategy

Per AZ, create:

- **Public subnet** (ingress only)
- **Private app subnet** (EKS managed nodes and internal services)
- **Private data subnet** (optional: stateful/self-managed data services)

Suggested segmentation (example only):

- `10.20.0.0/16` VPC (prod)
  - Public: `10.20.0.0/20`, `10.20.16.0/20`, `10.20.32.0/20`
  - Private-app: `10.20.64.0/19`, `10.20.96.0/19`, `10.20.128.0/19`
  - Private-data: `10.20.160.0/21`, `10.20.168.0/21`, `10.20.176.0/21`

## Private/public separation

- Internet-facing ALB/NLB live in **public subnets**.
- EKS worker nodes run in **private subnets only**.
- Outbound access from private subnets via **NAT Gateway per AZ** (avoid single NAT SPOF).
- Prefer VPC endpoints (S3, ECR, STS, CloudWatch, KMS, EC2) to reduce NAT dependency and cost.

---

## 3) EKS Control Plane Access Model

- Keep endpoint access **private-first**.
- If public endpoint is required, restrict with API server allowlist CIDRs + MFA-backed operator access.
- Use AWS IAM Authenticator model for Kubernetes authN.
- Use RBAC groups mapped from IAM roles (platform-admin, read-only, CI deployer, break-glass).
- Enable EKS control-plane logs: `api`, `audit`, `authenticator`, `controllerManager`, `scheduler`.

---

## 4) Node Group Topology and Capacity Strategy

## System vs application node pools

Recommended managed node groups:

1. **system-ondemand**
   - Runs CoreDNS, CNI, metrics-server, autoscaling controllers, ingress controllers.
   - On-Demand only, min 3 (spread across 3 AZs).
   - Taints: `CriticalAddonsOnly=true:NoSchedule` (or equivalent pattern).

2. **app-ondemand**
   - Critical API and synchronous business services.
   - On-Demand baseline for predictable performance.

3. **app-spot**
   - Stateless and interruption-tolerant workloads.
   - Multi-instance-family diversification.

4. **batch-spot**
   - Jobs/cronjobs/event consumers.
   - Scale-to-zero permitted.

5. **data-ondemand**
   - Stateful services requiring stable storage/network.
   - Prefer memory/storage optimized instances.

6. **security-ondemand-dedicated**
   - Vault, policy engines, scanners, runtime security components.
   - Strict taints/tolerations and namespace policy isolation.

## Spot vs On-Demand strategy

- **On-Demand:** system, security, tier-0 APIs, stateful critical workloads.
- **Spot:** batch, async workers, elastic compute.
- **Mixed strategy:** app tier with fallback to On-Demand when Spot unavailable.
- Use PodDisruptionBudgets + topology spread + interruption handling.

---

## 5) Ingress and East/West Traffic Architecture

## Ingress architecture

- Use AWS Load Balancer Controller.
- **Public ALB** for internet traffic.
- **Internal ALB/NLB** for private service exposure.
- Ingress classes per trust zone (public/internal).
- Optionally, CloudFront + WAF in front of public ALB for edge protection.

## Production traffic flow

1. Client -> Route53 -> (optional CloudFront/WAF) -> Public ALB
2. ALB -> Ingress controller -> Kubernetes Service -> Pod
3. Pod -> internal services (ClusterIP / service mesh / internal LB)
4. Pod outbound -> NAT or VPC Endpoint
5. Telemetry -> Prometheus/CloudWatch/OTel backends

---

## 6) Storage and Data Protection Architecture

## Storage architecture

- **EBS CSI** for block volumes (gp3 default, io2 for high IOPS).
- **EFS CSI** for shared POSIX volumes.
- StorageClasses by SLA tier (`gp3-standard`, `gp3-critical`, `io2-latency`).
- Enable encryption with KMS CMKs.

## Backup/disaster recovery architecture

- Velero for Kubernetes object + PV snapshot orchestration.
- AWS Backup policies for EBS/EFS/RDS (if used externally).
- Cross-region backup copy for compliance tiers.
- Define workload tiers with explicit RPO/RTO:
  - Tier-0: RPO < 15 min, RTO < 60 min
  - Tier-1: RPO < 1 hr, RTO < 4 hr
  - Tier-2: best effort

---

## 7) Security, IAM, and Isolation Architecture

## Security architecture

- Multi-layer model:
  - Network: SG segmentation + Kubernetes NetworkPolicies
  - Identity: IAM + IRSA + RBAC
  - Runtime: admission policies (OPA/Kyverno), image policies, pod security standards
  - Data: KMS encryption, secret externalization (e.g., AWS Secrets Manager/Vault)
- No SSH to nodes; use SSM Session Manager if node access is unavoidable.
- Image provenance and vulnerability scanning in CI.

## IAM/IRSA architecture

- One IAM role per service account for AWS API access.
- Narrow resource ARNs and conditions (namespace/service account binding).
- Separate IRSA roles per environment and per app domain.
- Dedicated cross-account role pattern for shared services access.

## Security boundaries

- Account boundary (preferred): separate AWS accounts per env/workload class.
- Network boundary: subnet + SG + NACL strategy.
- Cluster boundary: namespace + RBAC + policy controls.
- Node boundary: taints/affinity to isolate sensitive workloads.

## Workload isolation and blast-radius reduction

- Namespace isolation by team/domain.
- Dedicated node pools for security/data-critical workloads.
- Quotas/LimitRanges to prevent noisy-neighbor effects.
- Progressive delivery (canary/blue-green) to limit release impact.

---

## 8) Observability and Operations Architecture

## Observability architecture

- Metrics: Prometheus (or AMP) + Grafana.
- Logs: Fluent Bit -> CloudWatch/OpenSearch.
- Traces: OpenTelemetry Collector -> X-Ray/Jaeger/Tempo.
- SLO-based alerting (latency, error rate, saturation, availability).
- Golden dashboards per platform layer: control plane, node, namespace, service.

## Enterprise operational model

- Platform team owns cluster lifecycle, guardrails, shared services.
- App teams own namespace workloads via GitOps.
- Incident model: on-call rotations, severity matrix, runbooks, postmortems.
- Change model: PR-driven with policy checks and staged promotion.

---

## 9) GitOps and CI/CD Architecture

## GitOps architecture

- Argo CD or Flux as pull-based reconciler.
- Repo separation:
  - **platform repo** (cluster addons, policies, base infra manifests)
  - **application repos** (services, Helm/Kustomize overlays)
  - **environment repo** (promotion state: dev -> staging -> prod)
- Drift detection and self-healing enabled.
- Sync waves/hooks for dependency ordering.

## CI/CD architecture

Pipeline stages:

1. Build + unit tests
2. SAST + dependency + container scan
3. Image signing + SBOM publish
4. Push to ECR
5. Update GitOps manifests (immutable image tag)
6. Progressive deploy + automated verification

Promotion is pull-request based with approvals and policy gates.

---

## 10) Scaling and Failure Behavior

## Scaling behavior

- HPA scales pods based on CPU/memory/custom metrics.
- Cluster Autoscaler or Karpenter scales nodes from pending pods.
- Time-based pre-scaling for known peak windows.
- PriorityClasses ensure critical workloads scale first.

## Failure handling

- Pod failure: liveness/readiness probes + replica self-healing.
- Node failure: workloads rescheduled; autoscaler replaces capacity.
- Control plane issues: AWS-managed EKS HA control plane reduces ops burden.

## AZ failure handling

- Minimum 3 AZ deployment for nodes and load balancing.
- Topology spread constraints + anti-affinity across AZs.
- PDBs tuned so quorum services survive single-AZ loss.
- NAT Gateway per AZ avoids zonal egress dependency.

## Node failure handling

- Managed node group auto-repair/replace behavior.
- Drain-safe configs: PDB + graceful termination + preStop hooks.
- Separate failure domains by node pool purpose.

---

## 11) Recommended Production Topology

- 1 EKS cluster per environment for strong separation, or 1 prod cluster per major business domain for very large orgs.
- 3 AZ region deployment.
- 6 node groups minimum (system/app/batch/data/security separation).
- Public + internal ingress classes.
- Full observability stack with centralized logs/metrics/traces.
- Velero + AWS Backup with cross-region copy for Tier-0/Tier-1.
- GitOps-driven continuous reconciliation.

---

## 12) Recommended HA Strategy

- Multi-AZ EKS + Multi-AZ node groups + ALB cross-zone balancing.
- Replicas >= 3 for critical stateless APIs.
- Stateful sets distributed with zonal awareness.
- Backup + restore drills quarterly.
- Optional multi-region active/passive for regulated or extreme uptime requirements.

---

## 13) Recommended Operational Workflows

1. **Cluster lifecycle**: Terraform plan/apply through controlled pipeline.
2. **Add-on lifecycle**: GitOps managed; version pinning + phased rollout.
3. **Incident response**: alerts -> triage -> runbook -> mitigation -> postmortem.
4. **Patch management**: monthly node AMI/EKS patch windows with canary node groups.
5. **Access management**: JIT privileged access, audited and time-bounded.

---

## 14) Recommended Scaling Workflows

1. Define SLO and scaling signals per workload.
2. Set HPA min/max and PDB/priority policy.
3. Configure autoscaler/Karpenter with constrained instance families.
4. Run load tests and failure injection before production changes.
5. Review monthly: cost, interruption rate, saturation, right-sizing opportunities.

---

## 15) How This Maps to the Repository

- `modules/vpc`: multi-AZ network foundations and subnet layout.
- `modules/eks`: control plane and cluster baseline.
- `modules/node_groups`: capacity topology and isolation.
- `modules/security` + `modules/iam`: guardrails, access, IRSA primitives.
- `modules/storage`: persistent storage strategy.
- `modules/addons` + `modules/autoscaling` + `modules/scheduling`: platform operations plane.
- `tests/`: baseline workload and storage validation manifests.

This blueprint is intended to be **enterprise-comparable**: secure-by-default, resilient, scalable, and operationally governed.
