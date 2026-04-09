---
name: ocp-redhat-docs
description: >
  Query official Red Hat OpenShift documentation via Context7 for architecture, networking,
  storage, installation, operators, and any OCP-related topic. Use when asked to "check Red Hat
  docs", "verify with official docs", "buscar en docs de Red Hat", "verificar documentación
  oficial", "what does Red Hat say about", "documentación oficial de OpenShift", "consultar docs
  Red Hat", or any OCP/OpenShift technical question that requires official reference.
  Uses mcp__context7__resolve-library-id with /openshift/openshift-docs library.
  Do NOT use for generating documents (use redhat-cer-docs or redhat-atp-docs).
---

# OpenShift Red Hat Official Documentation Query

## Instructions

When the user asks to verify something against official Red Hat documentation, or needs official references for architecture decisions:

1. **Resolve the library ID** first (if not cached):
   - Use `mcp__context7__resolve-library-id` with `libraryName: "openshift"` and the query
   - The correct ID is `/openshift/openshift-docs`

2. **Query the documentation**:
   - Use `mcp__context7__query-docs` with `libraryId: "/openshift/openshift-docs"` and a specific query
   - Be specific in your query — e.g., "load balancer requirements for agent-based installer platform none" instead of just "load balancer"
   - If the first query doesn't return useful results, rephrase and try again (max 3 attempts)

3. **Format the response**:
   - Show the relevant documentation excerpt
   - Include the source file reference (e.g., `installation-load-balancing-user-infra.adoc`)
   - Explain how it applies to the user's current project context
   - If working in a project with a CLAUDE.md, check if the finding relates to any known discrepancy or pending item

4. **Optionally update project files**:
   - If the project has context files (e.g., `contexto/*.adoc`), offer to update them with the new reference
   - If it affects a documented discrepancy, offer to update the relevant document

## Context7 Library IDs

| Product | Library ID |
|---|---|
| OpenShift Container Platform | `/openshift/openshift-docs` |

## Common Query Topics

### Installation
- Agent-based Installer (install-config.yaml, agent-config.yaml)
- UPI (User-Provisioned Infrastructure)
- IPI (Installer-Provisioned Infrastructure)
- Platform: none / bare metal / Hyper-V / vSphere
- Bootstrap process and requirements
- RHCOS image and versions

### Networking
- Load Balancer requirements (mode tcp, Layer 4, HAProxy reference config)
- serviceNetwork and clusterNetwork CIDR configuration
- machineNetwork (single and multi-subnet)
- OVN-Kubernetes SDN
- DNS requirements (api, api-int, *.apps)
- Firewall port requirements between nodes
- Ingress Controller and Routes (passthrough, edge, reencrypt)

### Storage
- Persistent Volumes (NFS, iSCSI, FC, local)
- StorageClass and dynamic provisioning
- OpenShift Data Foundation (ODF/Ceph)
- Image Registry storage configuration
- CSI drivers

### Security & Certificates
- TLS certificate management (Ingress Controller, API Server)
- Custom wildcard certificate replacement
- Identity Providers (OIDC, LDAP, HTPasswd)
- RBAC and SCC

### Operators & Workloads
- AMQ Streams (Kafka on OpenShift)
- Monitoring (Prometheus, Alertmanager)
- Logging (Elasticsearch, Fluentd, Kibana)
- MachineConfig and MachineConfigPool

### Day 2 Operations
- Node labeling and taints (infra nodes)
- Cluster scaling
- Upgrades and EUS versions
- etcd backup and restore
