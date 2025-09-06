#!/bin/bash
# Mirror content from registry to local disk storage
# Creates content/ directory with all images and metadata

# Create content directory structure and cache
oc-mirror -c imageset-config.yaml \
    file://content \
    --v2 \
    --cache-dir ~/.cache \
#    --since 2025-09-01

