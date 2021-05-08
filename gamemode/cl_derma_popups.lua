function CAVEADVENTURE.FUNC.DermaMessage( text, title, buttonText, buttonFunc )
    buttonText = buttonText or "Continue"
    title = title or "MESSAGE"

	local popup = vgui.Create( "caveadventure_popup_base" )
	popup:SetHeader( title )

    surface.SetFont( "MontserratMedium20" )
    local popupW = math.max( ScrW()*0.15, surface.GetTextSize( text )+30 )

	local textArea = vgui.Create( "DPanel", popup )
	textArea:Dock( TOP )
	textArea:DockMargin( 10, 25, 10, 0 )
	textArea:SetTall( 30 )
	textArea.Paint = function( self2, w, h ) 
		draw.SimpleText( text, "MontserratMedium20", w/2, h/2, CAVEADVENTURE.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

    local bottomButton = vgui.Create( "caveadventure_button", popup )
    bottomButton:Dock( TOP )
    bottomButton:DockMargin( 10, 25, 10, 0 )
    bottomButton:SetTall( 40 )
    bottomButton:SetButtonText( buttonText )
    bottomButton.DoClick = function()
		if( buttonFunc ) then buttonFunc() end
		popup:Close()
    end

	popup:SetTargetSize( popupW, 25+textArea:GetTall()+25+bottomButton:GetTall()+10 )
    popup:SetStartCenter( ScrW()/2, ScrH()/2 )
    popup:Open()
end

function CAVEADVENTURE.FUNC.DermaQuery( text, title, ... )
    local buttonsToCreate = { ... }

	local popup = vgui.Create( "caveadventure_popup_base" )
	popup:SetHeader( title )

    surface.SetFont( "MontserratMedium20" )
	local popupW = math.max( ScrW()*0.15, surface.GetTextSize( text )+30 )

	local textArea = vgui.Create( "DPanel", popup )
	textArea:Dock( TOP )
	textArea:DockMargin( 10, 25, 10, 0 )
	textArea:SetTall( 30 )
	textArea.Paint = function( self2, w, h ) 
		draw.SimpleText( text, "MontserratMedium20", w/2, h/2, CAVEADVENTURE.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

    local buttonBack = vgui.Create( "DPanel", popup )
	buttonBack:Dock( TOP )
	buttonBack:DockMargin( 10, 25, 10, 0 )
	buttonBack:SetTall( 40 )
	buttonBack.Paint = function() end

    local buttons = {}
    local function createButton( text, func )
        local button = vgui.Create( "caveadventure_button", buttonBack )
        button:Dock( LEFT )
        button:DockMargin( 0, 0, 10, 0 )
        button:SetButtonText( text )
        button.DoClick = function()
            if( func ) then func() end
            popup:Close()
        end

        table.insert( buttons, button )

        for k, v in ipairs( buttons ) do
            v:SetWide( (popupW-20-((#buttons-1)*10))/#buttons )
        end
    end

    for k, v in ipairs( buttonsToCreate ) do
        if( k % 2 == 0 ) then continue end

        createButton( v, buttonsToCreate[k+1] )
    end

    popup:SetTargetSize( popupW, 25+textArea:GetTall()+25+buttonBack:GetTall()+10 )
    popup:SetStartCenter( ScrW()/2, ScrH()/2 )
    popup:Open()
end

function CAVEADVENTURE.FUNC.DermaStringRequest( text, title, default, confirmText, confirmFunc, cancelText, cancelFunc )
    default = default or ""
    confirmText = confirmText or "OK"
    cancelText = cancelText or "Cancel"
    title = title or "REQUEST"

	local popup = vgui.Create( "caveadventure_popup_base" )
	popup:SetHeader( title )

    surface.SetFont( "MontserratMedium20" )
	local popupW = math.max( ScrW()*0.15, surface.GetTextSize( text )+30 )

	local textArea = vgui.Create( "DPanel", popup )
	textArea:Dock( TOP )
	textArea:DockMargin( 10, 25, 10, 0 )
	textArea:SetTall( 30 )
	textArea.Paint = function( self2, w, h ) 
		draw.SimpleText( text, "MontserratMedium20", w/2, h/2, CAVEADVENTURE.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

    local textEntry = vgui.Create( "caveadventure_textentry", popup )
	textEntry:Dock( TOP )
	textEntry:DockMargin( 10, 10, 10, 0 )
	textEntry:SetTall( 40 )
	textEntry:SetValue( default )

    local buttonBack = vgui.Create( "DPanel", popup )
	buttonBack:Dock( TOP )
	buttonBack:DockMargin( 10, 10, 10, 10 )
	buttonBack:SetTall( 40 )
	buttonBack.Paint = function() end

    local buttons = {}
    local function createButton( text, func )
        local button = vgui.Create( "caveadventure_button", buttonBack )
        button:Dock( LEFT )
        button:DockMargin( 0, 0, 10, 0 )
        button:SetButtonText( text )
        button.DoClick = function()
            if( func ) then func( textEntry:GetValue() ) end
            popup:Close()
        end

        table.insert( buttons, button )

        for k, v in ipairs( buttons ) do
            v:SetWide( (popupW-20-((#buttons-1)*10))/#buttons )
        end
    end

    createButton( confirmText, confirmFunc )
    createButton( cancelText, cancelFunc )

    popup:SetTargetSize( popupW, 25+textArea:GetTall()+10+textEntry:GetTall()+10+buttonBack:GetTall()+10 )
    popup:SetStartCenter( ScrW()/2, ScrH()/2 )
    popup:Open()
end

function CAVEADVENTURE.FUNC.DermaNumberRequest( text, title, default, confirmText, confirmFunc, cancelText, cancelFunc )
    default = default or 0
    confirmText = confirmText or "OK"
    cancelText = cancelText or "Cancel"
    title = title or "REQUEST"

	local popup = vgui.Create( "caveadventure_popup_base" )
	popup:SetHeader( title )

    surface.SetFont( "MontserratMedium20" )
	local popupW = math.max( ScrW()*0.15, surface.GetTextSize( text )+30 )

	local textArea = vgui.Create( "DPanel", popup )
	textArea:Dock( TOP )
	textArea:DockMargin( 10, 25, 10, 0 )
	textArea:SetTall( 30 )
	textArea.Paint = function( self2, w, h ) 
		draw.SimpleText( text, "MontserratMedium20", w/2, h/2, CAVEADVENTURE.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

    local numberWang = vgui.Create( "caveadventure_numberwang", popup )
	numberWang:Dock( TOP )
	numberWang:DockMargin( 10, 10, 10, 0 )
	numberWang:SetTall( 40 )
	numberWang:SetValue( default )

    local buttonBack = vgui.Create( "DPanel", popup )
	buttonBack:Dock( TOP )
	buttonBack:DockMargin( 10, 10, 10, 10 )
	buttonBack:SetTall( 40 )
	buttonBack.Paint = function() end

    local buttons = {}
    local function createButton( text, func )
        local button = vgui.Create( "caveadventure_button", buttonBack )
        button:Dock( LEFT )
        button:DockMargin( 0, 0, 10, 0 )
        button:SetButtonText( text )
        button.DoClick = function()
            if( func ) then
                func( numberWang:GetValue() )
            end
            
            popup:Close()
        end

        table.insert( buttons, button )

        for k, v in ipairs( buttons ) do
            v:SetWide( (popupW-20-((#buttons-1)*10))/#buttons )
        end
    end

    createButton( confirmText, confirmFunc )
    createButton( cancelText, cancelFunc )

    popup:SetTargetSize( popupW, 25+textArea:GetTall()+10+numberWang:GetTall()+10+buttonBack:GetTall()+10 )
    popup:SetStartCenter( ScrW()/2, ScrH()/2 )
    popup:Open()
end

function CAVEADVENTURE.FUNC.DermaComboRequest( text, title, options, default, searchSelect, confirmText, confirmFunc, cancelText, cancelFunc )
    default = default or ""
    confirmText = confirmText or "OK"
    cancelText = cancelText or "Cancel"
    title = title or "REQUEST"

	local popup = vgui.Create( "caveadventure_popup_base" )
	popup:SetHeader( title )

    surface.SetFont( "MontserratMedium20" )
	local popupW = math.max( ScrW()*0.15, surface.GetTextSize( text )+30 )

	local textArea = vgui.Create( "DPanel", popup )
	textArea:Dock( TOP )
	textArea:DockMargin( 10, 25, 10, 0 )
	textArea:SetTall( 30 )
	textArea.Paint = function( self2, w, h ) 
		draw.SimpleText( text, "MontserratMedium20", w/2, h/2, CAVEADVENTURE.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

    local comboEntry = vgui.Create( searchSelect and "caveadventure_combosearch" or "caveadventure_combo", popup )
	comboEntry:Dock( TOP )
	comboEntry:DockMargin( 10, 10, 10, 0 )
	comboEntry:SetTall( 40 )
	comboEntry:SetValue( "Select Option" )
	for k, v in pairs( options ) do
		comboEntry:AddChoice( v, k, default == k or default == v )
	end

    local buttonBack = vgui.Create( "DPanel", popup )
	buttonBack:Dock( TOP )
	buttonBack:DockMargin( 10, 10, 10, 10 )
	buttonBack:SetTall( 40 )
	buttonBack.Paint = function() end

    local buttons = {}
    local function createButton( text, func )
        local button = vgui.Create( "caveadventure_button", buttonBack )
        button:Dock( LEFT )
        button:DockMargin( 0, 0, 10, 0 )
        button:SetButtonText( text )
        button.DoClick = function()
            if( func ) then
                func()
            end
            
            popup:Close()
        end

        table.insert( buttons, button )

        for k, v in ipairs( buttons ) do
            v:SetWide( (popupW-20-((#buttons-1)*10))/#buttons )
        end
    end

    createButton( confirmText, function()
        local value, data = comboEntry:GetSelected()
		if( value and data ) then
            if( confirmFunc ) then confirmFunc( value, data ) end
		else
			notification.AddLegacy( "You need to select a value!", 1, 3 )
		end
    end )
    createButton( cancelText, cancelFunc )

    popup:SetTargetSize( popupW, 25+textArea:GetTall()+10+comboEntry:GetTall()+10+buttonBack:GetTall()+10 )
    popup:SetStartCenter( ScrW()/2, ScrH()/2 )
    popup:Open()
end

function CAVEADVENTURE.FUNC.DermaProgressBar( title, textFunc, percentFunc, cancelFunc )
	local popup = vgui.Create( "caveadventure_popup_base" )
	popup:SetHeader( title )

    surface.SetFont( "MontserratMedium20" )

    local textArea = vgui.Create( "DPanel", popup )
	textArea:Dock( TOP )
	textArea:DockMargin( 10, 25, 10, 20 )
	textArea:SetTall( select( 2, surface.GetTextSize( textFunc() ) ) )
	textArea.Paint = function( self2, w, h ) 
		draw.SimpleText( textFunc(), "MontserratMedium20", w/2, h/2, CAVEADVENTURE.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	local progressArea = vgui.Create( "DPanel", popup )
	progressArea:Dock( TOP )
	progressArea:DockMargin( 10, 0, 10, 0 )
	progressArea:SetTall( 40 )
	progressArea.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, CAVEADVENTURE.FUNC.GetTheme( 2, 100 ) )

        local percent = math.Clamp( percentFunc(), 0, 1 )
        CAVEADVENTURE.FUNC.DrawRoundedMask( 8, 0, 0, w, h, function()
            surface.SetDrawColor( CAVEADVENTURE.FUNC.GetTheme( 3, 100 ) )
            surface.DrawRect( 0, 0, w*percent, h )
        end )

		draw.SimpleText( math.floor( percent*100 ) .. "%", "MontserratBold25", w/2, h/2-1, CAVEADVENTURE.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

    if( cancelFunc ) then
        local bottomButton = vgui.Create( "caveadventure_button", popup )
        bottomButton:Dock( TOP )
        bottomButton:DockMargin( 10, 10, 10, 10 )
        bottomButton:SetTall( 40 )
        bottomButton:SetButtonText( "Cancel" )
        bottomButton.DoClick = function()
            popup:Close()
        end

        popup:SetTargetSize( ScrW()*0.15, 25+textArea:GetTall()+20+progressArea:GetTall()+10+bottomButton:GetTall()+10 )
    else
        popup:SetTargetSize( ScrW()*0.15, 25+textArea:GetTall()+20+progressArea:GetTall()+10 )
    end

    popup:SetStartCenter( ScrW()/2, ScrH()/2 )
    popup:Open()

    return popup
end