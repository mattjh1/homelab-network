# Step 15 - Admin input lockdown
# Default-drop on chain=input. Only MGMT can reach the router's admin
# services; SRV gets a narrow hole for RouterOS API (home automation
# integration). Everything else falls through to the final drop.

:put "Step 15: input lockdown start"
/ip firewall filter add chain=input src-address=192.168.10.0/24 action=accept comment="accept MGMT input"
/ip firewall filter add chain=input src-address=192.168.30.0/24 protocol=tcp dst-port=8728,8729 action=accept comment="accept SRV API input"
/ip firewall filter add chain=input action=drop comment="default drop input"
:put "Step 15: input lockdown complete"
