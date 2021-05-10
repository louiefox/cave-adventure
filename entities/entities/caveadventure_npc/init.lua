AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
	self:SetModel( "models/breen.mdl" )

	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_BBOX )
	self:SetCollisionGroup( COLLISION_GROUP_PLAYER )

	self:SetUseType( SIMPLE_USE )
end

function ENT:ConfigKeyChanged( name, old, configKey )
	local configTable = CAVEADVENTURE.CONFIG.NPCs[configKey]
	if( configTable and configTable.Model ) then
		self:SetModel( configTable.Model )
	else
		self:SetModel( "models/breen.mdl" )
	end
end

util.AddNetworkString( "CaveAdventure.SendUseNPC" )
function ENT:Use( ply )
	if( not ply:IsPlayer() or (ply.CAVEADVENTURE_NPC_COOLDOWN or 0) > CurTime() ) then return end
	ply.CAVEADVENTURE_NPC_COOLDOWN = CurTime()+1

	local configKey = self:GetConfigKey() or ""
	local configTable = CAVEADVENTURE.CONFIG.NPCs[configKey]
	if( not configTable or not configTable.Options ) then return end

	net.Start( "CaveAdventure.SendUseNPC" )
		net.WriteString( configKey )
	net.Send( ply )
end

function ENT:OnTakeDamage( dmgInfo )
	return 0
end