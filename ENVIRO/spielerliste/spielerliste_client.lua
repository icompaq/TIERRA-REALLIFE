
GUISpielerlisteWindow = {}
GUISpielerlisteGrid = {}
GUISpielerClomus={}
GUISpielerLabel={}


function createSpielerliste()

local screenW, screenH = guiGetScreenSize()
GUISpielerlisteWindow[1] = guiCreateWindow((screenW - 691) / 2, (screenH - 480) / 2, 691, 480, "SpielerListe", false)
guiWindowSetSizable(GUISpielerlisteWindow[1], false)
table.insert(allGuis,GUISpielerlisteWindow[1])

GUISpielerlisteGrid[1] = guiCreateGridList(15, 32, 660, 382,false,GUISpielerlisteWindow[1])
guiGridListSetSelectionMode(GUISpielerlisteGrid[1],0)

GUISpielerClomus[1]=guiGridListAddColumn(GUISpielerlisteGrid[1],"ID",0.15)
GUISpielerClomus[2]=guiGridListAddColumn(GUISpielerlisteGrid[1],"SpielerName",0.45)
GUISpielerClomus[3]=guiGridListAddColumn(GUISpielerlisteGrid[1],"Ping",0.15)
GUISpielerClomus[4]=guiGridListAddColumn(GUISpielerlisteGrid[1],"SpielZeit in h|min",0.15)

GUISpielerLabel[1] = guiCreateLabel(29, 451, 32, 17, "Polizei", false, GUISpielerlisteWindow[1])
guiLabelSetColor(GUISpielerLabel[1], 0,250,250)--

GUISpielerLabel[2] = guiCreateLabel(71, 451, 15, 17, "-", false, GUISpielerlisteWindow[1])
guiLabelSetHorizontalAlign(GUISpielerLabel[2], "center", false)
GUISpielerLabel[3] = guiCreateLabel(24, 425, 132, 20, "LEGENDE:", false, GUISpielerlisteWindow[1])
guiSetFont(GUISpielerLabel[3], "clear-normal")
--guiLabelSetColor(GUISpielerLabel[3], 90, 0, 255)

GUISpielerLabel[4] = guiCreateLabel(99, 451, 30, 17, "News", false, GUISpielerlisteWindow[1])
guiLabelSetColor(GUISpielerLabel[4],  200,100,0)--

GUISpielerLabel[5] = guiCreateLabel(139, 451, 15, 17, "-", false, GUISpielerlisteWindow[1])
guiLabelSetHorizontalAlign(GUISpielerLabel[5], "center", false)
GUISpielerLabel[6] = guiCreateLabel(166, 451, 22, 17, "Taxi", false, GUISpielerlisteWindow[1])
guiLabelSetColor(GUISpielerLabel[6], 255,255,0)--

GUISpielerLabel[7] = guiCreateLabel(198, 451, 15, 17, "-", false, GUISpielerlisteWindow[1])
guiLabelSetHorizontalAlign(GUISpielerLabel[7], "center", false)
GUISpielerLabel[8] = guiCreateLabel(223, 451, 36, 17, "Medics", false, GUISpielerlisteWindow[1])
guiLabelSetColor(GUISpielerLabel[8], 230,0,0)--

GUISpielerLabel[9] = guiCreateLabel(269, 451, 15, 17, "-", false, GUISpielerlisteWindow[1])
guiLabelSetHorizontalAlign(GUISpielerLabel[9], "center", false)
GUISpielerLabel[10] = guiCreateLabel(294, 451, 107, 17, "sonstige Fraktionen", false, GUISpielerlisteWindow[1])
guiLabelSetColor(GUISpielerLabel[10], 200,140,140)--

GUISpielerLabel[11] = guiCreateLabel(411, 451, 15, 17, "-", false, GUISpielerlisteWindow[1])
guiLabelSetHorizontalAlign(GUISpielerLabel[11], "center", false)
GUISpielerLabel[12] = guiCreateLabel(436, 451, 46, 17, "Zivilisten", false, GUISpielerlisteWindow[1])
GUISpielerLabel[13] = guiCreateLabel(492, 451, 15, 17, "-", false, GUISpielerlisteWindow[1])
guiLabelSetHorizontalAlign(GUISpielerLabel[13], "center", false)
GUISpielerLabel[14] = guiCreateLabel(517, 451, 84, 17, "eigene Fraktion", false, GUISpielerlisteWindow[1])   
guiLabelSetColor(GUISpielerLabel[14], 0,255,0) --




guiSetVisible(GUISpielerlisteWindow[1],false)

  bindKey ( "tab", "down", function() showSpielerliste() end) 
  bindKey ( "tab", "up", function() hideSpielerliste() end) 

end
addEventHandler("onClientResourceStart",getRootElement(),createSpielerliste)

function showSpielerliste()
	local row
	local players = getElementsByType ( "player" ) -- get a table of all the players in the server
	local howmany=0
	
	for theKey,thePlayer in ipairs(players) do -- use a generic for loop to step through each player
		row=guiGridListAddRow(GUISpielerlisteGrid[1])
		howmany=howmany+1
		guiGridListSetItemText ( GUISpielerlisteGrid[1], row, GUISpielerClomus[1], tostring(theKey), false, true )
		guiGridListSetItemText ( GUISpielerlisteGrid[1], row, GUISpielerClomus[2], getPlayerName(thePlayer), false, true )
		guiGridListSetItemText ( GUISpielerlisteGrid[1], row, GUISpielerClomus[3], tostring(getPlayerPing(thePlayer)), false, true )
		if(isPlayerLoggedIn(thePlayer))then
			if(tonumber(getElementData(thePlayer,"afk_status"))==0)then
				--outputChatBox(getPlayerName(thePlayer).." "..math.round(tonumber(getElementData(thePlayer,"playtime"))/60,2,"floor"))
				--tostring(math.round((math.round(tonumber(getElementData(thePlayer,"playtime"))/60,2)-math.round(tonumber(getElementData(thePlayer,"playtime"))/60,0,"floor"))*60)
				guiGridListSetItemText ( GUISpielerlisteGrid[1], row, GUISpielerClomus[4], tostring( math.round(tonumber(getElementData(thePlayer,"playtime"))/60,0,"floor")).."|"..tostring(math.round((math.round(tonumber(getElementData(thePlayer,"playtime"))/60,2)-math.round(tonumber(getElementData(thePlayer,"playtime"))/60,0,"floor"))*60)), false, true )
			else
				guiGridListSetItemText ( GUISpielerlisteGrid[1], row, GUISpielerClomus[4], "AFK",false,true)
			end
			if(tonumber(getElementData(thePlayer,"fraktion"))==tonumber(getElementData(getLocalPlayer(),"fraktion"))) and tonumber(getElementData(getLocalPlayer(),"fraktion"))~=0 then
				guiGridListSetItemColor ( GUISpielerlisteGrid[1], row, GUISpielerClomus[1], 0,255,0,255 )
				guiGridListSetItemColor ( GUISpielerlisteGrid[1], row, GUISpielerClomus[2], 0,255,0,255  )
				guiGridListSetItemColor ( GUISpielerlisteGrid[1], row, GUISpielerClomus[3], 0,255,0,255  )
				guiGridListSetItemColor ( GUISpielerlisteGrid[1], row, GUISpielerClomus[4], 0,255,0,255  )				
			elseif(tonumber(getElementData(thePlayer,"fraktion"))==4)then
				guiGridListSetItemColor ( GUISpielerlisteGrid[1], row, GUISpielerClomus[1], 255,255,0,255 )
				guiGridListSetItemColor ( GUISpielerlisteGrid[1], row, GUISpielerClomus[2], 255,255,0,255 )
				guiGridListSetItemColor ( GUISpielerlisteGrid[1], row, GUISpielerClomus[3], 255,255,0,255 )
				guiGridListSetItemColor ( GUISpielerlisteGrid[1], row, GUISpielerClomus[4], 255,255,0,255 )
			elseif(tonumber(getElementData(thePlayer,"fraktion"))==3)then
				guiGridListSetItemColor ( GUISpielerlisteGrid[1], row, GUISpielerClomus[1], 200,100,0,255 )
				guiGridListSetItemColor ( GUISpielerlisteGrid[1], row, GUISpielerClomus[2], 200,100,0,255 )
				guiGridListSetItemColor ( GUISpielerlisteGrid[1], row, GUISpielerClomus[3], 200,100,0,255 )
				guiGridListSetItemColor ( GUISpielerlisteGrid[1], row, GUISpielerClomus[4], 200,100,0,255 )			
			elseif(tonumber(getElementData(thePlayer,"fraktion"))==1)or(tonumber(getElementData(thePlayer,"fraktion"))==9)then
				guiGridListSetItemColor ( GUISpielerlisteGrid[1], row, GUISpielerClomus[1], 0,250,250,255 )
				guiGridListSetItemColor ( GUISpielerlisteGrid[1], row, GUISpielerClomus[2], 0,250,250,255 )
				guiGridListSetItemColor ( GUISpielerlisteGrid[1], row, GUISpielerClomus[3], 0,250,250,255 )
				guiGridListSetItemColor ( GUISpielerlisteGrid[1], row, GUISpielerClomus[4], 0,250,250,255 )			
			elseif(tonumber(getElementData(thePlayer,"fraktion"))==10)then
				guiGridListSetItemColor ( GUISpielerlisteGrid[1], row, GUISpielerClomus[1], 230,0,0,255 )
				guiGridListSetItemColor ( GUISpielerlisteGrid[1], row, GUISpielerClomus[2], 230,0,0,255 )
				guiGridListSetItemColor ( GUISpielerlisteGrid[1], row, GUISpielerClomus[3], 230,0,0,255 )
				guiGridListSetItemColor ( GUISpielerlisteGrid[1], row, GUISpielerClomus[4], 230,0,0,255 )							
			
			elseif(tonumber(getElementData(thePlayer,"fraktion"))>0) and not(tonumber(getElementData(thePlayer,"fraktion"))==8)then
				guiGridListSetItemColor ( GUISpielerlisteGrid[1], row, GUISpielerClomus[1], 200,140,140,255 )
				guiGridListSetItemColor ( GUISpielerlisteGrid[1], row, GUISpielerClomus[2], 200,140,140,255 )
				guiGridListSetItemColor ( GUISpielerlisteGrid[1], row, GUISpielerClomus[3], 200,140,140,255 )
				guiGridListSetItemColor ( GUISpielerlisteGrid[1], row, GUISpielerClomus[4], 200,140,140,255 )						
			
			end
		end
	end
	guiSetText ( GUISpielerlisteWindow[1] , string.format("Spielerliste: %s Spieler online", howmany))
	guiSetVisible(GUISpielerlisteWindow[1],true)
	


end



function hideSpielerliste()
	
	guiGridListClear (GUISpielerlisteGrid[1])
	guiSetVisible(GUISpielerlisteWindow[1],false)


end

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end









