# AAP Platform Configuration Skeleton

This repository is a fill-in-the-blanks Configuration as Code skeleton for
Red Hat Ansible Automation Platform 2.7 platform resources. It supports
three environments (`dev`, `staging`, and `prod`), platform RBAC, LDAP,
private Automation Hub, execution environments, team onboarding/offboarding,
cross-organization sharing, and Jenkins promotion.

It contains no deployable customer team or sharing definitions. Do not run an
apply or onboarding playbook until every placeholder has been replaced and
the secrets have been encrypted.

## Required setup

1. Replace every `<...>` token in the inventory, environment files,
   `ansible.cfg`, and `Jenkinsfile`.
2. Set the gateway URL, certificate-validation setting, administrator
   username, and administrator password for each environment.
3. Set the SCM repository URL and credentials used to sync this repository.
4. Set the LDAP endpoint, bind identity, search bases and filters, group type,
   TLS behavior, and platform access/admin/operator group DNs.
5. Set the Red Hat API token and Hub custom collection namespace.
6. Review the secure default for Hub certificate validation in `ansible.cfg`.
7. Encrypt sensitive values in each `config/<env>/secrets.yml` with
   `ansible-vault` and store the vault password outside this repository.

The same variable names are present in all three environment directories so
each AAP cluster can be configured independently.

## Directory layout

```text
inventory/                         AAP gateway connection per environment
config/all/                        Shared dispatch-managed resources
config/<env>/_commons.yml          Non-secret environment values
config/<env>/secrets.yml            Secret values to encrypt with Ansible Vault
team_definitions/team.yml.template  Copy to a completed team definition
sharing_definitions/sharing.yml.template  Copy to a completed sharing definition
playbooks/                         Apply, lifecycle, sharing, and Hub playbooks
collections/requirements.yml       Required Ansible collections
```

Files ending in `.template` are intentionally excluded from the playbooks'
`*.yml` discovery. Copy a template to a new `.yml` file only after filling all
required fields.

## Team onboarding

1. Copy `team_definitions/team.yml.template` to
   `team_definitions/<team-name>.yml`.
2. Fill the team name, organization display name, description, LDAP group DNs,
   optional sub-teams, instance group, CaC repository URL, and environments.
3. Review the file and merge it through the platform configuration change
   process.
4. Run the onboarding wrapper for the target environment:

```bash
./team_onboarding.sh <dev|staging|prod>
```

The onboarding playbook creates the organization, operator team, LDAP maps,
service account, vault credential, CaC inventory, CaC project, and apply job
template. It is idempotent and can be run again after a failed attempt.

To offboard a team, supply its completed definition name directly to the
playbook:

```bash
ansible-playbook \
  -i inventory/inventory_<env>.yml \
  -l <env> \
  --vault-password-file <vault-password-file> \
  playbooks/team_offboarding.yml \
  -e team_name=<team-name>
```

## Cross-organization sharing

Copy `sharing_definitions/sharing.yml.template` to a completed `.yml` file
only when a reviewed sharing grant is required. Specify the owner
organization, consumer team, resource grants, and state. Use the API-based
playbook for cross-organization grants:

```bash
ansible-playbook \
  -i inventory/inventory_<env>.yml \
  -l <env> \
  --vault-password-file <vault-password-file> \
  playbooks/apply_sharing_api.yml
```

The module-based playbook remains available for same-organization grants.

## Applying platform configuration

Install the collections after configuring the Hub credentials expected by
`ansible.cfg`:

```bash
./fetch-collections.sh
```

Validate before applying:

```bash
ansible-lint playbooks/
yamllint -c .yamllint config inventory team_definitions sharing_definitions
```

Apply a selected environment with its vault password file:

```bash
VAULT_PASSWORD_FILE=<vault-password-file> ./apply-config.sh <dev|staging|prod>
```

The Jenkins pipeline performs collection installation, lint, dry-run, and
environment-specific promotion. Replace its credential ID placeholders
before enabling the pipeline.

## Shared resources

The shared configuration keeps the platform organization, operator team,
custom credential types, global execution environments, controller project,
Hub remotes and repositories, Hub credentials, token refresh, and collection
sync job templates. Team-specific projects, inventories, credentials, and job
templates are created by the onboarding playbook and then managed by each
team's own CaC repository.

## Secrets and safety

Never commit plaintext customer secrets or vault passwords. The committed
secret files are placeholders only. Replace them locally, encrypt sensitive
values with `ansible-vault encrypt_string` or `ansible-vault encrypt`, and
verify that no `<...>` tokens remain before applying.

This skeleton sanitizes the current working tree only. Existing Git history
and the repository remote are outside the scope of this folder.
