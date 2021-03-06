include( "shared.lua" )

function ENT:Draw()

end

CAVEADVENTURE.TEMP.Portals = CAVEADVENTURE.TEMP.Portals or {}
function ENT:Initialize()
    CAVEADVENTURE.TEMP.Portals = CAVEADVENTURE.TEMP.Portals or {}
	CAVEADVENTURE.TEMP.Portals[self] = true
end

function ENT:OnRemove()
    if( not CAVEADVENTURE.TEMP.Portals ) then return end
	CAVEADVENTURE.TEMP.Portals[self] = nil
end

function ENT:Think()
    if( self.ParticleEffect ) then return end

    local caveKey = self:GetCaveKey()
    local caveCfg = CAVEADVENTURE.CONFIG.Caves[caveKey or 0]
    if( not caveCfg ) then return end
    
    self.ParticleEffect = CreateParticleSystem( self, caveCfg.PortalParticle, PATTACH_ABSORIGIN_FOLLOW, 0, Vector( 0, 0, 0 ) )
end

hook.Add( "HUDPaint", "CaveAdventure.HUDPaint.Portals", function()
	local ply = LocalPlayer()
    for k, v in pairs( CAVEADVENTURE.TEMP.Portals or {} ) do
        if( not IsValid( k ) ) then
            CAVEADVENTURE.TEMP.Portals[k] = nil
            continue
        end

		local distance = ply:GetPos():DistToSqr( k:GetPos() )
		if( distance > 300000 ) then continue end

		local caveKey = k:GetCaveKey()
		local caveCfg = CAVEADVENTURE.CONFIG.Caves[caveKey or 0]
		if( not caveCfg ) then continue end

        local pos = k:GetPos()
        pos.z = pos.z+50

        local pos2d = pos:ToScreen()

        draw.SimpleTextOutlined( caveCfg.Name, "MontserratBold40", pos2d.x, pos2d.y+2, CAVEADVENTURE.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, CAVEADVENTURE.FUNC.GetTheme( 1 ) )
        draw.SimpleTextOutlined( "Level " .. caveCfg.Level, "MontserratBold25", pos2d.x, pos2d.y-2, CAVEADVENTURE.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, 0, 1, CAVEADVENTURE.FUNC.GetTheme( 1 ) )
    end
end )