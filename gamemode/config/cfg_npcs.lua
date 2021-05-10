-- NPC CONFIG --
CAVEADVENTURE.CONFIG.NPCs = {
    ["vendor_potions"] = {
        Name = "Potion Vendor",
        Position = Vector( 490, 0, -3007 ),
        Angles = Angle( 0, -180, 0 ),
        Options = {
            ["vendor"] = {
                Items = { 
                    ["potion_health_l"] = { 1500, 1 },
                    ["potion_health_m"] = { 375, 1 },
                    ["potion_health_s"] = { 150, 4 },
                    ["potion_mana_l"] = { 1500, 1 },
                    ["potion_mana_m"] = { 375, 1 },
                    ["potion_mana_s"] = { 150, 4 }
                }
            }
        }
    },
    ["vendor_food"] = {
        Name = "Food Vendor",
        Position = Vector( 490, 97, -3007 ),
        Angles = Angle( 0, -180, 0 )
    },
}