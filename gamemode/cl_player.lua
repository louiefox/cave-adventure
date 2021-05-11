-- GENERAL FUNCTIONS --
net.Receive( "CaveAdventure.SendUserID", function()
    CAVEADVENTURE_USERID = net.ReadUInt( 10 )
end )

net.Receive( "CaveAdventure.SendChatNotification", function()
    chat.AddText( net.ReadColor(), net.ReadString(), " ", net.ReadColor(), net.ReadString() )
end )

net.Receive( "CaveAdventure.SendSoundEffect", function()
    surface.PlaySound( net.ReadString() )
end )

-- CAVE FUNCTIONS --
net.Receive( "CaveAdventure.SendActiveCave", function()
    CAVEADVENTURE_ACTIVECAVE = net.ReadUInt( 4 )
end )

-- MONEY FUNCTIONS --
net.Receive( "CaveAdventure.SendMoney", function()
    CAVEADVENTURE_MONEY = net.ReadUInt( 32 ) or 0

    hook.Run( "CaveAdventure.Hooks.MoneyUpdated" )
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
        local slotKey, hasItem = net.ReadUInt( 8 ), net.ReadBool()

        if( hasItem ) then
            CAVEADVENTURE_INVENTORY[slotKey] = { net.ReadString(), net.ReadUInt( 32 ) }
        else
            CAVEADVENTURE_INVENTORY[slotKey] = nil
        end
    end

    hook.Run( "CaveAdventure.Hooks.InventoryUpdated" )
end )