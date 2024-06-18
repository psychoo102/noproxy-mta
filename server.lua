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
-----------------------------------------------------------------------

sendOptions = {
    queueName = "NOPROXY",
    connectionAttempts = 3,
    connectTimeout = 5000,
    headers = {
        ["Authorization"] = string.format("Bearer %s", noproxy.authorizationToken)
    }
}

addEventHandler("onResourceStart", resourceRoot, function()
	outputDebugString("[NOPROXY] Protection Enabled.")

	if noproxy.onStartCheckup then
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
		if ip == playerIP then outputDebugString("[NOPROXY] IP avoided.", 2) return false end
	end
	
    fetchRemote(string.format("https://api.noproxy.okaeri.cloud/v1/%s", playerIP), sendOptions, function (rdata, status)
        if (not status.success) then
            outputDebugString(string.format("[NOPROXY] Unable to verify %s (SERIAL: %s IP: %s)", getPlayerName(player), playerSerial, getPlayerIP(player)))
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
                    banPlayer(player, playerIP, nil, playerSerial, nil, noproxy.punishReason, noproxy.punishBanTime)
                end
            end
			outputDebugString("[NOPROXY] VPN/proxy detected on %s (SERIAL: %s IP: %s)", getPlayerName(player), playerSerial, getPlayerIP(player))
            return
        end

        outputDebugString(string.format("[NOPROXY] No VPN/proxy on %s (SERIAL: %s IP: %s)", getPlayerName(player), playerSerial, getPlayerIP(player)))
    end)
	return true
end

addEventHandler("onPlayerJoin", root, function()
	checkVPN(source, false)
end)