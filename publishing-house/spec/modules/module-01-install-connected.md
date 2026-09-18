# Module 01 — Install (Connected)

### Brief Overview

Module 1 walks participants through installing the RHOAI Operator from Red Hat's OLM-based OperatorHub into a connected (internet-accessible) OCP cluster. Starting from a bare cluster, participants apply Kustomize manifests to create the Operator subscription, wait for the CSV to succeed, instantiate a DSCInitialization, and then create a DataScienceCluster that enables the dashboard and KServe components. The module branches on RHOAI 3.4 vs 3.5 via `ifeval` conditional blocks baked into the content; both versions are supported from the same page. Participants end with dashboard access confirmed and predefined namespaces verified.

### Audience and Time

- **Target personas:** OCP platform administrators, MLOps engineers
- **Prerequisites for this module:** cluster-admin access on OCP 4.20+, oc CLI configured and authenticated, workshop manifests repository cloned (Getting Connected completed)
- **Estimated duration:** 25 minutes

### Learning Objectives

- Install the RHOAI Operator from OLM into the `redhat-ods-operator` namespace using Kustomize manifests
- Create a DSCInitialization and DataScienceCluster with the dashboard and KServe components enabled
- Verify successful operator installation by inspecting CSV status, DataScienceCluster conditions, and predefined namespace creation

### Lab Structure

| Section | Title | Duration |
|---------|-------|----------|
| 1 | Install the RHOAI Operator | 10 min |
| 2 | Create the DataScienceCluster | 8 min |
| 3 | Open the RHOAI Dashboard | 4 min |
| 4 | Confirm predefined namespaces | 3 min |

### Detailed Steps

1. Apply the RHOAI Operator Kustomize overlay: `oc apply -k manifests/rhoai/operator/overlays/connected/`
2. Wait for the CSV to reach Succeeded state: `oc wait csv --for condition=Succeeded -n redhat-ods-operator --timeout=5m`
3. Verify the installed version: `oc get csv -n redhat-ods-operator`
4. Apply the DSCInitialization manifest: `oc apply -k manifests/rhoai/dsc-init/`
5. Apply the version-appropriate DataScienceCluster overlay (3.4 or 3.5): `oc apply -k manifests/rhoai/dsc/overlays/3.x/`
6. Wait for the DataScienceCluster to reach Ready state: `oc wait datasciencecluster --for condition=Ready --timeout=10m`
7. Retrieve the RHOAI dashboard Route: `oc get route -n redhat-ods-applications`
8. Open the dashboard URL in a browser and confirm login.
9. Verify predefined namespaces: `oc get ns | grep -E 'redhat-ods|rhods'`

### Key Takeaways

- RHOAI installs into a dedicated operator namespace (`redhat-ods-operator`) via an OLM Subscription; the operator itself manages all downstream namespaces.
- The DataScienceCluster CR is the central control-plane resource — enabling or disabling platform capabilities (KServe, dashboard, MaaS) is done by editing this single resource.
- RHOAI creates a predictable set of application namespaces on installation; these are prerequisites for downstream exercises.
- The 3.4 vs 3.5 DSC schema differs in how components are declared; the workshop handles this with version-gated Kustomize overlays.

### Infrastructure Notes

- No GPU nodes required for this module.
- External registry access required: `registry.redhat.io` and `quay.io` must be reachable from cluster nodes.
- Operator pod scheduling requires at least one worker with ~2 CPU and 4 Gi RAM available.
