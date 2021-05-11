include( "shared.lua" )

function ENT:Draw()

end

CAVEADVENTURE.TEMP.SpawnPortals = CAVEADVENTURE.TEMP.SpawnPortals or {}
function ENT:Initialize()
    CAVEADVENTURE.TEMP.SpawnPortals = CAVEADVENTURE.TEMP.SpawnPortals or {}
	CAVEADVENTURE.TEMP.SpawnPortals[self] = true
end

function ENT:OnRemove()
    if( not CAVEADVENTURE.TEMP.SpawnPortals ) then return end
	CAVEADVENTURE.TEMP.SpawnPortals[self] = nil
end

function ENT:Think()
    if( self.ParticleEffect ) then return end
    self.ParticleEffect = CreateParticleSystem( self, "[8]orb_1", PATTACH_ABSORIGIN_FOLLOW, 0, Vector( 0, 0, 0 ) )
end

hook.Add( "HUDPaint", "CaveAdventure.HUDPaint.SpawnPortals", function()
	local ply = LocalPlayer()
    for k, v in pairs( CAVEADVENTURE.TEMP.SpawnPortals or {} ) do
        if( not IsValid( k ) ) then
            CAVEADVENTURE.TEMP.SpawnPortals[k] = nil
            continue
        end

		local distance = ply:GetPos():DistToSqr( k:GetPos() )
		if( distance > 300000 ) then continue end

        local pos = k:GetPos()
        pos.z = pos.z+30

        local pos2d = pos:ToScreen()

        draw.SimpleTextOutlined( "Spawn Portal", "MontserratBold40", pos2d.x, pos2d.y+2, CAVEADVENTURE.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, CAVEADVENTURE.FUNC.GetTheme( 1 ) )
        draw.SimpleTextOutlined( "Press " .. string.upper( input.LookupBinding( "+use" ) ) .. " to teleport!", "MontserratBold25", pos2d.x, pos2d.y-2, CAVEADVENTURE.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, 0, 1, CAVEADVENTURE.FUNC.GetTheme( 1 ) )
    end
end )