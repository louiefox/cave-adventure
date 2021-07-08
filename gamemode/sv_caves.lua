hook.Add( "OnNPCKilled", "CaveAdventure.OnNPCKilled.Caves", function( npc, attacker, inflictor ) 
    local caveKey, roomKey = npc.CaveKey, npc.RoomKey
    if( not caveKey or not roomKey ) then return end

    local cave = CAVEADVENTURE.TEMP.Caves[caveKey]
    if( not cave ) then return end

    local room = cave.Rooms[roomKey]
    if( not room ) then return end

    room.Monsters[npc] = nil

    if( table.Count( room.Monsters ) <= 0 ) then
        room.Completed = true
        room:OnCompleted()
    end
end )

hook.Add( "EntityTakeDamage", "CaveAdventure.EntityTakeDamage.Caves", function( target, dmgInfo ) 
    if( not target.IsMonster ) then return end

    local caveKey = target.CaveKey
    if( not caveKey ) then return end

    local cave = CAVEADVENTURE.TEMP.Caves[caveKey]
    if( not cave ) then return end

    local ply = dmgInfo:GetAttacker()
    if( not IsValid( ply ) or not ply:IsPlayer() ) then return end

    ply:SendCaveDamage( caveKey, math.Clamp( dmgInfo:GetDamage(), 0, target:Health() ) )
end )

util.AddNetworkString( "CaveAdventure.SendCompletedCave" )

concommand.Add( "cave_test_monster", function( ply )
    local pos = ply:GetEyeTrace().HitPos

    local monster = ents.Create( "cave_monster_undead" )
    monster:SetPos( pos+Vector( 0, 0, 10 ) )
    monster:SetInitMonsterClass( "undead" )
    monster:SetCavePlayers( { ply } )
    monster:Spawn()
end )