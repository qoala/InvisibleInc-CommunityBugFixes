# Available Bug Fixes

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
  * **Credit**: Qoalabear
