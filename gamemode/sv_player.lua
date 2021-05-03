local player_meta = FindMetaTable( "Player" )

function player_meta:TeleportToSpawn()
    self:SetPos( CAVE.GRID.StartPos+Vector( 0, 0, 10 ) )
    self:SetEyeAngles( Angle( 0, 90, 0 ) )
end