local PANEL = {}

function PANEL:Init()
    self:SetHeader( "BACKPACK" )

    self.top = vgui.Create( "DPanel", self )
    self.top:Dock( TOP )
    self.top:SetTall( 30 )
    self.top:DockMargin( 10, 10, 10, 0 )
    self.top.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, CAVEADVENTURE.FUNC.GetTheme( 2 ) )
        draw.RoundedBox( 8, 1, 1, w-2, h-2, CAVEADVENTURE.FUNC.GetTheme( 1 ) )
        draw.RoundedBox( 8, 1, 1, w-2, h-2, CAVEADVENTURE.FUNC.GetTheme( 2, 100 ) )
    end

    local moneyPanel = vgui.Create( "caveadventure_money", self.top )
    moneyPanel:Dock( RIGHT )
    moneyPanel:DockMargin( 0, 0, 10, 0 )
    moneyPanel:SetMoneyAmount( LocalPlayer():GetMoney() )

    hook.Add( "CaveAdventure.Hooks.MoneyUpdated", self, function()
        moneyPanel:SetMoneyAmount( LocalPlayer():GetMoney() )
    end )

    self.slotSpacing = 5

    self.grid = vgui.Create( "DIconLayout", self )
    self.grid:Dock( FILL )
    self.grid:DockMargin( 10, 10, 10, 10 )
    self.grid:SetSpaceX( self.slotSpacing )
    self.grid:SetSpaceY( self.slotSpacing )

    self:SetStartCenter( ScrW()*0.75, ScrH()*0.75 )
    self:SetTargetSize( ScrW()*0.15, 0 )

    self:RefreshSlots()
    self:RefreshItems()

    hook.Add( "CaveAdventure.Hooks.InventoryUpdated", self, self.RefreshItems )
    hook.Add( "CaveAdventure.Hooks.VendorToggled", self, self.UpdateCursor )

    self:Open()

    self.screenPanel = vgui.Create( "DPanel" )
    self.screenPanel:SetSize( ScrW(), ScrH() )
    self.screenPanel:SetZPos( -1000 )
    self.screenPanel.Paint = function() end
    self.screenPanel:Receiver( "CaveAdventure.Item.Inventory", function( self2, panels, dropped )
        local panel = panels[1]
        if( not dropped or not IsValid( panel ) ) then return end

        local dropperSlot = panel.slotKey
        if( not dropperSlot ) then return end

        CAVEADVENTURE.FUNC.DermaQuery( "Are you sure you want to DELETE this item?", "INVENTORY", "Confirm", function() 
            net.Start( "CaveAdventure.RequestDeleteInv" )
                net.WriteUInt( dropperSlot, 8 )
            net.SendToServer()
        end, "Cancel" )
    end )

    self.onClose = function()
        if( not CAVEADVENTURE.TEMP.RemoveOnClose ) then
            self.screenPanel:SetVisible( false )
        else
            self.screenPanel:Remove()
        end
    end
    self.onOpen = function()
        if( IsValid( self.screenPanel ) ) then
            self.screenPanel:SetVisible( true )
        end
    end
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
        slot:Receiver( "CaveAdventure.Item.Inventory", function( self2, panels, dropped )
            local panel = panels[1]
            if( not dropped or not IsValid( panel ) ) then return end

            local dropperSlot = panel.slotKey
            if( dropperSlot == i ) then return end

            net.Start( "CaveAdventure.RequestMoveInv" )
                net.WriteUInt( i, 8 )
                net.WriteUInt( dropperSlot, 8 )
            net.SendToServer()
        end )

        self.slotPanels[i] = slot
    end

    self:SetTargetSize( ScrW()*0.15, 10+self.top:GetTall()+20+(math.ceil( slotCount/slotsWide )*(slotSize+self.slotSpacing))-self.slotSpacing )
end

local gradientMat = Material( "cave_adventure/gradient_box.png" )
function PANEL:RefreshItems()
    local inventory = LocalPlayer():GetInventory()
    for k, v in ipairs( self.slotPanels ) do
        v:Clear()

        local item = inventory[k]
        if( not item ) then continue end

        local itemKey, amount = item[1], item[2]

        local infoPanel = vgui.Create( "caveadventure_item", v )
        infoPanel:Dock( FILL )
        infoPanel:SetItemInfo( itemKey, amount )
        infoPanel.OnCursorEntered = function( self2 )
            if( not IsValid( self2.tooltip ) ) then
                self2.tooltip = vgui.Create( "caveadventure_item_tooltip" )
                self2.tooltip:SetItemInfo( itemKey, amount )
                local x, y = self2:LocalToScreen( 0, 0 )
                self2.tooltip:SetPos( x+v:GetWide()+10, y+(v:GetTall()/2)-(self2.tooltip:GetTall()/2) )
                self2.tooltip.Think = function( self3 )
                    if( not IsValid( self2 ) or not self2:IsHovered() ) then
                        self3:Remove()
                    end
                end
            end
        end
        infoPanel.OnCursorExited = function( self2 )
            if( IsValid( self2.tooltip ) ) then
                self2.tooltip:Remove()
            end
        end
        infoPanel:Droppable( "CaveAdventure.Item.Inventory" )
        infoPanel.slotKey = k
        infoPanel.DoRightClick = function()
            if( IsValid( CAVEADVENTURE.TEMP.VendorMenu ) and CAVEADVENTURE.TEMP.VendorMenu:IsVisible() ) then
                net.Start( "CaveAdventure.RequestVendorSell" )
                    net.WriteUInt( k, 8 )
                net.SendToServer()
            end
        end

        v.infoPanel = infoPanel
    end

    self:UpdateCursor()
end

function PANEL:UpdateCursor()
    local cursor, customCursor = "hand"
    if( IsValid( CAVEADVENTURE.TEMP.VendorMenu ) and CAVEADVENTURE.TEMP.VendorMenu:IsVisible() ) then
        cursor, customCursor = "blank", Material( "cave_adventure/icons/cursor_sell.png" )
    end

    for k, v in ipairs( self.slotPanels ) do
        if( not IsValid( v.infoPanel ) ) then continue end
        v.infoPanel:SetCursor( cursor )
        v.infoPanel.customCursor = customCursor
    end
end

vgui.Register( "caveadventure_inventory", PANEL, "caveadventure_frame" )