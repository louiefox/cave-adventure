AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
	self:SetModel( "models/props_phx/construct/metal_wire1x2b.mdl" )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )

	self:SetUseType( SIMPLE_USE )
end

function ENT:Use( ply )
	if( not ply:IsPlayer() or (ply.CAVEADVENTURE_DOOR_COOLDOWN or 0) > CurTime() ) then return end
	ply.CAVEADVENTURE_DOOR_COOLDOWN = CurTime()+1

	local caveKey = self:GetCaveKey()
    
	local cave = CAVEADVENTURE.FUNC.SpawnCave( caveKey )
	cave:AddPlayer( ply )
end