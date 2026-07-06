# Homelab Network

Simple, repeatable RouterOS setup for home lab.
Source of truth is template scripts in `router/` and `ap/`.

## Network shape

- VLAN 10: MGMT — CAPsMAN AP management (`192.168.110.0/24` on `vlan-mgmt`)
- VLAN 20: CORE (`192.168.20.0/24`)
- VLAN 30: SRV (`192.168.30.0/24`)
- VLAN 50: KIDS (`192.168.50.0/24`)
- VLAN 60: IOT (`192.168.60.0/24`)
- VLAN 70: GUEST (`192.168.70.0/24`)

`ether6` is a standalone emergency access port at `192.168.10.1/24` — NOT part of the bridge or any VLAN.

## Big rules

- Never commit real secrets.
- Keep one script per step.
- Run in order (`01` -> `14`).
- If one step fails, stop.
- Fix or roll back before next step.

## Folder map

- `router/` ordered router scripts
- `ap/` AP bootstrap script
- `switch/` optional notes (not required in current router-as-switch path)
- `docs/network-plan.md` runbook
- `scripts/apply-all.sh` runner
- `secrets.env.example` env template

## Router port map (current hardware)

- `ether1`: WAN uplink
- `ether2`: office access (CORE VLAN 20)
- `ether3`: office access (SRV VLAN 30, server)
- `ether4`: AP trunk (via PoE injector, tagged VLANs)
- `ether5`: living room dumb switch uplink (IOT VLAN 60)
- `ether6`: emergency fallback (standalone, direct IP `192.168.10.1/24`, NOT in bridge — always reachable regardless of VLAN config)

## First setup (safe way)

### Do

1. Plug only router + your laptop + WAN.
2. Fresh router reminder: default IP is usually `192.168.88.1` and default user is `admin` (password may be blank depending on model/firmware).
3. Set admin password.
4. Set SSH key auth.
5. Copy env file and fill values.

```bash
cp secrets.env.example secrets.env
chmod 600 secrets.env
```

6. Dry-run first.

```bash
./scripts/apply-all.sh --env secrets.env --dry-run
```

### Check

- SSH key login works.
- Dry-run has no render errors.
- `WAN_INTERFACE`, `LAN_BRIDGE`, `ROUTER_AP_TRUNK_PORT` are correct.
- Access port vars (`MGMT_ACCESS_PORT`, office, living room) match real patching.

### If broken

- Use direct cable or console access.
- If remote path fails, move laptop patch-panel cable to MGMT drop (`MGMT_ACCESS_PORT`) and reconnect from MGMT VLAN.
- Undo last change.
- Re-run from last good step:

```bash
./scripts/apply-all.sh --env secrets.env --resume
```

## Apply flow

Step 03 is the baseline firewall (WAN drop, DHCP allow).
Steps 01–14 are the full setup. No strict input lockdown — `ether6` is the permanent emergency access path instead.

Recommended first run:

```bash
./scripts/apply-all.sh --env secrets.env --until 14-capsman.rsc --pause-each
```

Useful options:

```bash
./scripts/apply-all.sh --env secrets.env --from 05-bridge-vlans.rsc
./scripts/apply-all.sh --env secrets.env --until 07-dhcp.rsc
./scripts/apply-all.sh --env secrets.env --until 14-capsman.rsc
./scripts/apply-all.sh --env secrets.env --resume
```

## Important behavior

- DHCP input is allowed on non-WAN interfaces so all VLANs can get leases.
- No strict router input lockdown — `ether6` at `192.168.10.1/24` is the permanent out-of-band management path.
- MGMT can reach SRV for admin tasks.
- MGMT and SRV have explicit WAN egress allow rules.
- DNS redirect forces CORE/KIDS/IOT to AdGuard (`192.168.30.10`).
- DHCP advertises two DNS servers: AdGuard primary + container fallback (`172.31.255.2`).
- KIDS/IOT have explicit forward allow rules to reach AdGuard before the LAN block rules hit.
- KIDS/IOT/GUEST are blocked from querying router DNS directly (input chain, step 10).
- MGMT and SRV DNS are trusted by policy and not force-redirected.
- Guest DNS uses public resolver (`1.1.1.1`), no AdGuard.
- NTP uses local server first and public fallback for first boot safety.
- CAPsMAN manages AP with SSIDs on both 2.4GHz and 5GHz for all networks.

## AP and switch

- Dedicated managed switch is optional in this version.
- Router bridge handles VLAN switching directly.
- AP bootstrap is template-based in `ap/cap-bootstrap.rsc`.
- AP connects to router `ether4` through PoE injector.
- Living room dumb switch connects to router `ether5`.
- MGMT fallback laptop access is on router `ether6`.
- SSH post-install setup (wired MGMT-only, key auth): `docs/ssh-setup.md`.

## Secrets

- Real values go in `secrets.env` only.
- `secrets.env` is gitignored.
- Planned future: 1Password injection.

## TODO: printer on IoT VLAN, print from CORE

Prepped:
- `mdns-repeat-ifaces=vlan-core,vlan-iot` set (step 12), lets CORE discover IoT mDNS services (e.g. AirPrint/Bonjour).

Still needed once printer is connected:
- Confirm printer's DHCP lease/IP on IoT (60).
- Add forward firewall rule(s) allowing CORE (20) -> printer IP for actual print traffic (discovery alone isn't enough):
  - IPP: `protocol=tcp dst-port=631`
  - Raw/JetDirect (if used): `protocol=tcp dst-port=9100`
- Consider a static DHCP lease for the printer so the firewall rule doesn't break on IP change.

