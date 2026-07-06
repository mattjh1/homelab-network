# Step 08 - Static leases

:local leaseIp "{{ .STATIC_LEASE_IP }}"
:local leaseMac "{{ .STATIC_LEASE_MAC }}"

:put "Step 08: static lease start"
/ip dhcp-server lease add address=$leaseIp mac-address=$leaseMac server=dhcp-srv comment="homeserver"
/ip dhcp-server lease add address=192.168.60.237 mac-address=AC:15:18:F1:14:50 server=dhcp-iot comment="systemair-save-connect"
:put "Step 08: static lease complete"

