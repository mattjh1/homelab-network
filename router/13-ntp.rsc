# Step 13 - NTP client settings

:local ntpServer "{{ .NTP_SERVER }}"
:local ntpFallback "{{ .NTP_FALLBACK }}"

:put "Step 13: NTP start"
/system ntp client set enabled=yes servers=$ntpServer,$ntpFallback
:put "Step 13: NTP complete"

