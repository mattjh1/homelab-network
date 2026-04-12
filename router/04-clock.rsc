# Step 04 - Clock and timezone

:local timezoneName "{{ .TIMEZONE_NAME }}"

:put "Step 04: clock policy start"
/system clock set time-zone-name=$timezoneName
:put "Step 04: clock policy complete"

