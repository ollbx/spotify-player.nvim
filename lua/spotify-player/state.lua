local State = {}

function State.new(liked, playback)
	local state = setmetatable({}, {
		__index = State,
	})

	state._track_id = playback.item.id
	state._is_playing = playback.is_playing
	state._volume = playback.device.volume_percent
	state._position_ms = playback.progress_ms
	state._duration_ms = playback.item.duration_ms
	state._title = playback.item.name
	state._artist = playback.item.artists[1].name
	state._album = playback.item.album.name
	state._device = playback.device.name
	state._is_liked = liked[state._track_id] ~= nil
	state._repeat_mode = playback.repeat_state
	state._is_shuffle = playback.shuffle_state
	state._update_ms = vim.uv.now()
	return state
end

--- Returns `true` if there is a significant change.
function State:has_changed(old_state)
	if old_state == nil then
		return true
	end

	if self:get_title() ~= old_state:get_title() then
		return true
	end

	if self:is_liked() ~= old_state:is_liked() then
		return true
	end

	if self:is_playing() ~= old_state:is_playing() then
		return true
	end

	return false
end

function State:get_repeat_mode()
	return self._repeat_mode
end

function State:is_shuffle()
	return self._is_shuffle
end

function State:get_track_id()
	return self._track_id
end

function State:get_title()
	return self._title
end

function State:get_artist()
	return self._artist
end

function State:get_album()
	return self._album
end

function State:is_playing()
	return self._is_playing
end

function State:is_liked()
	return self._is_liked
end

function State:get_volume()
	return self._volume
end

function State:get_device()
	return self._device
end

function State:get_elapsed_ms()
	return vim.uv.now() - self._update_ms
end

function State:get_position_ms()
	if self._position_ms == nil then
		return nil
	end

	if self._is_playing then
		return self._position_ms + self:get_elapsed_ms()
	else
		return self._position_ms
	end
end

function State:get_position_percent()
	local duration = self:get_duration_ms()
	local position = self:get_position_ms()

	if duration == nil or position == nil then
		return nil
	end

	if position > duration then
		return 100.0
	else
		return 100.0 * position / duration
	end
end

function State:get_duration_ms()
	return self._duration_ms
end

function State:get_remaining_ms()
	local duration = self:get_duration_ms()
	local position = self:get_position_ms()

	if duration == nil or position == nil then
		return nil
	end

	if position > duration then
		return 0
	else
		return duration - position
	end
end

return State