# Postgres Migration Demos

This repo contains two parallel demo families:

- `demo-barman-plugin/`
  The original plugin-based demos:
  `cnpg-pitr`, `cnpg-standby-demo`, and `crunchy-cnpg-migration`.
- `demo-integrated-barman/`
  Integrated-Barman copies of the same three demos.

Each demo is intentionally isolated so its platform assets, manifests, namespaces, and scripts do not depend on another demo directory.
