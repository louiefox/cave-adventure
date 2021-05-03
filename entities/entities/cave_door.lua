AddCSLuaFile()

ENT.Base = "base_gmodentity"

function ENT:Initialize()
	if ( SERVER ) then
		self:SetModel( "models/hunter/plates/plate3x4.mdl" )
		self:SetMaterial( "models/props_pipes/GutterMetal01a" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
	end
end

function ENT:Use()
	if( self.Used ) then return end
	self.Used = true

	local room = self.room
	local wallKey = self.wallKey

	local axis = ((wallKey == 1 or wallKey == 3) and "X") or ((wallKey == 2 or wallKey == 4) and "Y")
	local change = ((wallKey == 2 or wallKey == 3) and 1) or -1

	local x, y = room.x+(axis == "X" and change or 0), room.y+(axis == "Y" and change or 0)
	local newRoom = CAVE.GRID:AddRoom( x, y )
	newRoom:AddDoorWay( (wallKey+2 > 4 and (wallKey+2)-4) or wallKey+2, true )
	newRoom:Generate()

	CAVE.GRID:ConnectRooms( room.x, room.y, x, y )

	self:Remove()
end