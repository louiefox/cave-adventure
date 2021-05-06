local player_meta = FindMetaTable( "Player" )

-- GENERAL FUNCTIONS --
util.AddNetworkString( "CaveAdventure.SendUserID" )
function player_meta:SetUserID( userID )
    self.CAVEADVENTURE_USERID = userID

    net.Start( "CaveAdventure.SendUserID" )
        net.WriteUInt( userID, 10 )
    net.Send( self )
end

function player_meta:TeleportToSpawn()
    self:SetPos( CAVE.GRID.StartPos+Vector( 0, 0, 10 ) )
    self:SetEyeAngles( Angle( 0, 90, 0 ) )
end

-- INVENTORY FUNCTIONS --
util.AddNetworkString( "CaveAdventure.SendInventory" )
function player_meta:SetInventory( inventory )
    self.CAVEADVENTURE_INVENTORY = inventory

    net.Start( "CaveAdventure.SendInventory" )
        net.WriteTable( inventory )
    net.Send( self )
end

util.AddNetworkString( "CaveAdventure.SendInventoryItems" )
function player_meta:SendInventoryItems( slotsChanged )
    local inventory = self:GetInventory()

    net.Start( "CaveAdventure.SendInventoryItems" )
        net.WriteUInt( table.Count( slotsChanged ), 10 )
        for k, v in pairs( slotsChanged ) do
            local item = inventory[v]
            net.WriteUInt( v, 8 )
            net.WriteBool( (item and true) or false )

            if( not item ) then continue end
            net.WriteString( item[1] )
            net.WriteUInt( item[2], 32 )
        end
    net.Send( self )
end

function player_meta:AddInventoryItems( ... )
    local vargs = { ... }

    local itemToGive = {}
    local inventory = self:GetInventory()
    for k, v in ipairs( vargs ) do
        if( k % 2 == 0 or not CAVEADVENTURE.CONFIG.Items[v] ) then continue end

        itemToGive[v] = vargs[k+1] or 1
    end

    if( table.Count( itemToGive ) < 1 ) then return end

    local slotsChanged = {}
    local slotCount = self:GetInvSlots()
    for k, v in pairs( itemToGive ) do
        local maxStack = CAVEADVENTURE.FUNC.GetMaxStack( k )
        local amountLeft = v
        for key, val in pairs( inventory ) do
            if( val[1] != k or val[2] >= maxStack ) then continue end

            local amount = math.Clamp( amountLeft, 1, maxStack-val[2] )
            inventory[key] = { k, val[2]+amount }
            table.insert( slotsChanged, key )

            amountLeft = amountLeft-amount
            if( amountLeft < 1 ) then break end
        end

        if( amountLeft > 0 ) then
            for i = 1, slotCount do
                if( inventory[i] ) then continue end

                inventory[i] = { k, math.Clamp( amountLeft, 1, maxStack ) }
                table.insert( slotsChanged, i )

                amountLeft = amountLeft-maxStack
                if( amountLeft < 1 ) then break end
            end
        end
    end

    self.CAVEADVENTURE_INVENTORY = inventory
    self:SendInventoryItems( slotsChanged )
end

-- function player_meta:TakeInventoryItems( ... )
--     local itemsToTake = { ... }

--     local itemsTaken = {}
--     local inventory = self:GetInventory()
--     for k, v in ipairs( itemsToTake ) do
--         if( k % 2 == 0 or not CAVEADVENTURE.CONFIG.Items[v] ) then continue end

--         local newAmount = (inventory[v] or 0)-(itemsToTake[k+1] or 1)

--         if( newAmount > 0 ) then
--             inventory[v] = newAmount
--         else
--             inventory[v] = nil
--         end

--         if( newAmount > 0 ) then
--             --CAVEADVENTURE.FUNC.SQLQuery( "INSERT OR REPLACE INTO botched_inventory( userID, itemKey, amount ) VALUES(" .. self:GetUserID() .. ", '" .. v .. "'," .. newAmount .. ");" )
--         else
--             --CAVEADVENTURE.FUNC.SQLQuery( "DELETE FROM botched_inventory WHERE userID = '" .. self:GetUserID() .. "' AND itemKey = '" .. v .. "';" )
--         end

--         itemsTaken[v] = newAmount
--     end

--     if( table.Count( itemsTaken ) < 1 ) then return end

--     self.CAVEADVENTURE_INVENTORY = inventory
--     self:SendInventoryItems( itemsTaken )
-- end