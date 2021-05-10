local PANEL = {}

function PANEL:Init()
    self:SetText( "" )
end

function PANEL:SetItemInfo( itemKey, amount )
    local itemConfig = CAVEADVENTURE.CONFIG.Items[itemKey]
    if( not itemConfig ) then return end

    self.amount = amount
    self.rarityConfig = CAVEADVENTURE.CONFIG.Rarities[itemConfig.Rarity]
    self.iconMat = itemConfig.Icon
end

local gradientMat = Material( "cave_adventure/gradient_box.png" )
function PANEL:Paint( w, h )
    self:CreateFadeAlpha( false, 255 )

    if( self.rarityConfig ) then
        CAVEADVENTURE.FUNC.DrawRoundedMask( 8, 0, 0, w, h, function()
            surface.SetDrawColor( self.rarityConfig[4] )
            surface.SetMaterial( gradientMat )
            surface.DrawTexturedRect( 0, 0, w, h )

            surface.SetDrawColor( self.rarityConfig[4].r, self.rarityConfig[4].g, self.rarityConfig[4].b, self.alphaOverride or self.alpha )
            surface.SetMaterial( gradientMat )
            surface.DrawTexturedRect( 0, 0, w, h )
        end )
    end

    if( self.iconMat ) then
        surface.SetDrawColor( 255, 255, 255 )
        surface.SetMaterial( self.iconMat )
        local iconSize = w*0.7
        surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
    end

    if( self.amount ) then draw.SimpleTextOutlined( self.amount, "MontserratBold25", w-5, h, CAVEADVENTURE.FUNC.GetTheme( 4 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, CAVEADVENTURE.FUNC.GetTheme( 1 ) ) end

    if( self.customCursor ) then
        local cursorX, cursorY = self:LocalCursorPos()
        if( cursorX <= 0 or cursorX >= w or cursorY <= 0 or cursorY >= h ) then return end

        DisableClipping( true )

        surface.SetMaterial( self.customCursor )

        surface.SetDrawColor( CAVEADVENTURE.FUNC.GetTheme( 1 ) )
        surface.DrawTexturedRect( cursorX+1, cursorY+1, 24, 24 )
        surface.DrawTexturedRect( cursorX-1, cursorY+1, 24, 24 )
        surface.DrawTexturedRect( cursorX+1, cursorY-1, 24, 24 )
        surface.DrawTexturedRect( cursorX-1, cursorY-1, 24, 24 )
        
        surface.SetDrawColor( CAVEADVENTURE.FUNC.GetTheme( 4 ) )
        surface.DrawTexturedRect( cursorX, cursorY, 24, 24 )

        DisableClipping( false )
    end
end

vgui.Register( "caveadventure_item", PANEL, "DButton" )