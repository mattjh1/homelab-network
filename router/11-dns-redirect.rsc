# Step 11 - DNS redirect policy
# MGMT and SRV are intentionally not force-redirected.
# CORE/KIDS/IOT are force-redirected to AdGuard.
# dst-address exclusion is required: without it, a client falling back to
# FALLBACK_DNS_IP (DHCP's secondary DNS) gets that query redirected right
# back to the (down) primary, making the fallback unreachable during the
# exact outage it exists for. Root-caused 2026-07-07 after a real server
# outage broke internet for CORE/KIDS/IOT despite the fallback container
# being up and healthy the whole time.

:local adguardDns "{{ .ADGUARD_DNS_IP }}"
:local fallbackDns "{{ .FALLBACK_DNS_IP }}"

:put "Step 11: DNS redirect start"
/ip firewall nat add chain=dstnat src-address=192.168.20.0/24 dst-address=!$fallbackDns protocol=udp dst-port=53 action=dst-nat to-addresses=$adguardDns comment="CORE DNS redirect"
/ip firewall nat add chain=dstnat src-address=192.168.20.0/24 dst-address=!$fallbackDns protocol=tcp dst-port=53 action=dst-nat to-addresses=$adguardDns comment="CORE DNS redirect TCP"
/ip firewall nat add chain=dstnat src-address=192.168.50.0/24 dst-address=!$fallbackDns protocol=udp dst-port=53 action=dst-nat to-addresses=$adguardDns comment="KIDS DNS redirect"
/ip firewall nat add chain=dstnat src-address=192.168.50.0/24 dst-address=!$fallbackDns protocol=tcp dst-port=53 action=dst-nat to-addresses=$adguardDns comment="KIDS DNS redirect TCP"
/ip firewall nat add chain=dstnat src-address=192.168.60.0/24 dst-address=!$fallbackDns protocol=udp dst-port=53 action=dst-nat to-addresses=$adguardDns comment="IOT DNS redirect"
/ip firewall nat add chain=dstnat src-address=192.168.60.0/24 dst-address=!$fallbackDns protocol=tcp dst-port=53 action=dst-nat to-addresses=$adguardDns comment="IOT DNS redirect TCP"
:put "Step 11: DNS redirect complete"

