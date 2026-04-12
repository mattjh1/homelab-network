# Step 08 - Static lease for home server

:local leaseIp "{{ .STATIC_LEASE_IP }}"
:local leaseMac "{{ .STATIC_LEASE_MAC }}"

:put "Step 08: static lease start"
/ip dhcp-server lease add address=$leaseIp mac-address=$leaseMac server=dhcp-srv comment="hemserver"
:put "Step 08: static lease complete"

