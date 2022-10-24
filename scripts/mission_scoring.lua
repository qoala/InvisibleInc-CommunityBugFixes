-- patch to client/mission_scoring

local mission_scoring = include( "mission_scoring" )
local array = include( "modules/array" )
local serverdefs = include( "modules/serverdefs" )
local rand = include("modules/rand")
local util = include( "modules/util" )
local unitdefs = include("sim/unitdefs")

local cbf_util = include( SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util" )
local constants = include( SCRIPT_PATHS.qoala_commbugfix .. "/constants" )

local oldDoFinishMission = mission_scoring.DoFinishMission
mission_scoring.DoFinishMission = function( sim, campaign, ... )

	-- -----
	-- DLC mid2 softlock fix.
	-- -----

	local player = sim:getPC()
	local agency = campaign.agency
	local survivors = false
	local deployed = player:getDeployed()
	local i = nil
	for agentID, deployData in pairs( deployed ) do
		local agentDef = serverdefs.findAgent( agency, agentID )
		-- log:write("LOG deployData")
		-- log:write(util.stringize(deployData,2))
		if deployData.agentDef and deployData.id then
			if deployData.escapedUnit and not deployData.agentDef.leave then
				survivors = true
				-- log:write("LOG survivors true")
			end
		end
		if deployData.agentDef.id == constants.AGENT_IDS.MONST3R_PC then
			i = agentID
		end
	end

	if i and (survivors == false) then
		local Monster_data = deployed[i]
		Monster_data.agentDef.leave = nil
		-- Remove Monst3r from the detention pool if he was a starting agent and lost, to prevent having 2 Monst3rs.
		-- Unless another mod is preserving augments from the detention pool, they will be lost.
		array.removeIf( agency.unitDefsPotential, function( adef ) return adef.id == constants.AGENT_IDS.MONST3R_PC end )
	end

	-- -----
	-- END DLC mid2 softlock fix.
	-- -----

	local previousFoundPrisoner = campaign.foundPrisoner

	local flow_result = oldDoFinishMission( sim, campaign, ... )

	-- -----
	-- Detention Centers agent chance fix
	-- -----

	local spawnAgentOption = cbf_util.optionsCheckFlag(campaign.difficultyOptions, "cbf_detention_spawnagent", constants.MISSIONDETCENTER_SPAWNAGENT.VANILLA)
	if spawnAgentOption ~= constants.MISSIONDETCENTER_SPAWNAGENT.VANILLA then
		if spawnAgentOption == constants.MISSIONDETCENTER_SPAWNAGENT.ALWAYS then
			campaign.foundPrisoner = true
		elseif sim:getTags().cbfCouldHaveAgent then
			-- No change needed
		elseif previousFoundPrisoner == nil and spawnAgentOption == constants.MISSIONDETCENTER_SPAWNAGENT.FIRSTAGENT then
			-- Initialize foundPrisoner for the first time.
			campaign.foundPrisoner = true
		else
			-- Leave the previous prisoner-vs-agent chance after missions that couldn't have an agent in the first place
			campaign.foundPrisoner = previousFoundPrisoner
		end
	end

	-- -----
	-- END Detention Centers agent chance fix
	-- -----

	-- -----
	-- Rescued agent status fix
	-- -----
	local rescued_agents = {}
	-- Find rescued agents first
	for i, agent in ipairs( sim._resultTable.agents ) do
		if agent.status == "RESCUED" then
			agent.name = agent.name.template
			table.insert(rescued_agents, agent.name)
		end
	end
	-- Delete the duplicates
	for i=#sim._resultTable.agents, 1, -1 do
		if array.find( rescued_agents, sim._resultTable.agents[i].name ) and sim._resultTable.agents[i].status ~= "RESCUED" then
			table.remove( sim._resultTable.agents, i )
		end
	end
	-- -----
	-- END Detention Centers agent chance fix
	-- -----

	return flow_result
end

-- -----
-- Escorts Fixed
-- -----

local oldUpdateAgencyFromSim = mission_scoring._updateAgencyFromSim
function mission_scoring._updateAgencyFromSim( campaign, sim, situations, ... )
	-- ===
	-- Duplicate unitDef upgrade tables before modifying them,
	-- to fix an oversight where the base game didn't always remember to do so when adding the unit to the agency.
	-- Otherwise modifications would modify the original unitDef.
	--
	-- The upgrade table of the agent that gets added by the ADD_AGENT campaign event (i.e. monst3r) isn't copied when added to the agency
	-- ===
	for k, unitDef in pairs( campaign.agency.unitDefs ) do
		if unitDef.upgrades then
			unitDef.upgrades = util.tdupe(unitDef.upgrades)
		end
	end

	oldUpdateAgencyFromSim( campaign, sim, situations, ... )
	simlog("CBFDEBUG: running updateAgencyFromSim")

	if not cbf_util.optionsCheckFlag(campaign.difficultyOptions, "cbf_escorts_fixed") then
		simlog("CBFDEBUG: escorts fixed disabled %s", tostring(campaign.difficultyOptions and campaign.difficultyOptions.cbf_params))
		if campaign.difficultyOptions.cbf_params then util.tlog(campaign.difficultyOptions.cbf_params) end
		return
	end

	-- ===
	-- Initialize tables, as necessary.
	-- ===

	local agency = campaign.agency

	if not sim._returnedItems then
		sim._returnedItems = {}
		sim._leavingAgents = {}
	end

	if not sim._params.agency.upgrades then
        sim._params.agency.upgrades = {}
    end

	-- ===
	-- Handle items returned by temporary units (see simunit:returnItemsToStash patch)
	-- Permanent items are sent to storage. Temporary item bonuses are applied.
	-- ===

	for i, item in ipairs(sim._returnedItems) do
		-- Move items to storage
		-- This includes the leaving agent's own items, but those get removed later
		local upgradeName = item:getUnitData().upgradeName
		if upgradeName then
			local unitData = item:getUnitData()
			if item:getUnitData().upgradeOverride then
				upgradeName = item:getUnitData().upgradeOverride
				unitData =  unitdefs.lookupTemplate( upgradeName )
			end
			local upgradeParams = unitData.createUpgradeParams and unitData:createUpgradeParams( item )
			table.insert( agency.upgrades, { upgradeName = upgradeName, upgradeParams = upgradeParams })
		end

		-- New Locations
		if item:getTraits().newLocations then
			agency.newLocations = util.tmerge( agency.newLocations, item:getTraits().newLocations )
		end

		local user = savefiles.getCurrentGame()

		-- UNLOCK LOGS
		if item:getTraits().lostData then
			local serverdefs = include( "modules/serverdefs" )
			local potentialLogIds, potentialLogs = {}, {}
			user.data.logs = user.data.logs or {}

			for i, log in ipairs(serverdefs.LOGS) do
				potentialLogIds[log.id] = i
			end
			for i, log in ipairs(user.data.logs) do
				potentialLogIds[log.id] = nil
			end
			for id, idx in pairs(potentialLogIds) do
				table.insert(potentialLogs, serverdefs.LOGS[idx])
			end

			if #potentialLogs > 0 then
				local gen = rand.createGenerator( campaign.seed )
				local logID = gen:nextInt( 1,  #potentialLogs )
				local newLog = util.tcopy(potentialLogs[logID])
				print("UNLOCKED LOG DATA",newLog.id)
				table.insert(user.data.logs,newLog)
				sim._resultTable.newLogData = newLog
			end
		end

		-- Cash reward items
		if item:getTraits().cashInReward then
			local value = sim:getQuery().scaleCredits(sim, item:getTraits().cashInReward )
			sim:addMissionReward(value)
			sim._resultTable.credits_gained.stolengoods = sim._resultTable.credits_gained.stolengoods and sim._resultTable.credits_gained.stolengoods + value or value
		end
	end

	local cbfEscortsRemoveOwnedItems = cbf_util.optionsCheckFlag(campaign.difficultyOptions, "cbf_escorts_remove_owned_items")
	local lootTable = sim._resultTable.loot

	-- ===
	-- Clean up agents that are leaving the agency.
	-- ===

	for _, leavingAgent in ipairs(sim._leavingAgents) do
		local agentID = leavingAgent:getUnitData() and leavingAgent:getUnitData().agentID
		if agentID then
			local agentDef = sim:getPC()._deployed[agentID]
			local keptItems = {{upgradeName = "clearChildren"}}

			-- ===
			-- Remove items that belong to agents that are leaving
			-- Items that went to storage (from the leaving agent) are always removed.
			-- Optionally, also remove such items held by other agents.
			-- ===
			-- TODO: Actually track the original item
			-- Will be required if a mod has an agent with non-unique items that joins the team and leaves
			if agentDef and agentDef.agentDef and agentDef.agentDef.template and unitdefs.lookupTemplate(agentDef.agentDef.template) then
				local upgrades = unitdefs.lookupTemplate(agentDef.agentDef.template).upgrades
				for i = #upgrades, 1, -1 do
					local upgradeName = upgrades[i]
					local template = unitdefs.lookupTemplate(upgradeName)
					if template and not template.traits.installed then
						local found = false

						for j, upgrade in pairs(agency.upgrades) do
							if upgrade == upgradeName or (type(upgrade) == "table" and upgrade.upgradeName == upgradeName) then
								table.insert(keptItems,upgrade)
								table.remove(agency.upgrades,j)
								found = true
								break
							end
						end

						-- Only check other agents if we're ok with removing the ability to steal monst3r's gun
						if cbfEscortsRemoveOwnedItems then
							for _, unitDef in pairs(agency.unitDefs) do
								if found then
									break
								end
								for j, upgrade in pairs(unitDef.upgrades) do
									if upgrade == upgradeName or (type(upgrade) == "table" and upgrade.upgradeName == upgradeName) then
										table.insert(keptItems,upgrade)
										table.remove(unitDef.upgrades,j)
										found = true

										-- Also remove from the "new items" loot list.
										array.removeElement(lootTable, upgradeName)

										break
									end
								end
							end
						end
					end
				end
			end

			-- ===
			-- Store the agent's own items as well as augments they've installed, in case they return later.
			-- ===
			if not agency._keptItems then
				agency._keptItems = {}
			end

			agency._keptItems[agentID] = keptItems

			for i,item in ipairs(leavingAgent:getChildren())do
				if item:getTraits().installed then
					local upgradeName = item:getUnitData().upgradeName
					if upgradeName then
						local unitData = item:getUnitData()
						if item:getUnitData().upgradeOverride then
							upgradeName = item:getUnitData().upgradeOverride
							unitData =  unitdefs.lookupTemplate( upgradeName )
						end
						local upgradeParams = unitData.createUpgradeParams and unitData:createUpgradeParams( item )
						table.insert( agency._keptItems[agentID], { upgradeName = upgradeName, upgradeParams = upgradeParams })
					end
				end
			end
		end
	end

	local user = savefiles.getCurrentGame()
	user:save()
end
