CAVEADVENTURE.TEMP.Caves = CAVEADVENTURE.TEMP.Caves or {}

local function CreateBuilding( model, material, pos, angles )
    local building = ents.Create( "cave_building" )
    building:SetBuildingModel( model )
    building:SetMaterial( material )
    building:SetPos( pos )
    if( angles ) then building:SetAngles( angles ) end
    building:Spawn()

    return building
end

local room_meta = {
    Remove = function( self )
        self.Floor:Remove()
        self.Ceiling:Remove()
        
        if( self.Entities ) then
            for k, v in ipairs( self.Entities ) do
                if( not IsValid( v ) ) then continue end
                v:Remove()
            end
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
        return self.Cave:GetRoomPos( self.x, self.y )
    end,
    AddDoorWay = function( self, wallKey, noDoor )
        local wall = self.Walls[wallKey]
        if( not IsValid( wall ) ) then return end

        local pos, angles, right = wall:GetPos(), wall:GetAngles(), wall:GetRight()

        wall:Remove()

        local wallEnts = {
            Wall1 = CreateBuilding( "models/hunter/plates/plate4x4.mdl", "cave_adventure/rock_wall", pos+right*166, angles ),
            Wall2 = CreateBuilding( "models/hunter/plates/plate4x4.mdl", "cave_adventure/rock_wall", pos-right*166, angles ),
            Wall3 = CreateBuilding( "models/hunter/plates/plate3x4.mdl", "cave_adventure/rock_wall", pos+Vector( 0, 0, 120 ), angles+Angle( 90, 0, 0 ) )
        }

        if( not noDoor ) then
            local door = ents.Create( "cave_door" )
            door:SetPos( pos+Vector( 0, 0, -69.8 ) )
            door:SetAngles( angles+Angle( 90, 0, 0 ) )
            door:Spawn()
            door.Cave = self.Cave
            door.Room = self
            door.WallKey = wallKey
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
            local bound = math.floor( self.Cave.Size/2 )

            if( x > bound or x < -bound or y > bound or y < -bound or self.Cave:RoomExists( x, y ) or self.Cave:RoomExistsAroundCoords( x, y, self.x, self.y, true ) ) then continue end

            self:AddDoorWay( i )
        end

        self.NavArea = navmesh.CreateNavArea( self.Floor:GetPos()+Vector( self.Cave.RoomSize/2, self.Cave.RoomSize/2, 0 ), self.Floor:GetPos()-Vector( self.Cave.RoomSize/2, self.Cave.RoomSize/2, 0 ) )

        local zombie = ents.Create( "cave_monster_zombie" )
        zombie:SetPos( self.Floor:GetPos()+Vector( 0, 0, 10 ) )
        zombie:SetInitMonsterClass( "zombie" )
        zombie:Spawn()
        zombie.CaveKey = self.Cave.CaveKey
        zombie.RoomKey = self.RoomKey

        table.insert( self.Entities, zombie )
    end,
    OnCompleted = function( self )
        local caveCfg = CAVEADVENTURE.CONFIG.Caves[self.Cave.CaveKey]
        local roomCfg = caveCfg.Rooms[self.RoomCfgKey]

        local chest = ents.Create( "caveadventure_chest" )
        chest:SetPos( self.Floor:GetPos()+Vector( 0, 0, 10 ) )
        chest:SetRewardPlayers( table.Copy( self.Cave.Players ) )
        chest:SetRarity( CAVEADVENTURE.FUNC.GetRandomRarity( roomCfg.ChestRarities ) )
        chest:Spawn()

        table.insert( self.Entities, chest )

        self.Cave:CheckCompletion()
    end
}

room_meta.__index = room_meta

local grid_meta = {
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
    Delete = function( self )
        self:Clear()
        CAVEADVENTURE.TEMP.Caves[self.CaveKey] = nil

        for k, v in pairs( self.Players or {} ) do
            if( not IsValid( k ) ) then continue end
            k:RemoveFromCave( self.CaveKey )
        end
    end,
    CheckCompletion = function( self )
        if( table.Count( self.Rooms ) < self.Size^2 ) then return end

        local deleteTime = CurTime()+60
        timer.Simple( deleteTime-CurTime(), function()
            if( not self or not self.CaveKey or not CAVEADVENTURE.TEMP.Caves[self.CaveKey] ) then return end
            self:Delete()
        end )

        net.Start( "CaveAdventure.SendCompletedCave" )
            net.WriteUInt( self.CaveKey, 4 )
            net.WriteUInt( deleteTime, 32 )
        net.Send( table.GetKeys( self.Players ) )
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
    RoomExistsAroundCoords = function( self, coordX, coordY, excludeX, excludeY, excludeSpawn )
        for i = 1, 4 do
            local axis = ((i == 1 or i == 3) and "X") or ((i == 2 or i == 4) and "Y")
            local change = ((i == 2 or i == 3) and 1) or -1

            local x, y = coordX+(axis == "X" and change or 0), coordY+(axis == "Y" and change or 0)

            local bound = (self.Size-1)/2
            if( x > bound or x < -bound or y > bound or y < -bound ) then continue end

            local room = self:GetRoom( x, y )
            if( not room ) then continue end

            if( excludeSpawn and room.SpawnRoom ) then continue end

            if( (excludeX and x == excludeX) and (excludeY and y == excludeY) ) then continue end

            return true
        end
    end,
    GetRoomPos = function( self, xCordinate, yCordinate )
        return Vector( self.StartPos[1]+(xCordinate*(self.RoomSize+self.RoomSpacing)), self.StartPos[2]+(yCordinate*(self.RoomSize+self.RoomSpacing)), self.StartPos[3] )
    end,
    GetRoom = function( self, xCordinate, yCordinate )
        return self.Rooms[self:CoordinatesToKey( xCordinate, yCordinate )]
    end,
    AddRoom = function( self, xCordinate, yCordinate, spawnRoom )
        if( self:RoomExists( xCordinate, yCordinate ) ) then return end

        local roomKey = self:CoordinatesToKey( xCordinate, yCordinate )

        local room = {
            Cave = self,
            RoomKey = roomKey,
            Entities = {},
            x = xCordinate,
            y = yCordinate,
            SpawnRoom = spawnRoom,
            RoomCfgKey = not spawnRoom and self:GetNextRoomCfg()
        }

        local pos = self:GetRoomPos( xCordinate, yCordinate )

        room.Floor = CreateBuilding( "models/hunter/plates/plate8x8.mdl", "cave_adventure/stone_floor", pos )

        room.Walls = {
            CreateBuilding( "models/hunter/plates/plate4x8.mdl", "cave_adventure/rock_wall", pos+Vector( -self.RoomSize/2, 0, 95 ), Angle( 90, 90, 90 ) ),
            CreateBuilding( "models/hunter/plates/plate4x8.mdl", "cave_adventure/rock_wall", pos+Vector( 0, self.RoomSize/2, 95 ), Angle( 90, 0, 90 ) ),
            CreateBuilding( "models/hunter/plates/plate4x8.mdl", "cave_adventure/rock_wall", pos+Vector( self.RoomSize/2, 0, 95 ), Angle( 90, 90, 90 ) ),
            CreateBuilding( "models/hunter/plates/plate4x8.mdl", "cave_adventure/rock_wall", pos+Vector( 0, -self.RoomSize/2, 95 ), Angle( 90, 0, 90 ) )
        }

        room.Ceiling = CreateBuilding( "models/hunter/plates/plate8x8.mdl", "cave_adventure/rock_wall", pos+Vector( 0, 0, 167.5 ) )

        if( spawnRoom ) then
            local portal = ents.Create( "caveadventure_spawnportal" )
            portal:SetPos( pos+Vector( 0, -150, 50 ) )
            portal:Spawn()
            table.insert( room.Entities, portal )
        end
    
        setmetatable( room, room_meta )
        self.Rooms[roomKey] = room

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

        local floor = CreateBuilding( "models/hunter/plates/plate3x8.mdl", "cave_adventure/stone_floor", corridorPos, Angle( 0, corridorDir, 0 ) )
        table.insert( self.CorridorEnts, floor )

        table.insert( self.CorridorEnts, CreateBuilding( "models/hunter/plates/plate3x8.mdl", "cave_adventure/rock_wall", floor:GetPos()+floor:GetForward()*72.6+floor:GetUp()*72, floor:GetAngles()+Angle( 90, 0, 0 ) ) ) -- Wall 1
        table.insert( self.CorridorEnts, CreateBuilding( "models/hunter/plates/plate3x8.mdl", "cave_adventure/rock_wall", floor:GetPos()-floor:GetForward()*72.6+floor:GetUp()*72, floor:GetAngles()+Angle( 90, 0, 0 ) ) ) -- Wall 2

        table.insert( self.CorridorEnts, CreateBuilding( "models/hunter/plates/plate3x8.mdl", "cave_adventure/rock_wall", floor:GetPos()+floor:GetUp()*121.6, floor:GetAngles() ) ) -- Ceiling
    end,
    AddPlayer = function( self, ply )
        self.Players[ply] = true
        ply:AddToCave( self.CaveKey )
    end,
    RemovePlayer = function( self, ply )
        self.Players[ply] = nil

        if( table.Count( self.Players ) <= 0 ) then
            self:Delete()
        end

        ply:RemoveFromCave( self.CaveKey )
    end,
    CanOpenDoor = function( self )
        for k, v in pairs( self.Rooms ) do
            if( not v.SpawnRoom and not v.Completed ) then return false end
        end

        return true
    end,
    GetNextRoomCfg = function( self )
        local caveCfg = CAVEADVENTURE.CONFIG.Caves[self.CaveKey]

        local previousCount = 0
        for k, v in ipairs( caveCfg.Rooms ) do
            if( table.Count( self.Rooms )-1 < previousCount+v.Count ) then
                return k
            end

            previousCount = previousCount+v.Count
        end
    end
}

grid_meta.__index = grid_meta

function CAVEADVENTURE.FUNC.SpawnCave( caveKey )
    local caveCfg = CAVEADVENTURE.CONFIG.Caves[caveKey]

    if( CAVEADVENTURE.TEMP.Caves[caveKey] ) then
        CAVEADVENTURE.TEMP.Caves[caveKey]:Clear()
    end
    
    local newCave = {
        CaveKey = caveKey,
        Size = caveCfg.Size,
        StartPos = caveCfg.StartPos,
        Rooms = {},
        CorridorEnts = {},
        Players = {},
        RoomSize = 380,
        RoomSpacing = 379
    }
    
    setmetatable( newCave, grid_meta )

    local room1 = newCave:AddRoom( 0, 0, true )
    room1:AddDoorWay( 2 )

    CAVEADVENTURE.TEMP.Caves[caveKey] = newCave

    return newCave
end