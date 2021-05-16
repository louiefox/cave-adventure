ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName		= "Treasure Chest"
ENT.Author			= "Brickwall"
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
    self:NetworkVar( "String", 0, "Rarity" )
end