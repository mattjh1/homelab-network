# Step 06 - VLAN interfaces

:local lanBridge "{{ .LAN_BRIDGE }}"
:local mgmtAccessPort "{{ .MGMT_ACCESS_PORT }}"

:put "Step 06: VLAN interfaces start"
# ether6 stays outside the bridge — direct IP for emergency/bootstrap access
/ip address add address=192.168.10.1/24 interface=$mgmtAccessPort comment="bootstrap-mgmt"

/interface vlan add name=vlan-mgmt vlan-id=10 interface=$lanBridge
/interface vlan add name=vlan-core vlan-id=20 interface=$lanBridge
/interface vlan add name=vlan-srv vlan-id=30 interface=$lanBridge
/interface vlan add name=vlan-kids vlan-id=50 interface=$lanBridge
/interface vlan add name=vlan-iot vlan-id=60 interface=$lanBridge
/interface vlan add name=vlan-guest vlan-id=70 interface=$lanBridge

# vlan-mgmt carries CAPsMAN AP management traffic on VLAN 10
/ip address add address=192.168.110.1/24 interface=vlan-mgmt comment="CAPsMAN-MGMT"
/ip address add address=192.168.20.1/24 interface=vlan-core comment="CORE"
/ip address add address=192.168.30.1/24 interface=vlan-srv comment="SRV"
/ip address add address=192.168.50.1/24 interface=vlan-kids comment="KIDS"
/ip address add address=192.168.60.1/24 interface=vlan-iot comment="IOT"
/ip address add address=192.168.70.1/24 interface=vlan-guest comment="GUEST"
:put "Step 06: VLAN interfaces complete"

