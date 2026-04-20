# Step 15 - Strict input lock-down (after VLANs/services are stable)

:local mgmtSubnet "{{ .MGMT_SUBNET }}"
:local mgmtComment "MGMT full access"
:local dropComment "drop all other router access"

:put "Step 15: strict input lock-down start"
/ip firewall filter remove [find where chain=input comment=$mgmtComment]
/ip firewall filter remove [find where chain=input comment=$dropComment]
/ip firewall filter add chain=input src-address=$mgmtSubnet action=accept comment=$mgmtComment
/ip firewall filter add chain=input action=drop comment=$dropComment
:put "Step 15: strict input lock-down complete"

