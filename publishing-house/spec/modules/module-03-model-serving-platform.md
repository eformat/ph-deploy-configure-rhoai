# Module 03 — Model-Serving Platform

### Brief Overview

Module 3 prepares the OCP cluster to host KServe-based model serving by creating the `rhoai-deploy` workshop project, enabling KServe single-model serving cluster-wide, and instantiating the vLLM CPU x86 ServingRuntime template in the project namespace. This module establishes the namespace-level and cluster-level configuration that all subsequent model deployment exercises depend on. Optional steps cover creating a storage connection Secret and setting a default deployment strategy annotation.

### Audience and Time

- **Target personas:** OCP platform administrators, MLOps engineers
- **Prerequisites for this module:** RHOAI installed with KServe component enabled (Module 1 or Module 2 completed), cluster-admin access
- **Estimated duration:** 20 minutes

### Learning Objectives

- Create and label the `rhoai-deploy` project namespace to activate KServe single-model serving
- Verify KServe single-model serving is enabled at the cluster level via the DataScienceCluster
- Instantiate the vLLM CPU x86 ServingRuntime template in the workshop project namespace

### Lab Structure

| Section | Title | Duration |
|---------|-------|----------|
| 1 | Create the workshop project | 3 min |
| 2 | Enable model serving | 5 min |
| 3 | Make a vLLM serving runtime available | 8 min |
| 4 (Opt) | Create a storage connection Secret | 2 min |
| 5 (Opt) | Set a default deployment strategy | 2 min |

### Detailed Steps

1. Create the workshop project: `oc new-project rhoai-deploy`
2. Apply the namespace label that enables KServe (disables ModelMesh): `oc label namespace rhoai-deploy modelmesh-enabled=false`
3. Verify the project exists and the label is set: `oc get project rhoai-deploy -o yaml`
4. Confirm KServe is enabled in the DataScienceCluster: `oc get datasciencecluster -o jsonpath='{.status.conditions}' | jq`
5. Inspect the pre-installed vLLM CPU x86 ServingRuntime template installed by RHOAI: `oc get template vllm-cpu-x86-runtime -n redhat-ods-applications`
6. Process the template and apply it to the workshop namespace: `oc process vllm-cpu-x86-runtime -n redhat-ods-applications | oc apply -n rhoai-deploy -f -`
7. Verify the ServingRuntime is present: `oc get servingruntime -n rhoai-deploy`
8. **(Optional)** Create a storage connection Secret for future S3-backed model deployments: `oc apply -f manifests/storage-connection/ -n rhoai-deploy`
9. **(Optional)** Set the default deployment strategy annotation on the namespace: `oc annotate namespace rhoai-deploy serving.kserve.io/deploymentMode=RawDeployment`

### Key Takeaways

- KServe vs ModelMesh selection is controlled per namespace via the `modelmesh-enabled` label — setting it to `false` routes all InferenceService resources in that namespace to KServe.
- The vLLM CPU x86 ServingRuntime is installed cluster-wide by RHOAI but must be explicitly instantiated into each project namespace; it is not auto-deployed.
- No object storage is required when using OCI modelcar images — the modelcar pattern is used throughout this workshop, so storage connection Secrets are optional.
- The `RawDeployment` mode runs KServe predictor pods directly without Knative; it is required for workloads that rely on KEDA autoscaling (Module 6).

### Infrastructure Notes

- ServingRuntime instantiation is namespace-scoped; each project hosting vLLM CPU workloads needs its own ServingRuntime copy.
- Template parameters for resource limits (CPU request/limit, memory request/limit) default to values appropriate for Qwen2.5-0.5B-Instruct (4 CPU, 8 Gi RAM).
