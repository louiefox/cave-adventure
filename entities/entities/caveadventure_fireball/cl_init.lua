include( "shared.lua" )

function ENT:Draw()

end

function ENT:Think()
    if( self.ParticleEffect or not self:GetParticleEffect() ) then return end
    self.ParticleEffect = CreateParticleSystem( self, self:GetParticleEffect(), PATTACH_ABSORIGIN_FOLLOW, 0, Vector( 0, 0, 0 ) )
end