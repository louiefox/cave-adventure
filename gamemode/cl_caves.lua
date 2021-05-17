net.Receive( "CaveAdventure.SendJoinCave", function()
    local caveKey = net.ReadUInt( 4 )

    local caveCfg = CAVEADVENTURE.CONFIG.Caves[caveKey]
    if( not caveCfg ) then return end

    CAVEADVENTURE.TEMP.CaveData = {
        StartTime = net.ReadUInt( 32 ),
        Players = {},
        CurrentRoom = 0,
        Damage = 0
    }

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

    CAVEADVENTURE.TEMP.CaveData = nil

    local caveNotification = vgui.Create( "caveadventure_cave_completed" )
    caveNotification:SetInfo( caveKey, deleteTime )
end )

net.Receive( "CaveAdventure.SendCavePlayer", function()
    local caveKey = net.ReadUInt( 4 )
    local delete = net.ReadBool()
    local ply = net.ReadEntity()

    if( (LocalPlayer():GetActiveCave() or 0) != caveKey or not CAVEADVENTURE.TEMP.CaveData or not IsValid( ply ) ) then return end

    if( not delete ) then
        CAVEADVENTURE.TEMP.CaveData.Players[ply] = true
    else
        CAVEADVENTURE.TEMP.CaveData.Players[ply] = nil
    end
end )

net.Receive( "CaveAdventure.SendCurrentCaveRoom", function()
    local caveKey = net.ReadUInt( 4 )
    local room = net.ReadUInt( 6 )

    if( (LocalPlayer():GetActiveCave() or 0) != caveKey or not CAVEADVENTURE.TEMP.CaveData ) then return end

    CAVEADVENTURE.TEMP.CaveData.CurrentRoom = room
end )

net.Receive( "CaveAdventure.SendCaveDamage", function()
    local caveKey = net.ReadUInt( 4 )
    local damage = net.ReadUInt( 16 )

    if( (LocalPlayer():GetActiveCave() or 0) != caveKey or not CAVEADVENTURE.TEMP.CaveData ) then return end

    CAVEADVENTURE.TEMP.CaveData.Damage = CAVEADVENTURE.TEMP.CaveData.Damage+damage
end )

local function GetTextH( text, font )
    surface.SetFont( font )
    return select( 2, surface.GetTextSize( text ) )
end

local function GetTextW( text, font )
    surface.SetFont( font )
    return surface.GetTextSize( text )
end

hook.Add( "HUDPaint", "CaveAdventure.HUDPaint.CaveStatus", function()
    local caveKey = LocalPlayer():GetActiveCave()
    if( not caveKey ) then return end

    local caveCfg = CAVEADVENTURE.CONFIG.Caves[caveKey]
    if( not caveCfg ) then return end

    local caveData = CAVEADVENTURE.TEMP.CaveData
    if( not caveData ) then return end

    local caveStatus = "Active"
    if( CurTime() < caveData.StartTime ) then
        caveStatus = "Preparing"
    end

    local x, y = ScrW()-CAVEADVENTURE.FUNC.ScreenScale( 75 ), ScrH()*0.5

    draw.SimpleTextOutlined( "CAVE STATUS", "MontserratBold30", x, y, CAVEADVENTURE.FUNC.GetTheme( 4 ), TEXT_ALIGN_RIGHT, 0, 2, CAVEADVENTURE.FUNC.GetTheme( 1 ) )

    local stats = {
        {
            Text = {
                { caveStatus, caveStatus == "Preparing" and CAVEADVENTURE.CONFIG.Themes.Orange or CAVEADVENTURE.CONFIG.Themes.Green },
                { "Status: ", CAVEADVENTURE.FUNC.GetTheme( 3 ) }
            }
        }
    }

    if( caveStatus == "Preparing" ) then
        table.insert( stats, {
            Text = {
                { math.max( 0, math.Round( caveData.StartTime-CurTime(), 1 ) ) .. "s", CAVEADVENTURE.FUNC.GetTheme( 4 ) },
                { "Starting in ", CAVEADVENTURE.FUNC.GetTheme( 3 ) }
            }
        } )
    end

    table.insert( stats, {
        Text = {
            { table.Count( caveData.Players ) .. "/" .. caveCfg.MaxPlayers, CAVEADVENTURE.FUNC.GetTheme( 4 ) },
            { "Players: ", CAVEADVENTURE.FUNC.GetTheme( 3 ) }
        }
    } )

    if( caveStatus != "Preparing" ) then
        table.insert( stats, {
            Text = {
                { caveData.CurrentRoom .. "/" .. (caveCfg.Size^2)-1, CAVEADVENTURE.FUNC.GetTheme( 4 ) },
                { "Room: ", CAVEADVENTURE.FUNC.GetTheme( 3 ) }
            }
        } )

        local dmgString = string.Comma( caveData.Damage )
        if( caveData.Damage >= 1000 ) then
            dmgString = math.Round( caveData.Damage/1000, 2 ) .. "K"
        end

        table.insert( stats, {
            Text = {
                { dmgString, CAVEADVENTURE.CONFIG.Themes.Red },
                { "Damage: ", CAVEADVENTURE.FUNC.GetTheme( 3 ) }
            }
        } )
    end

    local previousH = GetTextH( "CAVE STATUS", "MontserratBold30" )-5
    for k, v in ipairs( stats ) do
        local text = ""
        if( istable( v.Text ) ) then
            local previousW = 0
            for key, val in ipairs( v.Text ) do
                text = text .. val[1]
                draw.SimpleTextOutlined( val[1], "MontserratBold20", x-previousW, y+previousH, val[2], TEXT_ALIGN_RIGHT, 0, 2, CAVEADVENTURE.FUNC.GetTheme( 1 ) )
                previousW = previousW+GetTextW( val[1], "MontserratBold20" )
            end
        else
            text = v.Text
            draw.SimpleTextOutlined( v.Text, "MontserratBold20", x, y+previousH, CAVEADVENTURE.FUNC.GetTheme( 3 ), TEXT_ALIGN_RIGHT, 0, 2, CAVEADVENTURE.FUNC.GetTheme( 1 ) )
        end

        previousH = previousH+GetTextH( text, "MontserratBold20" )
    end
end )