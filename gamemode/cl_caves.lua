net.Receive( "CaveAdventure.SendJoinCave", function()
    local caveKey = net.ReadUInt( 4 )

    local caveCfg = CAVEADVENTURE.CONFIG.Caves[caveKey]
    if( not caveCfg ) then return end

    timer.Simple( CAVEADVENTURE.DEVCONFIG.TransitionTime, function()
        local caveNotification = vgui.Create( "caveadventure_cave_join" )
        caveNotification:SetCaveKey( caveKey )
    end )
end )

net.Receive( "CaveAdventure.SendCompletedCave", function()
    local caveKey = net.ReadUInt( 4 )
    local deleteTime = net.ReadUInt( 32 )

    local caveCfg = CAVEADVENTURE.CONFIG.Caves[caveKey]
    if( not caveCfg ) then return end

    local caveNotification = vgui.Create( "caveadventure_cave_completed" )
    caveNotification:SetInfo( caveKey, deleteTime )
end )