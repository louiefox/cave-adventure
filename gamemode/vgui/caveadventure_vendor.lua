local PANEL = {}

function PANEL:Init()
    self:SetHeader( "VENDOR" )

    self.bottom = vgui.Create( "DPanel", self )
    self.bottom:Dock( BOTTOM )
    self.bottom:SetTall( 75 )
    self.bottom.Paint = function( self2, w, h )
        draw.RoundedBoxEx( 8, 0, 0, w, h, CAVEADVENTURE.FUNC.GetTheme( 2, 100 ), false, false, true, true )
    end

    self.slotSpacing = 10
    self.slotH = 75

    self.grid = vgui.Create( "DIconLayout", self )
    self.grid:Dock( FILL )
    self.grid:DockMargin( 10, 10, 10, 10 )
    self.grid:SetSpaceX( self.slotSpacing )
    self.grid:SetSpaceY( self.slotSpacing )

    self:SetTargetSize( ScrW()*0.2, (5*(self.slotH+self.slotSpacing))-self.slotSpacing+20+self.bottom:GetTall() )
    self:SetStartCenter( ScrW()*0.25, ScrH()*0.5 )
    self:Open( false, true )
end

function PANEL:SetConfigKey( configKey )
    self.grid:Clear()

    local config = CAVEADVENTURE.CONFIG.NPCs[configKey]
    if( not config ) then return end

    local optionCfg = config.Options["vendor"]

    for i = 1, 10 do
        local slot = vgui.Create( "DPanel", self.grid )
        slot:SetSize( (ScrW()*0.2-30)/2, self.slotH )
        slot.Paint = function( self2, w, h )
            local alpha = 0
            if( IsValid( self2.button ) ) then
                self2.button:CreateFadeAlpha( false, 50 )
                alpha = self2.button.alpha
            end
            
            if( IsValid( self2.item ) ) then
                self2.item.alphaOverride = (alpha/50)*255
            end

            draw.RoundedBox( 8, 0, 0, w, h, CAVEADVENTURE.FUNC.GetTheme( 2 ) )
            draw.RoundedBox( 8, 2, 2, w-4, h-4, CAVEADVENTURE.FUNC.GetTheme( 1 ) )
            draw.RoundedBox( 8, 2, 2, w-4, h-4, CAVEADVENTURE.FUNC.GetTheme( 2, 100+alpha ) )

            if( IsValid( self2.button ) ) then
                CAVEADVENTURE.FUNC.DrawClickCircle( self2.button, w, h, CAVEADVENTURE.FUNC.GetTheme( 3, 50 ), 8 )
            end
        end

        local vendorSlot = i
        if( not optionCfg.Items[vendorSlot] ) then continue end

        local itemKey, cost, amount = optionCfg.Items[vendorSlot][1], optionCfg.Items[vendorSlot][2], optionCfg.Items[vendorSlot][3]

        local itemConfig = CAVEADVENTURE.CONFIG.Items[itemKey]
        if( not itemConfig ) then continue end

        local slotSize = self.slotH-4-10

        slot.item = vgui.Create( "caveadventure_item", slot )
        slot.item:SetSize( slotSize, slotSize )
        slot.item:SetPos( (slot:GetTall()/2)-(slotSize/2), (slot:GetTall()/2)-(slotSize/2) )
        slot.item:SetItemInfo( itemKey, amount )

        local rarityConfig = CAVEADVENTURE.CONFIG.Rarities[itemConfig.Rarity]

        local info = vgui.Create( "DPanel", slot )
        info:Dock( TOP )
        info:SetTall( 40 )
        info:DockMargin( self.slotH, 12, 0, 0 )
        info.Paint = function( self2, w, h )
            draw.SimpleText( itemConfig.Name, "MontserratBold20", 0, 0, CAVEADVENTURE.FUNC.GetTheme( 4, 125 ) )
            draw.SimpleText( rarityConfig[2], "MontserratMedium17", 0, 17, rarityConfig[3] )
        end

        local moneyBack = vgui.Create( "caveadventure_money", slot )
        moneyBack:Dock( BOTTOM )
        moneyBack:SetTall( 18 )
        moneyBack:DockMargin( self.slotH, 0, 10, 7 )

        local moneyPanel = vgui.Create( "caveadventure_money", moneyBack )
        moneyPanel:Dock( RIGHT )
        moneyPanel:SetMoneyAmount( cost, true )

        slot.button = vgui.Create( "DButton", slot )
        slot.button:SetSize( slot:GetSize() )
        slot.button:SetText( "" )
        slot.button.Paint = function( self2, w, h ) end
        slot.button.DoClick = function()
            CAVEADVENTURE.FUNC.DermaQuery( "Are you sure you want to purchase this?", "VENDOR", "Confirm", function() 
                if( LocalPlayer():GetMoney() >= cost ) then
                    net.Start( "CaveAdventure.RequestVendorPurchase" )
                        net.WriteString( configKey )
                        net.WriteUInt( vendorSlot, 8 )
                    net.SendToServer()
                else
                    CAVEADVENTURE.FUNC.DermaMessage( "You cannot afford to buy this!", "VENDOR" )
                end
            end, "Cancel" )
        end
    end
end

vgui.Register( "caveadventure_vendor", PANEL, "caveadventure_frame" )