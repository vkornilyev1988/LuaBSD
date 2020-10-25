

 	This project is designed to create firmware for various devices not tied to licenses and not be limited in relation to binary files. 
 That is it should work on any device and give an unlimited opportunity to change or supplement the capabilities of the semantics
 of firmware and programs on the fly. The basis instead of sh/bash (although they are left for compatibility) is not the interpreter 
 of commands and binary files, but the lua53 language (with the operators such as ls, ip, arp, cp and the like being implemented). 
 Why lua? This language is close to the C API and simple, even the easiest to understand for a person. It was created in order 
 to remove the complex syntax and be very functional. All the executable programs: zfs, ifconfig, busybox, firewall, 
 http, https, shell — basically everything consists not of binary files but of lua scripts, which will make it possible 
 to change the firmware semantics easily and not forcibly as the user needs. In general, take and don’t be limited to 
 binary files for certain architectures. In other words, all scripts are executable on any architecture, just copy 
 the previously written scripts to a completely different device and use. No restrictions.

========================================

 TODO:
- [x] Initial initialization of system boot 
- [x] Multithreaded network initialization, network initialization occurs in parallel to the boot
- [x] Dialog type:tables functions
- [x] Busybox commands (cp / ls / mv / rm / rename / du / cat, etc.)
- [x] ip table - network resource management command (network cards)
- [x] netgraph - netgraph network stack management team
- [ ] llvm - runtime under other OS architectures
- [ ] Operating system installer
- [ ] GUI
- [x] ZFS released teams working with ZFS and ZPOOL
- [ ] spwd work with users and groups (Functions exist, you need to write a module in lua)
- [x] chroot / jail / jls implement OS container functions
- [x] kldload / kldstat / kldunload - release tools for working with kernel modules
- [x] BDB - release work with data BerklyDB
- [x] SQlite / Mysql - release the ability to work with data
- [x] HTTP / HTTPS - implement websocket (there are not enough lua modules / Functions are also present)
- [x] Socket / Unix socket - implement work with sockets
- [x] JSON / CJSON - import json modules
- [ ] Implement a code editor
- [x] Shellinabox - Implement Remote Connectivity
- [ ] OpenSSH - Implement Remote Connectivity
- [ ] HardenedBSD security flags - add compilation flags for HardenedBSD