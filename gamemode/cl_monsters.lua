local displayDistance = 1000000
local healthLerps = {}

CAVEADVENTURE.TEMP.Monsters = CAVEADVENTURE.TEMP.Monsters or {}

hook.Add( "HUDPaint", "CaveAdventure.HUDPaint.Monsters", function()
    local ply = LocalPlayer()
    local scrW, scrH = ScrW(), ScrH()

    local sortedMonsters = {}
    for k, v in pairs( CAVEADVENTURE.TEMP.Monsters ) do
        if( not IsValid( k ) or not k.IsMonster ) then
            CAVEADVENTURE.TEMP.Monsters[k] = nil
            healthLerps[k] = nil
            continue
        end

        local distance = ply:GetPos():DistToSqr( k:GetPos() )
		if( distance < displayDistance ) then
            table.insert( sortedMonsters, { k, distance } )
		end
    end

    table.SortByMember( sortedMonsters, 2 )

    for k, v in pairs( sortedMonsters ) do
        local ent = v[1]
        local monsterConfig = CAVEADVENTURE.CONFIG.Monsters[ent:GetMonsterClass()] or {}

        local pos = ent:GetPos()
        pos.z = pos.z+ent:OBBMaxs().z

        local pos2d = pos:ToScreen()

        if( not healthLerps[ent] ) then
            healthLerps[ent] = ent:Health()
        end

        local maxHealth = ent:GetMaxHealth() or 100
        local health = math.Clamp( ent:Health() or maxHealth, 0, maxHealth )
        healthLerps[ent] = Lerp( RealFrameTime()*2, healthLerps[ent], health )

        local boxW, boxH = scrW*0.1, 30

        surface.SetDrawColor( CAVEADVENTURE.FUNC.GetTheme( 1 ) )
        surface.DrawRect( pos2d.x-(boxW/2), pos2d.y-boxH, boxW, boxH )

        local barPadding = 2
        local barW = boxW-(2*barPadding)

        surface.SetDrawColor( 255, 100, 100 )
        surface.DrawRect( pos2d.x-(barW/2), pos2d.y-boxH+barPadding, math.Clamp( barW*(healthLerps[ent]/maxHealth), 0, barW ), boxH-(2*barPadding) )

        surface.SetDrawColor( 224, 61, 61 )
        surface.DrawRect( pos2d.x-(barW/2), pos2d.y-boxH+barPadding, math.Clamp( barW*(health/maxHealth), 0, barW ), boxH-(2*barPadding) )

        local healthText = (health >= 1000 and math.Round( health/1000, 1 ) .. "K") or health
        draw.SimpleText( healthText, "MontserratBold25", pos2d.x+1, pos2d.y-2-(boxH/2)+1, CAVEADVENTURE.FUNC.GetTheme( 1 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        draw.SimpleText( healthText, "MontserratBold25", pos2d.x, pos2d.y-2-(boxH/2), CAVEADVENTURE.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        local monsterText = "LVL " .. (monsterConfig.Level or 1) .. ". " .. string.upper( monsterConfig.Name or ent:GetClass() )
        draw.SimpleText( monsterText, "MontserratBold25", pos2d.x+1, pos2d.y-boxH+1, CAVEADVENTURE.FUNC.GetTheme( 1 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
        draw.SimpleText( monsterText, "MontserratBold25", pos2d.x, pos2d.y-boxH, CAVEADVENTURE.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
    end
end )