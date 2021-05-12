local PANEL = {}

function PANEL:Init()
    self:SetSize( 0, 0 )
end

function PANEL:SetInfo( caveKey, deleteTime )
    local caveCfg = CAVEADVENTURE.CONFIG.Caves[caveKey]
    if( not caveCfg ) then 
        self:Remove()
        return
    end

    self.caveKey = caveKey
    self.deleteTime = deleteTime

    surface.SetFont( "MontserratBold70" )
    local headerX, headerY = surface.GetTextSize( "Completed - " .. caveCfg.Name )

    surface.SetFont( "MontserratBold50" )
    local subHeaderX, subHeaderY = surface.GetTextSize( "Teleporting in 60.1s" )

    local targetW, targetH = math.max( headerX, subHeaderX ), headerY+subHeaderY

    self:SetTall( targetH )
    self:SizeTo( targetW, targetH, 0.2 )

    surface.PlaySound( "cave_adventure/cave_start.wav" )
end

function PANEL:OnSizeChanged( w, h )
    self:SetPos( (ScrW()/2)-(w/2), ScrH()*0.25-(h/2) )
end

function PANEL:Think()
    if( not self.removing and self.caveKey and (LocalPlayer():GetActiveCave() or 0) != self.caveKey ) then
        self.removing = true
        self:SizeTo( 0, targetH, 0.2, 0, -1, function()
            self:Remove()
        end )
    end
end

function PANEL:Paint( w, h )
    local caveCfg = CAVEADVENTURE.CONFIG.Caves[self.caveKey]
    if( not caveCfg ) then return end

    draw.SimpleTextOutlined( "Completed - " .. caveCfg.Name, "MontserratBold70", w/2, 0, CAVEADVENTURE.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, 0, 2, CAVEADVENTURE.FUNC.GetTheme( 1 ) )
    draw.SimpleTextOutlined( "Teleporting in " .. math.max( 0, math.Round( self.deleteTime-CurTime(), 1 ) ) .. "s", "MontserratBold50", w/2, h, CAVEADVENTURE.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, CAVEADVENTURE.FUNC.GetTheme( 1 ) )
end

vgui.Register( "caveadventure_cave_completed", PANEL, "DPanel" )