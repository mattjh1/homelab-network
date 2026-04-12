# Step 13 - NTP client settings

:local ntpServer "{{ .NTP_SERVER }}"

:put "Step 13: NTP start"
/system ntp client set enabled=yes servers=$ntpServer
:put "Step 13: NTP complete"

