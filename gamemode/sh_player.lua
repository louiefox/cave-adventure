local player_meta = FindMetaTable( "Player" )

-- GENERAL FUNCTIONS --
function player_meta:GetUserID()
	if( CLIENT and self == LocalPlayer() ) then
		return CAVEADVENTURE_USERID or 0
	else
		return self.CAVEADVENTURE_USERID or 0
	end
end

-- MONEY FUNCTIONS --
function player_meta:GetMoney()
	return (CLIENT and CAVEADVENTURE_MONEY or self.CAVEADVENTURE_MONEY) or 0
end

-- INVENTORY FUNCTIONS --
function player_meta:GetInventory()
	return (CLIENT and CAVEADVENTURE_INVENTORY or self.CAVEADVENTURE_INVENTORY) or {}
end

function player_meta:GetInvSlots()
    return 30
end