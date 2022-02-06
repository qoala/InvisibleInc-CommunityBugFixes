
_M = {}

-- Check if a flag is enabled on the sim
function _M.simCheckFlag(sim, flag, default)
	return _M.optionsCheckFlag(sim:getParams().difficultyOptions, flag, default)
end

-- Check if a flag is enabled on the given difficultyOptions
function _M.optionsCheckFlag(difficultyOptions, flag, default)
	if difficultyOptions.cbf_params then
		return difficultyOptions.cbf_params[flag] or default
	else
		return difficultyOptions[flag] or default
	end
end

-- Extract a local variable from the given function's upvalues
function _M.extractUpvalue( fn, name )
	local i = 1
	while true do
		local n, v = debug.getupvalue(fn, i)
		assert(n, string.format( "Could not find upvalue: %s", name ) )
		if n == name then
			return v, i
		end
		i = i + 1
	end
end

return _M
