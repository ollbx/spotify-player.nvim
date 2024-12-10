local M = {}

--- Runs spotify-player command.
function M.cmd(args)
	return vim.system({ 'spotify_player', unpack(args) }):wait()
end

--- Likes the current track.
function M.like()
	M.cmd({ 'like' })
end

--- Unlikes the current track.
function M.unlike()
	M.cmd({ 'like', '-u' })
end

--- Returns liked tracks.
function M.get_liked()
	local res = M.cmd({ 'get', 'key', 'user-liked-tracks' })

	if res.code ~= 0 then
		return nil
	end

	return vim.json.decode(res.stdout)
end

--- Returns a map of all liked track IDs.
function M.get_liked_ids()
	local data = M.get_liked()
	local ids = {}

	for _, track in ipairs(data) do
		ids[track.id] = true
	end

	return ids
end

--- Returns information about the current playback.
function M.get_playback()
	local res = M.cmd({ 'get', 'key', 'playback' })

	if res.code ~= 0 then
		return nil
	end

	return vim.json.decode(res.stdout)
end

--- Returns high-level info about the currently played item.
function M.get_info()
	local data = M.get_playback()
	local liked = M.get_liked_ids()

	return {
		track_id = data.item.id,
		is_playing = data.is_playing,
		is_liked = not not liked[data.item.id],
		volume = data.device.volume_percent,
		repeat_state = data.repeat_state,
		shuffle = data.shuffle_state,
		device = data.device.name,
		title = data.item.name,
		album = data.item.album.name,
		artist = data.item.artists[1].name,
	}
end

--- Determines if the current title is liked.
function M.is_liked()
	local liked = M.get_liked_ids()
	local id = M.get_title_id()
	return not not liked[id]
end

--- Determines if music is currently playing.
function M.is_playing()
	return M.get_playback().is_playing
end

--- Returns the name of the playback device in use.
function M.get_device()
	return M.get_playback().device.name
end

--- Returns the repeat state.
function M.get_repeat_state()
	return M.get_playback().repeat_state
end

--- Returns the shuffle state (false, true).
function M.get_shuffle_state()
	return M.get_playback().shuffle_state
end

--- Returns the album of the current track.
function M.get_album()
	return M.get_playback().item.album.name
end

--- Returns the title of the current track.
function M.get_title()
	return M.get_playback().item.name
end

--- Returns the (first) artist of the current track.
function M.get_artist()
	return M.get_playback().item.artists[1].name
end

--- Returns the spotify ID of the current title.
function M.get_title_id()
	return M.get_playback().item.id
end

--- Toggles between pause and play.
function M.play_pause()
	M.cmd({ 'playback', 'play-pause' })
end

--- Starts playing.
function M.play()
	M.cmd({ 'playback', 'play' })
end

--- Stops playing.
function M.pause()
	M.cmd({ 'playback', 'pause' })
end

--- Advances to the next track.
function M.next()
	M.cmd({ 'playback', 'next' })
end

--- Advances to the previous track.
function M.prev()
	M.cmd({ 'playback', 'previous' })
end

--- Toggles the shuffle mode.
function M.toggle_shuffle()
	M.cmd({ 'playback', 'shuffle' })
end

--- Toggles the repeat mode.
function M.toggle_repeat()
	M.cmd({ 'playback', 'repeat' })
end

--- Sets the volume in percent.
function M.volume(percent)
	M.cmd({ 'playback', 'volume', percent })
end

--- Increases or decreases the volume by the given offset.
function M.change_volume(offset)
	M.cmd({ 'playback', 'volume', '--offset', '--', offset })
end

-- Prints a message with info about the current playback.
function M.print_info()
	local info = M.get_info()
	local text = ""

	if info.is_playing then
		text = text .. " "
	else
		text = text .. " "
	end

	if info.is_liked then
		text = text .. " "
	else
		text = text .. "  "
	end

	text = text .. info.title .. " (by " .. info.artist .. ")"
	text = text .. " (volume " .. info.volume .. "%)"

	print(text)
end

return M
