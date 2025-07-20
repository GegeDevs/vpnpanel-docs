# VPN Telegram Panel - Documentation

<p align="center">
	<a href="https://t.me/gegevps_tunnel_bot"><b>LIVE PREVIEW DEMO</b></a>
</p>

## Overview

<p align="center">
  <img src="./images/ClientDashboard.png" height="400"/>
  <img src="./images/AdminDashboard.png" height="400"/>
</p>
<p align="center">
  <img src="./images/TunnelMenu.png" height="300"/>
  <img src="./images/TunnelSupported.png" height="300"/>
</p>

## Register VPS IP Address for Access [FREE]

Register your VPS IP Address to this bot [GegeVPS AutoScript](https://t.me/GegeVPS_AutoScript_bot). There is a plan for one day every day. You can use it to test the bot's connection to the server.

## Installation

1. Install Docker Container on your server. [Follow the tutorial here](https://docs.docker.com/engine/install/)
2. Clone this Repository
	```bash
	git clone https://github.com/GegeDevs/vpnpanel-docs.git ./vpnpanel
	```
3. Change to the config directory
	```bash
	cd ./vpnpanel/config
	```
4. Edit `config.yaml`
	| TAG | Instruction |
	|--|--|
	| `<BOT_TOKEN>` | replace with your bot token from [botFather](https://t.me/BotFather) |
	| `<BOTNOTIF_TOKEN>` | replace with your bot token from [botFather](https://t.me/BotFather) |

5. Start Docker Compose
	```bash
	sudo docker compose up -d
	```

6. Test `/start` on your bot

## Update Latest Version

1. Go to Docker Compose directory
	```bash
	cd ./vpnpanel/config
	```

2. Enter this Command
	```bash
	sudo docker compose down --rmi all && \
	sudo docker compose up -d
	```

## Features

 - [x] Admin Panel Dashboard for Centralize Configuration
 - [x] Auto Backup Bot Data to Google Drive
 - [x] Pluginable for Supporting many VPN Server Script
 - [x] Broadcast Message to All Client
 - [x] Whitelabel Changer Interface
 - [x] Channels List Interface Editor
 - [x] Check Version Update
 - [x] Notes for each Tunnel Menu
 - [x] Editable Start Notes
 - [x] Hashtag Notes
 - [x] Supports Multiple tunnel types
 - [x] Tunnel Duration/Quota Based Plan
 - [x] Tunnel Transport Enabler/Disabler
 - [x] Add, Reduce, Check Balance Client
 - [x] Add, Delete, and List Server
 - [x] Add, Delete, Edit Tunnel Plan
 - [x] Add, Remove, and List Reseller
 - [x] Add, Remove, and List Admin
 - [x] Enable/Disable Server
 - [x] Enable/Disable Tunnel Plan
 - [x] Hide/Show Tunnel Type
 - [x] Hide/Show Payment Method
 - [x] Hide/Show Payment Gateway
 - [x] Hide/Show IP Server (Client Side)
 - [x] Interactive Payment Configuration
 - [x] Maintenance Mode Toggler

*TODO...*
 - [ ] RESTful API Access
 - [ ] Trial Button
 - [ ] QRIS Static as Alternative for QRIS Invalid (*like on [SeaBank](https://www.seabank.co.id/)*)

## Payment Gateway Supported
 
 - [x] [NOWPayments](https://account.nowpayments.io/sign-in)
 - [x] [Tripay](https://tripay.id/login)
 - [x] [VioletMediaPay](https://violetmediapay.com/)
 - [x] [OkeConnect](https://www.okeconnect.com/auth/secure_login) / [OrderKuota](https://orderkuota.com/)
 - [x] [Saweria](https://saweria.co)

*TODO...*
 - [ ] [Paypal](https://www.paypal.com/id/home)
 - [ ] [Qiospay](https://qiospay.id/)
 - [ ] [Midtrans](https://midtrans.com/id)

## Script Supported
 
 - [x] [Marzban-MarLing](https://github.com/GegeDevs/vpnpanel-docs/tree/main/modules/Marzban-MarLing)
 - [x] [Potato](https://github.com/GegeDevs/vpnpanel-docs/tree/main/modules/Potato)
 - [x] [SC_AryaBlitar](https://github.com/GegeDevs/vpnpanel-docs/tree/main/modules/SC_AryaBlitar)
 - [x] [SC_Rerechan02](https://github.com/GegeDevs/vpnpanel-docs/tree/main/modules/SC_Rerechan02)
 - [x] [usmt-py](https://github.com/GegeDevs/vpnpanel-docs/tree/main/modules/usmt-py)

*TODO...*
 - [ ] Make a request in the [Issues](https://github.com/GegeDevs/vpnpanel-docs/issues)


## Tunnel Supported

### Duration Based

| Tunnel | Code | Action Locally | Action Remotely |
|--|--|--|--|
| 🐡 SSH/OpenVPN | `sshovpn` | `info` | `create`, `extend`,<br/>  `delete`, `checklogin`,<br/> `lock`, `unlock` |
| 🛰️ SoftetherVPN | `sevpn` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |
| 🐉 WireGuard | `wireguard` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |
| 🦈 VMess | `vmess` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |
| 🐬 VLess | `vless` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |
| 🐎 Trojan | `trojan` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |
| 🥷🏿 Shadowsocks | `ssocks` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |
| 🦄 Trojan-Go | `trojango` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |
| 🛡️ Socks5 | `socks5` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |
| 🪽 Hysteria1 | `hysteria1` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |
| ⚡️ Hysteria2 | `hysteria2` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |
| 🎨 UDP Custom | `udpcustom` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |

*Command Format*
```bash
/etc/gegevps/bin/telegram-<CODE>-<ACTION>.sh <USERNAME> <PASSWORD> <DAYS>
```

*example*: 

```bash
# VMess Create Account
/etc/gegevps/bin/telegram-vmess-create.sh gegeuser gegepass 30 ws

# Username: gegeuser
# Password: gegepass
# Days: 30
# Transport: ws
```

### Quota Based

| Tunnel | Code | Action Locally | Action Remotely |
|--|--|--|--|
| 🦈 VMess Quota-Based | `vmessqb` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |
| 🐬 VLess Quota-Based | `vlessqb` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |
| 🐎 Trojan Quota-Based | `trojanqb` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |
| 🧪 NoobzVPN | `noobz` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |
| ⚡️ Hysteria 2 Quota-Based | `hysteria2qb` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |

*Command Format*
```bash
/etc/gegevps/bin/telegram-<CODE>-<ACTION>.sh <USERNAME> <PASSWORD> <DAYS> <QUOTA> <CYCLE [daily|weekly|montly]>
```

*example*: 

```bash
# VMess Create Account
/etc/gegevps/bin/telegram-vmess-create.sh gegeuser gegepass 30 25 daily ws

# Username: gegeuser
# Password: gegepass
# Days: 30
# Quota: 25 GB
# Cycle: daily
# Transport: ws
```

| Action | Details |
|--|--|
**`create` | Used to create tunnel accounts
**`extend` | Used to extend the active period of a tunnel account
*`info` | Check account details based on bot database
**`delete` | Delete user account on server
**`checklogin` | Check user login on server
**`lock` | Lock tunnel account
**`unlock` | Unlock tunnel account

> *Locally : *No connection to server required*<br>**Remotely : *Requires connection to server*

### Transport

| Transport | Details |
|--|--|
`tcp` | 🎯 TCP |
`ws` | 🌐 WebSocket |
`grpc` | 🧬 gRPC |
`xhttp` | 💨 XHTTP |
`httpupgrade` | 🆙 HTTPUpgrade |

# Debugging

### OrderKuota Payment Gateway

The original API Endpoint URL from OrderKuota **only allows connections from Indonesian IP addresses**. _However, this bot has been configured with an Indonesian IP Reverse Proxy, so it can still be used even if the bot is running on a server with an international IP._ Still, if you intend to use OrderKuota Payment Gateway as the main payment method, it is **recommended to host the bot server with an Indonesian IP**. **The Reverse Proxy embedded in the bot application** is hosted on the developer's personal (home) server, so there is **no guaranteed SLA uptime** due to various factors such as power outages and others. Thank you.

### Restore Backup File

```log
root@serverbot:~/vpnpanel/config# docker compose up -d && docker compose logs -f
Attaching to api-1, bot-1, nginx-1
nginx-1  | /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
nginx-1  | /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
nginx-1  | /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
api-1    | telegram-bot-api --http-port 8081 --dir=/var/lib/telegram-bot-api --temp-dir=/tmp/telegram-bot-api --username=telegram-bot-api --groupname=telegram-bot-api --api-id=191xxx --api-hash=1586c21e3d9d8exxxxx 
nginx-1  | 10-listen-on-ipv6-by-default.sh: info: can not modify /etc/nginx/conf.d/default.conf (read-only file system?)
nginx-1  | /docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
nginx-1  | /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
nginx-1  | /docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
nginx-1  | /docker-entrypoint.sh: Configuration complete; ready for start up
api-1    | [ 0][t 9][1752819429.874213457][Status.h:256][!ClientManager]        Unexpected Status [PosixError : Permission denied : 13 : File "/var/lib/telegram-bot-api/tqueue.binlog" can't be opened/created for reading and writing] in file /root/tdlib/telegram-bot-api/ClientManager.cpp at line 326
api-1    | [pid 1] [time 1752819429] ------- Log dump -------
..........
```

This is caused by a file permission issue. You can resolve it with the following command:

```bash
chmod -R 777 ./data # Grant more permissive access to data files
docker compose down && docker compose up -d
```
