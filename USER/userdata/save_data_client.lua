

local saveTimer=false
function start_mydata()
	
	if(isPlayerLoggedIn(getLocalPlayer()))then
		triggerServerEvent("SaveMyData",getLocalPlayer())
	end	
	saveTimer=setTimer(start_mydata,600000,1)
end
addEventHandler("onClientResourceStart",getRootElement(),start_mydata)

function reset_start_Timer()
	if(isTimer(saveTimer))then
		killTimer(saveTimer)
		saveTimer=false
	end
end
addEventHandler("onClientResourceStop",getRootElement(),reset_start_Timer)








