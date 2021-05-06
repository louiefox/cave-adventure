-- SHARED LOAD --
include( "shared.lua" )

-- CLIENT LOAD --
include( "cl_drawing.lua" )
include( "cl_fonts.lua" )
include( "cl_bshadows.lua" )
include( "cl_panelmeta.lua" )
include( "cl_hud.lua" )
include( "cl_player.lua" )
include( "cl_inventory.lua" )
include( "cl_monsters.lua" )

-- VGUI LOAD --
for k, v in pairs( file.Find( GM.FolderName .. "/gamemode/vgui/*.lua", "LUA" ) ) do
	include( "vgui/" .. v )
end

concommand.Add( "caveadventure_removeonclose", function()
    CAVEADVENTURE.TEMP.RemoveOnClose = not CAVEADVENTURE.TEMP.RemoveOnClose
end )

hook.Add( "PlayerButtonDown", "CaveAdventure.PlayerButtonDown.Menues", function( ply, button )
	if( button != KEY_B ) then return end

	if( CurTime() < (CAVEADVENTURE.TEMP.ButtonCooldown or 0) ) then return end
	CAVEADVENTURE.TEMP.ButtonCooldown = CurTime()+0.2

    if( IsValid( CAVEADVENTURE.TEMP.InvMenu ) ) then
        if( CAVEADVENTURE.TEMP.InvMenu:IsVisible() ) then
            CAVEADVENTURE.TEMP.InvMenu:Close()
        else
            CAVEADVENTURE.TEMP.InvMenu:Open()
        end
    else
        CAVEADVENTURE.TEMP.InvMenu = vgui.Create( "caveadventure_inventory" )
    end
end )