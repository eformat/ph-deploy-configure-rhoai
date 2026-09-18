# Module 04 — Serving with vLLM

### Brief Overview

Module 4 deploys the Qwen2.5-0.5B-Instruct model as a KServe InferenceService using the vLLM CPU runtime and an OCI modelcar image hosted on Quay.io. Participants apply the InferenceService manifest, monitor its transition to Ready state, then make authenticated inference requests using curl against the OpenAI-compatible `/v1/chat/completions` endpoint. The module also maps RHOAI's access-control spectrum (open, kube-rbac-proxy, token-scoped) and provides a walkthrough of the vLLM CPU-tuning arguments in the ServingRuntime YAML.

### Audience and Time

- **Target personas:** OCP platform administrators, MLOps engineers
- **Prerequisites for this module:** `rhoai-deploy` project and vLLM CPU ServingRuntime created (Module 3 completed)
- **Estimated duration:** 30 minutes

### Learning Objectives

- Deploy Qwen2.5-0.5B-Instruct as a KServe InferenceService using the vLLM CPU runtime and OCI modelcar image
- Verify successful model deployment by querying the OpenAI-compatible inference API endpoint with an authenticated request
- Analyze the access-control options available on the KServe inference route (kube-rbac-proxy, service account tokens, open access)

### Lab Structure

| Section | Title | Duration |
|---------|-------|----------|
| 1 | Deploy the CPU model | 10 min |
| 2 | Query the OpenAI-compatible API | 10 min |
| 3 | Understand the access-control options | 6 min |
| 4 (Opt) | Inspect the vLLM runtime arguments | 4 min |

### Detailed Steps

1. Apply the InferenceService Kustomize overlay: `oc apply -k manifests/inference/qwen2.5/ -n rhoai-deploy`
2. Monitor InferenceService status: `oc get inferenceservice -n rhoai-deploy -w`
3. Wait for Ready condition: `oc wait inferenceservice qwen2.5-0.5b-instruct --for=condition=Ready -n rhoai-deploy --timeout=10m`
4. Confirm the pod is running: `oc get pods -n rhoai-deploy`
5. Retrieve the inference route URL: `oc get route -n rhoai-deploy`
6. Mint a short-lived service account token for authentication: `oc create token default -n rhoai-deploy`
7. Store the token in an environment variable: `export TOKEN=$(oc create token default -n rhoai-deploy)`
8. Send a chat completion request: `curl -s -H "Authorization: Bearer $TOKEN" https://<route>/v1/chat/completions -H "Content-Type: application/json" -d '{"model":"qwen2.5-0.5b-instruct","messages":[{"role":"user","content":"What is Red Hat OpenShift AI?"}]}'`
9. Confirm a valid response body is returned with completion tokens.
10. Review the access-control spectrum: examine kube-rbac-proxy configuration, ServiceAccount, RoleBinding, and the open-access annotation option.
11. **(Optional)** Inspect the InferenceService YAML for CPU-tuning arguments: `oc get inferenceservice qwen2.5-0.5b-instruct -n rhoai-deploy -o yaml` — review `--max-model-len`, `--dtype=float32`, CPU thread-pool flags.

### Key Takeaways

- KServe InferenceService + vLLM CPU runtime enables serving small quantized LLMs on standard OCP workers — no GPU hardware is required.
- The OCI modelcar pattern packages model weights inside a container image; Quay.io serves as the model registry and eliminates S3 dependency entirely.
- kube-rbac-proxy sits in front of the vLLM pod and enforces OCP token-based authentication; the workshop uses short-lived service account tokens for the curl exercises.
- CPU serving requires disabling GPU-specific parallelism flags and tuning `--max-model-len` to fit within available RAM; these are pre-configured in the Kustomize overlay.

### Infrastructure Notes

- vLLM pod resource request: 4 CPU, 8 Gi RAM (set in the ServingRuntime template).
- Cold-start time (model weight load from OCI image): 2–5 minutes on typical CPU workers with 8+ cores.
- Qwen2.5-0.5B-Instruct requires approximately 2 Gi of RAM for model weights at float32; the 8 Gi request provides headroom for the KV cache.
- The OCI modelcar image is pulled from `quay.io` — outbound access to Quay.io is required from cluster nodes.
