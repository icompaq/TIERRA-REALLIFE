addEvent("onKickUserFrameRate",true)

function onKickUserFrameRate_func()
	outputChatBox(string.format("", getPlayerName(source)),getRootElement(),255,0,0)
	kickPlayer(source,"")
end
addEventHandler("onKickUserFrameRate",getRootElement(),onKickUserFrameRate_func)








