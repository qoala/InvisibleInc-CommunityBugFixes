-- patch to sim/units/simdisguiseitem

local util = include( "modules/util" )
local simunit = include( "sim/simunit" )
local simdefs = include( "sim/simdefs" )
local simfactory = include( "sim/simfactory" )
local mathutil = include( "modules/mathutil" )
local cdefs = include( "client_defs" )

local cbf_util = include( SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util" )

local item_disguise = { ClassType = "item_disguise" }

-- CBF: unchanged
function item_disguise:onSpawn( sim )
	sim:addTrigger( simdefs.TRG_UNIT_WARP, self )
	if sim:isVersion("0.17.7") then
		sim:addTrigger( simdefs.TRG_UNIT_USEDOOR, self )
	end
	sim:addTrigger( simdefs.TRG_START_TURN, self )
end

-- CBF: unchanged
function item_disguise:onDespawn( sim )
	sim:removeTrigger( simdefs.TRG_UNIT_WARP, self )
	if sim:isVersion("0.17.7") then
		sim:removeTrigger( simdefs.TRG_START_TURN, self )
	end
	sim:removeTrigger( simdefs.TRG_UNIT_USEDOOR, self )
end

-- CBF/Disguise Fix: 
-- * Disguise no longer breaks on re-captured cameras. Now requires an NPC-owned guard/drone.
-- * More consistent behavior when multiple guards are in deactivation range.
-- * Don't crash if the disguise is on the ground.
function item_disguise:onTrigger( sim, evType, evData )
	if evType == simdefs.TRG_UNIT_WARP or evType == simdefs.TRG_UNIT_USEDOOR then
		local unitOwner = self:getUnitOwner()
		if unitOwner and unitOwner:getTraits().disguiseOn then
			for _, npcUnit in pairs(sim:getNPC():getUnits()) do
				local x0, y0 = unitOwner:getLocation()
				local x1, y1 = npcUnit:getLocation()
				if x0 and x1 then
					local range = mathutil.dist2d( x0, y0, x1, y1 )
					if range <= 1.5 and npcUnit:getTraits().isGuard and sim:canUnitSeeUnit(npcUnit, unitOwner) then
						unitOwner:setDisguise(false)	
						unitOwner:interruptMove( sim )
					end
				end
			end	
		end
	elseif evType == simdefs.TRG_START_TURN then
		local owner = self:getUnitOwner()
		if not owner then return end
		local player = owner:getPlayerOwner()
		if player and sim:getCurrentPlayer() == player and owner and owner:getTraits().disguiseOn then
			local x,y owner:getLocation()
			if player:getCpus() >= self:getTraits().CPUperTurn then
				player:addCPUs( -self:getTraits().CPUperTurn, sim, x,y )
				sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=util.sformat( self:getTraits().warning ,self:getTraits().CPUperTurn), color=cdefs.COLOR_PLAYER_WARNING, sound = "SpySociety/Actions/mainframe_gainCPU",icon=nil } )
			else
				owner:setDisguise(false)
			end
		end
	end
end

-----------------------------------------------------
-- Interface functions


local function createItem( unitData, sim )
	return simunit.createUnit( unitData, sim, item_disguise )
end

simfactory.register( createItem )

return
{
	createItem = createItem,
}
