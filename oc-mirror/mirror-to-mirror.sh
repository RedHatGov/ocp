#!/bin/bash
# Mirror content directly from registry to registry (semi-connected flow)
# Bypasses disk storage - direct registry-to-registry mirroring

# Direct mirror from source registry to target registry
oc-mirror -c imageset-config.yaml \
    --workspace file://content \
    docker://$(hostname):8443 \
    --v2 \
    --cache-dir .cache
