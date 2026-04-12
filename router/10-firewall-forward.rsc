# Step 10 - Forward chain policy

:put "Step 10: forward policy start"
/ip firewall filter add chain=forward connection-state=established,related action=accept
/ip firewall filter add chain=forward connection-state=invalid action=drop comment="drop invalid forward"
/ip firewall filter add chain=forward src-address=192.168.20.0/24 dst-address=192.168.30.0/24 action=accept comment="CORE->SRV"
/ip firewall filter add chain=forward src-address=192.168.40.0/24 dst-address=192.168.30.0/24 action=accept comment="WORK->SRV"
/ip firewall filter add chain=forward src-address=192.168.50.0/24 dst-address=192.168.0.0/16 action=drop comment="KIDS block LAN"
/ip firewall filter add chain=forward src-address=192.168.60.0/24 dst-address=192.168.0.0/16 action=drop comment="IOT block LAN"
/ip firewall filter add chain=forward src-address=192.168.70.0/24 dst-address=192.168.0.0/16 action=drop comment="GUEST block LAN"
/ip firewall filter add chain=forward src-address=192.168.0.0/16 dst-address=192.168.0.0/16 action=drop comment="block inter-VLAN default"
:put "Step 10: forward policy complete"

