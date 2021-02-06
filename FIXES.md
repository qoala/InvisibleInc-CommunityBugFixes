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
* Final Mission: Mainframe Lock Skip
  * After completing the security hub, Monst3r is able to directly unlock the final doors as if he
    were carrying an appropriate keycard. The mission scripts still require Monst3r to activate the
	mainframe lock, so this just allows wandering in the final room without being able to win.
  * **Fix**: The security codes obtained by Monst3r no longer allow him to directly unlock doors.
  * **Campaign Option**: enable/disable fix
  * **Credit**: Qoalabear
* Final Mission: Dropping Incognita
  * Central is supposed to start with Incognita's drive and be unable to drop it. However, it can
    be dropped by transferring it to the ground while picking up another dropped item. It can also
	be transferred to a guard, safe, or KOed agent from the "looting" menu.
  * If Central was already part of the agency and tries to start the mission with a full inventory,
    then Incognita is spawned on the ground at her feet.
  * Incognita's presence isn't actually checked in order to win. (Not fixed, as this would require
    blocking an empty-handed Central from the final hallway to avoid softlocking her inside.)
  * **Note**: With Sim Constructor, if Central enters with a full inventory, then Incognita is added
    as a 9th item without any UI indication other than the extra encumbrance.
  * **Fix**:
    * Block all item transfers except with Central as the recipient.
	* The last item in Central's inventory is visibly dropped at the start of the mission instead of
	  Incognita's drive.
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
* Laser beam ally checks
  * Corp-controlled lasers turn off when guards walk through, and likewise for agency-controlled
    lasers and agents. Corp-controlled lasers also turn off when an agent drags a guard through.
    However agency-controlled trip against a guard being dragged by an agent. Also,
    agency-controlled lasers do not re-enable themselves after all allies have passed through.
  * **Fix** Lasers self-disable if either the dragging unit or the dragged unit is an ally. And
    lasers re-enable after all allies have left, regardless of owner.
  * **Credit**: Qoalabear
* Magic diagonal guard vision
  * Guards facing diagonally always see the orthogonally adjacent tiles on the side of their main
    vision cone, to prevent some easy exploits. However, this vision is still granted if the guard
	couldn't normally see the tile.
  * Pulse drones only have enough vision range to see their own tile normally, but if they just
    moved diagonally, they can be alerted by agents passing through the magic vision tiles.
  * Smoke blocks all normal vision, but not the magic vision tiles. If an agent moves through magic
    vision tiles, the guard turns to face the agent and can no longer see them.
  * **Fix**: Suppress the extra magic vision if a guard could not see those tiles regardless of
    facing.
  * **Campaign Option**: enable/disable fix
  * **Credit**: Qoalabear, Cyberboy2000
* Holoprojector sound through walls
  * Most sounds do not alert guards (notable exception: K&O turrets firing). However, the sound
    "continuously" emitted by a deployed holoprojector in a 1 tile radius does alert guards.
    In universe, this might be explained as the guard takes a closer look at the mobile pallet and
    realizes that it's a hologram. This doesn't make as much sense if a guard hears the projector
    from the other side of a wall. 
  * Separately, the sound is not checked when the projector is initially deployed (though any guard
    that can see the projector being deployed is alerted by sight). This is left unfixed, otherwise
    the holoprojector could be thrown and picked up in a single turn as a targetted sound
    distraction.
  * **Fix**: If the guard could not see the projector after turning to face it, the
  * **Campaign Option**: Choose guards hearing a projector through a wall to:
    * be alerted and investigate it (vanilla)
    * investigate it (default)
    * ignore it
  * **Credit**: Qoalabear
* Sleeping guards notice TAG
  * When a KOed guard wakes up, they investigate the location of their most recent attack (including
    attacks received while KOed). This includes an attack with a TAG pistol, even though TAG pistol
	hits are not otherwise noticed by awake guards.
  * **Fix**: Non-alerting attacks do not update the "last hit" property, so are ignored by KOed
    guards when selecting their wake-up investigation point.
  * **Campaign Option**: enable/disable fix
  * **Credit**: Qoalabear
* Guard Pathing: Stale observed paths
  * When a guard's current interest point moves (such as an agent moving through peripheral vision
    or sprinting past), the guard's observed path stays at the interest's initial position and
    doesn't update on its own. On the guard's turn, the guard will "correctly" travel to the
    interest point's final position; the observed path was lying.
  * **Fix**: Guard paths are forced to update after their current interest is moved. The update is
    deferred until the end of a multi-tile move to reduce unnecessary path calculations.
  * **Campaign Option**: enable/disable fix
  * **Credit**: Qoalabear


* Inventory: Ambush/overwatch are cancelled by dropping any item.
  * After dropping an item on the ground, picking up an item, or looting an item from a guard or
    safe, the agent's ambush and overwatch are cancelled. This applies even if the active weapon
	wasn't affected. Compare with toggling a door, which also has an animation, but doesn't reset
	ambush/overwatch.
  * **Fix**: Picking up/dropping items checks that any ambush/overwatch is still valid. If the
    ability is no longer available, then it is cancelled. Other item interactions (priming EMP, etc)
	no longer affect ambush/overwatch.
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
