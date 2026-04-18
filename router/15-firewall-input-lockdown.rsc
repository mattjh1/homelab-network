# Step 15 - Strict input lock-down (after VLANs/services are stable)

:local wanIface "{{ .WAN_INTERFACE }}"
:local mgmtSubnet "{{ .MGMT_SUBNET }}"

:put "Step 15: strict input lock-down start"
/ip firewall filter add chain=input connection-state=established,related action=accept comment="accept established,related"
/ip firewall filter add chain=input connection-state=invalid action=drop comment="drop invalid input"
/ip firewall filter add chain=input in-interface=!$wanIface protocol=udp dst-port=67 action=accept comment="allow DHCP from non-WAN interfaces"
/ip firewall filter add chain=input src-address=$mgmtSubnet action=accept comment="MGMT full access"
/ip firewall filter add chain=input in-interface=$wanIface action=drop comment="Drop unsolicited WAN input"
/ip firewall filter add chain=input action=drop comment="drop all other router access"
:put "Step 15: strict input lock-down complete"

