#!/bin/bash
# Upload tar content to registry
# Cache will be created fresh on this host - no cache transfer needed!

oc-mirror -c imageset-config.yaml \
    --from file://content \
    docker://$(hostname):8443 \
    --v2 \
    --cache-dir ~/.cache