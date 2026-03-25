# 🚀 EKS Platform Architecture (Production-Grade)

## 📌 Overview

This document describes the architecture, design decisions, and trade-offs for a production-grade Kubernetes platform built on AWS EKS.

The goal is to design a **highly available, secure, scalable, and cost-optimized** platform that supports multiple workload types with clear isolation and operational excellence.

---

## 🎯 System Goals

- 🟢 High Availability (Multi-AZ, fault-tolerant)
- 💰 Cost Optimization (Spot + On-Demand strategy)
- 🔒 Strong Security Isolation (workload & IAM boundaries)
- ⚙️ Scalability (horizontal & cluster-level autoscaling)
- 📦 Support for heterogeneous workloads (API, batch, data, etc.)
- 📊 Observability & operational visibility

---

## 📊 Workload Classification & SLA

| Workload   | Description                         | Availability | RTO   | RPO   |
|------------|-------------------------------------|-------------|-------|-------|
| API        | User-facing services                | 99.9%       | <1m   | 0     |
| System     | Core cluster components             | 99.99%      | <1m   | 0     |
| Ingestion  | Data pipelines / CPU-heavy jobs     | Best-effort | N/A   | N/A   |
| Batch      | Non-critical background jobs        | Best-effort | N/A   | N/A   |
| Data       | Stateful services (DB, ETL)         | 99.99%      | <5m   | <1m   |
| Security   | Vault, compliance, security agents  | 99.99%      | <1m   | 0     |

---

## 💰 Cost Strategy

- Use **On-Demand instances** for:
  - API workloads
  - System components
  - Security workloads

- Use **Spot instances** for:
  - Batch workloads (100%)
  - Ingestion workloads (~70%)

- Use **mixed instance types** to:
  - Reduce Spot interruption risk
  - Improve capacity availability

💡 Estimated cost reduction: **~60–70% vs fully On-Demand**

---

## 🌎 Region Strategy

- **Primary Region:** `ca-central-1` (Canada Central 🇨🇦)

### ✅ Reasons:
- Data residency compliance
- Lower latency for Canadian users

### ⚠️ Trade-offs:
- Slightly higher cost vs `us-east-1`
- Lower instance diversity in some cases

---

## 🏗️ High Availability Design

- Multi-AZ deployment (minimum 3 AZs)
- All node groups span multiple AZs
- API workloads:
  - Minimum 3 replicas
  - Load-balanced via ALB

- Control plane:
  - Fully managed by EKS
  - Multi-AZ by default

---

## 🌐 Network Architecture

### VPC Design

- CIDR: `10.0.0.0/16`

### Subnets

| Type     | CIDR Range       | Purpose              |
|----------|------------------|----------------------|
| Public   | 10.0.1.0/24      | ALB / ingress        |
| Public   | 10.0.2.0/24      | ALB / ingress        |
| Private  | 10.0.10.0/24     | Worker nodes         |
| Private  | 10.0.11.0/24     | Worker nodes         |

### Key Principles

- 🔒 Worker nodes in **private subnets only**
- 🌍 Internet access via NAT Gateway
- 🌐 Public subnets only for Load Balancers

---

## 🔐 Security Baseline

- IAM Roles for Service Accounts (IRSA)
- Least privilege access model
- Encryption at rest:
  - EBS volumes
  - Kubernetes secrets
- No SSH access to nodes
- Security Groups:
  - Strict inbound rules
  - Internal communication only where required

### 🔐 Advanced Practices

- Zero Trust mindset
- Workload isolation via node groups + taints
- Dedicated nodes for sensitive workloads

---

## 🧱 Node Group Strategy

| Node Group | Purpose                          | Capacity Type        | Notes |
|------------|----------------------------------|----------------------|------|
| System     | CoreDNS, autoscaler              | On-Demand            | Critical workloads |
| API        | User-facing services             | On-Demand (min=3)    | SLA-sensitive |
| Ingestion  | Data pipelines                   | Mixed (70% Spot)     | Cost-optimized |
| Batch      | Background jobs                  | 100% Spot            | Scale-to-zero |
| Data       | Stateful workloads               | Memory-optimized     | Persistent storage |
| Security   | Vault, compliance tools          | Dedicated            | Isolated |

---

## ⚙️ Scheduling & Isolation

- Node labels for workload targeting
- Taints to enforce isolation
- Tolerations in pod specs
- Node affinity / anti-affinity rules

### Example:

- Security workloads:
  - Only run on dedicated nodes
- Batch workloads:
  - Prefer Spot nodes

---

## 💾 Storage Strategy

- **EBS (gp3, io2)** for:
  - Stateful workloads
- **EFS** for:
  - Shared storage

### Features

- Dynamic provisioning via CSI drivers
- Backup strategy:
  - Velero (planned)

---

## 📈 Scaling Strategy

- Horizontal Pod Autoscaler (HPA)
- Cluster Autoscaler (or Karpenter)

### Goals:

- Fast scale-up for API workloads
- Cost-efficient scaling for batch workloads
- Scale-to-zero for non-critical jobs

---

## 📊 Observability

- Metrics:
  - Prometheus
- Visualization:
  - Grafana
- Logs:
  - CloudWatch

### Future Enhancements

- Alerting rules
- SLO dashboards

---

## 🏷️ Naming Convention

Format:

### Examples:
- `prod-eks-cluster`
- `prod-api-ng`
- `dev-batch-ng`

---

## 🧾 Tagging Strategy

| Key         | Example        |
|-------------|---------------|
| Environment | prod          |
| Owner       | platform-team |
| Project     | eks-platform  |
| CostCenter  | 1234          |

---

## ⚖️ Trade-offs & Decisions

| Decision | Reason | Trade-off |
|----------|------|----------|
| Spot instances | Cost savings | Interruption risk |
| Multi-AZ | High availability | Higher cost |
| Dedicated security nodes | Isolation | Resource overhead |
| ca-central-1 region | Compliance | Higher cost |

---

## 🚧 Future Improvements

- GitOps (ArgoCD / Flux)
- Karpenter for dynamic scaling
- Service Mesh (Istio)
- Advanced security policies (OPA / Kyverno)

---

## 🧠 Summary

This architecture is designed to:

- Balance **cost, reliability, and scalability**
- Support **multiple workload types**
- Provide **strong isolation and security**
- Be **production-ready and extensible**

---

## 👩‍💻 Author

Designed by: **Sara Iravani**  
Role: DevOps / Platform Engineer  
Location: Canada 🇨🇦

