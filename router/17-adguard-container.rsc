# Step 17 - Router-hosted AdGuardHome container
# Separate from the AdGuard instance on the SRV "homeserver" (ADGUARD_DNS_IP,
# 192.168.30.10) — this one runs directly on the router via RouterOS
# Container, reachable at FALLBACK_DNS_IP (172.31.255.2). DHCP advertises
# both so clients have a working fallback if the SRV box is down.
# Requires container mode enabled and a USB disk mounted at /usb1-part1
# (see /disk in a full `/export` — auto-detected, not scripted here).

:put "Step 17: AdGuard container start"
/interface veth add name=agh address=172.31.255.2/30 gateway=172.31.255.1 dhcp=no
/ip address add address=172.31.255.1/30 interface=agh comment="AdGuard container fallback"

/container config set registry-url=https://registry-1.docker.io tmpdir=/usb1-part1/tmp
/container mounts add name=agh_conf dst=/opt/adguardhome/conf src=/usb1-part1/conf/agh
/container mounts add name=agh_work dst=/opt/adguardhome/work src=/usb1-part1/conf/agh/work
/container envs add list=AGH key=QUIC_GO_DISABLE_RECEIVE_BUFFER_WARNING value=true

/container add name=adguardhome remote-image=adguard/adguardhome:latest interface=agh \
    root-dir=/usb1-part1/agh mounts=agh_conf,agh_work envlist=AGH \
    entrypoint=/opt/adguardhome/AdGuardHome \
    cmd="-c /opt/adguardhome/conf/AdGuardHome.yaml -h 0.0.0.0 -w /opt/adguardhome/work" \
    start-on-boot=yes logging=yes
:put "Step 17: AdGuard container complete"
