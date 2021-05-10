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

function ENT:Use( ply )
	if( not ply:IsPlayer() ) then return end

	local configTable = CAVEADVENTURE.CONFIG.NPCs[self:GetConfigKey() or ""]
	if( not configTable or not configTable.Options ) then return end

	if( table.Count( configTable.Options ) > 1 ) then

	else
		local optionType = table.GetKeys( configTable.Options )[1]

		local optionTypeCfg = CAVEADVENTURE.DEVCONFIG.NPCs[optionType]
		optionTypeCfg.UseFunction( configTable, configTable.Options[optionType] )
	end
end

function ENT:OnTakeDamage( dmgInfo )
	return 0
end