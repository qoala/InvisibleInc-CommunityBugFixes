-- patch to client/hud/mission_panel

local mission_panel = include( "hud/mission_panel" )

local oldProcessEvent = mission_panel.processEvent
function mission_panel:processEvent( ... )

	while self._hud._choice_dialog ~= nil do
		-- A dialog is open, which may not be skippable.
		-- Pause the queue until that dialog has been closed.
		self:yield()
	end

	oldProcessEvent( self, ... )
end
