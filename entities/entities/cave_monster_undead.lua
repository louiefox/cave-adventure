AddCSLuaFile()

ENT.Base 			= "base_nextbot"

function ENT:Initialize()
	self.IsMonster = true

    self.SpawnZoneRadius = 400000
    self.SpawnPos = self:GetPos()
    self.AttackDistance = 8000
	self.SpeedMultiplier = 1

	self.AttackAnimTime = 0.2
	self.AttackDelay = 2

	self:SetModel( "models/Zombie/Classic.mdl" )

	self.PassiveSound = table.Random( { "npc/zombie/moan_loop1.wav", "npc/zombie/moan_loop2.wav", "npc/zombie/moan_loop3.wav", "npc/zombie/moan_loop4.wav" } )
	self:EmitSound( self.PassiveSound, 50 )

	self.AlertSound = table.Random( { "npc/zombie/zombie_alert1.wav", "npc/zombie/zombie_alert2.wav", "npc/zombie/zombie_alert3.wav" } )
	self.DeathSound = table.Random( { "npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav" } )
	self.MeleeSound = "npc/zombie/zombie_hit.wav"
	self.MeleeDamage = { 5, 10 }

	if( CLIENT ) then
		CAVEADVENTURE.TEMP.Monsters[self] = true
	end
end

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "MaxHealth" )
	self:NetworkVar( "String", 0, "MonsterClass" )
end

function ENT:SetInitMonsterClass( monsterClass )
	local monsterConfig = CAVEADVENTURE.CONFIG.Monsters[monsterClass]
	if( not monsterConfig ) then
		self:Remove()
		return
	end

	self:SetMonsterClass( monsterClass )
	self:SetMaxHealth( monsterConfig.Health or 100 )
	self:SetHealth( self:GetMaxHealth() )
end

function ENT:SetCavePlayers( players )
	self.Players = players
end

function ENT:SetEnemy( ent )
	self.Enemy = ent
end

function ENT:GetEnemy()
	return self.Enemy
end

function ENT:HaveEnemy()
	local enemy = self:GetEnemy()

	if( not enemy or not IsValid( enemy ) or not enemy:IsPlayer() or not enemy:Alive() ) then return false end
	if( self.SpawnPos:DistToSqr( enemy:GetPos() ) > self.SpawnZoneRadius ) then return false end

	return true
end

function ENT:FindEnemy()
	for k,v in ipairs( self.Players or {} ) do
		if( not v:Alive() or self.SpawnPos:DistToSqr( v:GetPos() ) > self.SpawnZoneRadius ) then continue end

		self:SetEnemy( v )
		self:EmitSound( self.AlertSound or "" )
		return true
	end	

	self:SetEnemy( nil )
	return false
end

function ENT:EnemyIsInFront()
	local isInFront = false
	for k, v in ipairs( ents.FindInCone( self:GetPos(), self:GetForward()*200, 100, 45 ) ) do
		if( v == self:GetEnemy() ) then
			return true
		end
	end

	return false
end

function ENT:CanAttackEnemy()
	return self:GetPos():DistToSqr( self:GetEnemy():GetPos() ) <= self.AttackDistance and self:EnemyIsInFront()
end

function ENT:RunBehaviour()
	while( true ) do
		if( self:HaveEnemy() or self:FindEnemy() ) then
			if( self:GetPos():DistToSqr( self:GetEnemy():GetPos() ) <= self.AttackDistance ) then
				if( self:EnemyIsInFront() ) then
					if( not self.AttackStarted and CurTime() >= (self.LastAttack or 0)+self.AttackDelay ) then
						self.AttackStarted = true
						self.LastAttack = CurTime()

						self:StartActivity( ACT_MELEE_ATTACK1 )

						local startTime = CurTime()
						timer.Simple( self.AttackAnimTime, function()
							if( not IsValid( self ) ) then return end

							self.AttackStarted = false
							
							self:StartActivity( ACT_IDLE )

							if( not IsValid( self:GetEnemy() ) or not self:CanAttackEnemy() ) then return end
							self:GetEnemy():TakeDamage( (self.MeleeDamage and math.random( self.MeleeDamage[1], self.MeleeDamage[2] )) or 10, self, self )
							self:EmitSound( self.MeleeSound or "npc/zombie/zombie_hit.wav" )
						end )
					end
				else
					self.loco:FaceTowards( self:GetEnemy():GetPos() )
				end
			else
				self.loco:FaceTowards( self:GetEnemy():GetPos() )
				self:StartActivity( self.HasRunAct and ACT_RUN or ACT_WALK )
				self.loco:SetDesiredSpeed( 100*self.SpeedMultiplier )
				self.loco:SetAcceleration( 350 )
				self:ChaseEnemy()
				self.loco:SetAcceleration( 200 )
				self:StartActivity( ACT_IDLE )
			end

			coroutine.wait( 0.1 )
		else
			if( self:GetPos():DistToSqr( self.SpawnPos ) > 1000 ) then
				self:StartActivity( ACT_WALK )
				self.loco:SetDesiredSpeed( 100*self.SpeedMultiplier )

				self:MoveToPos( self.SpawnPos )
				
				self:StartActivity( ACT_IDLE )
			end

			coroutine.wait( 1 )
		end
	end
end	

function ENT:ChaseEnemy( options )
	local options = options or {}
	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	path:Compute( self, self:GetEnemy():GetPos() )

	if( !path:IsValid() ) then return "failed" end

	while( path:IsValid() and self:HaveEnemy() and not self:CanAttackEnemy() ) do
	
		if ( path:GetAge() > 0.1 ) then
			path:Compute(self, self:GetEnemy():GetPos())
		end
		path:Update( self )
		
		if ( options.draw ) then path:Draw() end

		if ( self.loco:IsStuck() ) then
			self:HandleStuck()
			return "stuck"
		end

		coroutine.yield()

	end

	return "ok"
end

function ENT:OnRemove()
	self:StopSound( self.PassiveSound or "" )
end

function ENT:OnKilled( dmginfo )
	hook.Call( "OnNPCKilled", GAMEMODE, self, dmginfo:GetAttacker(), dmginfo:GetInflictor() )

	self:EmitSound( self.DeathSound or "" )
	self:StopSound( self.PassiveSound or "" )
	self:Remove()
end

function ENT:OnTakeDamage( dmginfo )
	self.LastDamage = CurTime()
end

function ENT:Think()
	if( self:Health() < self:GetMaxHealth() and CurTime() >= (self.LastDamage or 0)+30 ) then
		self:SetHealth( self:GetMaxHealth() )
	end
end