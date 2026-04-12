# Switch — TP-Link SG108PE

## Port plan

| Port | Goes to         | Mode            | VLANs             |
|------|-----------------|-----------------|-------------------|
| 1    | Router          | Tagged trunk    | 10,20,30,50,60,70 |
| 2    | Server          | Untagged access | 30                |
| 3    | cAP ax (PoE)    | Tagged trunk    | 10,20,50,60,70    |
| 4    | Dumb IoT switch | Untagged access | 60                |
| 5–8  | Unused          | —               | —                 |

---

## Before touching anything

1. Plug laptop directly into switch. No router yet.
2. Set laptop static IP: `192.168.0.50/24`.
3. Open `http://192.168.0.1`. Login: `admin` / `admin`.
4. Change password. **System > User Account**.
5. Export backup. **System > Backup and Restore > Backup**.

---

## Step 1 — Enable 802.1Q VLAN

**VLAN > 802.1Q VLAN**

Enable it. Save.

Rollback: disable it.

---

## Step 2 — Create VLANs

**VLAN > 802.1Q VLAN > Add**

Add these one by one:

| VLAN ID | Name  |
|---------|-------|
| 10      | MGMT  |
| 20      | CORE  |
| 30      | SRV   |
| 50      | KIDS  |
| 60      | IOT   |
| 70      | GUEST |

Check: all six visible in list.

Rollback: delete them in same screen.

---

## Step 3 — VLAN membership

**VLAN > 802.1Q VLAN**

Select each VLAN. Set ports. Save after each.

T = Tagged. U = Untagged. — = Excluded.

| VLAN | Port 1 | Port 2 | Port 3 | Port 4 | Port 5–8 |
|------|--------|--------|--------|--------|----------|
| 10   | T      | —      | T      | —      | —        |
| 20   | T      | —      | T      | —      | —        |
| 30   | T      | U      | —      | —      | —        |
| 50   | T      | —      | T      | —      | —        |
| 60   | T      | —      | T      | U      | —        |
| 70   | T      | —      | T      | —      | —        |

Rollback: set all ports to — for that VLAN.

---

## Step 4 — PVID (port default VLAN)

**VLAN > 802.1Q PVID**

Set PVID per port. This is what untagged ingress traffic gets stamped with.

| Port | PVID |
|------|------|
| 1    | 1    |
| 2    | 30   |
| 3    | 1    |
| 4    | 60   |
| 5–8  | 1    |

Save.

Rollback: set PVID back to 1 for affected ports.

---

## Step 5 — Save and verify

Export backup. **System > Backup and Restore > Backup**.

Then plug everything in:

- Port 1 → router
- Port 2 → server
- Port 3 → cAP ax
- Port 4 → dumb IoT switch

Check:
- Server gets `192.168.30.10` lease.
- cAP ax appears in CAPsMAN on router.
- WiFi clients get address in expected VLAN range.
- IoT devices get `192.168.60.x`.

---

## If something breaks

| Problem | Where to look |
|---------|---------------|
| Lost switch UI | Hold reset 5–10s. Factory reset. Start over. |
| Wrong VLAN on a port | Step 3 — check membership table for that VLAN |
| Device gets wrong IP | Step 4 — check PVID for that port |
| cAP ax not joining CAPsMAN | Step 3 — confirm port 3 tagged on VLAN 10 |
| Server not reachable | Step 3 — confirm port 2 untagged on VLAN 30, Step 4 — PVID 30 |
