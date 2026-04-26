# Network Runbook (Caveman Mode)

Use this file on deployment day.
Short steps. No guesswork.

## VLAN set

- MGMT: `10` -> `192.168.10.0/24`
- CORE: `20` -> `192.168.20.0/24`
- SRV: `30` -> `192.168.30.0/24`
- KIDS: `50` -> `192.168.50.0/24`
- IOT: `60` -> `192.168.60.0/24`
- GUEST: `70` -> `192.168.70.0/24`

## Golden rules

1. Run scripts in order: `01` to `15`.
2. After each step: check before next.
3. If fail: stop. Roll back. Do not continue.
4. Keep console/direct cable ready.

## Pre-flight

### Do

- Verify SSH key login works.
- Verify `secrets.env` exists.
- Verify router port map is correct (`ether1` WAN, `ether2` CORE office, `ether3` SRV office, `ether4` AP trunk, `ether5` living room IOT, `ether6` MGMT fallback).
- Run dry-run.

### Check

- Render succeeds.
- No missing variable errors.

## Input lock-down timing

Step 03 is safe baseline only.
Strict router input lock-down moved to step 15.
This reduces deploy friction and reconnect pain.

## Step map

| Step | File | What it does | Quick check | If broken |
|---|---|---|---|---|
| 01 | `router/01-password.rsc` | Sets admin password | Login works with new creds | Reset creds from local access |
| 02 | `router/02-wan.rsc` | Starts WAN DHCP | Default route + ping internet | Disable bad WAN client and retry |
| 03 | `router/03-firewall-wan-drop.rsc` | Input baseline (safe) | WAN input blocked, DHCP still works for non-WAN | Remove step 03 input rules if needed |
| 04 | `router/04-clock.rsc` | Sets clock/timezone | Time and timezone look right | Set clock manually |
| 05 | `router/05-bridge-vlans.rsc` | Bridge + VLAN table + filtering | Bridge exists, VLAN table maps `ether4` trunk and access ports (`ether6` MGMT, `ether2` CORE, `ether3` SRV, `ether5` IOT) | Disable vlan-filtering and recover access |
| 06 | `router/06-vlan-interfaces.rsc` | VLAN interfaces + gateway IPs | Interfaces `vlan-*` exist with `.1` IPs | Remove bad VLAN interfaces |
| 07 | `router/07-dhcp.rsc` | DHCP pools/servers/networks | Clients get leases on each VLAN (12h trusted, 4h kids/iot, 1h guest) | Disable DHCP entries and retry |
| 08 | `router/08-static-lease.rsc` | Static lease for server | `192.168.30.10` lease bound to server MAC | Remove bad lease entry |
| 09 | `router/09-nat.rsc` | WAN masquerade | LAN clients reach internet | Disable NAT rule and re-add |
| 10 | `router/10-firewall-forward.rsc` | Inter-VLAN forward policy | MGMT->SRV and CORE->SRV work, KIDS/IOT/GUEST blocked from LAN | Disable step 10 rules and apply safe baseline |
| 11 | `router/11-dns-redirect.rsc` | Force DNS to AdGuard for CORE/KIDS/IOT | DNS logs show CORE/KIDS/IOT at AdGuard (MGMT/SRV trusted) | Remove step 11 NAT rules |
| 12 | `router/12-dns-fallback.rsc` | Router DNS fallback | Router DNS uses AdGuard + fallback | Reset `/ip dns` to known-good |
| 13 | `router/13-ntp.rsc` | NTP client config | Router time syncs (local first, public fallback) | Set time manually and retry |
| 14 | `router/14-capsman.rsc` | CAPsMAN profiles/provisioning | AP appears in CAPsMAN | Disable CAPsMAN config and use AP standalone |
| 15 | `router/15-firewall-input-lockdown.rsc` | Strict router input lock-down | MGMT can manage router; trusted CORE admin IP can manage router; others blocked | Disable step 15 rules from local session |

## Important security notes

- Step 03 allows DHCP input on non-WAN interfaces so non-MGMT VLANs can still get leases.
- Step 03 does not do final lock-down anymore.
- Step 15 applies final lock-down.
- After step 15, only MGMT subnet and `TRUSTED_CORE_ADMIN_IP` should manage router.
- MGMT->SRV is explicitly allowed for admin workflow.
- MGMT and SRV have explicit WAN forward allow rules.

## Safe first run command

```bash
./scripts/apply-all.sh --env secrets.env --until 14-capsman.rsc --pause-each
./scripts/apply-all.sh --env secrets.env --until 15-firewall-input-lockdown.rsc
```

## Resume command

```bash
./scripts/apply-all.sh --env secrets.env --resume
```

## Fallback access path

- If normal management path dies, use patch panel fallback.
- Move laptop cable to MGMT drop wired to router `ether6`.
- Reconnect from MGMT VLAN (`192.168.10.0/24`) and continue recovery.

## Incident note template

```text
Date/Time:
Step/File:
What failed:
Impact:
Rollback done:
Result:
Next action:
Operator:
```

