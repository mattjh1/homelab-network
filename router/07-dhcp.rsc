# Step 07 - DHCP pools and servers

:local adguardDns "{{ .ADGUARD_DNS_IP }}"
:local fallbackDns "{{ .FALLBACK_DNS_IP }}"
:local guestDns "{{ .GUEST_DNS_IP }}"

:put "Step 07: DHCP start"
# pool-mgmt serves CAPsMAN AP (connects via VLAN 10 trunk) — ether6 uses static IP only
/ip pool add name=pool-mgmt ranges=192.168.110.40-192.168.110.254
/ip pool add name=pool-core ranges=192.168.20.40-192.168.20.254
/ip pool add name=pool-srv ranges=192.168.30.40-192.168.30.254
/ip pool add name=pool-kids ranges=192.168.50.40-192.168.50.254
/ip pool add name=pool-iot ranges=192.168.60.40-192.168.60.254
/ip pool add name=pool-guest ranges=192.168.70.40-192.168.70.254

/ip dhcp-server add name=dhcp-mgmt interface=vlan-mgmt address-pool=pool-mgmt lease-time=12h
/ip dhcp-server add name=dhcp-core interface=vlan-core address-pool=pool-core lease-time=12h
/ip dhcp-server add name=dhcp-srv interface=vlan-srv address-pool=pool-srv lease-time=12h
/ip dhcp-server add name=dhcp-kids interface=vlan-kids address-pool=pool-kids lease-time=4h
/ip dhcp-server add name=dhcp-iot interface=vlan-iot address-pool=pool-iot lease-time=4h
/ip dhcp-server add name=dhcp-guest interface=vlan-guest address-pool=pool-guest lease-time=1h

/ip dhcp-server network add address=192.168.110.0/24 gateway=192.168.110.1 dns-server="$adguardDns,$fallbackDns"
/ip dhcp-server network add address=192.168.20.0/24 gateway=192.168.20.1 dns-server="$adguardDns,$fallbackDns"
/ip dhcp-server network add address=192.168.30.0/24 gateway=192.168.30.1 dns-server="$adguardDns,$fallbackDns"
/ip dhcp-server network add address=192.168.50.0/24 gateway=192.168.50.1 dns-server="$adguardDns,$fallbackDns"
/ip dhcp-server network add address=192.168.60.0/24 gateway=192.168.60.1 dns-server="$adguardDns,$fallbackDns"
/ip dhcp-server network add address=192.168.70.0/24 gateway=192.168.70.1 dns-server=$guestDns
:put "Step 07: DHCP complete"

