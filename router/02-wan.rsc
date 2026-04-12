# Step 02 - WAN baseline

:local wanIface "{{ .WAN_INTERFACE }}"

:put "Step 02: WAN config start"
/ip dhcp-client add interface=$wanIface use-peer-dns=no add-default-route=yes disabled=no
:put "Step 02: WAN config complete"

