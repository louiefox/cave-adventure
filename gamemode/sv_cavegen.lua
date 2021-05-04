CAVE = CAVE or {}

local room_meta = {
    Remove = function( self )
        self.Floor:Remove()
        self.Ceiling:Remove()
        
        if( self.NavArea ) then
            self.NavArea:Remove() 
        end

        for k, v in ipairs( self.Walls ) do
            if( not IsValid( v ) ) then
                for key, val in pairs( v ) do
                    if( not IsValid( val ) ) then continue end
                    val:Remove()
                end
            else
                v:Remove()
            end
        end
    end,
    GetPos = function( self )
        return CAVE.GRID:GetRoomPos( self.x, self.y )
    end,
    AddDoorWay = function( self, wallKey, noDoor )
        local wall = self.Walls[wallKey]
        if( not IsValid( wall ) ) then return end

        local pos, angles, right = wall:GetPos(), wall:GetAngles(), wall:GetRight()

        wall:Remove()

        local wallEnts = {}

        local wall1 = ents.Create( "cave_building" )
        wall1:SetModel( "models/hunter/plates/plate4x4.mdl" )
        wall1:SetMaterial( "cave_adventure/rock_wall" )
        wall1:SetPos( pos+right*166 )
        wall1:SetAngles( angles )
        wall1:Spawn()
        wallEnts.Wall1 = wall1

        local wall2 = ents.Create( "cave_building" )
        wall2:SetModel( "models/hunter/plates/plate4x4.mdl" )
        wall2:SetMaterial( "cave_adventure/rock_wall" )
        wall2:SetPos( pos-right*166 )
        wall2:SetAngles( angles )
        wall2:Spawn()
        wallEnts.Wall2 = wall2

        local wall3 = ents.Create( "cave_building" )
        wall3:SetModel( "models/hunter/plates/plate3x4.mdl" )
        wall3:SetMaterial( "cave_adventure/rock_wall" )
        wall3:SetPos( pos+Vector( 0, 0, 120 ) )
        wall3:SetAngles( angles+Angle( 90, 0, 0 ) )
        wall3:Spawn()
        wallEnts.Wall3 = wall3

        if( not noDoor ) then
            local door = ents.Create( "cave_door" )
            door:SetPos( pos+Vector( 0, 0, -69.8 ) )
            door:SetAngles( angles+Angle( 90, 0, 0 ) )
            door:Spawn()
            door.room = self
            door.wallKey = wallKey
            wallEnts.Door = door
        end

        self.Walls[wallKey] = wallEnts

        self:AddTorch( wallKey )
    end,
    AddTorch = function( self, wallKey )
        local walls = self.Walls[wallKey]

        if( istable( walls ) ) then
            local wall1 = walls.Wall1
            local wall2 = walls.Wall2

            local directions = { 0, 270, 180, 90 }
            local change = ((wallKey == 1 or wallKey == 2) and -35) or 35
            
            local torch1 = ents.Create( "cave_torch" )
            torch1:SetAngles( Angle( 0, directions[wallKey], 0 ) )
            torch1:SetPos( wall1:GetPos()+torch1:GetRight()*change )
            torch1:Spawn()
            self.Walls[wallKey].Torch1 = torch1

            local torch2 = ents.Create( "cave_torch" )
            torch2:SetAngles( Angle( 0, directions[wallKey], 0 ) )
            torch2:SetPos( wall2:GetPos()-torch2:GetRight()*change )
            torch2:Spawn()
            self.Walls[wallKey].Torch2 = torch2
        end
    end,
    Generate = function( self )
        for i = 1, 4 do
            local axis = ((i == 1 or i == 3) and "X") or ((i == 2 or i == 4) and "Y")
            local change = ((i == 2 or i == 3) and 1) or -1

            local x, y = self.x+(axis == "X" and change or 0), self.y+(axis == "Y" and change or 0)
            local bound = math.floor( CAVE.GRID.Size/2 )

            if( x > bound or x < -bound or y > bound or y < -bound or CAVE.GRID:RoomExists( x, y ) or CAVE.GRID:RoomExistsAroundCoords( x, y, self.x, self.y, true ) ) then continue end

            self:AddDoorWay( i )
        end

        self.NavArea = navmesh.CreateNavArea( self.Floor:GetPos()+Vector( CAVE.GRID.RoomSize/2, CAVE.GRID.RoomSize/2, 0 ), self.Floor:GetPos()-Vector( CAVE.GRID.RoomSize/2, CAVE.GRID.RoomSize/2, 0 ) )

        local zombie = ents.Create( "cave_monster_zombie" )
        zombie:SetPos( self.Floor:GetPos()+Vector( 0, 0, 10 ) )
        zombie:SetInitMonsterClass( "zombie" )
        zombie:Spawn()
    end,
    SetSpawnRoom = function( self )
        self.SpawnRoom = true
    end
}

room_meta.__index = room_meta

local grid_meta = {
    Rooms = {},
    CorridorEnts = {},
    Clear = function( self )
        for k, v in pairs( self.Rooms ) do
            v:Remove()
        end

        for k, v in ipairs( self.CorridorEnts ) do
            if( not IsValid( v ) ) then continue end
            v:Remove()
        end

        self.Rooms = {}
    end,
    CoordinatesToKey = function( self, xCordinate, yCordinate )
        local row = (math.ceil( self.Size/2 )-yCordinate)
        return ((row-1)*self.Size)+(xCordinate+math.ceil( self.Size/2 ))
    end,
    RoomExists = function( self, xCordinate, yCordinate )
        if( self.Rooms[self:CoordinatesToKey( xCordinate, yCordinate )] ) then
            return true
        else
            return false
        end
    end,
    GetRoom = function( self, xCordinate, yCordinate )
        return self.Rooms[self:CoordinatesToKey( xCordinate, yCordinate )]
    end,
    RoomExistsAroundCoords = function( self, coordX, coordY, excludeX, excludeY, excludeSpawn )
        for i = 1, 4 do
            local axis = ((i == 1 or i == 3) and "X") or ((i == 2 or i == 4) and "Y")
            local change = ((i == 2 or i == 3) and 1) or -1

            local x, y = coordX+(axis == "X" and change or 0), coordY+(axis == "Y" and change or 0)

            local room = CAVE.GRID:GetRoom( x, y )
            if( not ((excludeX and x == excludeX) or (excludeY and y == excludeY)) and room and not (excludeSpawn and room.SpawnRoom) ) then
                return true
            end
        end
    end,
    GetRoomPos = function( self, xCordinate, yCordinate )
        return Vector( self.StartPos[1]+(xCordinate*(self.RoomSize+self.RoomSpacing)), self.StartPos[2]+(yCordinate*(self.RoomSize+self.RoomSpacing)), self.StartPos[3] )
    end,
    GetRoom = function( self, xCordinate, yCordinate )
        return self.Rooms[self:CoordinatesToKey( xCordinate, yCordinate ) or 0]
    end,
    AddRoom = function( self, xCordinate, yCordinate )
        if( self:RoomExists( xCordinate, yCordinate ) ) then return end

        local room = {
            Walls = {},
            x = xCordinate,
            y = yCordinate
        }

        local pos = self:GetRoomPos( xCordinate, yCordinate )

        local floor = ents.Create( "cave_building" )
        floor:SetModel( "models/hunter/plates/plate8x8.mdl" )
        floor:SetMaterial( "cave_adventure/stone_floor" )
        floor:SetPos( pos )
        floor:Spawn()
        room.Floor = floor

        local wall1 = ents.Create( "cave_building" )
        wall1:SetModel( "models/hunter/plates/plate4x8.mdl" )
        wall1:SetMaterial( "cave_adventure/rock_wall" )
        wall1:SetPos( pos+Vector( -self.RoomSize/2, 0, 95 ) )
        wall1:SetAngles( Angle( 90, 90, 90 ) )
        wall1:Spawn()
        room.Walls[1] = wall1

        local wall2 = ents.Create( "cave_building" )
        wall2:SetModel( "models/hunter/plates/plate4x8.mdl" )
        wall2:SetMaterial( "cave_adventure/rock_wall" )
        wall2:SetPos( pos+Vector( 0, self.RoomSize/2, 95 ) )
        wall2:SetAngles( Angle( 90, 0, 90 ) )
        wall2:Spawn()
        room.Walls[2] = wall2

        local wall3 = ents.Create( "cave_building" )
        wall3:SetModel( "models/hunter/plates/plate4x8.mdl" )
        wall3:SetMaterial( "cave_adventure/rock_wall" )
        wall3:SetPos( pos+Vector( self.RoomSize/2, 0, 95 ) )
        wall3:SetAngles( Angle( 90, 90, 90 ) )
        wall3:Spawn()
        room.Walls[3] = wall3

        local wall4 = ents.Create( "cave_building" )
        wall4:SetModel( "models/hunter/plates/plate4x8.mdl" )
        wall4:SetMaterial( "cave_adventure/rock_wall" )
        wall4:SetPos( pos+Vector( 0, -self.RoomSize/2, 95 ) )
        wall4:SetAngles( Angle( 90, 0, 90 ) )
        wall4:Spawn()
        room.Walls[4] = wall4

        local ceiling = ents.Create( "cave_building" )
        ceiling:SetModel( "models/hunter/plates/plate8x8.mdl" )
        ceiling:SetMaterial( "cave_adventure/rock_wall" )
        ceiling:SetPos( pos+Vector( 0, 0, 167.5 ) )
        ceiling:Spawn()
        room.Ceiling = ceiling
    
        setmetatable( room, room_meta )
        self.Rooms[self:CoordinatesToKey( xCordinate, yCordinate )] = room

        return room
    end,
    ConnectRooms = function( self, room1X, room1Y, room2X, room2Y )
        local room1 = self:GetRoom( room1X, room1Y )
        local room2 = self:GetRoom( room2X, room2Y )

        if( not room1 or not room2 ) then return end

        local axis = (room1X == room2X and "Y") or (room1Y == room2Y and "X")
        
        if( not axis ) then
            print( "GRID ERROR: Attempted to connect rooms not next to each other." )
            return
        end

        local room1Pos, room2Pos = room1:GetPos(), room2:GetPos()
        local corridorPos, corridorDir = (room1Pos+room2Pos)/2
        local room1Wall, room2Wall
        if( axis == "X" ) then
            corridorDir = 90
            if( room1X > room2X ) then
                room1Wall, room2Wall = 1, 3
            else
                room1Wall, room2Wall = 3, 1
            end
        else
            corridorDir = 180
            if( room1Y < room2Y ) then
                room1Wall, room2Wall = 2, 4
            else
                room1Wall, room2Wall = 4, 2
            end
        end

        local floor = ents.Create( "cave_building" )
        floor:SetModel( "models/hunter/plates/plate3x8.mdl" )
        floor:SetMaterial( "cave_adventure/stone_floor" )
        floor:SetPos( corridorPos )
        floor:SetAngles( Angle( 0, corridorDir, 0 ) )
        floor:Spawn()
        table.insert( self.CorridorEnts, floor )

        local wall1 = ents.Create( "cave_building" )
        wall1:SetModel( "models/hunter/plates/plate3x8.mdl" )
        wall1:SetMaterial( "cave_adventure/rock_wall" )
        wall1:SetPos( floor:GetPos()+floor:GetForward()*72.6+floor:GetUp()*72 )
        wall1:SetAngles( floor:GetAngles()+Angle( 90, 0, 0 ) )
        wall1:Spawn()
        table.insert( self.CorridorEnts, wall1 )

        local wall2 = ents.Create( "cave_building" )
        wall2:SetModel( "models/hunter/plates/plate3x8.mdl" )
        wall2:SetMaterial( "cave_adventure/rock_wall" )
        wall2:SetPos( floor:GetPos()-floor:GetForward()*72.6+floor:GetUp()*72 )
        wall2:SetAngles( floor:GetAngles()+Angle( 90, 0, 0 ) )
        wall2:Spawn()
        table.insert( self.CorridorEnts, wall2 )

        local ceiling = ents.Create( "cave_building" )
        ceiling:SetModel( "models/hunter/plates/plate3x8.mdl" )
        ceiling:SetMaterial( "cave_adventure/rock_wall" )
        ceiling:SetPos( floor:GetPos()+floor:GetUp()*121.6 )
        ceiling:SetAngles( floor:GetAngles() )
        ceiling:Spawn()
        table.insert( self.CorridorEnts, ceiling )
    end
}

grid_meta.__index = grid_meta

function CAVEADVENTURE.FUNC.SpawnCave()
    if( CAVE.GRID ) then
        CAVE.GRID:Clear()
    end
    
    CAVE.GRID = {
        Size = 5,
        StartPos = Vector( 0, 0, 300 ),
        RoomSize = 380,
        RoomSpacing = 379
    }
    
    setmetatable( CAVE.GRID, grid_meta )

    CAVE.GRID:Clear()

    local room1 = CAVE.GRID:AddRoom( 0, 0 )
    room1:AddDoorWay( 2 )
    room1:SetSpawnRoom()

    for k, v in ipairs( player.GetAll() ) do
        v:TeleportToSpawn()
    end
end

concommand.Add( "spawn_cave", function( ply )
    if( IsValid( ply ) and not ply:IsSuperAdmin() ) then return end
    CAVEADVENTURE.FUNC.SpawnCave()
end )