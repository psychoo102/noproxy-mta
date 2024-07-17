local noproxy = {}

----------------------------Config----------------------------
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
-- Send to webhook when detected?
noproxy.sendWebhook = false
-- Discord webhook to inform when VPN/proxy detected
noproxy.webhookURL = ""
-- Discord webhook username
noproxy.webhookUsername = "NO-PROXY"
-----------------------------------------------------------------------

sendOptions = {
    queueName = "NO-PROXY",
    connectionAttempts = 3,
    connectTimeout = 5000,
    headers = {
        ["Authorization"] = string.format("Bearer %s", noproxy.authorizationToken)
    }
}

addEventHandler("onResourceStart", resourceRoot, function()
    outputServerLog("[NOPROXY] Protection Enabled.")
	outputDebugString("[NOPROXY] Protection Enabled.")

	if noproxy.onStartCheckup then
        outputServerLog("[NOPROXY] Checking players...")
        outputDebugString("[NOPROXY] Checking players...")
		for i, player in ipairs(getElementsByType("player")) do
			setTimer(function() checkVPN(player) end, i*100, 1)
		end
	end
end)

function checkVPN(player)
	assert(getElementType(player)=="player", "NOPROXY ERROR: No players were supplied")	
	local playerIP = getPlayerIP(player)
    local playerSerial = getPlayerSerial(player)
	
	for _, ip in ipairs(noproxy.excludeIPs) do
		if ip == playerIP then outputServerLog(string.format("[NOPROXY] IP %s avoided.", playerIP)) outputDebugString(string.format("[NOPROXY] IP %s avoided.", playerIP), 2) return false end
	end
	
    fetchRemote(string.format("https://api.noproxy.okaeri.cloud/v1/%s", playerIP), sendOptions, function (rdata, status)
        if (not status.success) then
            outputServerLog(string.format("[NOPROXY] Unable to verify %s (SERIAL: %s IP: %s)", getPlayerName(player), playerSerial, playerIP))
            outputDebugString(string.format("[NOPROXY] Unable to verify %s (SERIAL: %s IP: %s)", getPlayerName(player), playerSerial, playerIP))
            outputServerLog(string.format("[NOPROXY] Error: %s", status.statusCode))
            outputDebugString(string.format("[NOPROXY] Error: %s", status.statusCode))
            if noproxy.kickOnError then
                kickPlayer(player, "Unable to check your connection")
            end
            return
        end
        local data = fromJSON(rdata)
        if data.suggestions.block then
            if noproxy.punishOnDetect then
                if noproxy.punishmentWithKick then
                    kickPlayer(player, noproxy.punishReason)
                elseif noproxy.punishmentWithBan then
                    banPlayer(player, true, false, false, "NO-PROXY", noproxy.punishReason, noproxy.punishBanTime)
                end
            end
            local message = string.format("[NOPROXY] VPN/proxy detected on %s (SERIAL: %s IP: %s)", getPlayerName(player), playerSerial, playerIP)
            if noproxy.sendWebhook then
                sendToDiscord(message)
            end
            outputServerLog(message)
			outputDebugString(message)
            return
        end

        outputServerLog(string.format("[NOPROXY] No VPN/proxy on %s (SERIAL: %s IP: %s)", getPlayerName(player), playerSerial, playerIP))
        outputDebugString(string.format("[NOPROXY] No VPN/proxy on %s (SERIAL: %s IP: %s)", getPlayerName(player), playerSerial, playerIP))
    end)
	return true
end

addEventHandler("onPlayerJoin", root, function()
	checkVPN(source, false)
end)

----

function sendToDiscord(message)
    local request = fetchRemote(noproxy.webhookURL, {
		queueName = "NO-PROXY-WEBHOOKS",
		connectionAttempts = 10,
		connectTimeout = 2000, 
		formFields = {
			username = noproxy.webhookUsername,
			content = message
		}
	}, function() end)
end