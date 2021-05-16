ENT.Base = "base_gmodentity" 
 
ENT.PrintName		= "Spawn Portal"
ENT.Author			= "Brickwall"
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
    self:NetworkVar( "String", 0, "ParticleEffect" )
end