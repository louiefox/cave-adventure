local PANEL = {}

function PANEL:Init()
    self:SetHeader( "BACKPACK" )

    self.slotSpacing = 5

    self.grid = vgui.Create( "DIconLayout", self )
    self.grid:Dock( FILL )
    self.grid:DockMargin( 10, 10, 10, 10 )
    self.grid:SetSpaceX( self.slotSpacing )
    self.grid:SetSpaceY( self.slotSpacing )

    self:SetTargetSize( ScrW()*0.15, 0 )

    self:RefreshSlots()
    self:RefreshItems()

    hook.Add( "CaveAdventure.Hooks.InventoryUpdated", self, self.RefreshItems )

    self:SetStartCenter( ScrW()*0.75, ScrH()*0.75 )
    self:Open()
end

function PANEL:RefreshSlots()
    self.grid:Clear()

    local slotCount = LocalPlayer():GetInvSlots()

    local slotsWide = 5
    local slotSize = (self:GetWide()-20-((slotsWide-1)*self.slotSpacing))/slotsWide

    self.slotPanels = {}
    for i = 1, slotCount  do
        local slot = vgui.Create( "DPanel", self.grid )
        slot:SetSize( slotSize, slotSize )
        slot.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, CAVEADVENTURE.FUNC.GetTheme( 2, 100 ) )
        end

        self.slotPanels[i] = slot
    end

    self:SetTargetSize( ScrW()*0.15, self.headerSize+20+(math.ceil( slotCount/slotsWide )*(slotSize+self.slotSpacing))-self.slotSpacing )
end

local gradientMat = Material( "cave_adventure/gradient_box.png" )
function PANEL:RefreshItems()
    local inventory = LocalPlayer():GetInventory()
    for k, v in ipairs( self.slotPanels ) do
        v:Clear()

        local item = inventory[k]
        if( not item ) then continue end

        local itemKey, amount = item[1], item[2]
        local itemConfig = CAVEADVENTURE.CONFIG.Items[itemKey]
        local rarityConfig = CAVEADVENTURE.CONFIG.Rarities[itemConfig.Rarity]

        local infoPanel = vgui.Create( "DPanel", v )
        infoPanel:Dock( FILL )
        infoPanel.iconMat = itemConfig.Icon
        infoPanel.Paint = function( self2, w, h )
            CAVEADVENTURE.FUNC.DrawRoundedMask( 8, 0, 0, w, h, function()
                surface.SetDrawColor( rarityConfig[4] )
                surface.SetMaterial( gradientMat )
                surface.DrawTexturedRect( 0, 0, w, h )
            end )

            if( self2.iconMat ) then
                surface.SetDrawColor( 255, 255, 255 )
                surface.SetMaterial( self2.iconMat )
                local iconSize = w*0.7
                surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
            end

            draw.SimpleTextOutlined( amount, "MontserratBold25", w-5, h, CAVEADVENTURE.FUNC.GetTheme( 4 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, CAVEADVENTURE.FUNC.GetTheme( 1 ) )	
        end
    end
end

vgui.Register( "caveadventure_inventory", PANEL, "caveadventure_frame" )