-- CAVE CONFIG --
CAVEADVENTURE.CONFIG.Caves = {
    [1] = {
        Name = "Starter Cave",
        Level = 1,
        Size = 3,
        MaxPlayers = 3,
        StartPos = Vector( 0, 0, -1728 ),
        PortalPos = Vector( 200, -450, -2950 ),
        PortalParticle = "[8]magic_portal*",
        Rooms = {
            {
                Count = 7,
                ChestRarities = {
                    ["common"] = 80,
                    ["uncommon"] = 20
                },
                Layouts = {
                    {
                        Monsters = {
                            { "undead", Vector( 0, 0, 10 ) },
                            { "undead_mage", Vector( 50, 0, 10 ) },
                            { "undead_mage", Vector( -50, 0, 10 ) }
                        }
                    },
                    {
                        Monsters = {
                            { "undead_scout", Vector( -20, 0, 10 ) },
                            { "undead_scout", Vector( 20, 0, 10 ) }
                        }
                    },
                    {
                        Monsters = {
                            { "undead", Vector( -40, 0, 10 ) },
                            { "undead", Vector( 0, 0, 10 ) },
                            { "undead", Vector( 40, 0, 10 ) }
                        }
                    }
                }
            },
            {
                Count = 1,
                ChestRarities = {
                    ["uncommon"] = 80,
                    ["rare"] = 20
                },
                Layouts = {
                    {
                        Monsters = {
                            { "undead_mage", Vector( 0, 0, 10 ) },
                            { "undead_mage", Vector( 50, 0, 10 ) },
                            { "undead_mage", Vector( -50, 0, 10 ) }
                        }
                    }
                }
            }
        }
    },
    [2] = {
        Name = "Storm Cave",
        Level = 10,
        Size = 5,
        StartPos = Vector( 0, 0, -1328 ),
        PortalPos = Vector( 0, -450, -2950 ),
        PortalParticle = "[8]magic_portal"
    },
    [3] = {
        Name = "Deathly Cave",
        Level = 20,
        Size = 7,
        StartPos = Vector( 0, 0, -828 ),
        PortalPos = Vector( -200, -450, -2930 ),
        PortalParticle = "[8]red_vortex"
    }
}