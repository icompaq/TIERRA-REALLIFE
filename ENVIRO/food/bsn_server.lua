addEvent("buyFood_B",true)

function buyFood_B_func(menge,types)
    changePlayerMoney(source,-menge,"sonstiges","Essen gekauft")
	
	if(types=="pizza")then
        changeBizKasse(2, menge, "Essenskauf")
	elseif(types=="burger")then
        changeBizKasse(1, menge, "Essenskauf")
	elseif(types=="huhn")then
        changeBizKasse(3, menge, "Essenskauf")
	end
end
addEventHandler("buyFood_B",getRootElement(),buyFood_B_func)


local fastfoodmarker={}
function fastfoodmarker_load()
	local query="SELECT * FROM drivein"
	local result=mysql_query(handler,query)
	local zahler=0
	while (mysql_num_rows(result)>zahler) do
		local dasatz = mysql_fetch_assoc(result)
		local area=createMarker( dasatz["x"],  dasatz["y"],  dasatz["z"] , "cylinder", 4.0, 0, 0, 150, 150,  getRootElement() )
		fastfoodmarker[area]=dasatz["ID"]
		vioSetElementData(area,"typ",dasatz["typ"])
		addEventHandler("onMarkerHit",area,hitDriveInMarker,false)
		zahler=zahler+1
	end
end
addEventHandler("onResourceStart",getRootElement(),fastfoodmarker_load)

function hitDriveInMarker(hitElement)
	if(getElementType(hitElement)=="player")then
		if(isPedInVehicle(hitElement))then
			if(getPlayerMoney(hitElement)<15)then
				outputChatBox("Das DriveInMenü kostet 15$!",hitElement,255,0,0)
			else
                changePlayerMoney(hitElement,-15,"sonstiges","Essen gekauft (Drive In)")
				if(vioGetElementData(source,"typ")=="pizza")then
                    changeBizKasse(2, 15, "Essenskauf")
				elseif(vioGetElementData(source,"typ")=="burger")then
                    changeBizKasse(1, 15, "Essenskauf")
				elseif(vioGetElementData(source,"typ")=="huhn")then
                    changeBizKasse(3, 15, "Essenskauf")
				end
				triggerClientEvent(hitElement,"addFood",hitElement,500)
				outputChatBox("Du benötigst 10s um zu essen!",hitElement,255,0,0)
				local vehicle=getPedOccupiedVehicle(hitElement)
				setElementFrozen(hitElement,true)
				setElementFrozen(vehicle,true)
				vioSetElementData(vehicle,"isInTankProcedur",true)
				vioSetElementData(vehicle,"motor",false)
				setVehicleEngineState ( vehicle, false )
				vioSetElementData(vehicle,"motornum",0)
				setTimer(unfreezeDriveIn,10000,1,hitElement,vehicle)
			end
		end
	end
end

function unfreezeDriveIn(player,vehicle)
	setElementFrozen(player,false)
	setElementFrozen(vehicle,false)
	vioSetElementData(vehicle,"isInTankProcedur",false)	
	outputChatBox("Du hast aufgegessen!",player,255,0,0)
end



function createDriveInMarker(thePlayer,cmd,typ)
	if(isAdminLevel(thePlayer,4))then
		local x,y,z=getElementPosition(thePlayer)
		local query="INSERT INTO drivein (x,y,z,typ) VALUES ('"..x.."','"..y.."','"..(z-1).."','"..typ.."');"
		mysql_query(handler,query)
		local ID=mysql_insert_id(handler)
		local area=createMarker( x,y,z-1 , "cylinder", 4.0, 0, 0, 150, 150,  getRootElement() )
		outputChatBox(string.format("DriveIn ID %s created", ID),thePlayer,255,0,0)
		fastfoodmarker[area]=ID		
		vioSetElementData(area,"typ",typ)
		addEventHandler("onMarkerHit",area,hitDriveInMarker,false)

	end
end
addCommandHandler("adddrivein",createDriveInMarker,false,false)








