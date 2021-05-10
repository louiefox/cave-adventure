ENT.Base = "base_ai" 
ENT.Type = "ai"
 
ENT.PrintName		= "NPC"
ENT.Author			= "Brickwall"
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
    self:NetworkVar( "String", 0, "ConfigKey" )

    if( SERVER ) then
		self:NetworkVarNotify( "ConfigKey", self.ConfigKeyChanged )
	end
end