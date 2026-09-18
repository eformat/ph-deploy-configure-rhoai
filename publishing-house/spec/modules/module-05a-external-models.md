# Module 05a — External Models (Optional)

### Brief Overview

Module 5a is an optional supplementary module demonstrating MaaS ExternalModel support by deploying the llm-katan simulator — a lightweight server that mimics the APIs of five external AI providers: OpenAI, Anthropic, Azure OpenAI, AWS Bedrock, and Google Vertex AI. Participants configure ExternalModel resources (and ExternalProvider on RHOAI 3.5+) to route provider-specific requests through the MaaS gateway, mint API keys, and observe per-provider metrics in Perses dashboards. The module documents the resource model differences between RHOAI 3.4 and 3.5 and lists known platform caveats.

### Audience and Time

- **Target personas:** OCP platform administrators and MLOps engineers who need to proxy external AI provider APIs through the MaaS governance layer
- **Prerequisites for this module:** Module 5 completed (full MaaS governance stack running, including RHCL gateway and Perses dashboards)
- **Estimated duration:** 30 minutes

### Learning Objectives

- Deploy the llm-katan simulator to emulate multiple external AI provider API endpoints
- Configure ExternalModel resources to route provider-specific requests through the MaaS gateway
- Verify API key–authenticated requests to each simulated provider endpoint using the correct request format
- Observe per-provider request metrics in Perses observability dashboards

### Lab Structure

| Section | Title | Duration |
|---------|-------|----------|
| 1 | Deploy the llm-katan simulator | 8 min |
| 2 | Mint an API key and call each provider | 15 min |
| 3 | View simulator metrics in Perses | 5 min |
| — | Cleanup (optional) | 2 min |

### Detailed Steps

1. Deploy llm-katan using Helm template piped to `oc apply`: `helm template manifests/llm-katan/ | oc apply --server-side -f -`
2. Wait for llm-katan to become available: `oc rollout status deployment/llm-katan -n rhoai-deploy`
3. Verify the simulator started correctly by checking logs: `oc logs -l app=llm-katan -n rhoai-deploy`
4. Retrieve the llm-katan service endpoint for use in ExternalModel CRs.
5. **(RHOAI 3.5 only)** Apply the ExternalProvider CR: `oc apply -f manifests/external-models/externalprovider.yaml -n rhoai-deploy`
6. **(RHOAI 3.5 only)** Patch the ExternalProvider to enable each provider type: `oc patch externalproviders ...`
7. Apply ExternalModel CRs for each of the five providers (OpenAI, Anthropic, Azure OpenAI, AWS Bedrock, Google Vertex AI): `oc apply -f manifests/external-models/externalmodels/ -n rhoai-deploy`
8. Verify ExternalModel resources are created and synced: `oc get externalmodel -n rhoai-deploy`
9. Retrieve the current MaaS gateway endpoint.
10. Mint an API key scoped to the external models via the MaaS API.
11. Send test requests to each provider's simulated endpoint using the provider-specific request format (e.g., Bedrock uses different headers than OpenAI).
12. Observe the different response formats returned by each llm-katan provider endpoint.
13. Open the Perses dashboard and navigate to the External Models panel.
14. Verify per-provider request counts, latency, and error rate metrics.
15. **(Optional)** Clean up: `oc delete externalmodel --all -n rhoai-deploy` and uninstall llm-katan.

### Key Takeaways

- ExternalModel resources allow MaaS to apply the same API-key authentication and rate-limiting policies to external provider calls as it does to internally served models.
- RHOAI 3.4 uses the ExternalModel CRD alone; RHOAI 3.5 adds ExternalProvider (for provider-level configuration) and the Inference Payload Processor (IPP, for request transformation) — the module uses `ifeval` conditionals to gate version-specific steps.
- The llm-katan simulator is a test harness only — it returns deterministic synthetic responses and does not perform real LLM inference; no GPU or model weights are required.
- Known platform caveats are documented within the module and should be reviewed before adopting ExternalModel in a production MaaS deployment.

### Infrastructure Notes

- llm-katan resource requirements are minimal: 0.5 CPU, 512 Mi RAM.
- ExternalProvider CRD is only available in RHOAI 3.5+ clusters; attempts to apply it on 3.4 will fail — the content gates this with `ifeval`.
- No additional external network access is required for this module; all traffic is in-cluster (llm-katan runs inside OCP).
