AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
	self:SetModel( "" )
	self:DrawShadow( false )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
end

function ENT:SetRewardPlayers( players )
	self.RewardPlayers = players
end

util.AddNetworkString( "CaveAdventure.Net.RequestChestLoot" )
net.Receive( "CaveAdventure.Net.RequestChestLoot", function( len, ply )
	local ent = net.ReadEntity()
	if( not IsValid( ent ) or ply:GetPos():DistToSqr( ent:GetPos() ) > 22500 ) then return end

	if( not (ent.RewardPlayers or {})[ply] ) then return end

	ent.RewardPlayers[ply] = nil

	if( table.Count( ent.RewardPlayers ) <= 0 ) then
		ent:Remove()
	end
end )