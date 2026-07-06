# Step 16 - Management service lockdown
# Restricts RouterOS management services by source subnet, disables
# unused ones, and adds a read-only API user group for the SRV-side
# home automation integration (paired with the SRV API input rule in
# step 15 and the api/api-ssl restriction below).

:put "Step 16: service lockdown start"
/ip service set ftp disabled=yes
/ip service set telnet disabled=yes
/ip service set ssh address=192.168.10.0/24
/ip service set www address=192.168.10.0/24
/ip service set winbox address=192.168.10.0/24
/ip service set api address=192.168.30.0/24
/ip service set api-ssl address=192.168.30.0/24 disabled=yes

/tool mac-server set allowed-interface-list=none
/tool mac-server mac-winbox set allowed-interface-list=none

/user group add name=api-read policy="read,api,!local,!telnet,!ssh,!ftp,!reboot,!write,!policy,!test,!winbox,!password,!web,!sniff,!sensitive,!romon,!rest-api"
:put "Step 16: service lockdown complete"
