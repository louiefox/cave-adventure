local PANEL = {}

function PANEL:Init()
    self:SetSize( 50, 50 )
    self:DockPadding( 15, 10, 15, 10 )
    self:SetDrawOnTop( true )
end

function PANEL:SetItemInfo( itemKey, amount )
    local itemConfig = CAVEADVENTURE.CONFIG.Items[itemKey]
    if( not itemConfig ) then return end

    self.itemConfig = itemConfig
    self.rarityConfig = CAVEADVENTURE.CONFIG.Rarities[itemConfig.Rarity]

    self.maxWide = 0

    self:AddText( itemConfig.Name, "MontserratBold25", self.rarityConfig[3] )
    self:AddText( self.rarityConfig[2], "MontserratMedium20", CAVEADVENTURE.FUNC.GetTheme( 4 ) )
    self:AddText( "Item Level " .. itemConfig.ItemLevel, "MontserratMedium20", CAVEADVENTURE.FUNC.GetTheme( 3 ) )

    if( itemConfig.SellPrice ) then
        surface.SetFont( "MontserratMedium20" )
        local textX, textY = surface.GetTextSize( "Sell Price:" )

        local sellPricePanel = vgui.Create( "DPanel", self )
        sellPricePanel:Dock( TOP )
        sellPricePanel:SetTall( 24 )
        sellPricePanel.Paint = function( self2, w, h )
            draw.SimpleText( "Sell Price:", "MontserratMedium20", 0, h/2, CAVEADVENTURE.FUNC.GetTheme( 4 ), 0, TEXT_ALIGN_CENTER )
        end

        local moneyPanel = vgui.Create( "caveadventure_money", sellPricePanel )
        moneyPanel:Dock( LEFT )
        moneyPanel:DockMargin( textX+10, 0, 0, 0 )
        moneyPanel:SetMoneyAmount( itemConfig.SellPrice*amount, true )

        sellPricePanel:SetWide( textX+10+moneyPanel:GetWide() )
        self:AddInfo( sellPricePanel )
    end

    self:SetSize( 30+self.maxWide, self.infoH+20 )
end

function PANEL:AddText( text, font, color )
    surface.SetFont( font )
    local textX, textY = surface.GetTextSize( text )

    local infoPanel = vgui.Create( "DPanel", self )
    infoPanel:Dock( TOP )
    infoPanel:SetTall( textY )
    infoPanel.Paint = function( self2, w, h )
        draw.SimpleText( text, font, 0, 0, color )
    end

    self.infoH = (self.infoH or 0)+infoPanel:GetTall()
    self.maxWide = math.max( self.maxWide, textX )
end

function PANEL:AddInfo( panel )
    self.infoH = (self.infoH or 0)+panel:GetTall()
    self.maxWide = math.max( self.maxWide, panel:GetWide() )
end

local gradientMat = Material( "cave_adventure/gradient_box.png" )
function PANEL:Paint( w, h )
    BSHADOWS.BeginShadow( "item_tooltip" )
    BSHADOWS.SetShadowSize( "item_tooltip", w, h )
    local x, y = self:LocalToScreen( 0, 0 )
    draw.RoundedBox( 8, x, y, w, h, CAVEADVENTURE.FUNC.GetTheme( 2 ) )
    BSHADOWS.EndShadow( "item_tooltip", x, y, 1, 1, 1, 255, 0, 0, false )
end

vgui.Register( "caveadventure_item_tooltip", PANEL, "DPanel" )