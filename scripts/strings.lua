
local MOD_STRINGS =
{
	OPTIONS =
	{
		-- options with categories, sorted by english category name
		MISSIONDETCENTER_SPAWNAGENT = "DETENTION CENTER MISSIONS - AGENT/PRISONER CHANCE",
		MISSIONDETCENTER_SPAWNAGENT_TIP = "<c:FF8411>DETENTION CENTER MISSIONS - AGENT/PRISONER CHANCE</c>\nThe mission specifies 50-50 odds of an agent unless the player recently \"found a prisoner\". However, it sets this flag after any mission that didn't have a rescuable agent, even if it wasn't a detention center.\nIn all of the below options, if a detention center has a generic prisoner, the next detention center is guaranteed to have an agent\nVANILLA: If the previous mission wasn't a detention center, an agent is guaranteed to appear.\nGUARANTEED FIRST AGENT: Guarantees an agent in the first detention center of the campaign, as most players expect. Afterwards, like 50-50.\n50-50: Even odds of Agent/Prisoner, unless the most recent detention center had a generic prisoner.",
		MISSIONDETCENTER_SPAWNAGENT_VANILLA = "VANILLA",
		MISSIONDETCENTER_SPAWNAGENT_FIRSTAGENT = "GUARANTEED FIRST AGENT",
		MISSIONDETCENTER_SPAWNAGENT_FIFTYFIFTY = "50-50",
		MISSIONVAULT_HACKRESPONSE = "VAULT MISSIONS - SECURITY RESPONSE",
		MISSIONVAULT_HACKRESPONSE_TIP = "<c:FF8411>VAULT MISSIONS - SECURITY RESPONSE</c>\nDuring a Vault mission, the security response triggers when a device-targetted Incognita program reduces firewalls exactly to 0 on a vault device. This can be bypassed with non-programs (buster chip), area-targetted programs (data blast), or by simultaneously breaking multiple firewalls to a negative result. In all settings, experiment cases can also be bypassed by EMP.\nVANILLA: No change.\nANY-HACK: Response triggers when anything breaks all firewalls on a vault device.",
		MISSIONVAULT_HACKRESPONSE_VANILLA = "VANILLA",
		MISSIONVAULT_HACKRESPONSE_ANYHACK = "ANY-HACK",
		ENDING_REMOTEHACKING = "FINAL MISSION - FIX REMOTE HACKING",
		ENDING_REMOTEHACKING_TIP = "<c:FF8411>FINAL MISSION - FIX REMOTE HACKING</c>\nIn the OMNI Mainframe, Monst3r can perform hacking for the security hub and mainframe lock on arbitrary mainframe devices near the correct consoles. This fix forces the abilities to only appear on the intended devices.",
		NOPATROL_FIXFACING = "PREFAB STATIONARY GUARDS - FIX FACING",
		NOPATROL_FIXFACING_TIP = "<c:FF8411>PREFAB STATIONARY GUARDS - FIX FACING</c>\nAffects stationary guards placed by prefabs during level generation, such as detention center captains.\nThis makes them remember their initial facing, instead of facing arbitrary directions after being distracted.",
		NOPATROL_NOPATROLCHANGE = "PREFAB STATIONARY GUARDS - IGNORE PATROL CHANGE",
		NOPATROL_NOPATROLCHANGE_TIP = "<c:FF8411>PREFAB STATIONARY GUARDS - IGNORE PATROL CHANGE</c>\nAffects stationary guards placed by prefabs during level generation, such as detention center captains.\nThis makes them ignore signals to \"change up the guard patrols\", such as the DLC extended campaign alarm level. Notably does not apply to other guards of the same type (captain, CFO, etc.) if the prefab places them patrolling.",
		-- options without categories
		IDLE_FIXFAILEDPATROLPATH = "FIX BROKEN GUARD PATROLS",
		IDLE_FIXFAILEDPATROLPATH_TIP = "<c:FF8411>FIX BROKEN GUARD PATROLS</c>\nIf a guard fails to generate a patrol path, they can end up stationary without a remembered facing.\n\nDISABLED: Leave unchanged.\nSTATIONARY: Convert to a non-broken stationary patrol.\nREGENERATE: Generate a new patrol path with looser requirements.",
		IDLE_FIXFAILEDPATROLPATH_DISABLED = "DISABLED",
		IDLE_FIXFAILEDPATROLPATH_STATIONARY = "STATIONARY",
		IDLE_FIXFAILEDPATROLPATH_REGENERATE = "REGENERATE",
		PATHING_UPDATEOBSERVED = "FIX GUARD PATHING: UPDATE OBSERVED",
		PATHING_UPDATEOBSERVED_TIP = "<c:FF8411>FIX GUARD PATHING: UPDATE OBSERVED</c>\nSometimes, observed/TAGged guard paths don't visually update when the interest point moves, resulting in the observed path lying about what the guard will actually do.\nThis forces the guard's path to update immediately.",
	},
}

return MOD_STRINGS
