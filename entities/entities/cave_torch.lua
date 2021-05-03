AddCSLuaFile()
DEFINE_BASECLASS( "base_gmodentity" )

function ENT:Initialize()
	if( CLIENT ) then
		self.PixVis = util.GetPixelVisibleHandle()
	end

	if( SERVER ) then
		self:SetModel( "models/props_medieval/torch.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
	end
end

function ENT:GetLightPos()
    return self:GetPos()+(self:GetUp()*25)+(self:GetForward()*11.5)
end

function ENT:Think()
	self.BaseClass.Think( self )

	if( CLIENT ) then
		if( LocalPlayer():GetPos():DistToSqr( self:GetPos() ) > 800000 ) then return end

		local dlight = DynamicLight( self:EntIndex(), false )

		if( dlight ) then
            local size = 256
			dlight.Pos = self:GetLightPos()
			dlight.r = 255
			dlight.g = 98
			dlight.b = 0
			dlight.Brightness = 7
			dlight.Decay = size * 5
			dlight.Size = size
			dlight.DieTime = CurTime() + 1

			dlight.noworld = false
			dlight.nomodel = false
		end

		if( not self.ParticleEffect ) then
			self.ParticleEffect = CreateParticleSystem( self, "[1]groundflame1", PATTACH_ABSORIGIN_FOLLOW, 0, (self:GetUp()*25)+(self:GetForward()*11.5) )
		end
	end
end

ENT.RenderGroup = RENDERGROUP_BOTH
function ENT:DrawTranslucent( flags )
	BaseClass.DrawTranslucent( self, flags )
end