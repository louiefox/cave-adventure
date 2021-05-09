function CAVEADVENTURE.FUNC.SQLQuery( queryStr, func, singleRow )
	local query
	if( not singleRow ) then
		query = sql.Query( queryStr )
	else
		query = sql.QueryRow( queryStr, 1 )
	end
	
	if( query == false ) then
		print( "[CaveAdventure SQLLite] ERROR", sql.LastError() )
	elseif( func ) then
		func( query )
	end
end

-- PLAYERS --
if( not sql.TableExists( "caveadventure_players" ) ) then
	CAVEADVENTURE.FUNC.SQLQuery( [[ CREATE TABLE caveadventure_players ( 
		userID INTEGER PRIMARY KEY AUTOINCREMENT,
		steamID64 varchar(20) NOT NULL UNIQUE
	); ]] )
end

print( "[CaveAdventure SQLLite] caveadventure_players table validated!" )

-- PLAYERMODELS --
if( not sql.TableExists( "caveadventure_inventory" ) ) then
	CAVEADVENTURE.FUNC.SQLQuery( [[ CREATE TABLE caveadventure_inventory ( 
		userID int NOT NULL,
		slot int NOT NULL,
		item varchar(25) NOT NULL,
		amount int NOT NULL
	); ]] )
end

print( "[CaveAdventure SQLLite] caveadventure_inventory table validated!" )