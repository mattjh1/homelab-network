# Step 03 - WAN input hardening

:local wanIface "{{ .WAN_INTERFACE }}"

:put "Step 03: WAN firewall input baseline start"
/ip firewall filter add chain=input in-interface=$wanIface action=drop comment="Drop unsolicited WAN input"
:put "Step 03: WAN firewall input baseline complete"

