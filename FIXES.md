
## Configurable Fixes

The following fixes have their own options in the campaign settings at the start of a run, usually
because there's reasonable arguments over how to correctly fix the bug.

* Escorts Fixed: Return Escort-Owned Items
  * With the DLC extended campaign, it is possible to steal Monst3r's unique gun at the end of the
    mission by having a different agent carry it.
  * **Fix**: If any of Monst3r's starting items are on another agent when he leaves, the item is
    returned to Monst3r.
  * **Credit**: Cyberboy2000
* Detention Center Missions: Agent/Prisoner Chance
  * The mission is coded to give 50/50 odds of an agent or generic prisoner, unless the agency is
    full (guaranteed prisoner) or the player recently found a prisoner (guaranteed agent). This
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
  * **Fix**: If there is a wall between the guard and the projector (couldn't view it at range-1
    after turning), then instead of being alerted, the chosen behavior occurs.
  * **Campaign Option**: Choose guards hearing a projector through a wall to:
    * be alerted and investigate it (vanilla)
    * investigate it (default)
    * ignore it
  * **Credit**: Qoalabear

## General Fixes

The following fixes are applied when the "General Bug Fixes" toggle is enabled in the campaign
settings (enabled by default).

#### Mission-specific Fixes

* Chief Financial Suite & Data Banks:
  * If Data Banks spawn in a CFO mission and are completed before the interrogation, then the
    mission can crash, because the reward cards have the same tag.
  * **Fix**: Remove the unnecessary tag from the Data Banks side mission.
  * **Credit**: Qoalabear
* Detention Centers:
  * Rescued agents are displayed as "active" instead of "rescued" in the after-mission summary.
  * **Fix**: Correctly display "rescued" for newly added agents.
  * **Credit**: RaXaH
* Final Mission: Mainframe Lock Skip
  * After completing the security hub, Monst3r is able to directly unlock the final doors as if he
    were carrying an appropriate keycard. The mission scripts still require Monst3r to activate the
    mainframe lock, so this just allows wandering in the final room without being able to win.
  * **Fix**: The security codes obtained by Monst3r no longer allow him to directly unlock doors.
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
  * **Credit**: Qoalabear
* Final Mission: Remote Hacking
  * When Monst3r is near the security hub or mainframe lock, he can perform the associated hacking
    abilities on any mainframe device adjacent to himself (drones, OMNI Protectors, etc).
  * Also applies to Central's final objective, though any other units should've been teleported out
    by the time she approaches it.
  * **Fix**: The abilities only appear on their intended device.
  * **Credit**: Qoalabear
* Vault Missions: Security Response
  * The security response (spawning an enforcer to inspect the vault) triggers when a
    device-targetted Incognita program reduces firewalls exactly to 0 on a vault device.
  * The following techniques bypass this response entirely:
    1) Hack the device with a non-program (e.g. buster chip)
    2) Hack the device with an area-targetted program (e.g. data blast)
    3) Simultaneously break more firewalls than are currently on the device, producing a result less
    than 0 (e.g. Lockpick 2.0 when the target has 1 firewall)
    4) EMP the experiment case. Doesn't work on the vault terminal to unlock deposit boxes.
  * **Fix**: Trigger security whenever all firewalls are broken. Prevents the first 3 bypass
    options.
  * **Credit**: Qoalabear
* Escorts Fixed: Loot Bonuses on NPCs
  * Items carried out by non-agents or agents that automatically leave at the end of the mission
    (Monst3r during DLC mid2) are automatically transferred to the jet's Storage.
    However, items that grant immediate bonuses when extracted (valuable tech, site lists, etc)
    aren't recognized when carried out by one of these units.
  * **Fix**: Track items carried by non-agents and leaving agents, running the immediate bonus
    checks for each.
  * **Credit**: Cyberboy2000
* Escorts Fixed: Giving Monst3r Augments
  * After installing an augment in Monst3r during the DLC mid missions, he mysteriously loses it
    between then and the final mission.
  * **Fix**: Track items installed or owned by Monst3r when he leaves after mid2. Restore them when
    he is spawned for the final mission.
  * **Credit**: Cyberboy2000

#### Guard (Non-Pathing) Fixes
* Prefab stationary guards: Fix facing
  * Stationary guards placed by prefabs are stationary without a remembered facing, leaving them
    facing arbitrary directions after being distracted. For example, detention center captains
    will usually remain facing the wall after returning from a distraction.
  * **Fix**: Stores their initial facing, similar to randomly generated "stationary" guards.
  * **Credit**: Qoalabear
* Broken Guard Patrols: Guard cannot reach a valid 2nd patrol point
  * Without the beginner patrols setting, guards are required to find a patrol path using all of
    their AP and crossing into a separate worldgen "room". (A single contiguous space may be
    composed of multiple conjoined "rooms" during worldgen, so this doesn't necessarily match what a
    player would call a room) If this fails, the guard is left with a single patrol point and no
    facing in its path, reported as "stationary" but broken in a similar way to prefab stationary
    guards.
  * **Fix**: Generate a new patrol path, ignoring the restriction on patrolling into a different
    room.
  * **Credit**: Qoalabear, Cyberboy2000
* Magic guard vision
  * Guards facing diagonally always see the orthogonally adjacent tiles on the side of their main
    vision cone, to prevent some easy exploits. However, this vision is still granted if the guard
    couldn't normally see the tile.
  * Pulse drones only have enough vision range to see their own tile normally, but if they just
    moved diagonally, they can be alerted by agents passing through the magic vision tiles.
  * Smoke blocks all normal vision, but not the magic vision tiles. If an agent moves through magic
    vision tiles, the guard turns to face the agent and can no longer see them.
  * Conversely, with mods that can reduce guard vision arcs, it's possible for a guard to be unable
    to see the tile directly in front of their face, because their main vision arc covers too low
    a percentage of the tile.
  * **Fix**: Suppress the extra magic vision if a guard could not see those tiles regardless of
    facing.
  * **Fix**: Add magic vision to the tile directly in front of a guard if the guard could see that
    tile based on range & occlusion but ignoring facing/arc.
  * **Credit**: Qoalabear, Cyberboy2000
* Magic 360 vision
  * Units with 360-degree vision (in vanilla, only agents) always see all 4 orthogonally adjacent
    tiles, unless blocked by walls. This allows agents in smoke to see adjacent units.
  * Modded units with 360-degree vision also receive this, unexpectedly allowing them to shoot
    through smoke.
  * Also, agents that are facing diagonally only get the diagonal magic vision, which is
    inconsistent with when facing orthogonally. Agent facing should not matter for vision.
  * **Fix**: Suppress the extra magic vision for non-player units if LOS reports blocked vision.
  * **Fix**: Enable full magic vision for agents that are facing diagonally.
  * **Credit**: Qoalabear
* Sleeping guards notice TAG
  * When a KOed guard wakes up, they investigate the location of their most recent attack (including
    attacks received while KOed). This includes an attack with a TAG pistol, even though TAG pistol
    hits are not otherwise noticed by awake guards.
  * **Fix**: Non-alerting attacks do not update the "last hit" property, so are ignored by KOed
    guards when selecting their wake-up investigation point.
  * **Credit**: Qoalabear
* Pulse scan reactions
  * When an agent is scanned by a pulse drone, the notified guard is immediately updated, but
    doesn't react until his own turn. This can confuse the player as to what happened.
  * **Fix**: Guards process updated reactions following a pulse scan.
  * **Credit**: Qoalabear

#### Guard Pathing Fixes

* Stale observed paths
  * When a guard's current interest point moves (such as an agent moving through peripheral vision
    or sprinting past), the guard's observed path stays at the interest's initial position and
    doesn't update on its own. On the guard's turn, the guard will "correctly" travel to the
    interest point's final position; the observed path was lying.
  * **Fix**: Guard paths are forced to update after their current interest is moved. The update is
    deferred until the end of a multi-tile move to reduce unnecessary path calculations.
  * **Credit**: Qoalabear
* Blocked diagonal steps (Function Library/Disguise Fix)
  * **Fix**: Guards path through enemies unless _starting_ next to and facing them  (including recalculation after being blocked)
    * Guards still step orthogonally around obstacles if an agent is blocking a diagonal move.
    * Guards don't step orthogonally if an agent would've blocked a diagonal move, but has since moved out of the way.
    * Guards don't get stuck when blocked by disguised agents.
    * Small units (camera drones, etc) don't incorrectly behave as if an agent could block them.
  * **Credit**: wodzu\_93
* Inadvertently shared investigation points
  * Each guard maintains the individual "interest"s that they want to investigate, and only he
    should be updating them. Due to a bug in the code for non-alerted guards, guards with related
    interest points will also update the matching interest owned by the first guard that joined this
    investigation group. If the active guard's interest is then identical to that first guard's,
    then the active guard will inadvertently clear the first guard's interest point as well. The
    first guard will finish any in-progress walking path before re-checking his priorities
    and using any remaining movement to pursue his next goal. Given that he first walked close
    to the interest point, this will frequently be a surprise about-face into what should've been
    good hiding places.
  * Occurs relatively rarely, because the interest points need to be identical on unseen properties,
    and guards will usually try to perform their investigation in the same order as joining the
    investigation group. Seems to occur most commonly with camera interest points that involve
    longer paths to reach.
  * **Fix**: Guards only update their own interest when completing an investigation.
  * **Credit**: Qoalabear

#### Agent-Related Fixes

* In-Mission Agent Stat Consistency
  * A few bugs can incorrectly update an agent's numeric traits (such as AP, sprint bonus, KO
    damage) when they're applied. These traits are recalculated from your current skills and
    augments at the start of each mission, so the bug only affects the mission in which it occurs.
  * (1) Using an augment drill on certain augments (Skeletal Suspension, Titanium Rods, Subdermal
    Tools, Modular Cybernetic Frame X2, various modded augments) doubles the numeric effect of the
    augment instead of reversing it. Removing Titanium Rods grants +2KO damage. Removing archive
    Sharp's frame doubles the penalty to -2AP (while removing the armor penetration).
  * (2) Gaining max speed uses the current hacking bonus, instead of the current sprint bonus, to
    calculate the new sprint bonus. Speed is applied before hacking when these are gained normally,
    so it correctly produces a bonus of +1 (for +4AP when sprinting). But if Draco has max hacking
    and then gains max speed during a mission, he can get a sprint bonus of +6 (for +9AP when
    sprinting) for the mission.
  * **Fix**: Removing an installed augment correctly reverses traits modified via `modTrait`.
  * **Fix**: Gaining speed 5 during a mission calculates the new `sprintBonus` using the current
    `sprintBonus`.
  * **Credit**: Qoalabear
* Flurry Guns only transition to inactive while carried.
  * Flurry Guns say that they can only be used for one turn each mission, transitioning from Idle to Active on use, and
    then to Used at the start of the next turn. However, like cooldowns, this only applies if an agent is carrying it.
    By dropping the Flurry Gun between turns, it can be kept Active indefinitely.
  * **Fix**: Check for Flurry Gun deactivation directly, instead of relying on checking agent inventories.
  * **Credit**: Qoalabear
* Recharge Ventricular Lances
  * Ventricular Lances lack the ability to reduce their cooldown via charge pack.
  * The only other cooldown items that lack recharge:
    * Short-cooldown, duration-effect, deployable items (laptops, holo cover, etc)
    * Lock decoder. (Also has a short cooldown)
  * **Fix**: Add the recharge ability
  * **Credit**: Hekateras, Qoalabear
* Partially Blocked Peeking
  * Ignoring the special handling for doors, peeking gives you vision from each of the four diagonal
    corners, but only if there's a clear path to that tile. When one of those corners is blocked,
    no vision is granted for that direction, despite the fact that sometimes giving vision from the
    orthogonally adjacent tile would be useful.
  * **Fix**: If a diagonal corner is blocked, try peeking in the two orthogonal adjacencies for that
    diagonal, if either are open.
  * This may occasionally still miss some relevant vision, but preserving vanilla behavior when
    there's no obstructions within range 1 keeps the number of LoS calculations from growing too
    quickly.
  * **Credit**: Qoalabear

#### Program-Related Fixes

* Programs: Cycle clears PWR after some item-based "generate PWR at start of turn" effects
  * Cycle's stated effect is to clear all PWR then gain 3 PWR at the start of every turn. There's
    steps taken so that this clears PWR before any other program generates PWR, avoiding any other
    generator programs becoming completely useless.
  * However, the Distributed Processing augment and Portable Laptop items generate their PWR before
    that step.
  * **Fix**: Cycle's "clear PWR" step is moved to fire before any other start of turn effect.
  * **Credit**: Qoalabear

#### Miscellaneous Fixes

* Laser beam ally checks
  * Corp-controlled lasers turn off when guards walk through, and likewise for agency-controlled
    lasers and agents. Corp-controlled lasers also turn off when an agent drags a guard through.
    However agency-controlled trip against a guard being dragged by an agent. Also,
    agency-controlled lasers do not re-enable themselves after all allies have passed through.
  * **Fix** Lasers self-disable if either the dragging unit or the dragged unit is an ally. And
    lasers re-enable after all allies have left, regardless of owner.
  * **Credit**: Qoalabear
* IR Laser beam daemon lists
  * Daemon-spawning lasers spawn from the full list of standard daemons, including removed daemons
    (old Felix) and level-inappropriate daemons (Authority in OMNI, where there are no safes).
  * **Fix** Daemon-spawning lasers use the same spawn list as Fractal and the initial device spawns.
  * **Credit**: Qoalabear
* Smoke grenades: Dynamic edges
  * Smoke clouds spawn fake "smoke edge" units at their edges, that can be seen by guards outside
    the cloud as an investigation prompt. (Because guards outside the cloud can't see into the
    cloud, and the vision block isn't something the game engine directly supports as being "seen".)
  * Overlapping smoke clouds don't create duplicate "smoke edge" units. If those clouds have
    different expiry times (only possible with mods), then after the first cloud expires, it may
    have cleaned up smoke edges that were needed for guards to recognize the still-remaining clouds.
  * However if the smoke cloud ends at a doorway, closing the door after throwing the smoke grenade
    doesn't remove the smoke edge on the far side of the door. Guards will come investigate, even
    though there's no smoke (or indication of it) on that side of the door.
  * Conversely, if a door is opened (or with mods, a wall is broken) at the edge of the cloud, then
    no new smoke edge is created. Guards won't be able to see through the door, but won't have any
    reaction to the cloud.
  * **Fix** Smoke edge fake units keep track of the clouds that they're part of. Smoke edges only
    despawn when they have no associated clouds remaining.
  * **Fix** Smoke edge units are spawned at all tiles that are just beyond the cloud's boundary,
    but are only visible to guards if there's an open adjacency into the actual cloud. This is kept
    updated whenever doors/walls are modified. (Technical note: smoke edge units manage their
    visibility by moving off the map when disconnected from their cloud.)
  * **Credit**: Qoalabear
* Smoke grenades: Guards remember edges
  * Because guards react to the cloud via these smoke edge units as proxies, guards don't know
    whether or not they've already investigated a smoke cloud. They'll become redistracted when they
    see another cell of the cloud's edge. Also, unlike bodies, they make no attempt to track this on
    smoke clouds/edges. This re-distraction appeared inconsistently because it was only available on
    the edge tiles just past the cloud's boundary, not within the cloud.
  * **Fix** Guards make note of clouds that they've investigated and ignore any further edges of
    those clouds.
  * **Credit**: Qoalabear

## Always-Enabled Fixes

These are mostly either fixes for bugs that crash/softlock the game or UI fixes that don't allow the
player to do things they couldn't otherwise.

* Alarm Wheel: Tooltip incorrectly used the "advanced alarms" text
  * The text intended for the latter portion of an extended campaign is accidentally used at all times.
  * **Fix**: Use the normal alarms text when advanced alarms aren't present.
  * **Fix**: Parameterize the number of alarm stages using the existing simdefs value. (For mods)
  * **Credit**: Qoalabear, Cyberboy2000
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
* Disguise Fixes
  * Crash if the disguise is on the ground.
  * Re-captured cameras/turrets have different metadata compared to their original state. This difference allows them to
    break disguises if walking too close.
  * **Fix**: Don't crash if the disguise is on the ground.
  * **Fix**: Disguise no longer breaks on re-captured cameras/turrets.
  * **Fix**: More consistent behavior when multiple guards are in detection range.
  * **Credit**: wodzu\_93
* Rubiks on Mission Devicces
  * If data banks or mission-consoles in the final mission have Rubiks, they gain a firewall from the Daemon while still
    being agency controlled. This prevents them from being used.
  * **Fix**: Affected abilities check for device ownership instead of 0 firewalls.
  * **Credit**: wodzu\_93
* Modded: CFO Disguise can drag
  * If an agent is disguised as the CFO, or a similar "business man", attempting to drag a body
    fails. The business man animation defs don't include the default dragging animation.
  * **Fix**: Include the default dragging animation on the business man template.
  * **Credit**: Hekateras
* Modded: UI script events during a dialog
  * It was possible for scripted UI events to try to dismiss an unrelated dialog that was being
    displayed. Some, like the Executive Terminals "choose 1 of 4 sites" dialog, can't handle being
    dismissed.
  * **Fix**: Pause the offending event queue while a dialog is open.
  * **Credit**: Qoalabear
* Modded: Shirsh's Mod Combo Scanning Beacons are not agentic
  * The Scanning Beacons item, found in Shirsh's Mod Combo or originally in the Dr. Pedler mod,
    incorrectly declares itself as `isAgent`. This causes bugs in other mods (such as Advanced
    Cyber Warfare, but may also apply in vanilla) that attempt to loop over all player-controlled
    agents.
  * **Fix**: Patch the scanning beacons with the `isAgent` trait cleared.
  * **Credit**: Qoalabear
