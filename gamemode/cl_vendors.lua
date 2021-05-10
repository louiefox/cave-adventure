function CAVEADVENTURE.FUNC.OpenVendor( configKey )
    if( IsValid( CAVEADVENTURE.TEMP.VendorMenu ) ) then
        if( not CAVEADVENTURE.TEMP.VendorMenu:IsVisible() ) then
            CAVEADVENTURE.TEMP.VendorMenu:Open()
            CAVEADVENTURE.TEMP.VendorMenu:SetConfigKey( configKey )
        end
    else
        CAVEADVENTURE.TEMP.VendorMenu = vgui.Create( "caveadventure_vendor" )
        CAVEADVENTURE.TEMP.VendorMenu:SetConfigKey( configKey )
    end
end