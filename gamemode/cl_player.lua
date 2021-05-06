-- GENERAL FUNCTIONS --
net.Receive( "CaveAdventure.SendUserID", function()
    CAVEADVENTURE_USERID = net.ReadUInt( 10 )
end )

-- INVENTORY FUNCTIONS --
net.Receive( "CaveAdventure.SendInventory", function()
    CAVEADVENTURE_INVENTORY = net.ReadTable() or {}

    hook.Run( "CaveAdventure.Hooks.InventoryUpdated" )
end )

net.Receive( "CaveAdventure.SendInventoryItems", function()
    CAVEADVENTURE_INVENTORY = CAVEADVENTURE_INVENTORY or {}

    local amount = net.ReadUInt( 10 )
    for i = 1, amount do
        local slotKey, itemKey, itemAmount = net.ReadUInt( 8 ), net.ReadString(), net.ReadUInt( 32 )
        if( itemAmount > 0 ) then
            CAVEADVENTURE_INVENTORY[slotKey] = { itemKey, itemAmount }
        else
            CAVEADVENTURE_INVENTORY[slotKey] = nil
        end
    end

    hook.Run( "CaveAdventure.Hooks.InventoryUpdated" )
end )