# NoProxy VPN Detector for Multi Theft Auto

## Description

This simple resource is created to help protect Multi Theft Auto servers from malicious users using VPN connection to hide their real IP.

This script using [OK! No Proxy](https://www.okaeri.cloud/services/noproxy) API for VPN detection.

## Configuration

All you need to set is in main script file (server.lua)

You can get your own authorization token from [Customer Console](https://console.okaeri.cloud/)

```----------------------------Config----------------------------
--Set to true to check all the connected players on the resource start
noproxy.onStartCheckup = true 
--Put there your token from Okaeri Cloud service dashboard
noproxy.authorizationToken = "TOKEN"
-- here add IP's that you want to avoid checking
noproxy.excludeIPs = {
	"127.0.0.1",
}

-- Set to true if players should be kicked when is there an error with checking for VPN/proxy
noproxy.kickOnError = true
-- Set to true if players should be punished when VPN/proxy detected
noproxy.punishOnDetect = true
-- Put there reason for punishment if enabled
noproxy.punishReason = "VPN/proxy detected"
-- Set to true if players should be kicked on detection
noproxy.punishWithKick = false
-- Set to true if players should be banned on detection
noproxy.punishWithBan = true
-- Set ban time for using VPN/proxy in seconds (0 for permanent)
noproxy.punishBanTime = 0
-----------------------------------------------------------------------
```