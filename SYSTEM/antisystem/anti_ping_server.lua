local playerHightPingData={}
local maxAllowedPing=300
local maxPingCounts=10
local pingWhiteList={}

function init_anti_high_ping()
	setTimer(checkHighPing,1000,0)

    local query="SELECT * FROM whitelist WHERE ANTIHIGHPING='1'"
    local result=mysql_query(handler,query)
    local zahl=0
    while(mysql_num_rows(result) > zahl) do
        local dsatz = mysql_fetch_assoc(result)
        pingWhiteList[string.lower(dsatz["Nickname"])]=true
        zahl=zahl+1
    end


end
addEventHandler("onResourceStart",getRootElement(),init_anti_high_ping)


function aktualizePingWhiteList(thePlayer)
    if(isAdminLevel(thePlayer,4))then
        pingWhiteList={}

        local query="SELECT * FROM whitelist WHERE ANTIHIGHPING='1'"
        local result=mysql_query(handler,query)
        local zahl=0
        while(mysql_num_rows(result) > zahl) do
            local dsatz = mysql_fetch_assoc(result)
            pingWhiteList[string.lower(dsatz["Nickname"])]=true
            zahl=zahl+1
        end
    end
end
addCommandHandler("aktping",aktualizePingWhiteList,false,false)

function checkHighPing()
	for theKey, thePlayer in ipairs(getElementsByType("player"))do 
		if(vioGetElementData(thePlayer,"playtime"))then
			local ping=getPlayerPing(thePlayer)
			
			--outputChatBox(getPlayerName(thePlayer)..": "..ping.." "..tostring(playerHightPingData[thePlayer]))
			if(ping>=maxAllowedPing and not(pingWhiteList[string.lower(getPlayerName(thePlayer))]))then
				if(not(playerHightPingData[thePlayer]))then
					playerHightPingData[thePlayer]=0
				end
				playerHightPingData[thePlayer]=playerHightPingData[thePlayer]+1
				if (isAdminLevel(thePlayer, 4)) then return 0 end
				if(playerHightPingData[thePlayer]>maxPingCounts)then
					outputChatBox(string.format("ANTI-HIGH-PING: %s wurde aufgrund eines zuhohen Pings gekickt (%sms)", getPlayerName(thePlayer), maxAllowedPing),getRootElement(),255,0,0)
					kickPlayer(thePlayer,string.format("Dein Ping ist zu hoch! (max. %sms)", maxAllowedPing))
				end
			else
				playerHightPingData[thePlayer]=0
			end	
		end
	end
end








