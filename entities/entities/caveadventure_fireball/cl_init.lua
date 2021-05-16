include( "shared.lua" )

function ENT:Draw()

end

function ENT:Think()
    if( self.ParticleEffect or not self:GetParticleEffect() ) then return end
    self.ParticleEffect = CreateParticleSystem( self, self:GetParticleEffect(), PATTACH_ABSORIGIN_FOLLOW, 0, Vector( 0, 0, 0 ) )
end

net.Receive( "CaveAdventure.Net.SendFireballHit", function()
    local ent = net.ReadEntity()
    if( not IsValid( ent ) ) then return end

    local pos = ent:GetPos()
	local emitter = ParticleEmitter( pos )

	for i = 0, 100 do
		local part = emitter:Add( "effects/spark", pos )
		if ( part ) then
			part:SetColor( math.random( 0, 255 ), math.random( 0, 255 ), math.random( 0, 255 ) )
			part:SetDieTime( 0.5 )

			part:SetStartAlpha( 255 )
			part:SetEndAlpha( 0 )

			part:SetStartSize( 3 )
			part:SetEndSize( 0 )

			part:SetGravity( Vector( 0, 0, 0 ) )
			part:SetVelocity( VectorRand()*100 )
			part:SetCollide( true )
			part:SetAirResistance( 50 )
		end
	end

	emitter:Finish()

    if( net.ReadBool() ) then
        local emitter = ParticleEmitter( pos )
    
        for i = 0, 20 do
            local part = emitter:Add( "effects/blood", pos )
            if ( part ) then
                part:SetColor( 255, 50, 50 )
                part:SetDieTime( 0.5 )
    
                part:SetStartAlpha( 255 )
                part:SetEndAlpha( 0 )
    
                part:SetStartSize( 10 )
                part:SetEndSize( 10 )
    
                part:SetGravity( Vector( 0, 0, 0 ) )
                part:SetVelocity( VectorRand()*100 )
                part:SetCollide( true )
                part:SetAirResistance( 50 )
            end
        end
    
        emitter:Finish()
    end
end )