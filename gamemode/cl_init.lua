-- SHARED LOAD --
include( "shared.lua" )

-- CLIENT LOAD --
--include( "cl_bshadows.lua" )

-- VGUI LOAD --
for k, v in pairs( file.Find( GM.FolderName .. "/gamemode/vgui/*.lua", "LUA" ) ) do
	include( "vgui/" .. v )
end