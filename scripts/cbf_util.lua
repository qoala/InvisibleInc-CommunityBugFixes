
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

return _M
