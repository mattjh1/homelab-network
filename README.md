# Homelab Network

Simple, repeatable RouterOS setup for home lab.
Source of truth is template scripts in `router/` and `ap/`.

## Network shape

- VLAN 10: MGMT (`192.168.10.0/24`)
- VLAN 20: CORE (`192.168.20.0/24`)
- VLAN 30: SRV (`192.168.30.0/24`)
- VLAN 50: KIDS (`192.168.50.0/24`)
- VLAN 60: IOT (`192.168.60.0/24`)
- VLAN 70: GUEST (`192.168.70.0/24`)

## Big rules

- Never commit real secrets.
- Keep one script per step.
- Run in order (`01` -> `14`).
- If one step fails, stop.
- Fix or roll back before next step.

## Folder map

- `router/` ordered router scripts
- `ap/` AP bootstrap script
- `switch/` manual switch notes
- `docs/network-plan.md` runbook
- `scripts/apply-all.sh` runner
- `secrets.env.example` env template

## First setup (safe way)

### Do

1. Plug only router + your laptop + WAN.
2. Set admin password.
3. Set SSH key auth.
4. Copy env file and fill values.

```bash
cp secrets.env.example secrets.env
chmod 600 secrets.env
```

5. Dry-run first.

```bash
./scripts/apply-all.sh --env secrets.env --dry-run
```

### Check

- SSH key login works.
- Dry-run has no render errors.
- `WAN_INTERFACE`, `LAN_BRIDGE`, `TRUNK_PORT` are correct.

### If broken

- Use direct cable or console access.
- Undo last change.
- Re-run from last good step:

```bash
./scripts/apply-all.sh --env secrets.env --resume
```

## Apply flow

Run with pauses on first real deployment:

```bash
./scripts/apply-all.sh --env secrets.env --pause-each
```

Useful options:

```bash
./scripts/apply-all.sh --env secrets.env --from 05-bridge-vlans.rsc
./scripts/apply-all.sh --env secrets.env --until 07-dhcp.rsc
./scripts/apply-all.sh --env secrets.env --resume
```

## Important behavior

- DHCP input is allowed on non-WAN interfaces so all VLANs can get leases.
- Router admin access is only allowed from MGMT subnet.
- DNS redirect forces CORE/KIDS/IOT to AdGuard.
- Guest DNS uses public resolver (`1.1.1.1` by default).

## AP and switch

- Switch config is manual. See `switch/README.md`.
- AP bootstrap is template-based in `ap/cap-bootstrap.rsc`.
- AP and switch should be connected after base router steps are stable.

## Secrets

- Real values go in `secrets.env` only.
- `secrets.env` is gitignored.
- Planned future: 1Password injection.

