---
updated: 2024-05-08
author:
  name: Hannes Mehnert
  uri: https://github.com/hannesm
  email: hm519@cam.ac.uk
subject: MirageOS unikernel gallery
permalink: gallery
---

The MirageOS gallery features unikernels that are used in production.

- [QubesOS Firewall](https://github.com/mirage/qubes-mirage-firewall) [writeup](http://roscidus.com/blog/blog/2016/01/01/a-unikernel-firewall-for-qubesos/)- [Unipi](https://github.com/robur-coop/unipi), a webserver serving static websites from a git remote
- [Static website server](https://github.com/mirage/mirage-skeleton/tree/main/applications/static_website_tls), a unikernel with statically compiled website content
- [Pastebin](https://github.com/dinosaure/pasteur), a paste bin [online](https://paste.osau.re/)
- [Tlstunnel](https://github.com/robur-coop/tlstunnel), a TLS reverse proxy
- [CalDAV](https://github.com/robur-coop/caldav/tree/main/mirage), a CalDAV server [online](https://calendar.robur.coop)
- [MirageVPN](https://github.com/robur-coop/miragevpn), an OpenVPN(tm) [server](https://github.com/robur-coop/miragevpn/tree/main/mirage-server) and [client](https://github.com/robur-coop/miragevpn/tree/main/mirage-nat)
- [DHCP](https://github.com/mirage/mirage-skeleton/tree/main/applications/dhcp), a DHCP server
- [Primary DNS](https://github.com/robur-coop/dns-primary-git), an authoritative DNS server
- [Secondary DNS](https://github.com/robur-coop/dns-secondary), a secondary DNS server
- [Let's encrypt provisioning](https://github.com/robur-coop/dns-letsencrypt-secondary), a unikernel which provisions certificates via let's encrypt

Example live unikernels
- [NQSB website](https://github.com/mirleft/nqsb.io), website with a single resource, dispatch via SNI [online](https://nqsb.io)
- [MirageOS website](https://github.com/mirage/mirage-www), [online](https://mirageos.org)

Unikernel example repositories
- [mirage-skeleton](https://github.com/mirage/mirage-skeleton)

Emeriti
- [Canopy](https://github.com/Engil/Canopy), a git-blogging unikernel, content as markdown in a git remote
- [BTC Piñata](https://github.com/mirleft/btc-pinata), a self-serving security bounty
- [TLS handshake demonstration](https://github.com/mirleft/tls-demo-server)
