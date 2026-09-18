# RHOAI Deploy & Configure Workshop

## Overview

This hands-on lab guides OCP platform administrators and MLOps engineers through the complete lifecycle of deploying and operating Red Hat OpenShift AI (RHOAI) on CPU-only OpenShift clusters — no GPU is required for any exercise. The lab exists to give platform teams a repeatable, end-to-end path for installing RHOAI, enabling KServe-based model serving, and operating the full Models-as-a-Service (MaaS) governance stack in production-representative conditions.

Participants install the RHOAI Operator via OLM in both connected and air-gapped cluster environments, configure a DataScienceCluster with KServe single-model serving, deploy a quantized LLM (Qwen2.5-0.5B-Instruct) via the vLLM CPU runtime using OCI modelcar images, stand up the MaaS governance stack (PostgreSQL, Red Hat Connectivity Link, Authorino, Limitador, observability), govern models as LLMInferenceService resources via API keys and rate limits, and configure KEDA-based autoscaling for llm-d-served models driven by live vLLM queue metrics from Thanos Querier.

## Target Audience

- **Role:** OCP platform administrators and MLOps engineers responsible for deploying and operating AI/ML infrastructure
- **Experience level:** Advanced
- **What they already know:** OCP cluster administration (Namespaces, Operators, Routes, ClusterServiceVersions, RBAC), oc CLI proficiency, Kustomize basics, foundational LLM serving concepts
- **What they don't know:** RHOAI installation and operator lifecycle management, KServe configuration for single-model serving, vLLM CPU deployment patterns, MaaS governance architecture and configuration, llm-d autoscaling with KEDA

## Prerequisites

- cluster-admin access to an OCP 4.20+ cluster (SNO or multinode; CPU-only — no GPU nodes required)
- Ability to install OLM operators from OperatorHub or a local CatalogSource
- Familiarity with the oc CLI and core OCP concepts: Namespaces, Operators, Routes, ClusterServiceVersions, RBAC
- Working knowledge of Kustomize (`oc apply -k`)
- Basic understanding of LLM serving concepts (inference endpoints, tokens)
- No object storage (S3) required — model weights are loaded from OCI modelcar images on Quay.io
- Lab prerequisites cannot be validated automatically; participants are expected to meet them before starting

## Learning Objectives

1. Install the RHOAI Operator from OLM in connected and air-gapped cluster environments
2. Configure a DataScienceCluster resource with KServe single-model serving and MaaS components enabled
3. Deploy a CPU-optimized LLM as a KServe InferenceService using the vLLM CPU runtime
4. Verify inference API responses through authenticated requests to the OpenAI-compatible endpoint
5. Deploy the MaaS governance stack including PostgreSQL, Red Hat Connectivity Link, Authorino, and Limitador
6. Govern LLM access by provisioning API keys, enforcing rate limits, and observing MaaS telemetry
7. Configure ExternalModel resources to proxy external AI provider endpoints through the MaaS gateway
8. Deploy llm-d with KEDA autoscaling driven by vLLM queue metrics from Thanos Querier
9. Analyze replica scaling behavior by driving inference load and monitoring scale-up events

## Content Type

Lab (hands-on)

## Products & Technologies

- Red Hat OpenShift AI (RHOAI) 3.4 and 3.5
- Red Hat OpenShift Container Platform (OCP) 4.20+
- KServe (single-model serving, Raw Deployment mode)
- vLLM (CPU x86 runtime)
- llm-d (distributed inference, Endpoint Picker / InferencePool)
- Models-as-a-Service (MaaS, Tech Preview)
- Red Hat Connectivity Link (RHCL) / Kuadrant
- Authorino, Limitador, cert-manager
- Leader Worker Set operator, JobSet operator
- KEDA / Custom Metrics Autoscaler
- Cluster Observability Operator (COO)
- Red Hat build of OpenTelemetry
- Perses, Prometheus / User Workload Monitoring / Thanos Querier
- PostgreSQL (RHEL 9, in-cluster)
- oc-mirror v2, Kustomize, Helm v3
- Qwen2.5-0.5B-Instruct model (OCI modelcar on Quay.io)
- Gateway API (Envoy-based)
- kube-rbac-proxy

## Module Map

| Module | Title | Duration |
|--------|-------|----------|
| 1 | Install (Connected) | 25 min |
| 2 | Install (Disconnected) *(alt path)* | 40 min |
| 3 | Model-Serving Platform | 20 min |
| 4 | Serving with vLLM | 30 min |
| 5 | MaaS Governance | 60 min |
| 5a | External Models *(optional)* | 30 min |
| 6 | Scaling llm-d | 45 min |
| — | **Total hands-on (connected path, excl. 5a)** | **~210 min** |
| — | Getting Connected (setup) | 10 min |
| — | Conclusion + Cleanup | 15 min |
| — | **Total lab** | **~4 hours** |

*Module 2 is a parallel path to Module 1 for air-gapped clusters — participants complete one or the other, not both.*

## Difficulty Level

Advanced

## Environment

**Learner view:** Participants start with a bare OCP 4.20+ cluster with cluster-admin access. No RHOAI components are pre-deployed — every operator, namespace, and configuration resource is created during the lab exercises. Participants clone the workshop's Kustomize manifests repository (GitHub) during the setup module and use `oc apply -k` throughout. Model weights are pulled automatically from OCI modelcar images on Quay.io — no object storage setup is required. In-cluster PostgreSQL is deployed as part of the MaaS governance module.

**Automation needed:** Yes — the workshop depends on a pre-staged Kustomize manifests repository on GitHub that participants clone. The cluster itself does not require pre-provisioned RHOAI components; setup automation provisions only the base OCP cluster.

## Infrastructure Requirements

- **Cloud provider:** TBD — confirmed in infrastructure phase
- **Cluster type:** TBD — confirmed in infrastructure phase
- **OCP version:** TBD — confirmed in infrastructure phase
- **Topology:** TBD — confirmed in infrastructure phase
- **Sizing:** TBD — confirmed in infrastructure phase
- **Automation approach:** TBD — confirmed in infrastructure phase
- **AI/MaaS:** TBD — confirmed in infrastructure phase
- **External services:** TBD — confirmed in infrastructure phase
- **AAP version:** TBD — confirmed in infrastructure phase
- **Non-GA products:** TBD — confirmed in infrastructure phase

## Assessment Strategy (Optional)

No automated assessment. Participants verify their own progress by observing CLI output, resource status conditions, and dashboard state at the end of each exercise. Each module section ends with a visible result (e.g., InferenceService Ready, rate-limit 429 response, HPA replica count increasing) that confirms correct completion.
