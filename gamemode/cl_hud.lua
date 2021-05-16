local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true
}

hook.Add( "HUDShouldDraw", "CaveAdventure.HUDShouldDraw.Hide", function( name )
	if( hide[name] ) then
		return false
	end
end )

local binds = {
    {
        "BACKPACK",
        "B",
        Material( "cave_adventure/icons/backpack.png" )
    },
    {
        "CHARACTER",
        "C",
        Material( "cave_adventure/icons/character.png" )
    }
}

local rounded_bar = Material( "cave_adventure/hud/rounded_bar.png" )
local healthLerp = 0
hook.Add( "HUDPaint", "CaveAdventure.HUDPaint.HUD", function()
    local ply = LocalPlayer()

    -- HEALTH HUD --
    local w = ScrW()*0.15
    local h = (270/1624)*w

    local spacing = CAVEADVENTURE.FUNC.ScreenScale( 75 )
    local borderSpace = 5

    local targetHealth
    local health, maxHealth = ply:Health(), ply:GetMaxHealth()

    local regenData = CAVEADVENTURE_HEALTHREGEN
    if( regenData ) then
        local regenPercent = math.Clamp( (CurTime()-regenData[1])/regenData[2], 0, 1 )

        targetHealth = math.Clamp( health+(regenPercent*(maxHealth-health)), 1, maxHealth ) 
    else
        targetHealth = health
    end

    healthLerp = Lerp( RealFrameTime()*2, healthLerp, targetHealth )

    surface.SetMaterial( rounded_bar )

    surface.SetDrawColor( CAVEADVENTURE.FUNC.GetTheme( 1 ) )
    surface.DrawTexturedRect( spacing, ScrH()-spacing-h, w, h )

    CAVEADVENTURE.FUNC.DrawMask( "HealthHUD", function()
        surface.SetMaterial( rounded_bar )
        surface.SetDrawColor( 255, 255, 255 )
        surface.DrawTexturedRect( spacing+borderSpace, ScrH()-spacing-h+borderSpace, w-(2*borderSpace), h-(2*borderSpace) )
    end, function()
        surface.SetDrawColor( 255, 100, 100 )
        surface.DrawRect( spacing+borderSpace, ScrH()-spacing-h+borderSpace, (w-(2*borderSpace))*math.Clamp( healthLerp/maxHealth, 0, 1 ), h-(2*borderSpace) )

        surface.SetDrawColor( 224, 61, 61 )
        surface.DrawRect( spacing+borderSpace, ScrH()-spacing-h+borderSpace, (w-(2*borderSpace))*math.Clamp( targetHealth/maxHealth, 0, 1 ), h-(2*borderSpace) )
    end )

    -- BIND HUD --
    local iconSize = CAVEADVENTURE.FUNC.ScreenScale( 68 )
    local screenSpace = CAVEADVENTURE.FUNC.ScreenScale( 75 )

    local y = ScrH()-screenSpace-iconSize

    for k, v in ipairs( binds ) do
        local x = ScrW()-screenSpace-(k*iconSize)-((k-1)*CAVEADVENTURE.FUNC.ScreenScale( 50 ))

        surface.SetMaterial( v[3] )
        surface.SetDrawColor( 255, 255, 255 )
        surface.DrawTexturedRect( x, y, iconSize, iconSize )		

        draw.SimpleTextOutlined( v[1], "MontserratBold20", x+(iconSize/2), y+iconSize, CAVEADVENTURE.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, 0, 2, CAVEADVENTURE.FUNC.GetTheme( 1 ) )
        draw.SimpleTextOutlined( v[2], "MontserratBold30", x+iconSize, y+iconSize+5, CAVEADVENTURE.FUNC.GetTheme( 3 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, CAVEADVENTURE.FUNC.GetTheme( 1 ) )	
    end
end )