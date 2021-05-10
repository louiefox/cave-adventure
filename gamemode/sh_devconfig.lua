CAVEADVENTURE.DEVCONFIG = {}

-- NPC TYPES --
CAVEADVENTURE.DEVCONFIG.NPCs = {
    ["vendor"] = {
        UseFunction = function( configKey )
            CAVEADVENTURE.FUNC.OpenInventory()
            CAVEADVENTURE.FUNC.OpenVendor( configKey )
        end
    }
}