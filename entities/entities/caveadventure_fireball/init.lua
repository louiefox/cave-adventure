AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
	self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_FLY )
	self:SetSolid( SOLID_VPHYSICS )

	timer.Simple( 30, function()
		if( not IsValid( self ) ) then return end
		self:Remove()
	end )

	self:SetPos( self.StartPos+(self.Direction*50) )
	self:SetVelocity( self.Direction*200 )
end

function ENT:Think()
	if( not self.Direction ) then return end

	self:SetVelocity( self.Direction*200 )
end

function ENT:SetStartPos( pos )
	self.StartPos = pos
end

function ENT:SetTargetPos( pos )
	self.TargetPos = pos
end

function ENT:SetDirection( direction )
	self.Direction = direction
end

function ENT:SetSpeed( speed )
	self.Speed = speed
end

function ENT:SetAttacker( attacker )
	self.Attacker = attacker
end

function ENT:SetInflictor( inflictor )
	self.Inflictor = inflictor
end

util.AddNetworkString( "CaveAdventure.Net.SendFireballHit" )
function ENT:Touch( ent )
	if( ent:IsPlayer() ) then return end

	net.Start( "CaveAdventure.Net.SendFireballHit" )
		net.WriteEntity( self )
		net.WriteBool( ent.IsMonster )
	net.Broadcast()

	if( ent.IsMonster ) then
		ent:TakeDamage( 25, self.Attacker, self.Inflictor )
	end

	self:EmitSound( "ambient/explosions/explode_4.wav", 65 )
	self:Remove()
end