# Step 05 - Bridge and VLAN filtering

:local lanBridge "{{ .LAN_BRIDGE }}"
:local trunkPort "{{ .TRUNK_PORT }}"

:put "Step 05: bridge and VLAN setup start"
/interface bridge add name=$lanBridge vlan-filtering=no
/interface bridge port add bridge=$lanBridge interface=$trunkPort frame-types=admit-only-vlan-tagged
/interface bridge vlan add bridge=$lanBridge vlan-ids=10 tagged=($lanBridge . "," . $trunkPort)
/interface bridge vlan add bridge=$lanBridge vlan-ids=20 tagged=($lanBridge . "," . $trunkPort)
/interface bridge vlan add bridge=$lanBridge vlan-ids=30 tagged=($lanBridge . "," . $trunkPort)
/interface bridge vlan add bridge=$lanBridge vlan-ids=50 tagged=($lanBridge . "," . $trunkPort)
/interface bridge vlan add bridge=$lanBridge vlan-ids=60 tagged=($lanBridge . "," . $trunkPort)
/interface bridge vlan add bridge=$lanBridge vlan-ids=70 tagged=($lanBridge . "," . $trunkPort)
/interface bridge set [find where name=$lanBridge] vlan-filtering=yes
:put "Step 05: bridge and VLAN setup complete"

