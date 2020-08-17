# Scripts

Multiple scripts to help setting things up quickier than inputting all the commands and/or reviewing multiple forums to find the answer.

## Table of Contents

- [Disabling power save](setup.sh): Use it to make sure your wlan doesn't disconnect as the Pi doesn't have Wake on Lan.
- [Installing Docker](setup-docker.sh): Everything to install Docker in a single script.
- [Pihole](pihole.sh): **Requires Docker**. Disables and replaces default DNS server included by default. Install it in just a command.
- [Proxy ARP](proxy-arp.sh): This script will setup a bridge between a device and your router. It's helpful to attach a device to your network, like an old printer.
- **Ignored files**: This files should be ignored, they are used by other scripts. You can still review them, but should not be used directly.
  - set\-arp\-routing
