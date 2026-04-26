# Switch Notes (Optional / Future)

Current deployment path does not require a managed switch.
Router handles VLAN switching directly:

- `ether2` office CORE access
- `ether3` office SRV access
- `ether4` AP trunk via PoE injector
- `ether5` living room dumb switch (IOT access)
- `ether6` MGMT fallback laptop access

Use this folder only if you later add a managed switch again.
