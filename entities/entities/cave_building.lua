AddCSLuaFile()

ENT.Base = "base_gmodentity"

function ENT:Initialize()
	if( SERVER ) then
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
	end
end