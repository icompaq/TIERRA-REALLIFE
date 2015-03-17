--
-- Created by IntelliJ IDEA.
-- User: accow
-- Date: 24.04.2014
-- Time: 16:05
-- To change this template use File | Settings | File Templates.
--

haeuser={}
iraeume={}



-- Das nächstmögliche Haus suchen
function getNearestHouseByPlayer(thePlayer)
    local px,py,pz= getElementPosition(thePlayer)
    local hID, dis=getNearestHouseByCoords(px,py,pz)
    return hID,dis
end

function getNearestHouseByCoords(x,y,z)
    local nearestHouse=0
    local nearestHouseDis=6000
    for theKey,theHouse in pairs(haeuser)do
        local newDis=theHouse:getDistance(x,y,z)
        if(newDis<nearestHouseDis)then
            nearestHouse=theKey
            nearestHouseDis=newDis
        end
    end
    return nearestHouse,nearestHouseDis
end


-- Häuser Laden
function haussys_startup()
    local query="Select * From haussys_hdb"
    local result=mysql_query(handler,query)
    local zahler=0
    if(not result) then
        outputDebugString("Error executing the query: (" .. mysql_errno(handler) .. ") " .. mysql_error(handler))
    else
        zahler=0
        while (mysql_num_rows(result)>zahler) do
            local dasatz = mysql_fetch_assoc(result)

             haeuser[tonumber(dasatz["ID"])]=new(Haus,
                                                    dasatz["ID"],
                                                    dasatz["CoordX"],
                                                    dasatz["CoordY"],
                                                    dasatz["CoordZ"],
                                                    dasatz["IRID"],
                                                    dasatz["Preis"],
                                                    dasatz["Miete"],
                                                    dasatz["Kasse"],
                                                    dasatz["city"],
                                                    dasatz["QM"],
                                                    dasatz["Stockwerke"],
                                                    dasatz["Wert"])


            zahler=zahler+1
        end

        outputDebugString("# "..zahler.." Houses loaded!")
        mysql_free_result(result)
    end

    local query="Select * From haussys_irdb"
    local result=mysql_query(handler,query)
    if(not result) then
        outputDebugString("Error executing the query: (" .. mysql_errno(handler) .. ") " .. mysql_error(handler))
    else
        local zahler=0
        local dasatz={}
        while (mysql_num_rows(result)>zahler) do
            dasatz = mysql_fetch_assoc(result)

            iraeume[tonumber(dasatz["ID"])]=new(IRaum,
                                        dasatz["ID"],
                                        dasatz["CoordX"],
                                        dasatz["CoordY"],
                                        dasatz["CoordZ"],
                                        dasatz["Interior"],
                                        dasatz["Preis"],
                                        dasatz["QM"],
                                        dasatz["Stockwerke"],
                                        dasatz["Wert"])

            zahler=zahler+1
        end
        outputDebugString("# "..zahler.." Interior-Rooms loaded!")
        mysql_free_result(result)
    end
end
addEventHandler("onResourceStart",getRootElement(),haussys_startup)


--[[Adminbefehle zum Häusersystem]]
function haussys_addNewIR_func(thePlayer,cmd,Preis,QM,Stockwerke,Wert,...)
    if(isAdminLevel(thePlayer,4))then
        if(Preis and QM and Stockwerke and Wert)then
            local x,y,z=getElementPosition(thePlayer)
            local int=getElementInterior(thePlayer)
            local comment=""..table.concat({...}," ")

            local query="INSERT INTO haussys_irdb (CoordX,CoordY,CoordZ,Interior,Preis,QM,Stockwerke,Wert,Beschreibung) VALUES ('%s','%s','%s','%s','%s','%s','%s','%s','%s')"
            query=string.format(query,x,y,z,int,Preis,QM,Stockwerke,Wert,comment)


            mysql_query(handler,query)
            local id=mysql_insert_id(handler)
            iraeume[id]=new(IRaum,id,x,y,z,int,Preis,QM,Stockwerke,Wert)

            showError(thePlayer,"Innenraum wurde hinzugefügt.")

        else
            outputChatBox("Befehlssyntax: /addir Preis QM Stockwerke Wert Kommentar",thePlayer)
            outputChatBox("QM: geschätzte Zahl für Mögliche Innenraumgröße (Quadratmeter der Grundfläche)",thePlayer)
            outputChatBox("Wert: 0=>Arm 1=>Mittel 2=>Luxus",thePlayer)
        end
    end
end
addCommandHandler("addir",haussys_addNewIR_func,false,false)

function haussys_addNewHouse_func(thePlayer,cmd,Preis,city,QM,Stockwerke,Wert,...)
    if(isAdminLevel(thePlayer,4))then
        if(Preis and city and QM and Stockwerke and Wert)then
            local x,y,z=getElementPosition(thePlayer)
            local comment=""..table.concat({...}," ")

            local query="INSERT INTO haussys_hdb (CoordX,CoordY,CoordZ,Preis,city,QM,Stockwerke,Wert,Beschreibung) VALUES ('%s','%s','%s','%s','%s','%s','%s','%s','%s')"
            query=string.format(query,x,y,z,Preis,city,QM,Stockwerke,Wert,comment)

            mysql_query(handler,query)
            local id=mysql_insert_id(handler)

            haeuser[id]=new(Haus,id,x,y,z,0,Preis,0,0,city,QM,Stockwerke,Wert)
            showError(thePlayer,"Haus wurde hinzugefügt.")

        else
            outputChatBox("Befehlssyntax: /addhouse Preis city QM Stockwerke Wert Kommentar",thePlayer)
            outputChatBox("city: 0=>LS; 1=>LV; 2=>sonstiges; 3=>nicht handelbar",thePlayer)
            outputChatBox("QM: geschätzte Zahl für Mögliche Innenraumgröße (Quadratmeter der Grundfläche)",thePlayer)
            outputChatBox("Wert: 0=>Arm 1=>Mittel 2=>Luxus",thePlayer)
        end
    end
end
addCommandHandler("addhouse",haussys_addNewHouse_func,false,false)

function haussys_deleteHouse_func(thePlayer)
    if(isAdminLevel(thePlayer,4))then
        local hausid, dis=getNearestHouseByPlayer(thePlayer)
        local haus=haeuser[hausid]
        if(dis<10)then
            delete(haus)
            haeuser[hausid]=false
            haeuser[hausid]=nil
            showError(thePlayer,"Haus gelöscht.")
        end
    end
end
addCommandHandler("delhouse",haussys_deleteHouse_func,false,false)


function haussys_deleteHouse_func(thePlayer)
    if(isAdminLevel(thePlayer,4))then
        local hausid, dis=getNearestHouseByPlayer(thePlayer)
        local haus=haeuser[hausid]
        if(dis<10)then
            if(haus:getBesitzer())then
                local besitzerName=haus:getBesitzer()
                if(getPlayerFromName(besitzerName))then
                    vioSetElementData(getPlayerFromName(besitzerName,"hkey",0))
                else
                    local query="UPDATE userdata SET newhkey='0' WHERE Nickname='"..besitzerName.."'"
                    mysql_query(handler,query)
                end
                haus:setBesitzer(false)
                showError(thePlayer,"Haus entzogen.")
            end
        end
    end
end
addCommandHandler("takehouse",haussys_deleteHouse_func,false,false)

function haussys_gotoh(thePlayer, cmd, id)
    if(isAdminLevel(thePlayer,4))then
        if(id)then
            if(tonumber(id))then
                if(haeuser[tonumber(id)])then
                    local haus=haeuser[tonumber(id)]
                    haus:setPlayerOut(thePlayer)
                end
            end
        end
    end
end
addCommandHandler("gotoh",haussys_gotoh,false,false)

function haussys_ir(thePlayer, cmd, id)
    if(isAdminLevel(thePlayer,4))then
        if(id)then
            if(tonumber(id))then
                if(iraeume[tonumber(id)])then
                    local iraum=iraeume[tonumber(id)]
                    local x,y,z,int=iraum:getSpawnCoords()
                    setElementInterior(thePlayer,int)
                    setElementPosition(thePlayer,x,y,z)
                end
            end
        end
    end
end
addCommandHandler("ir",haussys_ir,false,false)


function isPlayerInAnyHouse(thePlayer)
    local dim=getElementDimension(thePlayer)
    if(dim>0)then
        if(haeuser[dim])then
            local haus=haeuser[dim]
            if(haus.isPlayerInHouse(thePlayer,100))then
                return true
            end
        end
    end
    return false
end











