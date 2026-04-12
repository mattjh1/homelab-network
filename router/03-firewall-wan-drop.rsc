# Step 03 - WAN input hardening

:local wanIface "{{ .WAN_INTERFACE }}"
:local mgmtSubnet "192.168.10.0/24"

:put "Step 03: WAN firewall input baseline start"
/ip firewall filter add chain=input connection-state=established,related action=accept comment="accept established,related"
/ip firewall filter add chain=input connection-state=invalid action=drop comment="drop invalid input"
/ip firewall filter add chain=input src-address=$mgmtSubnet action=accept comment="MGMT full access"
/ip firewall filter add chain=input in-interface=$wanIface action=drop comment="Drop unsolicited WAN input"
/ip firewall filter add chain=input action=drop comment="drop all other router access"
:put "Step 03: WAN firewall input baseline complete"

