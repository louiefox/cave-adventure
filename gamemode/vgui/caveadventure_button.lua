local PANEL = {}

function PANEL:Init()
    self:SetText( "" )
end

function PANEL:SetButtonText( text )
    self.text = text
end

function PANEL:Paint( w, h )
    self:CreateFadeAlpha( false, 75 )
        
    draw.RoundedBox( 8, 0, 0, w, h, CAVEADVENTURE.FUNC.GetTheme( 2 ) )

    local border = 2
    draw.RoundedBox( 8, border, border, w-(2*border), h-(2*border), CAVEADVENTURE.FUNC.GetTheme( 1 ) )
    draw.RoundedBox( 8, border, border, w-(2*border), h-(2*border), CAVEADVENTURE.FUNC.GetTheme( 2, 100+self.alpha ) )

    CAVEADVENTURE.FUNC.DrawClickCircle( self, w, h, CAVEADVENTURE.FUNC.GetTheme( 2 ), 8 )

    draw.SimpleText( self.text, "MontserratBold25", w/2, h/2-1, CAVEADVENTURE.FUNC.GetTheme( 4, 75+(180*(self.alpha/75)) ), 1, 1 )
end

vgui.Register( "caveadventure_button", PANEL, "DButton" )