if CLIENT then
	SWEP.PrintName = "Magic Wand"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true
end

SWEP.WorldModel = Model( "models/cave_adventure/magicwand/w_magicwand.mdl" )
SWEP.ViewModel = Model( "models/cave_adventure/magicwand/c_magicwand.mdl" )

SWEP.UseHands = true

SWEP.Sound = Sound("physics/wood/wood_box_impact_hard3.wav")

SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = 1
SWEP.Primary.Delay = 1
SWEP.Primary.Ammo = ""

function SWEP:Initialize()
	self:SetHoldType( "melee" )
end

function SWEP:SetupDataTables()
	self:NetworkVar( "Int", 0, "Spell" )
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire( CurTime()+self.Primary.Delay )
    self:SendWeaponAnim( ACT_VM_PRIMARYATTACK_1 )

    if( CLIENT ) then return end

    local ply = self.Owner

    local shootPos = ply:GetShootPos()
    local trace = ply:GetEyeTrace()

    if( shootPos:DistToSqr( trace.HitPos ) < 5000 ) then return end

    local fireball = ents.Create( "caveadventure_fireball" )
    fireball:SetParticleEffect( "[9]colorful_trail_1" )
    fireball:SetStartPos( shootPos )
    fireball:SetTargetPos( trace.HitPos )
    fireball:SetDirection( trace.Normal )
    fireball:SetAttacker( ply )
    fireball:SetInflictor( self )
    fireball:Spawn()

    ply:SendSoundEffect( "cave_adventure/spell_colorful.wav" )
end

function SWEP:SecondaryAttack()

end