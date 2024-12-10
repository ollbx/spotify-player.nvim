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

--- Searches using the given query.
function M.search(query)
	local res = M.cmd({ 'search', query })

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

--- Prints a message with info about the current playback.
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

--- Starts a radio from with the given track.
function M.play_track(id)
	M.cmd({ 'playback', 'start', 'radio', '-i', id, 'track'})
end

--- Starts playing the given artist.
function M.play_artist(id)
	M.cmd({ 'playback', 'start', 'context', '-i', id, 'artist'})
end

--- Starts playing the given album.
function M.play_album(id)
	M.cmd({ 'playback', 'start', 'context', '-i', id, 'album'})
end

--- Opens a select for tracks matching a query.
function M.select_track(query, cb)
	local result = M.search(query)
	local opts = { format_item = function(track)
		return track.name .. " by " .. track.artists[1].name
	end }
	vim.ui.select(result.tracks, opts, cb)
end

--- Opens a select for artists matching a query.
function M.select_artist(query, cb)
	local result = M.search(query)
	local opts = { format_item = function(artist)
		return artist.name
	end }
	vim.ui.select(result.artists, opts, cb)
end

--- Opens a select for albums matching a query.
function M.select_album(query, cb)
	local result = M.search(query)
	local opts = { format_item = function(album)
		return album.name .. " by " .. album.artists[1].name
	end }
	vim.ui.select(result.albums, opts, cb)
end

--- Interactively search for a track.
function M.search_track(cb)
	local input = vim.fn.input({ prompt = "Track: " })

	if input then
		local player = require("spotify-player")
		player.select_track(input, cb)
	end
end

--- Interactively search for an artist.
function M.search_artist(cb)
	local input = vim.fn.input({ prompt = "Artist: " })

	if input then
		local player = require("spotify-player")
		player.select_artist(input, cb)
	end
end

--- Interactively search for an album.
function M.search_album(cb)
	local input = vim.fn.input({ prompt = "Album: " })

	if input then
		local player = require("spotify-player")
		player.select_album(input, cb)
	end
end

return M
