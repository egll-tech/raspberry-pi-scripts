# Scripts

Multiple scripts to help setting things up quickier than inputting all the commands and/or reviewing multiple forums to find the answer.
You can use them by looking the github url in 'raw' mode and executing a single command.

```
curl -sL <URL> | sudo -E bash -
```

### Example

```
curl -sL https://raw.githubusercontent.com/egll-tech/raspberry-pi-scripts/master/scripts/setup.sh | sudo -E bash -
```

## Table of Contents

- [Disabling power save](setup.sh): Use it to make sure your wlan doesn't disconnect as the Pi doesn't have Wake on Lan.
- [Proxy ARP](proxy-arp.sh): This script will setup a bridge between a device and your router. It is helpful to extend your current network or attach a device to your network, like an old printer.
- **Ignored files**: This files should be ignored, they are used by other scripts. You can still review them, but should not be used directly.
  - set\-arp\-routing
