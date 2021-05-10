include( "shared.lua" )

function ENT:Draw()
	self:DrawModel()

    local pos = self:GetPos()
    local angles = self:GetAngles()

    angles:RotateAroundAxis( angles:Up(), 90 )
	angles:RotateAroundAxis( angles:Forward(), 90 )

	local yPos = -(self:OBBMaxs().z*21)

	local distance = LocalPlayer():GetPos():DistToSqr( pos )
	if( distance > 500000 ) then return end

	local configTable = CAVEADVENTURE.CONFIG.NPCs[self:GetConfigKey() or ""]
	if( not configTable ) then return end

	surface.SetFont( "MontserratBold70" )
	local width, height = surface.GetTextSize( configTable.Name )
	width, height = width+20, height+15

	cam.Start3D2D( pos+angles:Up()*0.5, angles, 0.05 )
		draw.RoundedBox( 8, -(width/2), yPos-(height/2), width, height, CAVEADVENTURE.FUNC.GetTheme( 2 ) )
		draw.SimpleText( configTable.Name, "MontserratBold70", 0, yPos, CAVEADVENTURE.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )	
	cam.End3D2D()
end