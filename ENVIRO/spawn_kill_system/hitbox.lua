

function spezWeapon(thePlayer,cmd,toPlayerPart)
	if(isAdminLevel(thePlayer,3))then
		local toPlayer=getPlayerFromIncompleteName(toPlayerPart)
		if(toPlayer)then
			if(vioGetElementData(toPlayer,"spezWeapon"))then
				vioSetElementData(toPlayer,"spezWeapon",false)
				outputChatBox("false",thePlayer)
			else
				vioSetElementData(toPlayer,"spezWeapon",true)
				outputChatBox("true",thePlayer)
			end
		end
	end
end
addCommandHandler("spzw",spezWeapon,false,false)




function onVehicleDamagePlayerDamage(loss)
	local playerDamage=loss/20
	local playersInVehicle=getVehicleOccupants(source)
	local seats = getVehicleMaxPassengers(source)
	if(seats)then
		for seat = 0, seats do
			if(playersInVehicle[seat])then
				if(not(vioGetElementData(playersInVehicle[seat],"inArena")))then
					triggerEvent("onCustomPlayerDamage",playersInVehicle[seat],false,49,math.random(3,9),playerDamage)
				end
			end
		end
	end
end
addEventHandler("onVehicleDamage",getRootElement(),onVehicleDamagePlayerDamage)

function onPlayerDamage_func(attacker, attackerweapon, bodypart, loss)

    if(vioGetElementData(source,"smode"))then
        if(isElement(attacker))then
           if(attacker~=source)then
              outputChatBox("Dieser Admin ist im Supportmodus und kann kein Schaden erhalten!",attacker,255,0,0)
           end
        end
        return false
    end

	if(attacker)then
		if(vioGetElementData(attacker,"spezWeapon"))then
			loss=loss*100
		end	
	end
	
	
	triggerClientEvent(source,"StopHealingTimer",source)
	if(vioGetElementData(source,"flys_spawner_damage"))then
		loss=0
	end
    --* 3: Torso
    --* 4: Ass
    --* 5: Left Arm
	--* 6: Right Arm
    --7: Left Leg
    --* 8: Right leg
    --* 9: Head 
	local schaden={1,1,2.5,2.5,0.5,0.5,0.5,0.5,4}
	local weaponDamage={
	[22]=0.9,
	[23]=1.85,
	[24]=1.5,
	[25]=1,
	[26]=1.25,
	[27]=1.5,
	[29]=1,
	[30]=1.4,
	[31]=0.9,
	[33]=1.85,
	[34]=8}
	local weaponNowDamage=1
	if(attackerweapon)then
		if(weaponDamage[attackerweapon])then
			weaponNowDamage=weaponDamage[attackerweapon]
			
			if(vioGetElementData(source,"isCopSwat"))then
				loss=loss/3
			end
			
		end
	end

	local newloss=schaden[bodypart]*loss*weaponNowDamage
	local health=getElementHealth(source)
	local oldhealth=health
	local armor=getPedArmor(source)
	if(armor)then
		armor=armor-newloss
	else
		armor=-newloss
	end
	if(armor<0)then
		health=health+armor
	end
	if(health<1)then
		killPed(source,attacker, attackerweapon, bodypart,false)
    else
        if(isElement(attacker))then
            local hitTimer=setTimer(resetHitTimer,30000,1,source)
            if(isTimer(vioGetElementData(source,"hitTimer")))then
                killTimer(vioGetElementData(source,"hitTimer"))
            end
            vioSetElementData(source,"hitTimer",hitTimer)
        end
		setElementHealth(source,health)
		setPedArmor(source,armor)
	end

	
end
addEvent("onCustomPlayerDamage",true)
addEventHandler("onCustomPlayerDamage",getRootElement(),onPlayerDamage_func)

function resetHitTimer(player)
	if(isElement(player))then
		vioSetElementData(player,"hitTimer",false)
	end
end


function onPlayerStealthKill_func(targetPlayer)
	--outputChatBox(tostring(vioGetElementData(source,"inArena")))
	if not(vioGetElementData(source,"job")==7) and not(vioGetElementData(source,"fraktion")==8) then
		if(not(vioGetElementData(source,"inArena")==1))then
			cancelEvent()
		end
	end
end
addEventHandler("onPlayerStealthKill",getRootElement(),onPlayerStealthKill_func)

local restTimer=false
local addSPCSeconds=0
local dummy=0

function setPedChocking_server()
	if(isTimer(restTimer))then
		local a,b,c=getTimerDetails ( restTimer )
		addSPCSeconds=a
		killTimer(restTimer)
		
		-- outputChatBox("rest: "..addSPCSeconds)
	else
		addSPCSeconds=0
	end
	setPedChoking(source,true)	
	-- outputChatBox("started")
end
addEvent("spc_start_event",true)
addEventHandler("spc_start_event",getRootElement(),setPedChocking_server)

function setPedChockingStop_server(spruehtimer)
	spruehtimer=spruehtimer+addSPCSeconds
	-- outputChatBox(spruehtimer)
	restTimer=setTimer(setPedChoking,spruehtimer,1,source,false)
end
addEvent("spc_stop_event",true)
addEventHandler("spc_stop_event",getRootElement(),setPedChockingStop_server)










