# Module 06 — Scaling llm-d

### Brief Overview

Module 6 installs KEDA (Custom Metrics Autoscaler), deploys the model as an LLMInferenceService backed by the llm-d Endpoint Picker (EPP) and InferencePool abstractions, publishes it through MaaS, then creates a KEDA ScaledObject driven by the `vllm:num_requests_waiting` metric sourced from Thanos Querier. Participants drive synthetic inference load with a Python load test script, then observe replica scale-up in real time by watching the HPA and Deployment. A reference-only exercise documents the GPU-specific Workload Variant Autoscaler (WVA) for teams that will eventually move to GPU hardware.

### Audience and Time

- **Target personas:** OCP platform administrators and MLOps engineers responsible for AI workload autoscaling
- **Prerequisites for this module:** Module 5 completed (MaaS governance stack running, User Workload Monitoring enabled, Thanos Querier active); cluster-admin access
- **Estimated duration:** 45 minutes

### Learning Objectives

- Install the KEDA Custom Metrics Autoscaler operator and create a KedaController instance
- Deploy an LLMInferenceService with the llm-d Endpoint Picker and InferencePool resources configured
- Configure a KEDA ScaledObject targeting the vLLM `num_requests_waiting` metric from Thanos Querier
- Drive inference load and observe automated replica scale-up and scale-down behavior

### Lab Structure

| Section | Title | Duration |
|---------|-------|----------|
| 1 | Install the Custom Metrics Autoscaler | 8 min |
| 2 | Deploy an LLMInferenceService | 8 min |
| 3 | Publish the scaling model through MaaS | 5 min |
| 4 | Autoscale with KEDA | 10 min |
| 5 | Drive load and observe scaling | 12 min |
| 6 (Ref) | Workload Variant Autoscaler on GPU | 2 min |

### Detailed Steps

1. Apply the KEDA operator subscription: `oc apply -k manifests/keda/operator/`
2. Wait for the KEDA CSV to reach Succeeded state: `oc wait csv --for condition=Succeeded -n openshift-keda --timeout=5m`
3. Apply the KedaController CR to start the KEDA controller: `oc apply -k manifests/keda/controller/`
4. Verify KEDA components are running: `oc get pods -n openshift-keda`
5. Deploy the LLMInferenceService with llm-d EPP: `oc apply -k manifests/llmd/ -n rhoai-deploy`
6. Wait for LLMInferenceService readiness: `oc wait llminferenceservice <name> --for=condition=Ready -n rhoai-deploy --timeout=10m`
7. Verify the InferencePool CR and EPP Deployment are created and running: `oc get inferencepool -n rhoai-deploy` and `oc get deploy -n rhoai-deploy`
8. Publish the llm-d model through MaaS: apply MaaS governance CRs (same pattern as Module 5) and mint an API key.
9. Apply the KEDA ScaledObject targeting `vllm:num_requests_waiting` from Thanos Querier: `oc apply -k manifests/keda/scaledobject/ -n rhoai-deploy`
10. Verify the ScaledObject and the derived HPA are created: `oc get scaledobject -n rhoai-deploy` and `oc get hpa -n rhoai-deploy`
11. Start the load test script: `python3 load-test.py --endpoint https://<maas-gateway> --api-key $KEY --rate 10`
12. In a second terminal, watch the HPA status update: `oc get hpa -n rhoai-deploy -w`
13. In a third terminal, watch the Deployment replica count: `oc get deploy <llmd-deploy> -n rhoai-deploy -w`
14. Observe replicas scale up from 1 toward the configured maximum as the request queue grows.
15. Stop the load test and observe replicas scale back down after the cooldown period.
16. **(Reference)** Review the Workload Variant Autoscaler (WVA) documentation — a GPU-aware autoscaler that selects between CPU and GPU variants based on demand; no hands-on steps (reference documentation only).

### Key Takeaways

- KEDA ScaledObject targets custom Prometheus metrics from Thanos Querier, enabling AI-workload-aware autoscaling without modifying application code.
- `vllm:num_requests_waiting` is a direct proxy for model serving demand — more reliable than generic CPU/memory signals for LLM inference workloads, which are bursty and latency-sensitive.
- The llm-d Endpoint Picker (EPP) and InferencePool provide intelligent request routing across multiple LLM replicas as they come online during scale-out, minimizing request queuing during ramp-up.
- The Workload Variant Autoscaler (WVA) extends this pattern to heterogeneous hardware (CPU + GPU), selecting the most cost-efficient replica type based on current queue depth.

### Infrastructure Notes

- Module 6 can scale to 4 LLM replicas under load; peak resource budget for model pods alone: 16 CPU + 32 Gi RAM.
- Thanos Querier must be able to scrape the vLLM metrics endpoint — User Workload Monitoring must be enabled (Module 5, Exercise 3a) before applying the ScaledObject.
- KEDA HPA cooldown periods (default: 300 seconds scale-down stabilization) mean scale-down is delayed after load stops — this is expected behavior.
- Ensure the cluster has sufficient CPU headroom across workers to schedule 4 additional vLLM pods at peak; estimate ~20 CPU and 36 Gi RAM total across all Module 6 components.
