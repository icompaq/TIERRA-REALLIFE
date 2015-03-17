local sonderzeichen={" ","ä","ü","ö",",","#","'","+","*","~",":",";","=","}","?","\\","{","&","/","§","\"","!","°","@","|","`","´"}

-- error bei . ^ und $
privVeh={}

function playerConnect (playerNick, playerIP, playerUsername, playerSerial, playerVersionNumber)
    if playerNick == "Player" then
        cancelEvent(true,"Der Nick \"Player\" ist nicht gestattet! Wähle im Settings-Menü einen neuen!")
        return true;
    else

        for theKey,theSonder in ipairs(sonderzeichen) do
            if(string.find(playerNick,theSonder))then
                --outputDebugString(theSonder)
                cancelEvent(true,"Es sind keine Farbcodes und Sonderzeichen gestattet!")
                return true;
            end
        end

        if(utfLen(playerNick)~=string.len(playerNick))then
            --cancelEvent(true,"Dein Nickname beinhaltet nicht erlaubte Sonderzeichen.")
            --return true;
            outputDebugString("UTFLEN: "..tostring(utfLen(playerNick)).." ~= STRINGLEN "..tostring(string.len(playerNick)))
        end

        local testtag=pregReplace ( config["clantag"], "\\[", ""  )
        testtag=pregReplace ( testtag, "\\]", ""  )
        if(string.find(playerNick,testtag))then
            --outputDebugString(theSonder)
            if (MySQL_GetString("players", "Nickname", "Nickname='"..playerNick.."'"))then

            else
                cancelEvent(true,"Das ClanTag "..config["clantag"].." kann nur durch einen Admin vergeben werden!")
                return true;
            end
        elseif(MySQL_DatasetExist("players","Nickname='"..config["clantag"]..playerNick.."'"))then
            cancelEvent(true,"Ein Mitglied des "..config["clantag"].."s trägt bereits diesen Namen!")
            return true;
        end

        if isNumeric(playerNick) then
            cancelEvent(true,"Es muessen Buchstaben enthalten sein!")
            return true;
        end






        local IP=mysql_escape_string(handler,playerIP)
        local uname=mysql_escape_string(handler,playerNick)
        local serial=mysql_escape_string(handler,playerSerial)



        if(MySQL_DatasetExist("ban","IP='"..IP.."'"))then
            local reason=MySQL_GetString("ban", "Grund", "IP='"..IP.."'")
            local datum=MySQL_GetString("ban", "Bandatum", "IP='"..IP.."'")
            local admin=MySQL_GetString("ban", "Admin", "IP='"..IP.."'")
            local banstring=string.format("Du wurdest am %s von Admin %s vom Server gebannt Grund%s weitere Info unter cp.tt-rl.de", datum, admin, reason)
            cancelEvent(true,banstring)
            return true;
        else

            if(MySQL_DatasetExist("ban","Nickname='"..uname.."'"))then
                local reason=MySQL_GetString("ban", "Grund", "Nickname='"..uname.."'")
                local datum=MySQL_GetString("ban", "Bandatum", "Nickname='"..uname.."'")
                local admin=MySQL_GetString("ban", "Admin", "Nickname='"..uname.."'")
                local banstring=string.format("Du wurdest am %s von Admin %s vom Server gebannt Grund%s weitere Info unter cp.tt-rl.de", datum, admin, reason)
                cancelEvent(true,banstring)
                return true;
            else
                if(MySQL_DatasetExist("ban","Serial='"..serial.."'"))then
                    local reason=MySQL_GetString("ban", "Grund", "Serial='"..serial.."'")
                    local datum=MySQL_GetString("ban", "Bandatum", "Serial='"..serial.."'")
                    local admin=MySQL_GetString("ban", "Admin", "Serial='"..serial.."'")
                    local banstring=string.format("Du wurdest am %s von Admin %s vom Server gebannt Grund%s weitere Info unter cp.tt-rl.de", datum, admin, reason)
                    cancelEvent(true,banstring)
                    return true;
                else

                    if(MySQL_DatasetExist("timeban","Nickname='"..uname.."'"))then
                        local reason=MySQL_GetString("timeban","Grund", "Nickname='"..uname.."'")
                        local admin=MySQL_GetString("timeban", "Admin", "Nickname='"..uname.."'")
                        local rest=MySQL_GetVar("timeban", "Minuten", "Nickname='"..uname.."'")
                        local timestring=rest.." Minuten"
                        if(rest>=120)then
                            rest=math.round(rest/60,0)
                            timestring=rest.." Stunden"
                        end
                        local banstring=string.format("Du bist noch %s gebannt! \nvon: %s \nGrund: %s", timestring, admin, reason)
                        cancelEvent(true,banstring)
                        return true;
                    end
                end
            end
        end

        --MultiaccCheck
        if not(MySQL_DatasetExist("players","Nickname='"..uname.."'"))then
            if(MySQL_DatasetExist("players","Serial='"..serial.."'"))then
                if(MySQL_DatasetExist("multiaccount_serial","Serial='"..serial.."'"))then
                    local multiSerialAccounts={}
                    local id=0
                    local result = mysql_query(handler, "SELECT * from multiaccount_serial WHERE Serial='"..serial.."'")
                    while(true) do
                        local dsatz = mysql_fetch_assoc(result)
                        if (not dsatz) then break else
                            id=dsatz["ID"]
                        end
                    end
                    mysql_free_result(result)
                    vioSetElementData(source,"deleteMultiAccErlaubnis",id)

                else
                    local multiSerialAccounts={}
                    local id=0
                    local result = mysql_query(handler, "SELECT * from players WHERE Serial='"..serial.."'")
                    while(true) do
                        local dsatz = mysql_fetch_assoc(result)
                        if (not dsatz) then break else
                            id=dsatz["ID"]
                        end
                    end
                    mysql_free_result(result)
                    --@todo: set Link to Accountshowsystem if wanted (need Controlpanel)
                    cancelEvent(true,string.format("Es wurden bereits Accounts von diesem PC, auf dem Server registriert."))
                    return true;
                end
            end
        end

        if(MySQL_GetVar("players", "force_nickchange", "Nickname='"..uname.."'")==1)then
            cancelEvent(true,"Dein Account ist gesperrt: Dein Nickname entspricht nicht den Richtlinien. Beantrage einen Nickchange auf "..config["maindomain"].." um einen Account wieder freizuschalten.")
            return true;
        end


    end
end

addEventHandler ("onPlayerConnect", getRootElement(), playerConnect)



addEvent("clientisreadyforlogin",true)
function playerreadylogin()

    local uname=mysql_escape_string(handler,getPlayerName ( source ))
    vioSetElementData(source,"logtries",0)
    if(MySQL_DatasetExist("players","Nickname='"..uname.."'"))then
        triggerClientEvent(source,"showLoginGui",source,source)
    else
        triggerClientEvent(source,"showRegisterGui",source,source)

    end

end
addEventHandler ("clientisreadyforlogin" , getRootElement(), playerreadylogin)

function RegisterPlayerData(nickname,pass,email,gebt,gebm,geby,werber)


    local salt=randomstring(25)
    local nickname=mysql_escape_string(handler,nickname)
    local pass=mysql_escape_string(handler,pass)
    local email=mysql_escape_string(handler,email)
    local gebt=mysql_escape_string(handler,gebt)
    local gebm=mysql_escape_string(handler,gebm)
    local geby=mysql_escape_string(handler,geby)
    local werber=mysql_escape_string(handler,werber)

    if(werber~="" and MySQL_DatasetExist("players","Nickname='"..werber.."'")) or werber=="" then

        if not(MySQL_DatasetExist("players","Nickname='"..nickname.."'")) then

            if(config["password_hash"]=="md5")then
                pass=md5(salt..pass)
            elseif(config["password_hash"]=="osha256")then
                pass=sha256(salt..pass)
            elseif(config["password_hash"]=="sha256")then
                pass=hash("sha256",salt..pass)
            else
                pass=hash ("sha512", salt..pass)
            end



            local loquery="INSERT INTO players (UUID,Nickname,Passwort,EMail,Geb_T,Geb_M,Geb_Y,werber,Salt,Serial,IP) VALUES (uuid(),'"..nickname.."','"..pass.."','"..email.."','"..gebt.."','"..gebm.."','"..geby.."','"..werber.."','"..salt.."','"..getPlayerSerial(source).."','"..getPlayerIP(source).."');"
            --save_log( "mysql", loquery)
            local resultre=mysql_query(handler,loquery)
            local lobquery="INSERT INTO userdata (Nickname) VALUES('"..nickname.."');"
            local resultre=mysql_query(handler,lobquery)
            local lobquery="INSERT INTO zeugnis (Nickname) VALUES('"..nickname.."');"
            local resultre=mysql_query(handler,lobquery)
            local lobquery="INSERT INTO lizensen (Nickname) VALUES('"..nickname.."');"
            local resultre=mysql_query(handler,lobquery)
            local lobquery="INSERT INTO jobskills (Nickname) VALUES('"..nickname.."');"
            local resultre=mysql_query(handler,lobquery)
            local lobquery="INSERT INTO inventar (Nickname) VALUES('"..nickname.."');"
            local resultre=mysql_query(handler,lobquery)
            local lobquery="INSERT INTO archievments (Nickname) VALUES('"..nickname.."');"
            local resultre=mysql_query(handler,lobquery)
            local lobquery="INSERT INTO premium (Name) VALUES('"..nickname.."');"
            local resultre=mysql_query(handler,lobquery)
            local lobquery="INSERT INTO terratapps (Nickname) VALUES('"..nickname.."');"
            local resultre=mysql_query(handler,lobquery)
            local lobquery="INSERT INTO rechte (Nickname) VALUES('"..nickname.."');"
            local resultre=mysql_query(handler,lobquery)
            --local timestring=MySQL_GetString("players", "LastLogin", "Nickname='"..nickname.."'")
            local lomquery="UPDATE players SET RegDat=LastUpdate WHERE Nickname='"..nickname.."';"
            local resultre=mysql_query(handler,lomquery)

            showCursor(source,false)
            triggerClientEvent(source,"hideRegisterGui",source)
            showError(source,"Du wurdest erfolgreich registriert! Logge dich nun ein!")

            local uname=mysql_escape_string(handler,getPlayerName ( source ))
            vioSetElementData(source,"logtries",0)
            if(MySQL_DatasetExist("players","Nickname='"..uname.."'"))then
                triggerClientEvent(source,"showLoginGui",source,source)
            else
                triggerClientEvent(source,"showRegisterGui",source,source)

            end
            if(vioGetElementData(source,"deleteMultiAccErlaubnis"))then
                local query="DELETE FROM multiaccount_serial WHERE ID='"..vioGetElementData(source,"deleteMultiAccErlaubnis").."'"
                mysql_query(handler,query)
            end
        else
            showError(source,"Ein ubekannter Fehler ist aufgetretten!")
        end
    else

        showError(source,"Ein Fehler ist aufgetretten. Der angegebene Werber existiert nicht!")
    end



end
addEvent("registerPlayer",true)
addEventHandler("registerPlayer",getRootElement(),RegisterPlayerData)

function resetIsLogged(source)
    if(isElement(source))then
        vioSetElementData(source,"isLoggedInNow",false)
    end
end

function LoginPlayerData(nickname,pw)

    nickname=mysql_escape_string(handler,nickname)
    local passdb=MySQL_GetString("players", "Passwort", "Nickname='"..nickname.."'")
    local saltdb=MySQL_GetString("players", "Salt", "Nickname='"..nickname.."'")
    pw=saltdb..pw
    if(config["password_hash"]=="md5")then
        pass=md5(pw)
    elseif(config["password_hash"]=="osha256")then
        pass=sha256(pw)
    elseif(config["password_hash"]=="sha256")then
        pass=hash("sha256",pw)
    else
        pass=hash ("sha512", pw)
    end

    if(passdb==pass) and not(vioGetElementData(source,"isLoggedInNow"))then
        vioSetElementData(source,"isLoggedInNow",true)
        setTimer(resetIsLogged,5000,1,source)
        triggerClientEvent(source,"bindclicksys_event",source)

        --MySQL_DatasetExist(table,bed)
        if not(MySQL_DatasetExist("userdata","Nickname='"..getPlayerName(source).."'"))then
            local lobquery="INSERT INTO userdata (Nickname) VALUES('"..nickname.."');"
            local resultre=mysql_query(handler,lobquery)
        end

        if not(MySQL_DatasetExist("inventar","Nickname='"..getPlayerName(source).."'"))then
            local lobquery="INSERT INTO inventar (Nickname) VALUES('"..nickname.."');"
            local resultre=mysql_query(handler,lobquery)
        end
        if not(MySQL_DatasetExist("archievments","Nickname='"..getPlayerName(source).."'"))then
            local lobquery="INSERT INTO archievments (Nickname) VALUES('"..nickname.."');"
            local resultre=mysql_query(handler,lobquery)
        end
        if not(MySQL_DatasetExist("premium","Name='"..getPlayerName(source).."'"))then
            local lobquery="INSERT INTO premium (Name) VALUES('"..nickname.."');"
            local resultre=mysql_query(handler,lobquery)
        end
        if not(MySQL_DatasetExist("terratapps","Nickname='"..getPlayerName(source).."'"))then
            local lobquery="INSERT INTO terratapps (Nickname) VALUES('"..nickname.."');"
            local resultre=mysql_query(handler,lobquery)
        end
        if not(MySQL_DatasetExist("rechte","Nickname='"..getPlayerName(source).."'"))then
            local lobquery="INSERT INTO rechte (Nickname) VALUES('"..nickname.."');"
            local resultre=mysql_query(handler,lobquery)
        end

        setPedStat ( source,69,500)--test
        setPedStat ( source,70,999)
        setPedStat ( source,71,999)
        setPedStat ( source,72,999)
        setPedStat ( source,73,999)
        setPedStat ( source,74,999)
        setPedStat ( source,75,999)
        setPedStat ( source,76,999)
        setPedStat ( source,77,999)
        setPedStat ( source,78,999)
        setPedStat ( source,79,999)



        triggerClientEvent(source,"setAtomKatastropheClient",source,atomkatastrophe)

        if(isDevServer())then
            triggerClientEvent(source,"recieveNewDevState",source)
        end

        local ip=getPlayerIP(source)
        local serial=getPlayerSerial(source)
        MySQL_SetVar("players", "Serial" , serial , "Nickname='"..nickname.."'")
        MySQL_SetVar("players", "IP" , ip , "Nickname='"..nickname.."'")
        local acQuery="UPDATE players SET LastLogin=LastUpdate WHERE Nickname='"..nickname.."'"
        mysql_query(handler,acQuery)

        local playersData=mysql.getFirstTableRow(handler,"players","Nickname='"..nickname.."'")
        local userdataData=mysql.getFirstTableRow(handler,"userdata","Nickname='"..nickname.."'")
        local lizensenData=mysql.getFirstTableRow(handler,"lizensen","Nickname='"..nickname.."'")
        local inventarData=mysql.getFirstTableRow(handler,"inventar","Nickname='"..nickname.."'")
        local jobskillsData=mysql.getFirstTableRow(handler,"jobskills","Nickname='"..nickname.."'")
        local archievmentsData=mysql.getFirstTableRow(handler,"archievments","Nickname='"..nickname.."'")
        local zeugnisData=mysql.getFirstTableRow(handler,"zeugnis","Nickname='"..nickname.."'")
        local rechteData=mysql.getFirstTableRow(handler,"rechte","Nickname='"..nickname.."'")

        setPlayerName (source, playersData["Nickname"] )

        --Rechte Data Loading
        vioSetElementData(source,"rechte_AllLeader",tonumber(rechteData["AllLeader"]))

        --playerData Loading--
        vioSetElementData(source,"Geb_T",tonumber(playersData["Geb_T"]))
        vioSetElementData(source,"Geb_M",tonumber(playersData["Geb_M"]))
        vioSetElementData(source,"Geb_Y",tonumber(playersData["Geb_Y"]))
        vioSetElementData(source,"DBID",tonumber(playersData["ID"]))
        vioSetElementData(source,"UniqueID",playersData["UUID"])
        vioSetElementData(source,"isDeveloper",tonumber(playersData["isDeveloper"]))


        --UserData Loading--
        vioSetElementData(source,"adminlvl",tonumber(userdataData["AdminLVL"]))
        vioSetElementData(source,"SupportLVL",tonumber(userdataData["SupportLVL"]))
        vioSetElementData(source,"spawnplace",tonumber(userdataData["Spawn"]))
        vioSetElementData(source,"skinid",tonumber(userdataData["Skin"]))
        vioSetElementData(source,"fraktion",tonumber(userdataData["Fraktion"]))
        vioSetElementData(source,"fraktionsrang",tonumber(userdataData["Fraktionsrang"]))
        vioSetElementData(source,"tode",tonumber(userdataData["Tode"]))
        vioSetElementData(source,"todezeit",tonumber(userdataData["TodZeit"]))
        vioSetElementData(source,"todelast",tonumber(userdataData["TodeLast"]))
        vioSetElementData(source,"playtime",tonumber(userdataData["PlayTime"]))
        vioSetElementData(source,"money",tonumber(userdataData["Geld"]))
        vioSetElementData(source,"bank",tonumber(userdataData["Bank"]))
        vioSetElementData(source,"addPayDayGehalt",tonumber(userdataData["paydaygehalt"]))
        vioSetElementData(source,"PremiumSpawn",tonumber(userdataData["PremiumSpawn"]))
        vioSetElementData(source,"schutzgeld",tonumber(userdataData["schutzgeld"]))
        vioSetElementData(source,"fuehrerscheinlooser",tonumber(userdataData["fuehrerscheinlooser"]))
        vioSetElementData(source,"job",tonumber(userdataData["Job"]))
        vioSetElementData(source,"knastzeit",tonumber(userdataData["Knastzeit"]))
        vioSetElementData(source,"lastknastzeit",tonumber(userdataData["lastKnastzeit"]))
        vioSetElementData(source,"alkaknast",tonumber(userdataData["alkaknast"]))
        vioSetElementData(source,"stvo",tonumber(userdataData["Stvo"]))
        vioSetElementData(source,"wanteds",tonumber(userdataData["Wanteds"]))
        vioSetElementData(source,"kaution",tonumber(userdataData["Kaution"]))
        vioSetElementData(source,"maxslots",tonumber(userdataData["VehSlots"]))
        vioSetElementData(source,"tbans",tonumber(userdataData["tbans"]))
        vioSetElementData(source,"ueberweisungssumme",tonumber(userdataData["ueberweisungssumme"]))
        vioSetElementData(source,"versicherung",tonumber(userdataData["versicherung"]))
        vioSetElementData(source,"lebensversicherung",tonumber(userdataData["lebensversicherung"]))
        vioSetElementData(source,"stvoFreePayDays",tonumber(userdataData["stvoFreePayDays"]))
        vioSetElementData(source,"FrakSkin",tonumber(userdataData["FrakSkin"]))
        vioSetElementData(source,"Hufeisen",tonumber(userdataData["Hufeisen"]))
        vioSetElementData(source,"speedtank",tonumber(userdataData["speedtank"]))
        vioSetElementData(source,"fisheslasthour",tonumber(userdataData["fisheslasthour"]))
        vioSetElementData(source,"hkey",tonumber(userdataData["newhkey"]))
        vioSetElementData(source,"kopfgeld",tonumber(userdataData["kopfgeld"]))
        vioSetElementData(source,"bizKey",tonumber(userdataData["bizKey"]))
        vioSetElementData(source,"prestigeKey",tonumber(userdataData["prestigeKey"]))
        vioSetElementData(source,"ingamespenden",tonumber(userdataData["ingamespenden"]))
        vioSetElementData(source,"tut",tonumber(userdataData["tutorial_gui"]))
        vioSetElementData(source,"mussAlka",tonumber(userdataData["mussAlka"]))

        vioSetElementData(source,"verheiratet",tonumber(userdataData["verheiratet"]))
        if(vioGetElementData(source,"verheiratet")~=0)then
            vioSetElementData(source,"verheiratetMitName",MySQL_GetString("players", "Nickname","ID='"..vioGetElementData(source,"verheiratet").."'"))
            if(vioGetElementData(source,"verheiratetMitName")==false)then
                vioSetElementData(source,"verheiratet",0)
                vioSetElementData(source,"verheiratetMitName","niemand")
            end
        end

        local telenummer=tonumber(userdataData["Telefonnummer"])
        if(telenummer==0)then
            local g=0
            while (g==0) do
                telenummer=math.random(100000,999999)
                if not(MySQL_DatasetExist("userdata","Telefonnummer='"..telenummer.."'"))then
                    g=telenummer
                end
            end
        end
        vioSetElementData(source,"telefon",telenummer)

        --inventar
        vioSetElementData(source,"drogen",tonumber(inventarData["Drogen"]))
        vioSetElementData(source,"tachodig_addon",tonumber(inventarData["tachodig_addon"]))
        vioSetElementData(source,"adgutscheine",tonumber(inventarData["adgutscheine"]))
        vioSetElementData(source,"adaktiv",tonumber(inventarData["adaktiv"]))
        vioSetElementData(source,"mats",tonumber(inventarData["Materials"]))
        vioSetElementData(source,"kanister",tonumber(inventarData["Benzinkanister"]))
        vioSetElementData(source,"lottoschein",tonumber(inventarData["Lottoschein"]))
        vioSetElementData(source,"rubbellos",tonumber(inventarData["Rubbellos"]))
        vioSetElementData(source,"lotto",inventarData["Lotto"])
        vioSetElementData(source,"snack",tonumber(inventarData["Snack"]))
        vioSetElementData(source,"hamburger",tonumber(inventarData["Hamburger"]))
        vioSetElementData(source,"terralapptapp",tonumber(inventarData["terralapptapp"]))
        vioSetElementData(source,"fertigessen",tonumber(inventarData["Fertigessen"]))
        vioSetElementData(source,"schnellhilfe",tonumber(inventarData["Schnellhilfe"]))
        vioSetElementData(source,"carfinder",tonumber(inventarData["CarFinder"]))
        vioSetElementData(source,"usecarfinder",tonumber(inventarData["UseCarFinder"]))
        vioSetElementData(source,"Hufeisenhelfer",tonumber(inventarData["Hufeisenhelfer"]))
        vioSetElementData(source,"geschenk",tonumber(inventarData["geschenk"]))
        vioSetElementData(source,"dice",tonumber(inventarData["dice"]))
        vioSetElementData(source,"Kondome",tonumber(inventarData["Kondome"]))
        vioSetElementData(source,"blutmesser",tonumber(inventarData["blutmesser"]))

        --Lizensen
        vioSetElementData(source,"autoLic",tonumber(lizensenData["autoLic"]))
        vioSetElementData(source,"truckLic",tonumber(lizensenData["truckLic"]))
        vioSetElementData(source,"planeLic",tonumber(lizensenData["planeLic"]))
        vioSetElementData(source,"bikeLic",tonumber(lizensenData["bikeLic"]))
        vioSetElementData(source,"boatLic",tonumber(lizensenData["boatLic"]))
        vioSetElementData(source,"heliLic",tonumber(lizensenData["heliLic"]))
        vioSetElementData(source,"lastautoLic",tonumber(lizensenData["lastautoLic"]))
        vioSetElementData(source,"lasttruckLic",tonumber(lizensenData["lasttruckLic"]))
        vioSetElementData(source,"lastplaneLic",tonumber(lizensenData["lastplaneLic"]))
        vioSetElementData(source,"lastbikeLic",tonumber(lizensenData["lastbikeLic"]))
        vioSetElementData(source,"lastheliLic",tonumber(lizensenData["lastheliLic"]))
        vioSetElementData(source,"quadLic",tonumber(lizensenData["quadLic"]))
        vioSetElementData(source,"sonstigeLic",tonumber(lizensenData["sonstigeLic"]))
        vioSetElementData(source,"angelLic",tonumber(lizensenData["angelLic"]))
        vioSetElementData(source,"waffenLic",tonumber(lizensenData["waffenLic"]))
        vioSetElementData(source,"persoLic",tonumber(lizensenData["persoLic"]))
        vioSetElementData(source,"reiseLic",tonumber(lizensenData["reiseLic"]))

        --Archievments
        vioSetElementData(source,"Erfolg_Fischermeister",tonumber(archievmentsData["Erfolg_Fischermeister"]))
        vioSetElementData(source,"Punkte_Fischermeister",tonumber(archievmentsData["Punkte_Fischermeister"]))
        vioSetElementData(source,"Erfolg_MrLicenses",tonumber(archievmentsData["Erfolg_MrLicenses"]))
        vioSetElementData(source,"Erfolg_First_50",tonumber(archievmentsData["Erfolg_First_50"]))
        vioSetElementData(source,"Erfolg_First_100",tonumber(archievmentsData["Erfolg_First_100"]))
        vioSetElementData(source,"Erfolg_First_1000",tonumber(archievmentsData["Erfolg_First_1000"]))
        vioSetElementData(source,"Erfolg_Millionaer",tonumber(archievmentsData["Erfolg_Millionaer"]))
        vioSetElementData(source,"Erfolg_10erFahrzeugrausch",tonumber(archievmentsData["Erfolg_10erFahrzeugrausch"]))
        vioSetElementData(source,"Erfolg_20erFahrzeugrausch",tonumber(archievmentsData["Erfolg_20erFahrzeugrausch"]))
        vioSetElementData(source,"Erfolg_50erFahrzeugrausch",tonumber(archievmentsData["Erfolg_50erFahrzeugrausch"]))
        vioSetElementData(source,"Erfolg_Busmeister",tonumber(archievmentsData["Erfolg_Busmeister"]))
        vioSetElementData(source,"Punkte_Busmeister",tonumber(archievmentsData["Punkte_Busmeister"]))
        vioSetElementData(source,"Erfolg_Lotto1",tonumber(archievmentsData["Erfolg_Lotto1"]))
        vioSetElementData(source,"Erfolg_Lotto2",tonumber(archievmentsData["Erfolg_Lotto2"]))
        vioSetElementData(source,"Erfolg_Lotto3",tonumber(archievmentsData["Erfolg_Lotto3"]))
        vioSetElementData(source,"Erfolg_Rubbellosgluck",tonumber(archievmentsData["Erfolg_Rubbellosgluck"]))
        vioSetElementData(source,"Erfolg_10erLos",tonumber(archievmentsData["Erfolg_10erLos"]))
        vioSetElementData(source,"Erfolg_Benzin_leer",tonumber(archievmentsData["Erfolg_Benzin_leer"]))
        vioSetElementData(source,"Erfolg_Mein_erstes_Geld",tonumber(archievmentsData["Erfolg_Mein_erstes_Geld"]))
        vioSetElementData(source,"Erfolg_MyOwnHome",tonumber(archievmentsData["Erfolg_MyOwnHome"]))
        vioSetElementData(source,"Erfolg_MyOwnBiz",tonumber(archievmentsData["Erfolg_MyOwnBiz"]))
        vioSetElementData(source,"Erfolg_Autoeinsteiger",tonumber(archievmentsData["Erfolg_Autoeinsteiger"]))
        vioSetElementData(source,"Erfolg_Mein_erstes_Brot",tonumber(archievmentsData["Erfolg_Mein_erstes_Brot"]))
        vioSetElementData(source,"Erfolg_Ersatztanke",tonumber(archievmentsData["Erfolg_Ersatztanke"]))
        vioSetElementData(source,"Erfolg_Fraktionseinsteiger",tonumber(archievmentsData["Erfolg_Fraktionseinsteiger"]))
        vioSetElementData(source,"Erfolg_10Hufeisen",tonumber(archievmentsData["Erfolg_10Hufeisen"]))
        vioSetElementData(source,"Erfolg_100Hufeisen",tonumber(archievmentsData["Erfolg_100Hufeisen"]))
        vioSetElementData(source,"Erfolg_1000Hufeisen",tonumber(archievmentsData["Erfolg_1000Hufeisen"]))
        vioSetElementData(source,"Punkte_Meisterpilot",tonumber(archievmentsData["Punkte_Meisterpilot"]))
        vioSetElementData(source,"Erfolg_Meisterpilot",tonumber(archievmentsData["Erfolg_Meisterpilot"]))
        vioSetElementData(source,"Punkte_Meistertrucker",tonumber(archievmentsData["Punkte_Meistertrucker"]))
        vioSetElementData(source,"Erfolg_Meistertrucker",tonumber(archievmentsData["Erfolg_Meistertrucker"]))
        vioSetElementData(source,"Erfolg_KMPokal",tonumber(archievmentsData["Erfolg_KMPokal"]))
        vioSetElementData(source,"Erfolg_TerraFriend",tonumber(archievmentsData["Erfolg_TerraFriend"]))
        vioSetElementData(source,"Erfolg_Strassenreiniger",tonumber(archievmentsData["Erfolg_Strassenreiniger"]))
        vioSetElementData(source,"Punkte_Strassenreiniger",tonumber(archievmentsData["Punkte_Strassenreiniger"]))
        vioSetElementData(source,"Erfolg_Meeresreiniger",tonumber(archievmentsData["Erfolg_Meeresreiniger"]))
        vioSetElementData(source,"Punkte_Meeresreiniger",tonumber(archievmentsData["Punkte_Meeresreiniger"]))
        vioSetElementData(source,"Erfolg_Muellsammler",tonumber(archievmentsData["Erfolg_Muellsammler"]))
        vioSetElementData(source,"Punkte_Muellsammler",tonumber(archievmentsData["Punkte_Muellsammler"]))
        vioSetElementData(source,"Erfolg_Pizzaraser",tonumber(archievmentsData["Erfolg_Pizzaraser"]))
        vioSetElementData(source,"Punkte_Pizzaraser",tonumber(archievmentsData["Punkte_Pizzaraser"]))
        vioSetElementData(source,"Erfolg_Farmerjunge",tonumber(archievmentsData["Erfolg_Farmerjunge"]))
        vioSetElementData(source,"Punkte_Farmerjunge",tonumber(archievmentsData["Punkte_Farmerjunge"]))
        vioSetElementData(source,"Erfolg_Steinraeumer",tonumber(archievmentsData["Erfolg_Steinraeumer"]))
        vioSetElementData(source,"Punkte_Steinraeumer",tonumber(archievmentsData["Punkte_Steinraeumer"]))
        vioSetElementData(source,"Erfolg_Langlaeufer",tonumber(archievmentsData["Erfolg_Langlaeufer"]))
        vioSetElementData(source,"Punkte_Langlaeufer",tonumber(archievmentsData["Punkte_Langlaeufer"]))
        vioSetElementData(source,"Erfolg_Rekordschwimmer",tonumber(archievmentsData["Erfolg_Rekordschwimmer"]))
        vioSetElementData(source,"Punkte_Rekordschwimmer",tonumber(archievmentsData["Punkte_Rekordschwimmer"]))

        --JobSkills
        vioSetElementData(source,"fischSkill",tonumber(jobskillsData["fischSkill"]))
        vioSetElementData(source,"fischSkillPoints",tonumber(jobskillsData["fischSkillPoints"]))
        vioSetElementData(source,"busSkill",tonumber(jobskillsData["busSkill"]))
        vioSetElementData(source,"busSkillPoints",tonumber(jobskillsData["busSkillPoints"]))
        vioSetElementData(source,"muellSkill",tonumber(jobskillsData["muellSkill"]))
        vioSetElementData(source,"muellSkillPoints",tonumber(jobskillsData["muellSkillPoints"]))
        vioSetElementData(source,"pizzaSkill",tonumber(jobskillsData["pizzaSkill"]))
        vioSetElementData(source,"pizzaSkillPoints",tonumber(jobskillsData["pizzaSkillPoints"]))
        vioSetElementData(source,"truckSkill",tonumber(jobskillsData["truckSkill"]))
        vioSetElementData(source,"truckSkillPoints",tonumber(jobskillsData["truckSkillPoints"]))
        vioSetElementData(source,"sweeperSkill",tonumber(jobskillsData["sweeperSkill"]))
        vioSetElementData(source,"sweeperSkillPoints",tonumber(jobskillsData["sweeperSkillPoints"]))
        vioSetElementData(source,"flyersSkill",tonumber(jobskillsData["flyersSkill"]))
        vioSetElementData(source,"flyersSkillPoints",tonumber(jobskillsData["flyersSkillPoints"]))
        vioSetElementData(source,"farmerSkill",tonumber(jobskillsData["farmerSkill"]))
        vioSetElementData(source,"farmerSkillPoints",tonumber(jobskillsData["farmerSkillPoints"]))
        vioSetElementData(source,"bergWerkSkill",tonumber(jobskillsData["bergWerksSkill"]))
        vioSetElementData(source,"bergWerkSkillPoints",tonumber(jobskillsData["bergWerkSkillPoints"]))
        vioSetElementData(source,"meeresSkill",tonumber(jobskillsData["meeresSkill"]))
        vioSetElementData(source,"meeresSkillPoints",tonumber(jobskillsData["meeresSkillPoints"]))

        --Zeugnis
        vioSetElementData(source,"NAME_orientierung",tonumber(zeugnisData["NAME_orientierung"]))
        vioSetElementData(source,"NAME_theorie_Beamte",tonumber(zeugnisData["NAME_theorie_Beamte"]))
        vioSetElementData(source,"NAME_Gelaendefahr",tonumber(zeugnisData["NAME_Gelaendefahr"]))
        vioSetElementData(source,"NAME_sozial",tonumber(zeugnisData["NAME_sozial"]))
        vioSetElementData(source,"NAME_Waffenumgang",tonumber(zeugnisData["NAME_Waffenumgang"]))
        vioSetElementData(source,"NAME_spezFahrtest",tonumber(zeugnisData["NAME_spezFahrtest"]))
        vioSetElementData(source,"NAME_Strategisch",tonumber(zeugnisData["NAME_Strategisch"]))
        vioSetElementData(source,"NAME_praktisch_Beamte",tonumber(zeugnisData["NAME_praktisch_Beamte"]))
        vioSetElementData(source,"NAME_refresh",tonumber(zeugnisData["refresh"]))




        --WarnsLoading + Sonstiges


        vioSetElementData(source,"last_fishes",0)

        local warns=tonumber(MySQL_GetResultsCount("warns",	"Nickname='"..nickname.."'"))
        vioSetElementData(source,"warns",warns)
        vioSetElementData(source,"telefontoggle",0)
        vioSetElementData(source,"Tazer",0)
        vioSetElementData(source,"cuffed",0)
        vioSetElementData(source,"antiflut",0)

        if(vioGetElementData(source,"knastzeit")==0)then
            vioSetElementData(source,"alkaknast",0)
        end

        vioSetElementData(source,"cuffed",0)
        vioSetElementData(source,"schutzzahlung",false)
        if(vioGetElementData(source,"playtime")<(25*60))then
            setPlayerNametagText ( source, "[ROOKIE]-"..getPlayerName(source) )
        else
            setPlayerNametagText ( source, getPlayerName(source) )
        end



        vioSetElementData(source,"fishpoints",0)
        if(vioGetElementData(source,"fraktion")>0)then
            setPlayerTeam(source,team[vioGetElementData(source,"fraktion")])
        end
        setPlayerWantedLevel(source,vioGetElementData(source,"wanteds"))

        --Loginfenster vorher schliessen damit beim TutGUI der Cursor auch wieder angezeigt werden kann :)
        triggerClientEvent(source,"hideLoginGui",source)

        if(vioGetElementData(source,"tut")==0)then
            triggerClientEvent(source,"showTutGui_first",source,source)
            vioSetElementData(source,"tut",1)
        end


        local maxslot=vioGetElementData(source,"maxslots")
        local zah=0

        for k=1,vioGetElementData(source,"maxslots"),1 do
            vioSetElementData(source,"slot"..k,-1)
        end

        for theKey,thevehicleentry in ipairs(privVeh) do
            if(string.lower(thevehicleentry[1])== string.lower(getPlayerName(source)))then
                local slot=thevehicleentry[2]
                vioSetElementData(source,"slot"..slot,thevehicleentry[3])
            end
        end

        setPlayerMoney ( source,vioGetElementData(source,"money"))

        local time=getRealTime()
        local premiumOutTime=(MySQL_GetVar("premium", "PremiumUntil","Name='"..nickname.."'"))-time.timestamp
        vioSetElementData(source,"premium",0)
        if(premiumOutTime>0)then
            local days=math.round(((premiumOutTime/60)/60)/24)
            vioSetElementData(source,"premium",premiumOutTime)
            outputChatBox(string.format("Du hast noch %s Tage Premium!", days),source,0,255,0)
            if(days<7)then
                outputChatBox("ACHTUNG! Dein Premiumstatus läuft bald aus! Verlängere jetzt dein Premium!",source,0,255,0)
            end
        else
            outputChatBox("Du hast kein Premium? Kauf dir doch welches! Infos unter /premium!",source,0,255,0)
        end

        local onlineSchutzUntil = (MySQL_GetVar("terratapps", "OnlineSchutzUntil","Nickname = '" .. nickname .. "' ")) - time.timestamp
        vioSetElementData(source, "onlineschutzuntil", 0)
        if (onlineSchutzUntil > 0) then
            local days = math.round(((onlineSchutzUntil / 60) / 60) / 24)
            vioSetElementData(source, "onlineschutzuntil", onlineSchutzUntil+time.timestamp)
            outputChatBox(string.format("Du hast noch %s Tage OnlineSchutz!", days), source, 0, 255, 0)
            if (days < 7) then
                outputChatBox("ACHTUNG! Dein OnlineSchutz läuft bald aus! Verlängere jetzt deinen OnlineSchutz!", source, 0, 255, 0)
            end
        end



        outputServerLog(nickname.." logged in!")
        loadGutschriften(source)

        local timer=getRealTime()

        vioSetElementData(source,"loggedin",timer.timestamp)
        vioSetElementData(source,"afk_timer",0)
        vioSetElementData(source,"afk_status",0)




        if(vioGetElementData(source,"fraktion")>1 and vioGetElementData(source,"fraktion")~=5)then
            setPlayerSpawn(source,vioGetElementData(source,"spawnplace"),vioGetElementData(source,"FrakSkin"),vioGetElementData(source,"fraktion"),113)
        else
            setPlayerSpawn(source,vioGetElementData(source,"spawnplace"),vioGetElementData(source,"skinid"),vioGetElementData(source,"fraktion"),113)
        end

        loadTapps(source)



        fadeCamera (source, true,5.0)
        setCameraTarget (source, source)

        --setPlayerSpawnWeapons(source,vioGetElementData(source,"fraktion"),vioGetElementData(source,"fraktionsrang"))
        triggerClientEvent(source,"empfangeRuhezonenData",source,ruhezonen)
        sendalkacolshape_func(source)



    else
        logversuche=tonumber(vioGetElementData(source,"logtries"))
        logversuche=logversuche+1
        vioSetElementData(source,"logtries",logversuche)
        local rest=5-logversuche


        showError(source,string.format("Sie haben ein falsches Passwort eingegeben! Sie haben noch %s Versuche!", rest))

        if(rest==0)then
            kickPlayer ( source, "Zuviele LogIn Versuche mit falschen Passwort!" )
        end
    end

end
addEvent("loginPlayer",true)
addEventHandler("loginPlayer",getRootElement(),LoginPlayerData)

function loadTapps(thePlayer)
    local appTable={}
    appTable["Tapp-Marketplace"]=1
    appTable["Friendlist"]=MySQL_GetVar("terratapps", "Friendlist","Nickname='"..getPlayerName(thePlayer).."'")
    appTable["GPS"]=MySQL_GetVar("terratapps", "GPS","Nickname='"..getPlayerName(thePlayer).."'")
    appTable["Stopuhr"]=MySQL_GetVar("terratapps", "Stopuhr","Nickname='"..getPlayerName(thePlayer).."'")
    appTable["Blitzermelder"]=MySQL_GetVar("terratapps", "Blitzermelder","Nickname='"..getPlayerName(thePlayer).."'")
    appTable["Kompass"]=MySQL_GetVar("terratapps", "Kompass","Nickname='"..getPlayerName(thePlayer).."'")
    appTable["EMail"]=MySQL_GetVar("terratapps", "EMail","Nickname='"..getPlayerName(thePlayer).."'")
    appTable["Notizblock"]=MySQL_GetVar("terratapps", "Notizblock","Nickname='"..getPlayerName(thePlayer).."'")
    appTable["Colorpicker"]=MySQL_GetVar("terratapps", "Colorpicker","Nickname='"..getPlayerName(thePlayer).."'")
    appTable["TicTacToe"]=MySQL_GetVar("terratapps", "TicTacToe","Nickname='"..getPlayerName(thePlayer).."'")
    appTable["MineSweeper"]=MySQL_GetVar("terratapps", "MineSweeper","Nickname='"..getPlayerName(thePlayer).."'")
    appTable["OnlineBanking"]=MySQL_GetVar("terratapps", "OnlineBanking","Nickname='"..getPlayerName(thePlayer).."'")
    appTable["OnlineSchutz"]=MySQL_GetVar("terratapps", "OnlineSchutz","Nickname='"..getPlayerName(thePlayer).."'")
    vioSetElementData(thePlayer,"tappapps",appTable)

    local mails=MySQL_GetResultsCount("emails","neu='1' and Empfaenger='"..getPlayerName(thePlayer).."'")
    if(mails)then
        if(tonumber(mails))then
            if(tonumber(mails)>0)then
                if(appTable["EMail"]==1)then
                    outputChatBox(string.format("Sie haben %s neue Emails!", mails),thePlayer,255,0,0)
                else
                    outputChatBox("Sie haben neue Emails. Kaufen Sie sich die Email-Tapp des Terralapptapps um sie zu lesen!",thePlayer,255,0,0)
                end
            end
        end
    end


end

function dontcmd()
    if(not(isPlayerLoggedIn(source)))then
        cancelEvent()
    end
end
addEventHandler("onPlayerCommand",getRootElement(),dontcmd)

function loadGutschriften(thePlayer)
    --outputDebugString("Gutschrift loaded")

    local query=mysql_query(handler,"SELECT * FROM gutschriften WHERE Nickname='"..getPlayerName(thePlayer).."'")
    local zahler=0
    while (mysql_num_rows(query)>zahler) do
        local dasatz = mysql_fetch_assoc(query)
        outputChatBox(dasatz["Grund"],thePlayer,0,255,0)
        outputChatBox("Du erhälst dafür:",thePlayer,0,255,0)
        if(tonumber(dasatz["Geld"])>0)or(tonumber(dasatz["Geld"])<0)then
            outputChatBox(string.format("- Geld: %s", toprice(dasatz["Geld"])),thePlayer,0,255,0)
            changePlayerBank(thePlayer,tonumber(dasatz["Geld"]),"sonstiges","Gutschrift",dasatz["Grund"])
        end
        if(tonumber(dasatz["VehSlots"])>0)then
            outputChatBox(string.format("- Fahrzeugslots: %s", dasatz["VehSlots"]),thePlayer,0,255,0)
            vioSetElementData(thePlayer,"maxslots",vioGetElementData(thePlayer,"maxslots")+tonumber(dasatz["VehSlots"]))
            local k=0
            for k=0,tonumber(dasatz["VehSlots"])-1,1 do
                vioSetElementData(thePlayer,"slot"..vioGetElementData(thePlayer,"maxslots")-k,-1)
            end
        end
        mysql_query(handler,"DELETE FROM gutschriften WHERE ID='"..dasatz["ID"].."'")
        zahler=zahler+1
    end

    local query=mysql_query(handler,"SELECT * FROM servermessage WHERE Nickname='"..getPlayerName(thePlayer).."'")
    local zahler=0
    while (mysql_num_rows(query)>zahler) do
        local dasatz = mysql_fetch_assoc(query)
        outputChatBox(string.format("Offline-Message von %s: %s (Zeit: %s)", dasatz["VonName"], dasatz["Message"], dasatz["Time"]),thePlayer)
        mysql_query(handler,"DELETE FROM servermessage WHERE ID='"..dasatz["ID"].."'")
        zahler=zahler+1
    end
    mysql_query(handler,"UPDATE players SET AktiveDays=0 WHERE Nickname='"..getPlayerName(thePlayer).."'")
    mysql_query(handler,"UPDATE userdata SET AktiveDays=0 WHERE Nickname='"..getPlayerName(thePlayer).."'")

end



function save_offline_message(playername,vonname,text)
    if(not playername or not vonname or not text or type(playername)~="string" or type(vonname)~="string" or type(text)~="string")then
        outputDebugString("ErrorHelp save_offline_message: "..debug.traceback())
    end
    local query="INSERT INTO servermessage (Nickname,VonName,Message) VALUES ('"..playername.."','"..vonname.."','"..text.."')"
    mysql_query(handler,query)
end








