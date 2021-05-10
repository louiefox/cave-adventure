util.AddNetworkString( "CaveAdventure.RequestVendorPurchase" )
net.Receive( "CaveAdventure.RequestVendorPurchase", function( len, ply )
    local configKey = net.ReadString()
    local vendorSlot = net.ReadUInt( 8 )

    if( not configKey or not vendorSlot ) then return end

    local npcCfg = CAVEADVENTURE.CONFIG.NPCs[configKey]
    if( not npcCfg or not npcCfg.Options ) then return end

    local optionCfg = npcCfg.Options["vendor"]
    if( not optionCfg ) then return end

    local itemData = optionCfg.Items[vendorSlot]
    if( not itemData ) then return end

    local itemKey, cost, amount = itemData[1], itemData[2], itemData[3]

    local itemCfg = CAVEADVENTURE.CONFIG.Items[itemKey]
    if( not itemCfg ) then return end
    
    if( itemCfg.SellPrice > cost ) then
        ply:SendChatNotification( Color( 255, 0, 0 ), "[DEV ERROR]", Color( 255, 255, 255 ), "Sell price is greater than cost. Details: '" .. itemKey .. "' from '" .. configKey .. "'." )
        return
    end

    if( ply:GetMoney() < cost ) then return end

    ply:TakeMoney( cost )
    ply:AddInventoryItems( itemKey, amount )

    ply:SendChatNotification( Color( 50, 255, 50 ), "[VENDOR]", Color( 255, 255, 255 ), "Purchased x" .. amount .. " " .. itemCfg.Name .. " from " .. npcCfg.Name .. " for " .. CAVEADVENTURE.FUNC.FormatMoneyText( cost ) .. "." )
    ply:SendSoundEffect( "cave_adventure/vendor_buy.wav" )
end )

util.AddNetworkString( "CaveAdventure.RequestVendorSell" )
net.Receive( "CaveAdventure.RequestVendorSell", function( len, ply )
    local slot = net.ReadUInt( 8 )
    if( not slot ) then return end
    
    local inventory = ply:GetInventory()
    if( not inventory[slot] ) then return end

    local itemKey, amount = inventory[slot][1], inventory[slot][2]

    local itemCfg = CAVEADVENTURE.CONFIG.Items[itemKey]
    if( not itemCfg ) then return end

    local sellMoney = amount*(itemCfg.SellPrice)
    ply:AddMoney( sellMoney )

    ply:SendChatNotification( Color( 50, 255, 50 ), "[VENDOR]", Color( 255, 255, 255 ), "Sold x" .. amount .. " " .. itemCfg.Name .. " for " .. CAVEADVENTURE.FUNC.FormatMoneyText( sellMoney ) .. "." )
    ply:SendSoundEffect( "cave_adventure/vendor_sell.wav" )

    inventory[slot] = nil

    ply.CAVEADVENTURE_INVENTORY = inventory
    ply:SendInventoryItems( { slot } )
    ply:SaveInventorySlotsToDB( { slot } )
end )