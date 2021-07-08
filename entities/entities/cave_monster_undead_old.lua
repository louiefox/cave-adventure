AddCSLuaFile()

ENT.Base 			= "cave_monster_undead"
DEFINE_BASECLASS( "cave_monster_undead" )

function ENT:Initialize()
	BaseClass.Initialize( self )
	
	self:SetModel( "models/Zombie/Classic.mdl" )

	self.PassiveSound = table.Random( { "npc/zombie/moan_loop1.wav", "npc/zombie/moan_loop2.wav", "npc/zombie/moan_loop3.wav", "npc/zombie/moan_loop4.wav" } )
	self:EmitSound( self.PassiveSound, 50 )

	self.AlertSound = table.Random( { "npc/zombie/zombie_alert1.wav", "npc/zombie/zombie_alert2.wav", "npc/zombie/zombie_alert3.wav" } )
	self.DeathSound = table.Random( { "npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav" } )
	self.MeleeSound = "npc/zombie/zombie_hit.wav"
	self.MeleeDamage = { 5, 10 }
	self.SpeedMultiplier = 0.1
end