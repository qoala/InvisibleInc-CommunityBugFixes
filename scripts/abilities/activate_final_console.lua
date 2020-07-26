-- patch to sim/abilities/activate_final_console.lua

local util = include( "modules/util" )
local abilitydefs = include( "sim/abilitydefs" )

local oldActivateFinalConsole = abilitydefs.lookupAbility("activate_final_console")
local oldIsTarget = oldActivateFinalConsole.isTarget

local activate_final_console = util.extend(oldActivateFinalConsole)
{
  isTarget = function( self, abilityOwner, unit, targetUnit )
    local sim = abilityOwner:getSim()
    if sim:getParams().difficultyOptions.cbf_ending_remotehacking then
      if targetUnit ~= abilityOwner then
        return false
      end
    end
    return oldIsTarget( self, abilityOwner, unit, targetUnit )
  end
}
return activate_final_console
