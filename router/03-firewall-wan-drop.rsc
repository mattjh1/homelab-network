# Step 03 - WAN input hardening

:local wanIface "{{ .WAN_INTERFACE }}"

:put "Step 03: WAN firewall input baseline start"
/ip firewall filter add chain=input connection-state=established,related action=accept comment="accept established,related"
/ip firewall filter add chain=input connection-state=invalid action=drop comment="drop invalid input"
/ip firewall filter add chain=input in-interface=!$wanIface protocol=udp dst-port=67 action=accept comment="allow DHCP from non-WAN interfaces"
/ip firewall filter add chain=input in-interface=$wanIface action=drop comment="Drop unsolicited WAN input"
:put "Step 03 note: default-drop input policy is added in step 15"
:put "Step 03: WAN firewall input baseline complete"

