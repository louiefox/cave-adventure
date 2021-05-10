ENT.Base = "base_gmodentity" 
 
ENT.PrintName		= "Cave Portal"
ENT.Author			= "Brickwall"
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
    self:NetworkVar( "Int", 0, "CaveKey" )
end