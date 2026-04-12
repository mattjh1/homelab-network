# Step 11 - DNS redirect policy

:local adguardDns "{{ .ADGUARD_DNS_IP }}"

:put "Step 11: DNS redirect start"
/ip firewall nat add chain=dstnat src-address=192.168.20.0/24 protocol=udp dst-port=53 action=dst-nat to-addresses=$adguardDns comment="force DNS CORE udp"
/ip firewall nat add chain=dstnat src-address=192.168.20.0/24 protocol=tcp dst-port=53 action=dst-nat to-addresses=$adguardDns comment="force DNS CORE tcp"
/ip firewall nat add chain=dstnat src-address=192.168.40.0/24 protocol=udp dst-port=53 action=dst-nat to-addresses=$adguardDns comment="force DNS WORK udp"
/ip firewall nat add chain=dstnat src-address=192.168.40.0/24 protocol=tcp dst-port=53 action=dst-nat to-addresses=$adguardDns comment="force DNS WORK tcp"
/ip firewall nat add chain=dstnat src-address=192.168.50.0/24 protocol=udp dst-port=53 action=dst-nat to-addresses=$adguardDns comment="force DNS KIDS udp"
/ip firewall nat add chain=dstnat src-address=192.168.50.0/24 protocol=tcp dst-port=53 action=dst-nat to-addresses=$adguardDns comment="force DNS KIDS tcp"
/ip firewall nat add chain=dstnat src-address=192.168.60.0/24 protocol=udp dst-port=53 action=dst-nat to-addresses=$adguardDns comment="force DNS IOT udp"
/ip firewall nat add chain=dstnat src-address=192.168.60.0/24 protocol=tcp dst-port=53 action=dst-nat to-addresses=$adguardDns comment="force DNS IOT tcp"
:put "Step 11: DNS redirect complete"

