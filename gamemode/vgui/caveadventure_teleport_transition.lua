local PANEL = {}

function PANEL:Init()
    self:SetSize( ScrW(), ScrH() )
end

function PANEL:SetEndTime( endTime )
    self.endTime = endTime

    surface.PlaySound( "cave_adventure/cave_start.wav" )
end

function PANEL:Think()
    if( not self.removing and self.endTime and CurTime() >= self.endTime ) then
        self.removing = true
        self:AlphaTo( 0, 0.2, 0, function()
            self:Remove()
        end )
    end
end

function PANEL:Paint( w, h )
    surface.SetDrawColor( CAVEADVENTURE.FUNC.GetTheme( 1 ) )
    surface.DrawRect( 0, 0, w, h )

    local old = DisableClipping( true )
	render.RenderView( {
		origin = Vector( 1357, -174, -2736 ),
		angles = Angle( 0, 90, 0 ),
		x = 0, y = 0,
		w = w, h = h
	} )
	DisableClipping( old )

    CAVEADVENTURE.FUNC.DrawBlur( self, 4, 4 )

    draw.SimpleTextOutlined( "TELEPORTING", "MontserratBold70", w/2, h*0.5, CAVEADVENTURE.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, CAVEADVENTURE.FUNC.GetTheme( 1 ) )
    draw.SimpleTextOutlined( "Teleporting in " .. math.max( 0, math.Round( (self.endTime or 0)-CurTime(), 1 ) ) .. "s", "MontserratBold50", w/2, h*0.5, CAVEADVENTURE.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, 0, 2, CAVEADVENTURE.FUNC.GetTheme( 1 ) )
end

vgui.Register( "caveadventure_teleport_transition", PANEL, "DPanel" )