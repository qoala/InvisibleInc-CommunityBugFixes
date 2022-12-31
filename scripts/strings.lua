local MOD_STRINGS = {
    OPTIONS = {
        GENERALFIXES = "GENERAL BUG FIXES",
        GENERALFIXES_TIP = "<c:FF8411>GENERAL BUG FIXES</c>\nFixes for bugs that players don't usually need to tweak. See the mod description for a full list.\nIf this and other options are all disabled, only crash/softlock and UI fixes are applied.",

        ESCORTS_ITEMS = "ESCORTS FIXED - RETURN ESCORT-OWNED ITEMS",
        ESCORTS_ITEMS_TIP = "<c:FF8411>RETURN ESCORT-OWNED ITEMS</c>\nRemoves the option to permanently take items from temporary agents.",

        MISSIONDETCENTER_SPAWNAGENT = "DETENTION CENTER MISSIONS - AGENT/PRISONER CHANCE",
        MISSIONDETCENTER_SPAWNAGENT_TIP = "<c:FF8411>DETENTION CENTER MISSIONS - AGENT/PRISONER CHANCE</c>\nThe mission specifies 50-50 odds of an agent unless the player recently \"found a prisoner\". However, it sets this flag after any mission that didn't have a rescuable agent, even if it wasn't a detention center.\nIn all of the below options, if a detention center has a generic prisoner, the next detention center is guaranteed to have an agent\nIn order from most to least appearance of agents.\nALWAYS: An agent always appears, until the agency is full.\nVANILLA: If the previous mission wasn't a detention center, an agent is guaranteed to appear.\nGUARANTEED FIRST AGENT: Guarantees an agent in the first detention center of the campaign, as most players expect. Afterwards, like 50-50.\n50-50: Even odds of Agent/Prisoner, unless the most recent detention center had a generic prisoner.",
        MISSIONDETCENTER_SPAWNAGENT_ALWAYS = "ALWAYS",
        MISSIONDETCENTER_SPAWNAGENT_VANILLA = "VANILLA",
        MISSIONDETCENTER_SPAWNAGENT_FIRSTAGENT = "GUARANTEED FIRST AGENT",
        MISSIONDETCENTER_SPAWNAGENT_FIFTYFIFTY = "50-50",

        HOLOWALLSOUNDS = "HOLOPROJECTOR SOUND THROUGH WALLS",
        HOLOWALLSOUNDS_TIP = "<c:FF8411>HOLOPROJECTOR SOUND THROUGH WALLS</c>\nLike other sounds, the 1-tile-radius hum produced by an active holoprojector travels through walls. Unlike most other sounds, it immediately alerts guards, presumably because close inspection reveals the hologram's nature. This change affects how guards react to holoprojector sounds when walls entirely block them from the source.\nALERT (VANILLA): Guards are alerted when they hear a holoprojector through walls.\nNOTICED: Guards investigate when they hear a holoprojector through walls.\nIGNORED: Guards ignore holoprojector sounds through walls.",
        HOLOWALLSOUNDS_VANILLA = "ALERT (VANILLA)",
        HOLOWALLSOUNDS_NOTICE = "NOTICED",
        HOLOWALLSOUNDS_IGNORE = "IGNORED",
    },
}

return MOD_STRINGS
