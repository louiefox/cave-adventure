resource.AddFile( "resource/fonts/montserrat-bold.ttf" )
resource.AddFile( "resource/fonts/montserrat-medium.ttf" )

-- SHARED LOAD --
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

-- CLIENT LOAD --
AddCSLuaFile( "cl_init.lua" )

-- SERVER LOAD --
include( "sv_cavegen.lua" )

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
end

function GM:PlayerLoadout( ply )
    ply:StripWeapons()
    ply:Give( "weapon_hands" )

	return true
end

hook.Add( "PlayerNoClip", "CaveAdventure.Hooks.PlayerNoClip", function( ply, desiredState )
	if( desiredState == false ) then
		return true
	elseif( ply:IsSuperAdmin() ) then
		return true
	end
end )