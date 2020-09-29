# Available Bug Fixes

* Detention Center Missions: Agent/Prisoner Chance
  * The mission is coded to give 50/50 odds of an agent or generic prisoner, unless the agency is
    full (guaranteed prisoner) or the player recently found the prisoner (guaranteed agent). This
    guarantees that the player needs to visit at most 2 detention centers to find an agent.
  * Except that the game sets `foundPrisoner` after _any_ mission that didn't have a rescueable
    agent, even if it wasn't a detention center so didn't have a prisoner. The 50/50 only applies if
    the player visits detention centers back-to-back.
  * **Fix 1** (default): The `foundPrisoner` flag is only updated after detention center missions.
    There is a 50/50 chance of Agent/Prisoner if the most recent detention center had an agent, no
    matter how many intervening missions have been visited. Additionally, force the first detention
    center to have an agent, because the bug has led most players to expect that.
  * **Fix 2**: The `foundPrisoner` flag is only updated after detention center missions.  There is a
    50/50 chance of Agent/Prisoner unless the most recent detention center had a prisoner, no matter
    how many intervening missions have been visited. The first detention center has a 50/50 chance.
  * **Campaign Option**: choose one of the available fixes or vanilla behavior.
  * **Credit**: Qoalabear, Mobbstar, pesnitor
* Vault Missions: Security Response
  * The security response (spawning an enforcer to inspect the vault) triggers when a
    device-targetted Incognita program reduces firewalls exactly to 0 on a vault device.
  * The following techniques bypass this response entirely:
    1) Hack the device with a non-program (e.g. buster chip)
    2) Hack the device with an area-targetted program (e.g. data blast)
    3) Simultaneously break more firewalls than are currently on the device, producing a result less
    than 0 (e.g. Lockpick 2.0 when the target has 1 firewall)
    4) EMP the experiment case. Doesn't work on the vault terminal to unlock deposit boxes.
  * **Fix 1**: Trigger security whenever all firewalls are broken. Prevents the first 3 bypass
    options.
  * **Campaign Option**: choose one of the available fixes or vanilla behavior.
  * **Credit**: Qoalabear
* Final Mission: Remote Hacking
  * When Monst3r is near the security hub or mainframe lock, he can perform the associated hacking
    abilities on any mainframe device adjacent to himself (drones, OMNI Protectors, etc).
  * Also applies to Central's final objective, though any other units should've been teleported out
    by the time she approaches it.
  * **Fix**: The abilities only appear on their intended device.
  * **Campaign Option**: enable/disable fix
  * **Credit**: Qoalabear
* Prefab stationary guards: Fix facing
  * Stationary guards placed by prefabs are stationary without a remembered facing, leaving them
    facing arbitrary directions after being distracted. For example, detention center captains
    will usually remain facing the wall after returning from a distraction.
  * **Fix**: Stores their initial facing, similar to randomly generated "stationary" guards.
  * **Campaign Option**: enable/disable fix
  * **Credit**: Qoalabear
* Prefab stationary guards: Ignore patrol change
  * Stationary guards placed by prefabs are included in signals to "change up the guard patrols",
    such as the DLC extended campaign alarm level. Captains shouldn't leave their prisoners
    unguarded.
  * **Fix**: Such guards are skipped when generating new patrols. They behave normally once alerted.
    Inconsistent behavior from the player's perspective with Worldgen Extended. Stationary captains,
    CFOs, etc ignore patrol change, but the same units that spawned patrolling in new prefabs will
    not.
  * **Campaign Option**: enable/disable fix
  * **Credit**: Qoalabear
* Broken Guard Patrols: Guard cannot reach a valid 2nd patrol point
  * Without the beginner patrols setting, guards are required to find a patrol path using all of
    their AP and crossing into a separate worldgen "room". (A single contiguous space may be
    composed of multiple conjoined "rooms" during worldgen, so this doesn't necessarily match what a
    player would call a room) If this fails, the guard is left with a single patrol point and no
    facing in its path, reported as "stationary" but broken in a similar way to prefab stationary
    guards.
  * **Fix 1**: Generate a new patrol path, ignoring the restriction on patrolling into a different
    room. (Default)
  * **Fix 2**: Generate a stationary patrol, using normal logic for 'optimal stationary facing'.
    This may produce surprising behavior if it is triggered during a patrol change. After travelling
    to and investigating the point, the guard immediately turns to face the calculated direction.
  * **Campaign Option**: choose one of the available fixes or no fix.
  * **Credit**: Qoalabear, Cyberboy2000
* Guard Pathing: Stale observed paths
  * When a guard's current interest point moves (such as an agent moving through peripheral vision
    or sprinting past), the guard's observed path stays at the interest's initial position and
    doesn't update on its own. On the guard's turn, the guard will "correctly" travel to the
    interest point's final position; the observed path was lying.
  * **Fix**: Guard paths are forced to update after their current interest is moved. The update is
    deferred until the end of a multi-tile move to reduce unnecessary path calculations.
  * **Campaign Option**: enable/disable fix
  * **Credit**: Qoalabear


* DLC mid-missions: Save corruption if Monst3r is the sole survivor of DLC mid2.
  * Occurs if Monst3r is the only surviving agent, and he is not officially on your team. This
    contradicts in-game tips/dialogue suggesting that "Our agents are expendable, but Monst3r must
    survive".
  * **Fix**: Monst3r joins your agency if he is the only survivor of the mission, allowing you to
    continue the campaign.
  * **Credit**: Hekateras
* DLC mid-missions: Crash if Monst3r is in the detention pool when starting DLC mid1.
  * Occurs if the agency started with Monst3r, lost him, and did not recover him before mid1.
  * **Fix**: The version of Monst3r in the detention pool is temporarily suppressed. Like the final
    mission, he will not have any augments, equipment, or upgrades from the abandoned Monst3r. In
    the unlikely event the player triggers both this and 'Monst3r is the sole survivor of mid2', the
    abandoned Monst3r in the detention pool is purged to prevent getting two of him.
  * **Credit**: Hekateras, Qoalabear
* DLC Extended Campaign: Can teleport out the last active agent without the Power Cell.
  * The game tries to disable the teleport ability if it would remove all your agents and you don't
    have the power cell (the same code also applies to the Quantum Reservoir in mid 2). This is a
    reasonable check, because the campaign ends in a loss if you end the mission without retrieving
    the power cell.  It does allow partial teleports, assuming the player can use the remaining
    agents to try for the power cell.
  * However, the check doesn't distinguish between active and downed agents being left behind. The
    player is allowed to escape without the power cell and immediately lose because all remaining
    agents are neutralized.
  * **Fix**: The teleport ability is disabled if the power cell isn't escaped/escaping and all
    remaining agents (if any) are neutralized. This uses the same "neutralized" definition as the
    check to immediately end the mission. KOed agents are only neutralized if they're pinned by a
    guard (allowing them to hopefully wake up undisturbed).
  * **Credit**: Qoalabear, Hekateras
* Databank Animation: Facing after toggling a door while hacking.
  * If an agent is hacking a databank and toggles a door, then the agent is left hacking the open
    air in front of the door.
  * Most actions set an animation facing for just their animation (opening a safe, etc), but don't
    affect the agent's persistent facing. The only other actions that automatically updated facing
    (attacks) also cancel any in-progress hacking by that agent.
  * **Fix**: Don't change facing when toggling a door and in the middle of hacking.
  * **Credit**: Qoalabear
* Modded: UI script events during a dialog
  * It was possible for scripted UI events to try to dismiss an unrelated dialog that was being
    displayed. Some, like the Executive Terminals "choose 1 of 4 sites" dialog, can't handle being
    dismissed.
  * **Fix**: Pause the offending event queue while a dialog is open.
  * **Credit**: Qoalabear
