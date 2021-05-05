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

hook.Add( "HUDPaint", "CaveAdventure.HUDPaint.HUD", function()
    local iconSize = CAVEADVENTURE.FUNC.ScreenScale( 64 )
    local screenSpace = CAVEADVENTURE.FUNC.ScreenScale( 75 )

    local y = ScrH()-screenSpace-iconSize

    for k, v in ipairs( binds ) do
        local x = ScrW()-screenSpace-(k*iconSize)-((k-1)*CAVEADVENTURE.FUNC.ScreenScale( 50 ))

        surface.SetMaterial( v[3] )

        surface.SetDrawColor( CAVEADVENTURE.FUNC.GetTheme( 1 ) )
        surface.DrawTexturedRect( x-1, y-1, iconSize, iconSize )
        surface.DrawTexturedRect( x+1, y-1, iconSize, iconSize )
        surface.DrawTexturedRect( x-1, y+1, iconSize, iconSize )
        surface.DrawTexturedRect( x+1, y+1, iconSize, iconSize )

        surface.SetDrawColor( CAVEADVENTURE.FUNC.GetTheme( 4 ) )
        surface.DrawTexturedRect( x, y, iconSize, iconSize )		

        draw.SimpleTextOutlined( v[1], "MontserratBold20", x+(iconSize/2), y+iconSize, CAVEADVENTURE.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, 0, 2, CAVEADVENTURE.FUNC.GetTheme( 1 ) )
        draw.SimpleTextOutlined( v[2], "MontserratBold30", x+iconSize, y+iconSize+5, CAVEADVENTURE.FUNC.GetTheme( 3 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, CAVEADVENTURE.FUNC.GetTheme( 1 ) )	
    end
end )