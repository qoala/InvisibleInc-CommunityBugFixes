# Notes to Modders

## Missions with Rescueable Agents

If adding a new mission type that allows rescuing an agent, then when the mission determines if an
agent is available (usually during mission init):

* If `sim:getParams().foundPrisoner`, then consider guaranteeing an agent spawns if the agency isn't
  full. (This if from the vanilla detention center behavior)
    * If you skip this check, then maybe skip setting both of the following tags, so that
      `foundPrisoner` isn't updated either.
* If an agent is available, set `sim:getTags().hadAgent = agentDef.id` with the agent being spawned.
  (This is from the vanilla detention center behavior)
* Whether or not an agent is available, set `sim:getTags().cbfCouldHaveAgent = true`.

## Persistent Agent Animations

If agents or other units can be engaged in a persistent animation, such as the hacking loop used by
Monst3r in the OMNI Mainframe or by any agent on a databank, consider wrapping
`simquery.cbfAgentHasStickyFacing` as follows:

```
if simquery.cbfAgentHasStickyFacing then
  local oldAgentHasStickyFacing = simquery.cbfAgentHasStickyFacing

  function simquery.cbfAgentHasStickyFacing( unit, ... )
    local result = oldAgentHasStickyFacing( unit, ... )

    return result or {your own check here}
  end
end
```

It currently checks for:

* vanilla/DLC: `monster_hacking`, `data_hacking` traits
* Manual Hacking mod: `mod_data_hacking` trait
