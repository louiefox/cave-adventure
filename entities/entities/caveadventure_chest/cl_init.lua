include( "shared.lua" )

function ENT:Draw()
	if( not IsValid( self.clientsideModel ) ) then
		self.clientsideModel = ClientsideModel( "models/cave_adventure/treasurechest/treasurechest.mdl" )
		return
	end

	self.clientsideModel:SetPos( self:GetPos()+Vector( 0, 0, 10 ) )
	self.clientsideModel:SetAngles( Angle( 0, CurTime()*50, 0 ) )
end

function ENT:Initialize()
	CAVEADVENTURE.TEMP.Chests[self] = true
end

function ENT:OnRemove()
	CAVEADVENTURE.TEMP.Chests[self] = nil

	if( IsValid( self.clientsideModel ) ) then
		self.clientsideModel:Remove()
	end
end

local gradientMatU, gradientMatD = Material("gui/gradient_up"), Material("gui/gradient_down")
local function GetClosestEnt()
	local ply = LocalPlayer()
	local pos = ply:GetPos()+ply:GetForward()*20

	local entTable = {}
	for k, v in pairs( ents.FindInSphere( pos, 150 ) ) do
		if( IsValid( v ) and CAVEADVENTURE.TEMP.Chests and CAVEADVENTURE.TEMP.Chests[v] ) then
			table.insert( entTable, { pos:DistToSqr( v:GetPos() ), v } )
		end
	end

	table.sort( entTable, function(a, b) return a[1] < b[1] end )

	return (entTable[1] or {})[2]
end

CAVEADVENTURE.TEMP.Chests = CAVEADVENTURE.TEMP.Chests or {}
hook.Add( "HUDPaint", "CaveAdventure.HUDPaint.Chests", function()
	local ent = GetClosestEnt()
	local clientModel = IsValid( ent ) and ent.clientsideModel

	if( IsValid( ent ) and IsValid( clientModel ) ) then
		local pos = Vector( clientModel:GetPos().x, clientModel:GetPos().y, clientModel:GetPos().z+30 )
		local pos2d = pos:ToScreen()

		local x, y = pos2d.x, pos2d.y
		local w, h = CAVEADVENTURE.FUNC.ScreenScale( 500 ), CAVEADVENTURE.FUNC.ScreenScale( 150 )
		
		local bottomH = CAVEADVENTURE.FUNC.ScreenScale( 35 )
		local mainH = h-bottomH

		surface.SetDrawColor( 0, 0, 0, 200 )
		surface.DrawRect( x-(w/2), y-h, w, h )

		local accentBorderH = 2

		local rarityCfg = CAVEADVENTURE.CONFIG.Rarities[ent:GetRarity() or "common"]
		local accent = rarityCfg[4]

		surface.SetDrawColor( accent )
		surface.DrawRect( x-(w/2), y-h, w, accentBorderH )

		surface.SetDrawColor( accent )
		surface.DrawRect( x-(w/2), y-bottomH-accentBorderH, w, accentBorderH )

		surface.SetDrawColor( accent.r, accent.g, accent.b, 50 )
		surface.SetMaterial( gradientMatD )
		surface.DrawTexturedRect( x-(w/2), y-h, w, mainH/2 )
		surface.SetMaterial( gradientMatU )
		surface.DrawTexturedRect( x-(w/2), y-bottomH-(mainH/2), w, mainH/2 )

		draw.SimpleTextOutlined( "Treasure Chest", "MontserratBold40", x-(w/2)+CAVEADVENTURE.FUNC.ScreenScale( 60 ), y-bottomH-(mainH/2), CAVEADVENTURE.FUNC.GetTheme( 4 ), 0, TEXT_ALIGN_BOTTOM, 1, CAVEADVENTURE.FUNC.GetTheme( 1 ) )
		draw.SimpleTextOutlined( rarityCfg[2], "MontserratBold25", x-(w/2)+CAVEADVENTURE.FUNC.ScreenScale( 60 ), y-bottomH-(mainH/2), rarityCfg[3], 0, 0, 1, CAVEADVENTURE.FUNC.GetTheme( 1 ) )

		draw.SimpleTextOutlined( "Press " .. string.upper( input.LookupBinding( "+use" ) ) .. " to open!", "MontserratBold25", x, y-(bottomH/2), CAVEADVENTURE.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, CAVEADVENTURE.FUNC.GetTheme( 1 ) )
	end
end )

hook.Add( "KeyPress", "CaveAdventure.KeyPress.PickupChest", function( ply, key )
	if( key == IN_USE ) then
		local ent = GetClosestEnt()
		if( not IsValid( ent ) ) then return end

		if( CurTime() < (CAVEADVENTURE_CHESTPICKUP_COOLDOWN or 0) ) then return end
		CAVEADVENTURE_CHESTPICKUP_COOLDOWN = CurTime()+0.2

		net.Start( "CaveAdventure.Net.RequestChestLoot" )
			net.WriteEntity( ent )
		net.SendToServer()
	end
end )