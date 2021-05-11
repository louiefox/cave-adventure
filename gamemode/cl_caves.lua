net.Receive( "CaveAdventure.SendStartCave", function()
    local caveKey = net.ReadUInt( 4 )

    local caveCfg = CAVEADVENTURE.CONFIG.Caves[caveKey]
    if( not caveCfg ) then return end

    local caveNotification = vgui.Create( "caveadventure_cave_notificaiton" )
    caveNotification:SetCaveKey( caveKey )
end )