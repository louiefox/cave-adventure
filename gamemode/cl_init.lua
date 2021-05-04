-- SHARED LOAD --
include( "shared.lua" )

-- CLIENT LOAD --
include( "cl_drawing.lua" )
include( "cl_fonts.lua" )
include( "cl_monsters.lua" )

-- VGUI LOAD --
for k, v in pairs( file.Find( GM.FolderName .. "/gamemode/vgui/*.lua", "LUA" ) ) do
	include( "vgui/" .. v )
end