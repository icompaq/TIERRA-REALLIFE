munkisten={
{false,false,false,false},
{2503.994140625,-1697.0048828125,12.556974411011,0},
{false,false,false,false},
{false,false,false,false},
{false,false,false,false},
{732.4462890625,-1450.859375,17.1953125,0},
{false,false,false,false},
{false,false,false,false},
{false,false,false,false},
{false,false,false,false},
{2025.013671875,1896.83984375,11.753378868103,0},
{2788.0625,2261.7734375,10.3203125,0},
{2378.23828125,1041.6494140625,10.3203125,87.543151855469}
}

munkistenFrak={false,false,false,false,false,false,false,false,false,false,false,false,false}

	




function onCreateMunEntnahme()
	local kiste=false
	local kisteb=false
	for theKey,theCords in pairs(munkisten)do
		if(munkisten[theKey][1]~=false)then
			kiste=createObject(1271,munkisten[theKey][1],munkisten[theKey][2],munkisten[theKey][3])
			kisteb=createObject(2041,munkisten[theKey][1],munkisten[theKey][2],munkisten[theKey][3]+0.5)
			setElementInterior(kiste,munkisten[theKey][4])
			setElementInterior(kisteb,munkisten[theKey][4])
			munkistenFrak[theKey]=kiste
			addEventHandler("onElementClicked",kiste,clickonMunKiste)
			
			--outputDebugString("loaded MunKiste: "..tostring(theKey).." "..munkisten[theKey][1].." "..munkisten[theKey][2].." "..munkisten[theKey][3].." "..munkisten[theKey][4])
		end	
	end


end
addEventHandler("onResourceStart",getRootElement(),onCreateMunEntnahme)

function checkMunKistenDistance(thePlayer)
	local frak= vioGetElementData(thePlayer,"fraktion")
	local x,y,z=getElementPosition(thePlayer)
	dis=getDistanceBetweenPoints3D(x,y,z,munkisten[frak][1],munkisten[frak][2],munkisten[frak][3])
	if(dis<10)then
		return true
	else
		outputChatBox("Du bist nicht bei der Waffenkiste!",thePlayer,255,0,0)
		return false
	end
end

addEvent("GetMunOutOfFrakMun",true)
function GetMunOutOfFrakMun_func(howMany,weapon)
	if(checkMunKistenDistance(source))then
		local fraktion=vioGetElementData(source,"fraktion")
		if(howMany>frakmun[fraktion])then
			showError(source,"Es liegt nicht soviel Munition im Depot!")	
		else
			if(howMany<0)then howMany=-howMany end
			giveWeapon ( source, weapon, howMany)
			frakdepot_log(fraktion,3,-howMany,getPlayerName(source))
			showError(source,string.format("Du hast erfolgreich %s Patronen fuer deine %s aus dem Depot entnommen!", howMany, getWeaponNameFromID(weapon)))
			frakmun[fraktion]=frakmun[fraktion]-howMany
			triggerClientEvent(source,"aktualizeMunDepotGUI",source,frakmun[fraktion])
		end
	end
	
end
addEventHandler("GetMunOutOfFrakMun",getRootElement(),GetMunOutOfFrakMun_func)

attackerFraktionOfDepot=0
defenderFraktionOfDepot=0
wasAttackInLastFiveHoursOfDepot=false
isAttackofDepot=false
attackOfDepotTimer=false

function clickonMunKiste(mouseButton,buttonState, playerWhoClicked)
	if(buttonState=="down")then
		local fraktion=vioGetElementData(playerWhoClicked,"fraktion")
		if(munkistenFrak[fraktion]==source)then
			local mun=frakmun[fraktion]
			if(mun==0)then
                showError(playerWhoClicked,"Im Depot befindet sich keine Munition!")
			else
				triggerClientEvent(playerWhoClicked,"showMunTruckEntnahmeGUI",playerWhoClicked,mun)
			end	
		else 
			if(munkistenFrak[fraktion])then
				
					if(not(wasAttackInLastFiveHoursOfDepot))then
						local beginAttackAT=0
						for theKey,theKiste in ipairs(munkistenFrak)do
							if(theKiste==source)then
								beginAttackAT=theKey
							end
						end
						local playerOnlineOfDefender=0
						for theKey,thePlayer in ipairs(getPlayersInTeam(team[beginAttackAT]))do
							playerOnlineOfDefender=playerOnlineOfDefender+1
						end
						local x,y,z=getElementPosition(playerWhoClicked)
						if(getDistanceBetweenPoints3D(x,y,z,munkisten[beginAttackAT][1],munkisten[beginAttackAT][2],munkisten[beginAttackAT][3]))then
							if(playerOnlineOfDefender>1)then
								wasAttackInLastFiveHoursOfDepot=true
								isAttackofDepot=true
								attackerFraktionOfDepot=fraktion
								defenderFraktionOfDepot=beginAttackAT
								for theKey,thePlayers in ipairs(getPlayersInTeam(team[beginAttackAT]))do
									outputChatBox("Das Fraktionsdepot wird angegriffen!",thePlayers,255,0,0)
								end
								for theKey,thePlayers in ipairs(getPlayersInTeam(team[fraktion]))do
									outputChatBox("Ihr habt ein Angriff auf ein Fraktionsdepot gestartet! Haltet 15 Minuten an der Kiste aus um das Sicherheitssystem zu knacken!",thePlayers,255,0,0)
								end
								attackOfDepotTimer=setTimer(winAttackOfDepot,900000,1)
								setTimer(resetAttackingOfDepot,18000000,1)
							
							else
								outputChatBox("Es sind nicht genügend Spieler Online von der Fraktion die du angreifen möchtest!",playerWhoClicked,255,0,0)
							end	
						end
					else
						outputChatBox("Es wurde bereits ein Depot innerhalb der letzten 5 Stunden überfallen!",playerWhoClicked,255,0,0)
					end
				end

		end
	end
end


function winAttackOfDepot()
	local peopleInNearOfDepot=0
	local kx,ky,kz=getElementPosition(munkistenFrak[defenderFraktionOfDepot])
	for theKey,thePlayers in ipairs(getPlayersInTeam(team[attackerFraktionOfDepot]))do
		local px,py,pz=getElementPosition(thePlayers)
		local dis=getDistanceBetweenPoints3D(px,py,pz,kx,ky,kz)
		if(dis<20)then
			peopleInNearOfDepot=peopleInNearOfDepot+1
		end
	end
	if(peopleInNearOfDepot>0)then
		local erbeutung=math.random(5,15)
		local zerstoerung=math.random(1,7)
		local ermon=math.round(frakkasse[defenderFraktionOfDepot]/100*erbeutung)
		local erdro=math.round(frakdrogen[defenderFraktionOfDepot]/100*erbeutung)
		local ermun=math.round(frakmun[defenderFraktionOfDepot]/100*erbeutung)
		
		local zermon=math.round(frakkasse[defenderFraktionOfDepot]/100*zerstoerung)
		local zerdro=math.round(frakdrogen[defenderFraktionOfDepot]/100*zerstoerung)
		local zermun=math.round(frakmun[defenderFraktionOfDepot]/100*zerstoerung)
		
		frakkasse[attackerFraktionOfDepot]=frakkasse[attackerFraktionOfDepot]+ermon
		frakdrogen[attackerFraktionOfDepot]=frakdrogen[attackerFraktionOfDepot]+erdro

		frakmun[attackerFraktionOfDepot]=frakmun[attackerFraktionOfDepot]+ermun
		frakdepot_log(attackerFraktionOfDepot,1,ermon,"Kistenangriff")	
		frakdepot_log(attackerFraktionOfDepot,2,erdro,"Kistenangriff")	
		frakdepot_log(attackerFraktionOfDepot,3,ermun,"Kistenangriff")	
		
		
		frakkasse[defenderFraktionOfDepot]=frakkasse[defenderFraktionOfDepot]-ermon-zermon
		frakdrogen[defenderFraktionOfDepot]=frakdrogen[defenderFraktionOfDepot]-erdro-zerdro
		frakmun[defenderFraktionOfDepot]=frakmun[defenderFraktionOfDepot]-ermun-zermun		
		frakdepot_log(defenderFraktionOfDepot,1,(-ermon-zermon),"Kistenangriff")	
		frakdepot_log(defenderFraktionOfDepot,2,(-erdro-zerdro),"Kistenangriff")	
		frakdepot_log(defenderFraktionOfDepot,3,(-ermun-zermun),"Kistenangriff")			
		
		
		for theKey,thePlayers in ipairs(getPlayersInTeam(team[attackerFraktionOfDepot]))do
			outputChatBox(string.format("Der Angriff war erfolgreich! Ihr habt %s, %sg Drogen und %s Munition erbeutet!", toprice(ermon), erdro, ermun),thePlayers,255,0,0)
		end	
		for theKey,thePlayers in ipairs(getPlayersInTeam(team[defenderFraktionOfDepot]))do
			outputChatBox(string.format("Ihr konntet das Depot nicht verteidigen! Die Gegner haben %s, %sg Drogen und %s Munition erbeutet!", toprice(ermon), erdro, ermun),thePlayers,255,0,0)
			outputChatBox(string.format("Leider wurden weitere %s, %sg Drogen und %s Munition zerstört", toprice(zermon), zerdro, zermun),thePlayers,255,0,0)
		end	
		attackerFraktionOfDepot=0
		defenderFraktionOfDepot=0
		isAttackofDepot=false
		attackOfDepotTimer=false
	
	else		
		for theKey,thePlayers in ipairs(getPlayersInTeam(team[attackerFraktionOfDepot]))do
			outputChatBox("Ihr konntet leider nicht an der Kiste bleiben! Der Angriff ist fehlgeschlagen!",thePlayers,255,0,0)
		end	
		for theKey,thePlayers in ipairs(getPlayersInTeam(team[defenderFraktionOfDepot]))do
			outputChatBox("Ihr habt den Angriff erfolgreich abgewehrt!",thePlayers,255,0,0)
		end			
		attackerFraktionOfDepot=0
		defenderFraktionOfDepot=0
		isAttackofDepot=false
		attackOfDepotTimer=false
	end
end

function resetAttackingOfDepot()
	attackerFraktionOfDepot=0
	defenderFraktionOfDepot=0
	wasAttackInLastFiveHoursOfDepot=false
	isAttackofDepot=false
	attackOfDepotTimer=false

end


function checkDeathOfDepot()
	if(isAttackofDepot)then
		if(vioGetElementData(source,"fraktion")==attackerFraktionOfDepot)then
			local peopleInNearOfDepot=0
			local kx,ky,kz=getElementPosition(munkistenFrak[defenderFraktionOfDepot])
			for theKey,thePlayers in ipairs(getPlayersInTeam(team[attackerFraktionOfDepot]))do
				local px,py,pz=getElementPosition(thePlayers)
				local dis=getDistanceBetweenPoints3D(px,py,pz,kx,ky,kz)
				if(dis<10)and not(isPedDead ( thePlayers ))then
					peopleInNearOfDepot=peopleInNearOfDepot+1
				end
			end
			if(peopleInNearOfDepot==0)then
				for theKey,thePlayers in ipairs(getPlayersInTeam(team[attackerFraktionOfDepot]))do
					outputChatBox("Ihr konntet leider nicht an der Kiste bleiben! Der Angriff ist fehlgeschlagen!",thePlayers,255,0,0)
				end	
				for theKey,thePlayers in ipairs(getPlayersInTeam(team[defenderFraktionOfDepot]))do
					outputChatBox("Ihr habt den Angriff erfolgreich abgewehrt!",thePlayers,255,0,0)
				end			
				attackerFraktionOfDepot=0
				defenderFraktionOfDepot=0
				isAttackofDepot=false
				killTimer(attackOfDepotTimer)
				attackOfDepotTimer=false
			end
		end
	
	end
end
addEventHandler("onPlayerWasted",getRootElement(),checkDeathOfDepot)













