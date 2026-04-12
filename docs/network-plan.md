# Network Execution Plan and Rollback Runbook

This file is the source of truth for applying and recovering configuration changes.
All steps are written for first deployment on new hardware.

## Deployment Rules

1. Apply router scripts in lexical order (`01` -> `14`).
2. Verify each step before moving forward.
3. If a step fails, execute rollback for that step immediately.
4. If rollback does not restore a healthy state, use worst-case recovery path.
5. Record incidents using the template at the end of this file.

## Router Script Variable Pattern

- Each `router/*.rsc` file declares RouterOS `:local` variables at the top.
- Values are injected by Go templates (for example `{{ .WAN_INTERFACE }}`) from `secrets.env`.
- Rendering uses strict missing-key behavior; missing variables fail before anything is sent to the router.
- Keep variables step-local so each file is auditable and independently testable.

## Pre-Flight Checks

- Confirm out-of-band recovery path exists (serial or direct local access).
- Confirm SSH key login works before automated runs.
- Confirm `secrets.env` exists and has non-placeholder values locally.
- Confirm target is correct hardware and not production by mistake.

## Router Steps

| Step | File | Purpose | Prerequisites | Success Signals | Immediate Rollback | Worst-Case Recovery |
|---|---|---|---|---|---|---|
| 01 | `router/01-password.rsc` | Set/update admin credential policy | Local console fallback confirmed | Admin auth policy updated, login test succeeds | Reapply previous credential settings from local session | Boot into recovery flow and reset credentials from console |
| 02 | `router/02-wan.rsc` | Define WAN uplink and address mode | Correct WAN interface identified | WAN link up, default route present | Remove/disable added WAN interface and route | Disable WAN config and restore minimal mgmt IP locally |
| 03 | `router/03-firewall-wan-drop.rsc` | Baseline WAN input hardening | Mgmt access allowlist verified | WAN input blocked except expected mgmt paths | Disable/drop rules added in this step | Use safe mode or console to remove locking rules |
| 04 | `router/04-clock.rsc` | Set timezone and clock policy | Timezone chosen | Correct timezone and system time applied | Revert timezone/NTP flags to previous values | Reset time config manually from console |
| 05 | `router/05-bridge-vlans.rsc` | Create bridge and VLAN filtering plan | VLAN IDs and ports confirmed | Bridge exists, VLAN filter entries visible | Remove newly added bridge/VLAN entries | Disable VLAN filtering and return to flat LAN temporarily |
| 06 | `router/06-vlan-interfaces.rsc` | Create VLAN L3 interfaces | Step 05 successful | VLAN interfaces up/up on expected bridge | Remove added VLAN interfaces | Recreate mgmt interface on native LAN then retry |
| 07 | `router/07-dhcp.rsc` | Add DHCP pools and servers | VLAN interfaces present | Clients receive expected scope addresses | Disable/remove DHCP server and pool additions | Re-enable previous DHCP source or static fallback |
| 08 | `router/08-static-lease.rsc` | Reserve static lease placeholders | Known MAC placeholders ready | Lease entries created with placeholders only | Remove leases created in this step | Flush lease additions and rebuild after validation |
| 09 | `router/09-nat.rsc` | Add outbound NAT policy | WAN and LAN routing already valid | LAN clients reach internet | Disable/remove new NAT rule | Restore previous srcnat behavior manually |
| 10 | `router/10-firewall-forward.rsc` | Add inter-zone forward policy | NAT and addressing verified | Intended traffic passes, blocked traffic denied | Disable forward rules from this step | Temporarily set permissive rule, then rebuild policy |
| 11 | `router/11-dns-redirect.rsc` | Enforce local DNS redirection | Local DNS resolver available | Client DNS forced to approved resolver | Remove DNS redirect NAT/filter rules | Disable redirect and use fallback DNS policy |
| 12 | `router/12-dns-fallback.rsc` | Add fallback DNS behavior | Step 11 successful | Resolver fallback works when primary fails | Remove fallback resolver settings | Revert to basic resolver config only |
| 13 | `router/13-ntp.rsc` | Configure NTP client servers | Upstream DNS/WAN healthy | NTP synchronized | Remove custom NTP server entries | Set manual time until connectivity restored |
| 14 | `router/14-capsman.rsc` | CAPsMAN baseline for AP adoption | VLAN and DHCP for AP mgmt ready | AP can discover/register to controller | Disable CAPsMAN settings added in step | Manage AP standalone until controller is fixed |

## AP and Switch Notes

- AP bootstrap and switch UI runbooks are in `ap/` and `switch/`.
- Every manual switch action must include:
  - exact UI path,
  - verification checkpoint,
  - reverse action.

## Known-Good Restart Points

- After step 04: mgmt access and time baseline are stable.
- After step 08: LAN segmentation and addressing should be stable.
- After step 10: routing and firewall intent should be stable.
- After step 14: wireless controller integration complete.

If a failure requires reset, restart from the last known-good point and reapply forward.

## First-Time Hardware Recovery Path

1. Stop automation immediately.
2. Attempt SSH recovery with previous key/user.
3. If unreachable, use direct LAN/console access.
4. Disable last applied rule group or script effect.
5. Confirm mgmt path health (`ping`, local auth, route visibility).
6. Resume from the last successful script (not the failed midpoint).

## Incident Note Template

Use this entry format for each failure:

```text
Date/Time:
Hardware:
Step/File:
Observed failure:
Impact:
Rollback action used:
Result after rollback:
Follow-up change:
Operator:
```

