# AP CAP bootstrap script (Go-template values)

:local enableCap "{{ .ENABLE_AP_CAP }}"
:local lanBridge "{{ .LAN_BRIDGE }}"
:local apTrunkPort "{{ .AP_TRUNK_PORT }}"
:local capsmanDiscoveryIface "{{ .CAPSMAN_DISCOVERY_INTERFACE }}"

:put "Starting CAP bootstrap"

:if ($enableCap = "true") do={
  /interface bridge add name=$lanBridge vlan-filtering=no
  /interface bridge port add bridge=$lanBridge interface=$apTrunkPort frame-types=admit-only-vlan-tagged
  # SRV VLAN 30 is intentionally excluded from AP trunk.
  /interface bridge vlan add bridge=$lanBridge vlan-ids=10,20,50,60,70 tagged=$lanBridge,$apTrunkPort
  /interface bridge set [find where name=$lanBridge] vlan-filtering=yes

  /interface vlan add name=vlan-mgmt vlan-id=10 interface=$lanBridge
  /ip dhcp-client add interface=vlan-mgmt disabled=no

  /interface wifi cap set enabled=yes discovery-interfaces=$capsmanDiscoveryIface
} else={
  :put "CAP bootstrap skipped by template variable"
}

:put "CAP bootstrap complete"

