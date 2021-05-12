local player_meta = FindMetaTable( "Player" )

-- GENERAL FUNCTIONS --
util.AddNetworkString( "CaveAdventure.SendUserID" )
function player_meta:SetUserID( userID )
    self.CAVEADVENTURE_USERID = userID

    net.Start( "CaveAdventure.SendUserID" )
        net.WriteUInt( userID, 10 )
    net.Send( self )
end

util.AddNetworkString( "CaveAdventure.SendChatNotification" )
function player_meta:SendChatNotification( tagColor, tagString, msgColor, msgString )
    local whiteColor = Color( 255, 255, 255 )
	net.Start( "CaveAdventure.SendChatNotification" )
		net.WriteColor( tagColor or whiteColor )
		net.WriteString( tagString or "" )
		net.WriteColor( msgColor or whiteColor )
		net.WriteString( msgString or "" )
	net.Send( self )
end

util.AddNetworkString( "CaveAdventure.SendSoundEffect" )
function player_meta:SendSoundEffect( soundEffect )
	net.Start( "CaveAdventure.SendSoundEffect" )
		net.WriteString( soundEffect )
	net.Send( self )
end

function player_meta:TeleportToSpawn()
    self:AddTeleportTransition()
    self:SetPos( Vector( 0, 0, -3000 ) )
    self:SetEyeAngles( Angle( 0, 90, 0 ) )
end

util.AddNetworkString( "CaveAdventure.SendTeleportTransition" )
function player_meta:AddTeleportTransition()
    self:Freeze( true )
    
    local endTime = CurTime()+CAVEADVENTURE.DEVCONFIG.TransitionTime
    timer.Simple( endTime-CurTime(), function()
        if( not IsValid( self ) ) then return end
        self:Freeze( false )
    end )

    net.Start( "CaveAdventure.SendTeleportTransition" )
        net.WriteUInt( endTime, 32 )
    net.Send( self )
end

-- CAVE FUNCTIONS --
function player_meta:TeleportToCave( caveKey )
    local cave = CAVEADVENTURE.TEMP.Caves[caveKey]
    if( not cave ) then return end

    self:SetPos( cave.StartPos+Vector( 0, 0, 10 ) )
    self:SetEyeAngles( Angle( 0, 90, 0 ) )
end

util.AddNetworkString( "CaveAdventure.SendActiveCave" )
function player_meta:SetActiveCave( caveKey )
    self.CAVEADVENTURE_ACTIVECAVE = caveKey

    net.Start( "CaveAdventure.SendActiveCave" )
        net.WriteBool( caveKey != nil )
        if( caveKey ) then 
            net.WriteUInt( caveKey, 4 ) 
        end
    net.Send( self )
end

util.AddNetworkString( "CaveAdventure.SendJoinCave" )
function player_meta:AddToCave( caveKey )
    local cave = CAVEADVENTURE.TEMP.Caves[caveKey]
    if( not cave ) then return end

    self:SetActiveCave( caveKey )

    net.Start( "CaveAdventure.SendJoinCave" )
        net.WriteUInt( caveKey, 4 )
    net.Send( self )

    self:AddTeleportTransition()
    self:TeleportToCave( caveKey )
end

function player_meta:RemoveFromCave( caveKey )
    self:SetActiveCave( nil )

    self:TeleportToSpawn()
end

-- MONEY FUNCTIONS --
util.AddNetworkString( "CaveAdventure.SendMoney" )
function player_meta:SetMoney( money )
    money = math.max( 0, money )
    
    self.CAVEADVENTURE_MONEY = money

    net.Start( "CaveAdventure.SendMoney" )
        net.WriteUInt( money, 32 )
    net.Send( self )

    CAVEADVENTURE.FUNC.SQLQuery( "UPDATE caveadventure_players SET money = " .. money .. " WHERE userID = '" .. self:GetUserID() .. "';" )
end

function player_meta:AddMoney( amount )
    self:SetMoney( self:GetMoney()+amount )
end

function player_meta:TakeMoney( amount )
    self:SetMoney( self:GetMoney()-amount )
end

-- INVENTORY FUNCTIONS --
util.AddNetworkString( "CaveAdventure.SendInventory" )
function player_meta:SetInventory( inventory )
    self.CAVEADVENTURE_INVENTORY = inventory
    self:SendInventoryItems( table.GetKeys( inventory ) )
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

function player_meta:SaveInventorySlotsToDB( slots )
    local userID = self:GetUserID()
    local inventory = self:GetInventory()

    for k, slot in ipairs( slots ) do
        local item = inventory[slot]
        if( item ) then
            CAVEADVENTURE.FUNC.SQLQuery( "SELECT * FROM caveadventure_inventory WHERE userID = '" .. userID .. "' AND slot = '" .. slot .. "';", function( data )
                if( data ) then 
                    CAVEADVENTURE.FUNC.SQLQuery( "UPDATE caveadventure_inventory SET item = '" .. item[1] .. "', amount = " .. item[2] .. " WHERE userID = '" .. userID .. "' AND slot = '" .. slot .. "';" )
                else
                    CAVEADVENTURE.FUNC.SQLQuery( "INSERT INTO caveadventure_inventory( userID, slot, item, amount ) VALUES(" .. userID .. "," .. slot .. ",'" .. item[1] .. "'," .. item[2] .. ");" )
                end
            end, true )
        else
            CAVEADVENTURE.FUNC.SQLQuery( "DELETE FROM caveadventure_inventory WHERE userID = '" .. userID .. "' AND slot = '" .. slot .. "';" )
        end
    end
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
    self:SaveInventorySlotsToDB( slotsChanged )
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