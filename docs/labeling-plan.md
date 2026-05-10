# Physical Labeling Plan

Use this before final install in cabinet.
Goal: one glance tells where cable goes and what network it carries.

## Label format

Use same pattern everywhere:

`<ID> | <SRC> -> <DST> | <ROLE/VLAN>`

Example:

`C-04 | R:e4 -> AP:eth1 | TRUNK 10,20,50,60,70`

## Device short names

- `R` = Router (RB5009)
- `AP` = Access point
- `PP` = Patch panel
- `LR-SW` = Living room switch (TP-Link SG105E)
- `ONT` = Fiber modem/ONT
- `LAP` = Laptop/admin device

## Router port legend label

Print one label and stick on router top or cabinet rail:

- `e1 WAN` -> `ONT` (DHCP client, internet uplink)
- `e2 CORE` -> office/core drop (`VLAN 20` untagged)
- `e3 SRV` -> office/server drop (`VLAN 30` untagged)
- `e4 AP-TRUNK` -> AP uplink (`tagged 10,20,50,60,70`)
- `e5 LR-IOT` -> living room switch uplink (`VLAN 60` untagged)
- `e6 MGMT` -> admin fallback port (`VLAN 10` untagged)

## Cable ID plan

Assign cable IDs once. Label both ends with same ID.

- `C-01` Router `e1` <-> `ONT`
- `C-02 CORE` Router `e2` <-> office core run
- `C-03 SRV` Router `e3` <-> office server run
- `C-04 AP` Router `e4` <-> AP run
- `C-05 LR` Router `e5` <-> living room run
- `C-06 MGMT` Router `e6` <-> mgmt drop
- `C-07` Living room wall <-> `LR-SW` uplink
- `C-08` `LR-SW` port 2 <-> living room device 1
- `C-09` `LR-SW` port 3 <-> living room device 2
- `C-10` `LR-SW` port 4 <-> living room device 3

If you add/replace cable later, do not reuse old ID. Continue with `C-11+`.

## Cable label size (fold-around)

Use these print sizes for patch cables:

- Width: `60-75 mm`
- Height: `12-15 mm`
- Text zone per side after fold: about `28-35 mm`

This gives readable text on both sides when folded around cable.

Recommended max text length per cable label side:

- `18-24` characters

Good short format for fold labels:

`C-04 R:e4->AP`

`TRUNK 10,20,50`

If your printer supports two-line labels, use 2 lines like above.
If one-line only, prioritize cable ID + endpoints and keep VLAN role on device/patch labels.

## Living room switch label

Stick small map on switch or nearby:

- `P1 UPLINK` -> wall jack from router `e5` (`VLAN 60`)
- `P2 DEV-1` -> living room device 1
- `P3 DEV-2` -> living room device 2
- `P4 DEV-3` -> living room device 3
- `P5 SPARE`

## Patch panel labels

For each used jack, print:

`<ROOM>-<JACK> | from R:eX | <VLAN/ROLE>`

Examples:

- `OFFICE-A | from R:e2 | CORE V20`
- `OFFICE-B | from R:e3 | SRV V30`
- `AP-CEIL | from R:e4 | TRUNK`
- `LIVING-TV | from R:e5 | IOT V60`
- `MGMT-DROP | from R:e6 | MGMT V10`

## Cable label placement

- Put label on both ends.
- Place label 3-5 cm from connector (not on latch).
- Wrap so text reads without unplugging if possible.
- For fold-around labels, center fold on cable and keep same text visible from either side.
- Add second tiny arrow label if direction matters (`R -> PP`).

## Fast recovery labels

Add one obvious sticker near patch panel:

`EMERGENCY ROUTER ACCESS: move laptop to MGMT-DROP (R:e6, 192.168.10.0/24)`

This matches fallback path in `docs/network-plan.md`.

## Print-ready label text

Use these exact strings in label printer.

### Router legend labels

- `R:e1 WAN -> ONT`
- `R:e2 CORE V20`
- `R:e3 SRV V30`
- `R:e4 AP TRUNK`
- `R:e5 LR IOT V60`
- `R:e6 MGMT V10`

### Cable fold-around labels (two-line)

- `C-01 WAN R:e1->ONT`
- `WAN UPLINK`
- `C-02 CORE R:e2`
- `CORE V20`
- `C-03 SRV R:e3`
- `SRV V30`
- `C-04 AP R:e4`
- `TRUNK 10,20,50,60,70`
- `C-05 LR R:e5`
- `IOT V60`
- `C-06 MGMT R:e6`
- `MGMT V10`
- `C-07 LR WALL->SW:P1`
- `UPLINK V60`
- `C-08 SW:P2->DEV1`
- `LR DEVICE`
- `C-09 SW:P3->DEV2`
- `LR DEVICE`
- `C-10 SW:P4->DEV3`
- `LR DEVICE`

### Cable fold-around labels (one-line fallback)

- `C-01 WAN R:e1->ONT`
- `C-02 CORE R:e2`
- `C-03 SRV R:e3`
- `C-04 AP R:e4`
- `C-05 LR R:e5`
- `C-06 MGMT R:e6`
- `C-07 LR->SW:P1`
- `C-08 SW:P2->DEV1`
- `C-09 SW:P3->DEV2`
- `C-10 SW:P4->DEV3`

### Patch panel labels

- `OFFICE-A | R:e2 | CORE V20`
- `OFFICE-B | R:e3 | SRV V30`
- `AP-CEIL | R:e4 | TRUNK`
- `LIVING-TV | R:e5 | IOT V60`
- `MGMT-DROP | R:e6 | MGMT V10`

### Living room switch labels

- `P1 UPLINK V60`
- `P2 DEV-1`
- `P3 DEV-2`
- `P4 DEV-3`
- `P5 SPARE`

### Emergency sticker

- `EMERGENCY: MOVE LAPTOP TO MGMT-DROP (R:e6) 192.168.10.0/24`

