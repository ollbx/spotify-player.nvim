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
	state._track = playback.item.name
	state._artist = playback.item.artists[1].name
	state._artist_id = playback.item.artists[1].id
	state._album = playback.item.album.name
	state._album_id = playback.item.album.id
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

	if self:get_track() ~= old_state:get_title() then
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

--- Returns the current repeat mode. One of 'off', 'track' or 'context'.
function State:get_repeat_mode()
	return self._repeat_mode
end

--- Returns `true` if shuffle is enabled.
function State:is_shuffle()
	return self._is_shuffle
end

--- Returns the spotify ID of the track.
function State:get_track_id()
	return self._track_id
end

--- Returns the name of the track.
function State:get_track()
	return self._track
end

--- Returns the name of the artist.
function State:get_artist()
	return self._artist
end

--- Returns the spotify ID of the artist.
function State:get_artist_id()
	return self._artist_id
end

--- Returns the name of the album.
function State:get_album()
	return self._album
end

--- Returns the spotify ID of the album.
function State:get_album_id()
	return self._album_id
end

--- Returns `true` if the music is currently playing.
function State:is_playing()
	return self._is_playing
end

--- Returns `true` if the current track is on the list of liked tracks.
function State:is_liked()
	return self._is_liked
end

--- Returns the current volume.
function State:get_volume()
	return self._volume
end

--- Returns the current playback device.
function State:get_device()
	return self._device
end

--- Returns the time elapsed since the last state update.
function State:get_elapsed_ms()
	return vim.uv.now() - self._update_ms
end

--- Returns the playback position.
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

--- Returns the playback position in percent.
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

--- Returns the track duration.
function State:get_duration_ms()
	return self._duration_ms
end

--- Returns the remaining playback time on the track.
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
