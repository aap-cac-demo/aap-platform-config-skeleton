#!/bin/sh
set -eu

ansible-galaxy collection install \
    -r collections/requirements.yml \
    -p ./collections \
    --force \
    --clear-response-cache
