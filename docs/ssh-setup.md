# SSH Setup (Post-Install)

Goal: reach router admin with low pain, keep admin locked to MGMT only.

Current network model:

- MGMT: `192.168.10.0/24`, wired only (`ether6`), no WAN route — connecting
  here gets you the router and nothing else, no internet.
- Router MGMT IP: `192.168.10.1`.
- Admin services (SSH, Winbox, WebFig) are restricted at the service level
  to the MGMT subnet, regardless of firewall filter rules. See "Why wired
  only" below.

No jump host. No ProxyJump. Deliberately simple: plug the MGMT cable in,
SSH straight to the router. Internet stays up the whole time over your
normal WiFi/LAN connection — MGMT is a second, parallel link with no
gateway configured, used only for router access.

## Why wired only

`/ip service` has its own `address=` allow-list per service, separate from
`/ip firewall filter`. Check it:

```
/ip service print detail where name=ssh
```

Expect `address=192.168.10.0/24`. This is what actually blocks access from
CORE or any other VLAN — not the firewall forward/input chains. Widening
this would let SSH work from CORE without the cable, but the current
restriction is a deliberate choice: MGMT has no WAN route, so even a fully
compromised admin session can't be used to reach out to the internet.
Kept as-is on purpose.

## 1) Key already set up

Key auth is already imported on the router:

```
/user/ssh-keys print
```

Should show `admin` with an ed25519 key. If missing, generate + import:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/homelab_router -C "homelab-router"
scp ~/.ssh/homelab_router.pub admin@192.168.10.1:
```

On the router:

```
/user/ssh-keys import public-key-file=homelab_router.pub user=admin
```

## 2) Client SSH config

`~/.ssh/config`:

```sshconfig
Host homelab-router
  HostName 192.168.10.1
  User admin
  IdentityFile ~/.ssh/homelab_router
  IdentitiesOnly yes
```

## 3) Connect

- Plug laptop into MGMT (`ether6`), set static profile `192.168.10.2/24`,
  no gateway.
- `ssh homelab-router`

## 4) If broken

- `ssh -vvv homelab-router` — check it's actually trying pubkey auth, not
  falling back to password (falls back silently if the key isn't imported
  or `IdentitiesOnly` isn't set and the wrong key offers first).
- Confirm the static MGMT profile is active: `ip route get 192.168.10.1`
  should show your MGMT interface, not a default-route hop.
- `/ip service print detail where name=ssh` on router (via console/Winbox
  if SSH itself is the thing broken) — confirm `address=` still covers
  `192.168.10.0/24`.

## 5) Use with this repo

`scripts/apply-all.sh` uses direct SSH fields from `secrets.env`, run from
a machine on the MGMT subnet (same wired access as above). No jump host
involved.
