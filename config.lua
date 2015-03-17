-- not used in all files... will be set later
config={}
-- Name of Owner
config["owner"]="[TP]iCompaq"

--Supportemail
config["supportmail"]="server@tierra-rl.eu"

-- array with all domains which should not found in Anti-Advertise-Functions
config["domains"]={"tierra-rl.eu","tierra-rl.eu"} 

-- Main Domain / will later be set in credits or info guis
config["maindomain"]="http://tierra-rl.eu"

--Bugtracker URL
config["bugdomain"]="https://github.com/icompaq/TIERRA-REALLIFE/issues";

--IP or Domain to Teamspeak3
config["teamspeak"]="folgt"

--Clantag: will protect Register with this tag or names of Clanmembers without this tag (Will set that [ABC]DEF is the same like DEF in checkups)
config["clantag"]="[TP]"

--Community Name - The Name of the Community, which should be written f.e. in credits
config["communityname"]="Tierra Reallife"

--passwort Hash Algo ... 
--Options:  
--   -> md5    (old System... not recommend)
--   -> osha256   (Sha256 before MTA:SA 1.4.1)
--   -> sha256    (Sha256 // avaible after MTA:SA 1.4.1)
--   -> sha512    (Sha512 // avaible after MTA:SA 1.4.1  -- recommend)
config["password_hash"]="sha512"

--Mappername
config["mappername"]="[TP]Poldi"

--Scriptername
config["scriptername"]="[TP]iCompaq"

--MYSQL CONFIG:
config["mysqlhost"]="localhost"
config["mysqluser"]="username"
config["mysqlpassword"]="password"
config["mysqldb"]="databasename"

--IF You want to have a second unique log database set 'uniquelogdb' to true else let it be false
--IF true setup the other entries
config["uniquelogdb"]=false
config["logmysqlhost"]="localhost"
config["logmysqluser"]="logusername"
config["logmysqlpassword"]="logpassword"
config["logmysqldb"]="logdatabasename"

--24h Restart type
-- Options:
-- GMX - Gamemoderestart at 3/4 o'clock
-- SHUTDOWN  - complete Shutdown of the server at 3/4 o'clock  (recommend but you have to setup a automatic restart Script on your host)
-- NONE - No Restart at 3/4 o'clock (not recommend)
config["dailyrestarttype"]="SHUTDOWN"




