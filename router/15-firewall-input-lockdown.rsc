# Step 15 - Strict input lock-down (after VLANs/services are stable)

:local mgmtSubnet "{{ .MGMT_SUBNET }}"
:local trustedCoreAdminIp "{{ .TRUSTED_CORE_ADMIN_IP }}"
:local trustedCoreComment "Trusted CORE admin"
:local mgmtComment "MGMT full access"
:local dropComment "drop all other router access"

:put "Step 15: strict input lock-down start"
:if ($trustedCoreAdminIp = "0.0.0.0") do={ :error "TRUSTED_CORE_ADMIN_IP must be set to your admin laptop CORE IP" }
/ip firewall filter remove [find where chain=input comment=$trustedCoreComment]
/ip firewall filter remove [find where chain=input comment=$mgmtComment]
/ip firewall filter remove [find where chain=input comment=$dropComment]
/ip firewall filter add chain=input src-address=$trustedCoreAdminIp action=accept comment=$trustedCoreComment
/ip firewall filter add chain=input src-address=$mgmtSubnet action=accept comment=$mgmtComment
/ip firewall filter add chain=input action=drop comment=$dropComment
:put "Step 15: strict input lock-down complete"

