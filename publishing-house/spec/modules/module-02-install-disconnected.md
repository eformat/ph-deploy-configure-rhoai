# Module 02 — Install (Disconnected)

### Brief Overview

Module 2 is the air-gapped parallel to Module 1, covering RHOAI installation in clusters with no direct internet access. Participants mirror the RHOAI Operator images using oc-mirror v2 in a two-phase disk-transfer workflow, apply the generated CatalogSource, ImageDigestMirrorSet (IDMS), and ImageTagMirrorSet (ITMS) to redirect OLM pulls to the local registry, then complete the DataScienceCluster installation offline. An alternative lighter-weight path using a Quay.io pull-through proxy cache is provided for lab environments where full disk mirroring is impractical. Participants complete one path (full mirror or proxy), not both.

### Audience and Time

- **Target personas:** OCP platform administrators deploying RHOAI in air-gapped or restricted-network environments
- **Prerequisites for this module:** cluster-admin on OCP 4.20+ (OCP 4.22 recommended for oc-mirror v2 stability), oc-mirror v2 binary installed on a connected mirror host, access to a private mirror registry reachable from cluster nodes, workshop manifests cloned
- **Estimated duration:** 40 minutes

### Learning Objectives

- Mirror RHOAI Operator images using oc-mirror v2 in a two-phase connected-to-disconnected workflow
- Apply the generated CatalogSource, ImageDigestMirrorSet, and ImageTagMirrorSet to enable offline OLM installs
- Install RHOAI and create a DataScienceCluster in an air-gapped cluster environment
- Configure a Quay.io pull-through proxy cache as a lightweight alternative to full disk mirroring

### Lab Structure

| Section | Title | Duration |
|---------|-------|----------|
| 1 | Prepare the mirror host | 5 min |
| 2 | Mirror images with oc-mirror v2 | 15 min |
| 3 | Install the local CatalogSource | 8 min |
| 4 | Complete the DataScienceCluster offline | 7 min |
| 5 (Alt) | Quay.io proxy pull-through cache | 5 min |

### Detailed Steps

1. Download and install oc-mirror v2 on the connected mirror host: `curl -L -O <mirror-binary-url> && tar xzvf oc-mirror.tar.gz && sudo mv oc-mirror /usr/local/bin/`
2. Retrieve the cluster pull secret: `oc get secret pull-secret -n openshift-config -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d > pull-secret.json`
3. Create an `ImageSetConfiguration` YAML targeting the RHOAI operator channel and version range.
4. Run Phase 1 — connected host to disk archive: `oc-mirror --v2 -c imagesetconfig.yaml file:///path/to/mirror-archive`
5. Transfer the mirror archive to the disconnected environment (USB drive, sneakernet, or secure file transfer).
6. Run Phase 2 — disk archive to internal mirror registry: `oc-mirror --v2 --from file:///path/to/mirror-archive docker://internal-registry.example.com/`
7. Apply the generated CatalogSource, IDMS, and ITMS from the oc-mirror results directory: `oc apply -k oc-mirror-workspace/results-*/`
8. Verify the local catalog is available: `oc get catalogsource -n openshift-marketplace` and `oc get packagemanifest | grep rhoai`
9. Apply the Operator subscription pointing to the local CatalogSource and wait for the CSV to succeed.
10. Complete the DataScienceCluster installation as in Module 1 (DSCInitialization + DataScienceCluster manifests).
11. **(Alternative) Quay.io proxy:** Configure a mirror-by-tag rule pointing to `quay.io` in an ImageContentSourcePolicy on the cluster; no disk transfer needed — the registry host still requires outbound internet access.

### Key Takeaways

- oc-mirror v2 separates image collection (Phase 1, connected) from cluster-side population (Phase 2, disconnected), enabling true air-gapped workflows.
- The generated IDMS/ITMS resources transparently redirect image pulls cluster-wide — no changes to Operator manifests or Subscriptions are required.
- A Quay.io pull-through proxy cache is faster to configure but requires the registry host to reach `quay.io`; it is not a true air-gap solution.
- OCP 4.22 is recommended for disconnected installs due to improved oc-mirror v2 reliability and IDMS/ITMS handling.

### Infrastructure Notes

- Disconnected path requires a private mirror registry (e.g., Quay, Harbor) reachable from all cluster nodes.
- `mirror.openshift.com` and `registry.redhat.io` must be accessible from the connected mirror host for Phase 1.
- Estimated mirror archive size for RHOAI operator: 50–100 GB depending on version and included component images.
- The pull-through proxy alternative requires the registry host to have outbound access to `quay.io` — verify firewall rules allow this.
