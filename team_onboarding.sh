#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <dev|staging|prod>" >&2
    exit 2
fi

target_env="$1"
vault_password_file="${VAULT_PASSWORD_FILE:-../.vault-pass}"

ansible-playbook \
    -i "inventory/inventory_${target_env}.yml" \
    -l "$target_env" \
    --vault-password-file="$vault_password_file" \
    playbooks/team_onboarding.yml
