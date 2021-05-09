util.AddNetworkString( "CaveAdventure.RequestMoveInv" )
net.Receive( "CaveAdventure.RequestMoveInv", function( len, ply )
    local receiverSlot = net.ReadUInt( 8 )
    local dropperSlot = net.ReadUInt( 8 )
    if( not receiverSlot or not dropperSlot ) then return end

    local maxSlots = ply:GetInvSlots()
    if( receiverSlot == dropperSlot or receiverSlot > maxSlots or dropperSlot > maxSlots or receiverSlot < 1 or receiverSlot < 1 ) then return end
    
    local inventory = ply:GetInventory()

    local dropItem = inventory[dropperSlot]
    if( not dropItem ) then return end

    local receiveItem = inventory[receiverSlot]
    if( not receiveItem ) then
        inventory[receiverSlot] = dropItem
        inventory[dropperSlot] = nil
    elseif( receiveItem[1] == dropItem[1] ) then
        local maxStack = CAVEADVENTURE.FUNC.GetMaxStack( receiveItem[1] )

        local newAmount = math.Clamp( receiveItem[2]+dropItem[2], 1, maxStack )
        local amountLeft = dropItem[2]-(newAmount-receiveItem[2])
        inventory[receiverSlot][2] = newAmount

        if( amountLeft > 0 ) then
            inventory[dropperSlot][2] = amountLeft
        else
            inventory[dropperSlot] = nil
        end
    else
        inventory[receiverSlot] = dropItem
        inventory[dropperSlot] = receiveItem
    end

    ply.CAVEADVENTURE_INVENTORY = inventory
    ply:SendInventoryItems( { receiverSlot, dropperSlot } )
end )

util.AddNetworkString( "CaveAdventure.RequestDeleteInv" )
net.Receive( "CaveAdventure.RequestDeleteInv", function( len, ply )
    local slot = net.ReadUInt( 8 )
    if( not slot ) then return end
    
    local inventory = ply:GetInventory()
    if( not inventory[slot] ) then return end

    inventory[slot] = nil

    ply.CAVEADVENTURE_INVENTORY = inventory
    ply:SendInventoryItems( { slot } )
end )