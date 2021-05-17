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

function CAVEADVENTURE.FUNC.FormatMoneyText( money )
    local gold, silver, copper = CAVEADVENTURE.FUNC.GetMoneyTable( money )
    local coins = {
        { gold, "Gold" },
        { silver, "Silver" },
        { copper, "Copper" }
    }

    local moneyString = ""
    for k, v in ipairs( coins ) do
        if( v[1] <= 0 ) then continue end

        if( moneyString == "" ) then
            moneyString = v[1] .. " " .. v[2]
        else
            moneyString = moneyString .. ", " .. v[1] .. " " .. v[2]
        end
    end

    return moneyString
end

function CAVEADVENTURE.FUNC.GetRandomRarity( rarityCfg )
    local randomNum = math.random( 0, 100 )
    local previousChance = 0

    for k, v in pairs( rarityCfg ) do
        if( randomNum <= previousChance+v ) then return k end
        previousChance = previousChance+v
    end
end