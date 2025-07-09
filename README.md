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

## Installation

1. Install Docker Container on your server. [Follow the tutorial here](https://docs.docker.com/engine/install/)
2. Clone this Repository
	```bash
	git clone https://github.com/GegeDevs/vpnpanel-docs.git ./vpnpanel
	```
3. Use one of these two options
	```bash
	cd ./vpnpanel/config
	```
4. Edit `config.yaml`
	| TAG | Instruction |
	|--|--|
	| `<BOT_TOKEN>` | replace with yout bot token from [botFather](https://t.me/BotFather) |
	| `<BOTNOTIF_TOKEN>` | replace with yout bot token from [botFather](https://t.me/BotFather) |

5. Start Docker Compose
	```bash
	sudo docker compose up -d
	```

6. Test `/start` on your bot

## Register VPS IP Address for Access [FREE]

Register your VPS IP Address to this bot [GegeVPS AutoScript](https://t.me/GegeVPS_AutoScript_bot). There is a plan for one day every day. You can use it to test the bot's connection to the server.

## Features

 - [x] Admin Panel Dashboard for Centralize Configuration
 - [x] Pluginable for Supporting many VPN Server Script
 - [x] Broadcast Message to All Client
 - [x] Notes for each Tunnel Menu
 - [x] Editable Start Notes
 - [x] Hashtag Notes
 - [x] Supports Multiple tunnel types
 - [x] Tunnel Duration/Quota Based Plan
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
 - [ ] RESTful API
 - [ ] Auto Backup Bot Data
 - [ ] QRIS Static as Alternative for QRIS Invalid (*like on [SeaBank](https://www.seabank.co.id/)*)

## Payment Gateway Supported
 
 - [x] [NOWPayments](https://account.nowpayments.io/sign-in)
 - [x] [Tripay](https://tripay.id/login)
 - [x] [OkeConnect](https://www.okeconnect.com/auth/secure_login) / [OrderKuota](https://orderkuota.com/)
 - [x] [Saweria](https://saweria.co)

*TODO...*
 - [ ] [Paypal](https://www.paypal.com/id/home)
 - [ ] [Qiospay](https://qiospay.id/)
 - [ ] [Midtrans](https://midtrans.com/id)

## Tunnel Supported

### Duration Based

| Tunnel | Code | Action Locally | Action Remotely |
|--|--|--|--|
| SSH/OpenVPN | `sshovpn` | `info` | `create`, `extend`,<br/>  `delete`, `checklogin`,<br/> `lock`, `unlock` |
| SoftetherVPN | `sevpn` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |
| WireGuard | `wireguard` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |
| VMess | `vmess` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |
| VLess | `vless` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |
| Trojan | `trojan` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |
| Shadowsocks | `ssocks` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |
| Trojan-Go | `trojango` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |
| Socks5 | `socks5` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |
| Hysteria1 | `hysteria1` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |
| Hysteria2 | `hysteria2` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |
| UDP Custom | `udpcustom` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |

*Command Format*
```bash
/etc/gegevps/bin/telegram-<CODE>-<ACTION>.sh <USERNAME> <PASSWORD> <DAYS>
```

*example*: 

```bash
# VMess Create Account
/etc/gegevps/bin/telegram-vmess-create.sh gegeuser gegepass 30

# Username: gegeuser
# Password: gegepass
# Days: 30
```

### Quota Based

| Tunnel | Code | Action Locally | Action Remotely |
|--|--|--|--|
| VMess Quota-Based | `vmessqb` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |
| VLess Quota-Based | `vlessqb` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |
| Trojan Quota-Based | `trojanqb` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |
| NoobzVPN | `noobz` | `info` | `create`, `extend`,<br/> `delete`, `checklogin`,<br/> `lock`, `unlock` |

*Command Format*
```bash
/etc/gegevps/bin/telegram-<CODE>-<ACTION>.sh <USERNAME> <PASSWORD> <DAYS> <QUOTA> <CYCLE [daily|weekly|montly]>
```

*example*: 

```bash
# VMess Create Account
/etc/gegevps/bin/telegram-vmess-create.sh gegeuser gegepass 30 25 daily

# Username: gegeuser
# Password: gegepass
# Days: 30
# Quota: 25 GB
# Cycle: daily
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
