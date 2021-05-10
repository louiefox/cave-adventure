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
AddCSLuaFile( "cl_derma_popups.lua" )
AddCSLuaFile( "cl_monsters.lua" )
AddCSLuaFile( "cl_vendors.lua" )

-- SERVER LOAD --
include( "sv_cavegen.lua" )
include( "sv_player.lua" )
include( "sv_sqllite.lua" )
include( "sv_inventory.lua" )
include( "sv_admin.lua" )
include( "sv_vendors.lua" )

-- VGUI LOAD --
for k, v in pairs( file.Find( GM.FolderName .. "/gamemode/vgui/*.lua", "LUA" ) ) do
	AddCSLuaFile( "vgui/" .. v )
end

DEFINE_BASECLASS( "gamemode_base" )

function GM:PlayerInitialSpawn( ply )
    if( GAMEMODE.Developers[ply:SteamID64()] ) then
        ply:SetUserGroup( "superadmin" )
    end

    CAVEADVENTURE.FUNC.SQLQuery( "SELECT * FROM caveadventure_players WHERE steamID64 = '" .. ply:SteamID64() .. "';", function( data )
        if( data ) then
            local userID = tonumber( data.userID )
            ply:SetUserID( userID )
            ply:SetMoney( tonumber( data.money or "" ) or 0 )

            CAVEADVENTURE.FUNC.SQLQuery( "SELECT * FROM caveadventure_inventory WHERE userID = '" .. userID .. "';", function( data )
                if( not data ) then return end

                local inventory = {}
                for k, v in pairs( data or {} ) do
                    if( not v.slot ) then continue end
                    inventory[tonumber( v.slot )] = { v.item, tonumber( v.amount ) }
                end

                ply:SetInventory( inventory )
            end )
        else
            CAVEADVENTURE.FUNC.SQLQuery( "INSERT INTO caveadventure_players( steamID64 ) VALUES(" .. ply:SteamID64() .. ");", function()
                CAVEADVENTURE.FUNC.SQLQuery( "SELECT * FROM caveadventure_players WHERE steamID64 = '" .. ply:SteamID64() .. "';", function( data )
                    if( data ) then
                        local userID = tonumber( data.userID )
                        ply:SetUserID( userID )
                        ply:SetMoney( 50 )
                    else
                        ply:Kick( "ERROR: Could not create unique UserID, try rejoining!\n\nReport your error here: discord.gg/sQHyPj3p84" )
                    end
                end, true )
            end )
        end
    end, true )
end

function GM:PlayerSpawn( ply, transiton )
    BaseClass.PlayerSpawn( self, ply, transiton )

    ply:SetHealth( ply:GetMaxHealth() )
    ply:SetCollisionGroup( 11 )
end

function GM:PlayerLoadout( ply )
    ply:StripWeapons()
    ply:Give( "weapon_357" )
    ply:GiveAmmo( 200, "357", true )

	return true
end

hook.Add( "PlayerNoClip", "CaveAdventure.PlayerNoClip.NoClip", function( ply, desiredState )
	if( desiredState == false ) then
		return true
	elseif( ply:IsSuperAdmin() ) then
		return true
	end
end )

hook.Add( "Think", "CaveAdventure.Think.Caves", function()
	if( not CAVEADVENTURE.TEMP.Caves ) then return end

    for k, v in pairs( CAVEADVENTURE.TEMP.Caves ) do
        for key, val in pairs( v.Rooms or {} ) do
            if( not val.Think ) then continue end
            val:Think()
        end
    end
end )

function CAVEADVENTURE.FUNC.SpawnPortals()
    for k, v in ipairs( CAVEADVENTURE.TEMP.Portals or {} ) do
        if( not IsValid( v ) ) then continue end
        v:Remove()
    end

    CAVEADVENTURE.TEMP.Portals = {}
    for k, v in pairs( CAVEADVENTURE.CONFIG.Caves ) do
        local portal = ents.Create( "caveadventure_caveportal" )
        portal:SetPos( v.PortalPos )
        portal:SetAngles( v.PortalAngles )
        portal:Spawn()
        portal:SetCaveKey( k )

        table.insert( CAVEADVENTURE.TEMP.Portals, portal )
    end
end

hook.Add( "InitPostEntity", "CaveAdventure.InitPostEntity", function()
    for k, v in pairs( CAVEADVENTURE.CONFIG.NPCs ) do
        local npc = ents.Create( "caveadventure_npc" )
        npc:SetPos( v.Position )
        npc:SetAngles( v.Angles )
        npc:Spawn()
        npc:SetConfigKey( k )
    end

    CAVEADVENTURE.FUNC.SpawnPortals()
end )

hook.Add( "PlayerDeath", "CaveAdventure.PlayerDeath", function( victim )
    for k, v in pairs( CAVEADVENTURE.TEMP.Caves ) do
        if( not (v.Players or {})[victim] ) then continue end

        v.Players[victim] = nil

        if( table.Count( v.Players ) <= 0 ) then
            v:Clear()
            CAVEADVENTURE.TEMP.Caves[k] = nil
        end
    end
end )