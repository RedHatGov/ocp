#!/bin/bash
# Mirror content from registry to disk (m2d)
#
# This will download all content based on the imageset-config.yaml to the local .cache directory
# It will also create tar file(s) in the content directory
#   Note: The tar files are designed to be disposable
#          To generate new tars run again and add the since cmd based on what has already been loaded into the disconnected registry
#          ls content/working-dir/.history 

oc-mirror -c imageset-config.yaml \
    file://content \
    --v2 \
    --cache-dir ~/.cache \
#    --since 2025-09-01