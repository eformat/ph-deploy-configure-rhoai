# Module 05 — MaaS Governance

### Brief Overview

Module 5 is the most complex module, standing up the complete Models-as-a-Service (MaaS) governance stack in nine sequential exercises. Starting from the `rhoai-deploy` namespace, participants deploy in-cluster PostgreSQL (the MaaS control-plane database), install Red Hat Connectivity Link (Kuadrant) and bootstrap the Envoy gateway, configure Authorino (authentication) and Limitador (rate limiting), enable User Workload Monitoring and COO-based observability (OpenTelemetry + Perses), then enable MaaS in the DataScienceCluster. The model is deployed as an LLMInferenceService governed by MaaS CRs; participants mint API keys, drive rate-limited inference requests, and observe telemetry in Perses dashboards.

### Audience and Time

- **Target personas:** OCP platform administrators and MLOps engineers responsible for AI governance and multi-tenant model access
- **Prerequisites for this module:** Module 4 completed (vLLM InferenceService running), cluster-admin access, User Workload Monitoring not yet enabled (this module enables it)
- **Estimated duration:** 60 minutes

### Learning Objectives

- Deploy in-cluster PostgreSQL and provision the secrets required by the MaaS control plane
- Install Red Hat Connectivity Link (Kuadrant) and bootstrap the Envoy-based gateway
- Enable User Workload Monitoring and the COO observability stack (OpenTelemetry, Perses) for MaaS metrics
- Deploy a model as an LLMInferenceService and publish it through MaaS governance resources (API keys, rate limits)
- Demonstrate rate limiting behavior and observe MaaS telemetry alongside vLLM engine metrics in Perses dashboards

### Lab Structure

| Section | Title | Duration |
|---------|-------|----------|
| 1 | Provision PostgreSQL and secrets | 5 min |
| 2 | Install RHCL and bootstrap the gateway | 8 min |
| 3a | Enable User Workload Monitoring | 5 min |
| 3b | Install serving-path and observability operators | 8 min |
| 3c | Enable MaaS in the DSC and dashboard | 4 min |
| 4 | Deploy the model as an LLMInferenceService | 8 min |
| 5 | Publish and govern the model | 6 min |
| 6 | Mint an API key and call the model | 5 min |
| 7 | Demonstrate rate limiting | 5 min |
| 8 | View engine metrics and MaaS telemetry | 4 min |
| 9 | Test in the Gen AI playground | 2 min |

### Detailed Steps

1. Generate a random PostgreSQL password: `openssl rand -base64 32 | tr -d '=+/' | head -c 32`
2. Create the PostgreSQL credentials secret in the `rhoai-deploy` namespace.
3. Deploy PostgreSQL using Kustomize: `oc apply -k manifests/maas/postgresql/ -n rhoai-deploy`
4. Wait for PostgreSQL to become available: `oc rollout status deployment/postgresql -n rhoai-deploy`
5. Install the RHCL operator subscription: `oc apply -k manifests/rhcl/operator/` and wait for CSV to succeed.
6. Apply the Kuadrant CR and Envoy gateway bootstrap manifests: `oc apply -k manifests/rhcl/gateway/`
7. Patch the Authorino CR if needed to set the `--ext-authz-timeout` flag: `oc patch authorino authorino --type merge -p '...'`
8. Enable User Workload Monitoring by patching the `cluster-monitoring-config` ConfigMap in `openshift-monitoring`.
9. Install the Leader Worker Set operator subscription and wait for readiness.
10. Install the JobSet operator subscription and wait for readiness.
11. Install the Cluster Observability Operator (COO) subscription.
12. Install the Red Hat build of OpenTelemetry subscription and wait for readiness.
13. Enable MaaS in the DataScienceCluster by applying the MaaS-enabled DSC overlay: `oc apply -k manifests/rhoai/dsc/overlays/maas/`
14. Verify MaaS components are running: `oc rollout status -n redhat-ods-applications`
15. Deploy the model as an LLMInferenceService: `oc kustomize manifests/maas/llm-inferenceservice/ | envsubst | oc apply -f -`
16. Wait for LLMInferenceService readiness.
17. Apply MaaS governance CRs (MaaSToken, RateLimitPolicy): `oc apply -k manifests/maas/governance/ -n rhoai-deploy`
18. Mint an API key via the MaaS API: `curl -X POST https://<maas-gateway>/api-keys -H "Authorization: Bearer $TOKEN" ...`
19. Store the API key and call the model through the MaaS gateway endpoint.
20. Drive a rate-limit loop to trigger 429 responses: `for i in $(seq 100); do curl -s -o /dev/null -w "%{http_code}" https://<maas-gateway>/v1/chat/completions ...; done`
21. Observe rate-limit rejections in terminal output and Limitador metrics.
22. Open the Perses dashboard and review vLLM engine metrics (requests per second, latency, KV cache utilization) and MaaS telemetry panels (API key usage, rate-limit events).
23. Navigate to the RHOAI dashboard Gen AI playground and submit a test prompt via the MaaS-governed endpoint.

### Key Takeaways

- MaaS adds a full governance layer above KServe: the Kuadrant gateway mediates all inference traffic, Authorino enforces API-key authentication, and Limitador applies per-key rate limits.
- The LLMInferenceService CRD is the MaaS-aware model resource — it wraps the underlying InferenceService and binds to MaaS policy CRs.
- COO + OpenTelemetry + Perses forms a self-contained observability stack; no external Prometheus or Grafana instance is required.
- MaaS is a Tech Preview feature in RHOAI 3.4 and 3.5 — not recommended for production workloads without Red Hat support guidance.

### Infrastructure Notes

- PostgreSQL requires a PersistentVolumeClaim; ensure a StorageClass with dynamic provisioning is available.
- RHCL/Kuadrant deploys an Envoy-based gateway pod — budget approximately 2 CPU and 4 Gi RAM for gateway components.
- COO and OpenTelemetry add approximately 1 CPU and 2 Gi RAM of additional cluster overhead.
- Total additional resource budget for Module 5 components (beyond the vLLM pod): approximately 8 CPU and 20 Gi RAM across all new deployments.
