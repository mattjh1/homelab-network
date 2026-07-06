# Step 12 - Router upstream DNS configuration
# Sets router's own DNS resolver upstream — not advertised to clients.
# Client DNS: DHCP advertises AdGuard (192.168.30.10) + container fallback (172.31.255.2).

:put "Step 12: router DNS start"
/ip dns set allow-remote-requests=yes servers=1.1.1.1,8.8.8.8 mdns-repeat-ifaces=vlan-core,vlan-iot
:put "Step 12: router DNS complete"
