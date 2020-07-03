
local MOD_STRINGS =
{
	OPTIONS =
	{
		NOPATROL_FIXFACING = "PREFAB STATIONARY GUARDS - FIX FACING",
		NOPATROL_FIXFACING_TIP = "<c:FF8411>PREFAB STATIONARY GUARDS - FIX FACING</c>\nAffects stationary guards placed by prefabs during level generation, such as detention center captains.\nThis makes them remember their initial facing, instead of facing arbitrary directions after being distracted.",
		NOPATROL_NOPATROLCHANGE = "PREFAB STATIONARY GUARDS - IGNORE PATROL CHANGE",
		NOPATROL_NOPATROLCHANGE_TIP = "<c:FF8411>PREFAB STATIONARY GUARDS - IGNORE PATROL CHANGE</c>\nAffects stationary guards placed by prefabs during level generation, such as detention center captains.\nThis makes them ignore signals to \"change up the guard patrols\", such as the DLC extended campaign alarm level. Notably does not apply to other guards of the same type (captain, CFO, etc.) if the prefab places them patrolling.",
		IDLE_FIXFAILEDPATROLPATH = "FIX BROKEN GUARD PATROLS",
		IDLE_FIXFAILEDPATROLPATH_TIP = "<c:FF8411>FIX BROKEN GUARD PATROLS</c>\nIf a guard fails to generate a patrol path, they can end up stationary without a remembered facing.\n\nDISABLED: Leave unchanged.\nSTATIONARY: Convert to a non-broken stationary patrol.\nREGENERATE: Generate a new patrol path with looser requirements.",
		IDLE_FIXFAILEDPATROLPATH_DISABLED = "DISABLED",
		IDLE_FIXFAILEDPATROLPATH_STATIONARY = "STATIONARY",
		IDLE_FIXFAILEDPATROLPATH_REGENERATE = "REGENERATE",
	},
}

return MOD_STRINGS
