util.AddNetworkString( "CaveAdventure.RequestVendorPurchase" )
net.Receive( "CaveAdventure.RequestVendorPurchase", function( len, ply )
    local configKey = net.ReadString()
    local vendorSlot = net.ReadUInt( 8 )

    if( not configKey or not vendorSlot ) then return end

    local npcCfg = CAVEADVENTURE.CONFIG.NPCs[configKey]
    if( not npcCfg or not npcCfg.Options ) then return end

    local optionCfg = npcCfg.Options["vendor"]
    if( not optionCfg ) then return end

    local itemCfg = optionCfg.Items[vendorSlot]
    if( not itemCfg ) then return end

    if( ply:GetMoney() < itemCfg[2] ) then return end

    ply:TakeMoney( itemCfg[2] )
    ply:AddInventoryItems( itemCfg[1], itemCfg[3] )

    ply:SendChatNotification( Color( 255, 50, 50 ), "[VENDOR] ", Color( 255, 255, 255 ), "Purchased x" .. itemCfg[3] .. " " .. CAVEADVENTURE.CONFIG.Items[itemCfg[1]].Name .. " from " .. npcCfg.Name .. " for " .. CAVEADVENTURE.FUNC.FormatMoneyText( itemCfg[2] ) .. "." )
end )