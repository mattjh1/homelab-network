# Step 14 - CAPsMAN baseline

:local capsmanMgmtIface "{{ .CAPSMAN_MGMT_INTERFACE }}"
:local enableCapsman "{{ .ENABLE_CAPSMAN }}"
:local secCorePass "{{ .WIFI_PASS_CORE }}"
:local secKidsPass "{{ .WIFI_PASS_KIDS }}"
:local secIotPass "{{ .WIFI_PASS_IOT }}"
:local secGuestPass "{{ .WIFI_PASS_GUEST }}"
:local ssidCore "{{ .SSID_CORE }}"
:local ssidKids "{{ .SSID_KIDS }}"
:local ssidIot "{{ .SSID_IOT }}"
:local ssidGuest "{{ .SSID_GUEST }}"

:put "Step 14: CAPsMAN baseline start"
:if ($enableCapsman = "true") do={
  /interface wifi cap set enabled=yes
  /interface wifi capsman set enabled=yes interfaces=$capsmanMgmtIface ca-certificate=auto certificate=auto

  /interface wifi security add name=sec-core authentication-types=wpa2-psk passphrase=$secCorePass ft=no ft-over-ds=no
  /interface wifi security add name=sec-kids authentication-types=wpa2-psk passphrase=$secKidsPass
  /interface wifi security add name=sec-iot authentication-types=wpa2-psk passphrase=$secIotPass
  /interface wifi security add name=sec-guest authentication-types=wpa2-psk passphrase=$secGuestPass

  /interface wifi channel add name=ch-5g band=5ghz-ax frequency=5745,5765,5785,5805,5825 width=20/40/80mhz
  # pinned to a single 2.4GHz channel (6) to avoid interference, not auto-scanned
  /interface wifi channel add name=ch-2g band=2ghz-ax frequency=2437 width=20mhz

  /interface wifi datapath add name=dp-core vlan-id=20
  /interface wifi datapath add name=dp-kids vlan-id=50
  /interface wifi datapath add name=dp-iot vlan-id=60
  /interface wifi datapath add name=dp-guest vlan-id=70

  /interface wifi configuration add name=cfg-core-5g ssid=$ssidCore security=sec-core datapath=dp-core channel=ch-5g mode=ap steering.rrm=yes steering.wnm=yes
  /interface wifi configuration add name=cfg-core-2g ssid=$ssidCore security=sec-core datapath=dp-core channel=ch-2g mode=ap steering.2g-probe-delay=yes steering.rrm=yes steering.wnm=yes
  /interface wifi configuration add name=cfg-kids-5g ssid=$ssidKids security=sec-kids datapath=dp-kids channel=ch-5g mode=ap
  /interface wifi configuration add name=cfg-kids-2g ssid=$ssidKids security=sec-kids datapath=dp-kids channel=ch-2g mode=ap
  /interface wifi configuration add name=cfg-iot-5g ssid=$ssidIot security=sec-iot datapath=dp-iot channel=ch-5g mode=ap
  /interface wifi configuration add name=cfg-iot-2g ssid=$ssidIot security=sec-iot datapath=dp-iot channel=ch-2g mode=ap
  /interface wifi configuration add name=cfg-guest-5g ssid=$ssidGuest security=sec-guest datapath=dp-guest channel=ch-5g mode=ap
  /interface wifi configuration add name=cfg-guest-2g ssid=$ssidGuest security=sec-guest datapath=dp-guest channel=ch-2g mode=ap

  /interface wifi provisioning add action=create-enabled master-configuration=cfg-core-5g slave-configurations=cfg-kids-5g,cfg-iot-5g,cfg-guest-5g supported-bands=5ghz-ax
  /interface wifi provisioning add action=create-enabled master-configuration=cfg-core-2g slave-configurations=cfg-kids-2g,cfg-iot-2g,cfg-guest-2g supported-bands=2ghz-ax
} else={
  :put "Step 14: CAPsMAN disabled by template variable"
}
:put "Step 14: CAPsMAN baseline complete"

