local PANEL = {}

function PANEL:Init()
    self:SetSize( ScrW(), ScrH() )
    self:MakePopup()
    self:SetAlpha( 0 )
    self:AlphaTo( 255, 0.2 )

    self.frame = vgui.Create( "caveadventure_frame", self )
    self.frame.closeFunc = function() self:Close() end

    self.initFinished = true
end

function PANEL:SetHeader( header )
    self.frame:SetHeader( header )
end

function PANEL:SetTargetSize( w, h )
    self.frame:SetTargetSize( w, h )
end

function PANEL:SetStartCenter( x, y )
    self.frame:SetStartCenter( x, y )
end

function PANEL:Open()
    self.frame:Open()
end

function PANEL:Close()
    self.frame:Close()

    self:AlphaTo( 0, 0.2, 0, function() 
        local oldX, oldY = input.GetCursorPos()

        self:Remove() 

        timer.Simple( 0, function() input.SetCursorPos( oldX, oldY ) end )
    end )
end

function PANEL:OnChildAdded( panel )
    if( not self.initFinished ) then return end
    panel:SetParent( self.frame )
end

function PANEL:Paint( w, h )
    CAVEADVENTURE.FUNC.DrawBlur( self, 4, 4 )
end

vgui.Register( "caveadventure_popup_base", PANEL, "EditablePanel" )