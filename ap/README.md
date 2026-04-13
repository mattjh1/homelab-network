# AP Setup

AP uses separate render pass. Router renderer defaults to router/ only.

## Render
```bash
set -a && source secrets.env && set +a
go run scripts/render-router-templates.go --src-dir ap --dst-dir .rendered/ap
```

## Copy to AP
```bash
scp .rendered/ap/cap-bootstrap.rsc admin@<AP_IP>:cap-bootstrap.rsc
```

## Import on AP
```bash
ssh admin@<AP_IP> "/import file-name=cap-bootstrap.rsc"
```

## Verify
On main router run:
```
/interface wifi capsman remote-cap print
```
AP must appear in list.

## Order
Run this step last. After router and switch fully up and CAPsMAN enabled.

Done.
