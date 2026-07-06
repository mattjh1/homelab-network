# Step 10 - Forward chain policy

:local wanIface "{{ .WAN_INTERFACE }}"
:local adguardDns "{{ .ADGUARD_DNS_IP }}"

:put "Step 10: forward policy start"
/ip firewall filter add chain=forward src-address=192.168.10.0/24 dst-address=192.168.110.0/24 action=accept comment="MGMT->CAPsMAN-mgmt"
/ip firewall filter add chain=forward connection-state=established,related action=accept
/ip firewall filter add chain=forward connection-state=invalid action=drop comment="drop invalid forward"
/ip firewall filter add chain=forward src-address=192.168.10.0/24 dst-address=192.168.30.0/24 action=accept comment="MGMT->SRV"
/ip firewall filter add chain=forward src-address=192.168.20.0/24 dst-address=192.168.30.0/24 action=accept comment="CORE->SRV"
/ip firewall filter add chain=forward src-address=192.168.10.0/24 out-interface=$wanIface action=accept comment="MGMT->WAN"
/ip firewall filter add chain=forward src-address=192.168.30.0/24 dst-address=!192.168.0.0/16 action=accept comment="SRV->WAN explicit"
# DNS exceptions must come before LAN block rules
/ip firewall filter add chain=forward src-address=192.168.50.0/24 dst-address=$adguardDns protocol=udp dst-port=53 action=accept comment="KIDS->AdGuard DNS UDP"
/ip firewall filter add chain=forward src-address=192.168.50.0/24 dst-address=$adguardDns protocol=tcp dst-port=53 action=accept comment="KIDS->AdGuard DNS TCP"
/ip firewall filter add chain=forward src-address=192.168.50.0/24 dst-address=$adguardDns protocol=tcp dst-port=853 action=accept comment="KIDS DNS-over-TLS -> AdGuard"
/ip firewall filter add chain=forward src-address=192.168.60.0/24 dst-address=$adguardDns protocol=udp dst-port=53 action=accept comment="IOT->AdGuard DNS UDP"
/ip firewall filter add chain=forward src-address=192.168.60.0/24 dst-address=$adguardDns protocol=tcp dst-port=53 action=accept comment="IOT->AdGuard DNS TCP"
/ip firewall filter add chain=forward src-address=192.168.60.0/24 dst-address=$adguardDns protocol=tcp dst-port=853 action=accept comment="IOT DNS-over-TLS -> AdGuard"
/ip firewall filter add chain=forward src-address=192.168.50.0/24 dst-address=192.168.0.0/16 action=drop comment="KIDS block LAN"
/ip firewall filter add chain=forward src-address=192.168.60.0/24 dst-address=$adguardDns protocol=tcp dst-port=443 action=accept comment="IOT->SRV HTTPS (AIOStreams)"
/ip firewall filter add chain=forward src-address=192.168.30.0/24 dst-address=192.168.60.237 protocol=tcp dst-port=502 action=accept comment="SRV->IOT Modbus (Systemair FTX)"
/ip firewall filter add chain=forward src-address=192.168.60.0/24 dst-address=192.168.0.0/16 action=drop comment="IOT block LAN"
/ip firewall filter add chain=forward src-address=192.168.70.0/24 dst-address=192.168.0.0/16 action=drop comment="GUEST block LAN"
/ip firewall filter add chain=forward src-address=192.168.0.0/16 dst-address=192.168.0.0/16 action=drop comment="block inter-VLAN default"

# Block untrusted VLANs from bypassing AdGuard by querying router DNS directly
/ip firewall address-list remove [find list=untrusted]
/ip firewall address-list add list=untrusted address=192.168.50.0/24 comment=KIDS
/ip firewall address-list add list=untrusted address=192.168.60.0/24 comment=IOT
/ip firewall address-list add list=untrusted address=192.168.70.0/24 comment=GUEST
/ip firewall filter remove [find where comment="block untrusted DNS UDP"]
/ip firewall filter remove [find where comment="block untrusted DNS TCP"]
/ip firewall filter add chain=input src-address-list=untrusted protocol=udp dst-port=53 action=drop comment="block untrusted DNS UDP"
/ip firewall filter add chain=input src-address-list=untrusted protocol=tcp dst-port=53 action=drop comment="block untrusted DNS TCP"
:put "Step 10: forward policy complete"

