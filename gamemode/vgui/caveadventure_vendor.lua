local PANEL = {}

function PANEL:Init()
    self:SetHeader( "VENDOR" )

    self.top = vgui.Create( "DPanel", self )
    self.top:Dock( TOP )
    self.top:SetTall( 30 )
    self.top:DockMargin( 10, 10, 10, 0 )
    self.top.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, CAVEADVENTURE.FUNC.GetTheme( 2, 100 ) )
    end

    self.slotSpacing = 5

    self.grid = vgui.Create( "DIconLayout", self )
    self.grid:Dock( FILL )
    self.grid:DockMargin( 10, 10, 10, 10 )
    self.grid:SetSpaceX( self.slotSpacing )
    self.grid:SetSpaceY( self.slotSpacing )

    self:SetTargetSize( ScrW()*0.15, ScrH()*0.4 )
    self:SetStartCenter( ScrW()*0.25, ScrH()*0.5 )
    self:Open()
end

vgui.Register( "caveadventure_vendor", PANEL, "caveadventure_frame" )