-- patch to client/include.lua

-- Override the reinclude global function.
--   Called on mission scripts.
--   reinclude only differs from include with config.DEV enabled, where it tries to reload a file
--   without restarting Invisible Inc. However, this wipes out mod overrides.
reinclude = include
