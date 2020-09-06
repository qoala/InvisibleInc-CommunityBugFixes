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
