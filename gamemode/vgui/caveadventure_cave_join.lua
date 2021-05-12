local PANEL = {}

function PANEL:Init()
    self:SetSize( 0, 0 )
end

function PANEL:SetCaveKey( caveKey )
    local caveCfg = CAVEADVENTURE.CONFIG.Caves[caveKey]
    if( not caveCfg ) then 
        self:Remove()
        return
    end

    self.caveKey = caveKey

    surface.SetFont( "MontserratBold70" )
    local headerX, headerY = surface.GetTextSize( caveCfg.Name )

    surface.SetFont( "MontserratBold50" )
    local subHeaderX, subHeaderY = surface.GetTextSize( "Level " .. caveCfg.Level )

    local targetW, targetH = math.max( headerX, subHeaderX ), headerY+subHeaderY

    self:SetTall( targetH )
    self:SizeTo( targetW, targetH, 0.2 )

    timer.Simple( 2, function()
        if( not IsValid( self ) ) then return end

        self:SizeTo( 0, targetH, 0.2, 0, -1, function()
            self:Remove()
        end )
    end )

    surface.PlaySound( "cave_adventure/cave_start.wav" )
end

function PANEL:OnSizeChanged( w, h )
    self:SetPos( (ScrW()/2)-(w/2), ScrH()*0.25-(h/2) )
end

function PANEL:Paint( w, h )
    local caveCfg = CAVEADVENTURE.CONFIG.Caves[self.caveKey]
    if( not caveCfg ) then return end

    draw.SimpleTextOutlined( caveCfg.Name, "MontserratBold70", w/2, 0, CAVEADVENTURE.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, 0, 2, CAVEADVENTURE.FUNC.GetTheme( 1 ) )
    draw.SimpleTextOutlined( "Level " .. caveCfg.Level, "MontserratBold50", w/2, h, CAVEADVENTURE.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, CAVEADVENTURE.FUNC.GetTheme( 1 ) )
end

vgui.Register( "caveadventure_cave_join", PANEL, "DPanel" )