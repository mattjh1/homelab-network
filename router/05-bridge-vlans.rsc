# Step 05 - Bridge and VLAN filtering

:local lanBridge "{{ .LAN_BRIDGE }}"
:local apTrunkPort "{{ .ROUTER_AP_TRUNK_PORT }}"
:local officeCorePort "{{ .OFFICE_CORE_PORT }}"
:local officeSrvPort "{{ .OFFICE_SRV_PORT }}"
:local livingroomAccessPort "{{ .LIVINGROOM_ACCESS_PORT }}"

:put "Step 05: bridge and VLAN setup start"
/interface bridge add name=$lanBridge vlan-filtering=no
/interface bridge port add bridge=$lanBridge interface=$apTrunkPort frame-types=admit-only-vlan-tagged
/interface bridge port add bridge=$lanBridge interface=$officeCorePort frame-types=admit-only-untagged-and-priority-tagged pvid=20
/interface bridge port add bridge=$lanBridge interface=$officeSrvPort frame-types=admit-only-untagged-and-priority-tagged pvid=30
/interface bridge port add bridge=$lanBridge interface=$livingroomAccessPort frame-types=admit-only-untagged-and-priority-tagged pvid=60

# VLAN 10 tagged on bridge+trunk only — ether6 stays outside bridge as emergency fallback
/interface bridge vlan add bridge=$lanBridge vlan-ids=10 tagged=$lanBridge,$apTrunkPort
/interface bridge vlan add bridge=$lanBridge vlan-ids=20 tagged=$lanBridge,$apTrunkPort untagged=$officeCorePort
/interface bridge vlan add bridge=$lanBridge vlan-ids=30 tagged=$lanBridge,$apTrunkPort untagged=$officeSrvPort
/interface bridge vlan add bridge=$lanBridge vlan-ids=50 tagged=$lanBridge,$apTrunkPort
/interface bridge vlan add bridge=$lanBridge vlan-ids=60 tagged=$lanBridge,$apTrunkPort untagged=$livingroomAccessPort
/interface bridge vlan add bridge=$lanBridge vlan-ids=70 tagged=$lanBridge,$apTrunkPort
/interface bridge set [find where name=$lanBridge] vlan-filtering=yes
:put "Step 05: bridge and VLAN setup complete"

