AddCSLuaFile()

ENT.Base = "base_gmodentity"

function ENT:Initialize()

end

function ENT:SetBuildingModel( model )
	self:SetModel( model )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
end