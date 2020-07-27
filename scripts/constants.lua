-- Constants shared between other files.

-- IDs from existing agentdefs.
local AGENT_IDS =
{
	-- Player-version of Monst3r. Used both at agency start or DLC mid missions.
	-- There is a separate ID for OMNI mainframe Monst3r.
	MONST3R_PC = 100,
}

-- Enum values for vault mission fix of hack response.
local MISSIONVAULT_HACKRESPONSE =
{
	VANILLA = 0,
	ANYHACK = 1,
}

-- Enum values for IdleSituation fix of failed patrol paths.
local IDLE_FIXFAILEDPATROLPATH =
{
	DISABLED = 0,
	STATIONARY = 1,
	REGENERATE = 2,
}

return {
	AGENT_IDS = AGENT_IDS,

	MISSIONVAULT_HACKRESPONSE = MISSIONVAULT_HACKRESPONSE,
	IDLE_FIXFAILEDPATROLPATH = IDLE_FIXFAILEDPATROLPATH,
}
