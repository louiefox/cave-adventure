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
AddSharedFile( "config/cfg_monsters.lua" )

AddSharedFile( "sh_player.lua" )

function GM:Initialize()

end