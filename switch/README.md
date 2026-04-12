# Switch Configuration Runbook (Manual UI)

This switch workflow is documented manually because many SMB switch platforms are UI-first.
Keep this file aligned with VLAN and DHCP intent in `docs/network-plan.md`.
VLANs in use: `10/20/30/50/60/70` (subnets and gateways are defined in router scripts).

## Before You Start

- Export current switch config backup from the UI.
- Confirm direct management access path.
- Record firmware version and model.

## Manual Workflow (Example Structure)

1. Create VLAN IDs used by router design.
2. Assign tagged/untagged membership per port profile.
3. Set management VLAN and confirm switch UI is still reachable.
4. Apply trunk/access profiles to edge ports.
5. Save configuration and export post-change backup.

## Verification Checkpoints

- Management UI reachable after each major change.
- Intended trunk port carries expected VLANs.
- Access ports obtain expected DHCP leases from router.
- No unintended VLAN bleed between client zones.

## Rollback Guidance

For each manual change, document:

- **UI path used** (for example: `VLAN > Membership`)
- **Action taken** (what was changed)
- **Reverse action** (how to undo immediately)
- **Validation** (how to confirm the rollback worked)

If management access is lost:

1. Use physical/local access recovery method for your switch model.
2. Revert the last VLAN management-related change first.
3. Restore the pre-change backup if targeted rollback fails.

