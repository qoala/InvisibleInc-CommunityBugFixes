# Available Bug Fixes

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
