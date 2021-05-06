concommand.Add( "caveadventure_additem", function( ply, cmd, args )
    if( not args[1] or not args[2] ) then return end
    ply:AddInventoryItems( args[1], tonumber( args[2] ) or 1 )
end )