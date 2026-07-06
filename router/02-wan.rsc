# Step 02 - WAN baseline
# WAN moved from ether1 to sfp-sfpplus1. Old ether1 client kept disabled
# below as a fallback slot, not actively used.

:local wanIface "{{ .WAN_INTERFACE }}"

:put "Step 02: WAN config start"
/ip dhcp-client add interface=ether1 use-peer-dns=no disabled=yes comment="legacy WAN, disabled"
/ip dhcp-client add interface=$wanIface use-peer-dns=no add-default-route=yes disabled=no
:put "Step 02: WAN config complete"

