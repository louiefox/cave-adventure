resource.AddFile( "resource/fonts/montserrat-bold.ttf" )
resource.AddFile( "resource/fonts/montserrat-medium.ttf" )

-- SHARED LOAD --
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

-- CLIENT LOAD --
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_drawing.lua" )
AddCSLuaFile( "cl_fonts.lua" )
AddCSLuaFile( "cl_bshadows.lua" )
AddCSLuaFile( "cl_panelmeta.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_player.lua" )
AddCSLuaFile( "cl_inventory.lua" )
AddCSLuaFile( "cl_monsters.lua" )

-- SERVER LOAD --
include( "sv_cavegen.lua" )
include( "sv_player.lua" )
include( "sv_inventory.lua" )
include( "sv_admin.lua" )

-- VGUI LOAD --
for k, v in pairs( file.Find( GM.FolderName .. "/gamemode/vgui/*.lua", "LUA" ) ) do
	AddCSLuaFile( "vgui/" .. v )
end

DEFINE_BASECLASS( "gamemode_base" )

function GM:PlayerInitialSpawn( ply )
    if( GAMEMODE.Developers[ply:SteamID64()] ) then
        ply:SetUserGroup( "superadmin" )
    end
end

function GM:PlayerSpawn( ply, transiton )
    BaseClass.PlayerSpawn( self, ply, transiton )

    ply:SetHealth( ply:GetMaxHealth() )
    ply:SetCollisionGroup( 11 )

    ply:TeleportToSpawn()
end

function GM:PlayerLoadout( ply )
    ply:StripWeapons()
    ply:Give( "m9k_glock" )

	return true
end

hook.Add( "PlayerNoClip", "CaveAdventure.PlayerNoClip.NoClip", function( ply, desiredState )
	if( desiredState == false ) then
		return true
	elseif( ply:IsSuperAdmin() ) then
		return true
	end
end )

hook.Add( "InitPostEntity", "CaveAdventure.InitPostEntity.CaveGen", function()
    CAVEADVENTURE.FUNC.SpawnCave()
end )

hook.Add( "Think", "CaveAdventure.Think.Caves", function()
	if( CAVE.GRID ) then
        for k, v in pairs( CAVE.GRID.Rooms or {} ) do
            if( not v.Think ) then continue end
            v:Think()
        end
    end
end )