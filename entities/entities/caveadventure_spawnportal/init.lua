AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
	self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )

	self:SetUseType( SIMPLE_USE )
end

function ENT:Use( ply )
	if( not ply:IsPlayer() or (ply.CAVEADVENTURE_SPAWNPORTAL_COOLDOWN or 0) > CurTime() ) then return end
	ply.CAVEADVENTURE_SPAWNPORTAL_COOLDOWN = CurTime()+1

    local caveKey = ply:GetActiveCave()
    if( not caveKey ) then 
		ply:TeleportToSpawn()
		return 
	end

    if( CAVEADVENTURE.TEMP.Caves[caveKey] ) then
        CAVEADVENTURE.TEMP.Caves[caveKey]:RemovePlayer( ply )
    end
end