# Step 09 - NAT baseline

:local wanIface "{{ .WAN_INTERFACE }}"

:put "Step 09: NAT start"
/ip firewall nat add chain=srcnat out-interface=$wanIface action=masquerade comment="Outbound NAT"
:put "Step 09: NAT complete"

