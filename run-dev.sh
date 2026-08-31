#!/usr/bin/env bash
# Apply platform config, then onboard teams, against the dev inventory.
# Extra ansible-playbook args are forwarded (e.g. -e, --limit, -v).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

INVENTORY="${INVENTORY:-inventories/dev.yml}"

ansible-playbook playbooks/apply_config.yml -i "$INVENTORY" "$@"
ansible-playbook playbooks/team_onboarding.yml -i "$INVENTORY" "$@"
