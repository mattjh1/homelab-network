# SSH Setup (Post-Install)

Goal: reach MGMT devices with low pain, keep MGMT locked down.

Current network model:

- CORE: `192.168.20.0/24`
- MGMT: `192.168.10.0/24`
- Router MGMT IP: `192.168.10.1`

Use jump host in CORE. SSH goes through jump host into MGMT.

## Why this is good

- Keep MGMT isolated.
- Still easy to use every day.
- One short command to reach router/switch/AP.

## 1) Make keys

```bash
ssh-keygen -t ed25519 -f ~/.ssh/homelab_jump -C "homelab-jump"
ssh-keygen -t ed25519 -f ~/.ssh/homelab_router -C "homelab-router"
```

## 2) Put public keys on targets

Put:

- `~/.ssh/homelab_jump.pub` on jump host user
- `~/.ssh/homelab_router.pub` on router admin user

## 3) Add SSH config

Put this in `~/.ssh/config`:

```sshconfig
Host homelab-jump
  HostName 192.168.20.10
  User youruser
  IdentityFile ~/.ssh/homelab_jump
  IdentitiesOnly yes

Host router-mgmt
  HostName 192.168.10.1
  User admin
  IdentityFile ~/.ssh/homelab_router
  IdentitiesOnly yes
  ProxyJump homelab-jump
```

Optional speed/reliability:

```sshconfig
Host *
  ServerAliveInterval 30
  ServerAliveCountMax 3
  ControlMaster auto
  ControlPath ~/.ssh/cm-%r@%h:%p
  ControlPersist 10m
```

## 4) Test

### Do

```bash
ssh homelab-jump
ssh router-mgmt
```

### Check

- jump host login works
- router login works through jump

### If broken

- run `ssh -vvv router-mgmt`
- check jump host can reach `192.168.10.1`
- check router input rules still allow trusted admin source

## 5) Web UI tunnel (switch/AP)

Use local tunnel when UI is only in MGMT.

Example (switch UI at `192.168.10.2:443`):

```bash
ssh -J homelab-jump -L 8443:192.168.10.2:443 youruser@192.168.20.10
```

Open:

- `https://localhost:8443`

## 6) Use with this repo

`scripts/apply-all.sh` uses direct SSH fields from `secrets.env`.
For first runs, use direct local MGMT access as documented in `docs/network-plan.md`.

If you want jump-host execution for automation later, run script from host that can already reach MGMT.

