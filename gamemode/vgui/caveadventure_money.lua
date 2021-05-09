local PANEL = {}

function PANEL:Init()
    self:SetWide( 0 )
end

local coinMat = Material( "cave_adventure/icons/coin.png" )
local cGold, cSilver, cCopper = Color( 181, 151, 40 ), Color( 159, 159, 159 ), Color( 149, 84, 48 )
function PANEL:SetMoneyAmount( money )
    local gold, silver, copper = CAVEADVENTURE.FUNC.GetMoneyTable( money )

    local coins = { 
		{ gold, cGold },
		{ silver, cSilver },
		{ copper, cCopper }
	}

	surface.SetFont( "MontserratMedium20" )

	for k, v in ipairs( coins ) do
        if( v[1] <= 0 ) then continue end
        
		local textX, textY = surface.GetTextSize( v[1] )
        local iconSize = CAVEADVENTURE.FUNC.ScreenScale( 16 )

        local coinPanel = vgui.Create( "DPanel", self )
        coinPanel:Dock( LEFT )
        coinPanel:SetWide( textX+3+iconSize )
        coinPanel:DockMargin( 0, 0, 10, 0 )
        coinPanel.Paint = function( self2, w, h )
            draw.SimpleText( v[1], "MontserratMedium20", 0, (h/2), CAVEADVENTURE.FUNC.GetTheme( 4 ), 0, TEXT_ALIGN_CENTER )

            surface.SetDrawColor( v[2] )
            surface.SetMaterial( coinMat )
            surface.DrawTexturedRect( textX+3, (h/2)-(iconSize/2)+1, iconSize, iconSize )
        end

        self:SetWide( self:GetWide()+coinPanel:GetWide()+(self:GetWide() > 0 and 10 or 0) )
	end
end

function PANEL:Paint( w, h )

end

vgui.Register( "caveadventure_money", PANEL, "DPanel" )