# Step 12 - DNS fallback configuration

:local adguardDns "{{ .ADGUARD_DNS_IP }}"
:local publicFallbackDns "{{ .GUEST_DNS_IP }}"

:put "Step 12: DNS fallback start"
/ip dns set allow-remote-requests=yes servers=($adguardDns . "," . $publicFallbackDns)
:put "Step 12: DNS fallback complete"

