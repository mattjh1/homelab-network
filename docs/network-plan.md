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

1. Run scripts in order: `01` to `17`.
2. After each step: check before next.
3. If fail: stop. Roll back. Do not continue.
4. Keep console/direct cable ready.

## Pre-flight

### Do

- Verify SSH key login works.
- Verify `secrets.env` exists.
- Verify router port map is correct (`sfp-sfpplus1` WAN, `ether1` legacy/disabled, `ether2` CORE office, `ether3` SRV office, `ether4` AP trunk, `ether5` living room IOT, `ether6` MGMT fallback).
- Run dry-run.

### Check

- Render succeeds.
- No missing variable errors.

## Input lock-down

Step 03 is safe baseline (WAN drop, invalid drop). Step 15 adds the real
default-drop input chain — only MGMT and a narrow SRV->API hole (RouterOS
API, 8728/8729, for the home automation integration) get past it.
`ether6` at `192.168.10.1/24` is the permanent out-of-band path regardless.
Untrusted VLAN DNS block rules (KIDS/IOT/GUEST can't query router DNS) are in step 10.
Step 16 additionally locks `/ip service` itself: ssh/www/winbox to MGMT only,
api/api-ssl to SRV only, ftp/telnet disabled. This is a second, independent
restriction — it blocks a service even if the input chain would allow the
packet through.

## Step map

| Step | File | What it does | Quick check | If broken |
|---|---|---|---|---|
| 01 | `router/01-password.rsc` | Sets admin password | Login works with new creds | Reset creds from local access |
| 02 | `router/02-wan.rsc` | Starts WAN DHCP on `sfp-sfpplus1` (`ether1` kept as disabled legacy slot) | Default route + ping internet | Disable bad WAN client and retry |
| 03 | `router/03-firewall-wan-drop.rsc` | Input baseline (safe) | WAN input blocked, DHCP still works for non-WAN | Remove step 03 input rules if needed |
| 04 | `router/04-clock.rsc` | Sets clock/timezone | Time and timezone look right | Set clock manually |
| 05 | `router/05-bridge-vlans.rsc` | Bridge + VLAN table + filtering (`ether6` stays outside bridge) | Bridge exists, VLAN table maps `ether4` trunk and access ports (`ether2` CORE, `ether3` SRV, `ether5` IOT) | Disable vlan-filtering and recover via `ether6` |
| 06 | `router/06-vlan-interfaces.rsc` | VLAN interfaces + IPs (`ether6` direct IP + vlan-mgmt for CAPsMAN) | `ether6` has `192.168.10.1/24`, `vlan-mgmt` has `192.168.110.1/24`, others have `.1` IPs | Remove bad addresses |
| 07 | `router/07-dhcp.rsc` | DHCP pools/servers/networks (dual DNS: AdGuard + fallback container) | Clients get leases; DNS shows two servers | Disable DHCP entries and retry |
| 08 | `router/08-static-lease.rsc` | Static leases for server + IoT device | `192.168.30.10` and `192.168.60.237` leases bound to their MACs | Remove bad lease entry |
| 09 | `router/09-nat.rsc` | WAN masquerade | LAN clients reach internet | Disable NAT rule and re-add |
| 10 | `router/10-firewall-forward.rsc` | Inter-VLAN forward policy + DNS/DoT exception rules + untrusted DNS block + MGMT->CAPsMAN-mgmt | MGMT->SRV, CORE->SRV, MGMT->CAPsMAN-mgmt work; KIDS/IOT/GUEST blocked from LAN; KIDS/IOT can reach AdGuard DNS+DoT; untrusted can't query router DNS | Disable step 10 rules and apply safe baseline |
| 11 | `router/11-dns-redirect.rsc` | Force DNS to AdGuard for CORE/KIDS/IOT | DNS logs show CORE/KIDS/IOT at AdGuard (MGMT/SRV trusted) | Remove step 11 NAT rules |
| 12 | `router/12-router-dns.rsc` | Router upstream DNS (`1.1.1.1,8.8.8.8`), mDNS repeat on CORE/IOT | `/ip dns print` shows correct servers | Reset `/ip dns` to known-good |
| 13 | `router/13-ntp.rsc` | NTP client config | Router time syncs (local first, public fallback) | Set time manually and retry |
| 14 | `router/14-capsman.rsc` | CAPsMAN profiles/provisioning (2.4GHz pinned ch.6 + 5GHz for all SSIDs) | AP appears in CAPsMAN; Home/Kids/IoT/Guests SSIDs visible on both bands | Disable CAPsMAN config and use AP standalone |
| 15 | `router/15-input-lockdown.rsc` | Default-drop input chain; accept MGMT + SRV API (8728/8729) only | Non-MGMT/SRV source can't reach router admin ports; MGMT/SRV still can | Remove the default-drop rule from local access |
| 16 | `router/16-service-lockdown.rsc` | `/ip service` restricted (ssh/www/winbox->MGMT, api->SRV), ftp/telnet disabled, MAC discovery off, `api-read` user group | `/ip service print` shows restricted `address=`; ftp/telnet disabled | Widen `address=` from local access |
| 17 | `router/17-adguard-container.rsc` | Router-hosted AdGuardHome container (veth `agh`, `172.31.255.2/30`) | Container running, `172.31.255.2` answers DNS | Check `/container print`, USB disk mounted |

## Important security notes

- Step 15 default-drops input; only MGMT and SRV (API only) get through. `ether6` (MGMT) is the permanent out-of-band access port either way.
- Step 16 independently restricts `/ip service` by subnet — a second lock, not redundant with step 15 (it blocks at the service level even if input chain would allow it).
- MGMT->SRV and MGMT->CAPsMAN-mgmt are explicitly allowed for admin/AP-management workflow.
- MGMT and SRV have explicit WAN forward allow rules.
- KIDS/IOT/GUEST have DNS + DNS-over-TLS exception rules (can reach AdGuard on SRV) before LAN block rules.
- KIDS/IOT/GUEST cannot query router DNS directly (step 10 input block).
- Confirmed 2026-07-07: step 03's DHCP-allow-on-non-WAN rule doesn't appear in a live `/export`, but a CORE device still pulled a fresh lease after its dynamic entry was removed and it was forced to re-discover. RouterOS's DHCP server evidently isn't gated by this rule for its own protocol — no live gap, template rule is effectively belt-and-suspenders.

## Safe first run command

```bash
./scripts/apply-all.sh --env secrets.env --until 17-adguard-container.rsc --pause-each
```

## Resume command

```bash
./scripts/apply-all.sh --env secrets.env --resume
```

## Fallback access path

- If normal management path dies, use patch panel fallback.
- Move laptop cable to MGMT drop wired to router `ether6`.
- Set laptop static IP: `192.168.10.2/24`, no gateway.
- SSH to `192.168.10.1` — `ether6` is always reachable, independent of bridge/VLAN state.

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

