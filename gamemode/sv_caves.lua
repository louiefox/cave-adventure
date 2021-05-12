hook.Add( "OnNPCKilled", "CaveAdventure.OnNPCKilled.Caves", function( npc, attacker, inflictor ) 
    local caveKey, roomKey = npc.CaveKey, npc.RoomKey
    if( not caveKey or not roomKey ) then return end

    local cave = CAVEADVENTURE.TEMP.Caves[caveKey]
    if( not cave ) then return end

    local room = cave.Rooms[roomKey]
    if( not room ) then return end

    room.Completed = true
    room:OnCompleted()
end )

util.AddNetworkString( "CaveAdventure.SendCompletedCave" )