GM.Name = "Cave Adventure"
GM.Author = "Brickwall"
GM.Email = "N/A"
GM.Website = "brickwall.dev"
GM.Developers = {
    ["76561198070943403"] = true
}

CAVEADVENTURE = {
    FUNC = {},
    CONFIG = {},
    TEMP = (CAVEADVENTURE and CAVEADVENTURE.TEMP) or {}
}

local function AddSharedFile( filePath )
	AddCSLuaFile( filePath )
	include( filePath )
end

AddSharedFile( "config/cfg_main.lua" )
AddSharedFile( "config/cfg_caves.lua" )
AddSharedFile( "config/cfg_items.lua" )
AddSharedFile( "config/cfg_monsters.lua" )
AddSharedFile( "config/cfg_npcs.lua" )

AddSharedFile( "sh_player.lua" )
AddSharedFile( "sh_devconfig.lua" )

function GM:Initialize()

end

function CAVEADVENTURE.FUNC.GetMaxStack( itemKey )
    return 10
end

function CAVEADVENTURE.FUNC.GetMoneyTable( money )
    local gold = math.floor( money/10000 )
    money = money-gold*10000

    local silver = math.floor( money/100 )
    money = money-silver*100

    return gold, silver, money
end