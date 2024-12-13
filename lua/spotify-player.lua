local State = require("spotify-player.state")

local M = {}

local update_timer = nil
local cached_liked = nil
local cached_state = nil
local opts = {}

local default_opts = {
	notify_cb = function(state)
		local text = ""

		if state:is_playing() then
			text = text .. " "
		else
			text = text .. " "
		end

		if state:is_liked() then
			text = text .. " "
		else
			text = text .. ""
		end

		if state:is_shuffle() then
			text = text .. " "
		else
			text = text .. ""
		end

		if state:get_repeat_mode() == 'track' then
			text = text .. "󰑘 "
		elseif state:get_repeat_mode() == 'context' then
			text = text .. "󰑖 "
		else
			text = text .. ""
		end

		text = text .. state:get_title() .. " (by " .. state:get_artist() .. ")"
		text = text .. " (volume " .. state:get_volume() .. "%)"

		vim.notify(text)
	end,
	schedule_update = true,
}

local CMD_TIMEOUT = 1000
local SEARCH_TIMEOUT = 15000
local UPDATE_TIMEOUT = 5000
local UPDATE_DELAY = 1000

--- Runs spotify-player command.
local function run_cmd(args, cb, to)
	return vim.system(
		{ 'spotify_player', unpack(args) },
		{ timeout = to or CMD_TIMEOUT },
		cb)
end

function M.setup(user_opts)
	opts = vim.tbl_deep_extend('keep', user_opts, default_opts)
end

function M.get_opts()
	return opts
end

--- Updates the cached likes. Calls `cb` afterwards.
function M.update_liked(cb)
	vim.system(
		{ 'spotify_player', 'get', 'key', 'user-liked-tracks' },
		{ timeout = UPDATE_TIMEOUT },
		function(res)
			if res.code == 0 then
				local data = vim.json.decode(res.stdout)

				if data ~= nil then
					local map = {}

					for _, track in ipairs(data) do
						map[track.id] = true
					end

					cached_liked = map
				end
			end

			if cb ~= nil then
				vim.schedule(function()
					cb(cached_liked)
				end)
			end
		end
	)
end

--- Updates the cached state. Calls `cb` afterwards.
function M.update_state(cb)
	-- Update liked tracks first, if we don't have it.
	if cached_liked == nil then
		M.update_liked(function()
			M.update_state(cb)
		end)
	else
		vim.system(
			{ 'spotify_player', 'get', 'key', 'playback' },
			{ timeout = UPDATE_TIMEOUT },
			function(res)
				if res.code == 0 and res.stdout ~= nil then
					local playback = vim.json.decode(res.stdout)

					if playback ~= nil then
						cached_state = State.new(cached_liked, playback)
					end
				end

				if cb ~= nil then
					vim.schedule(function()
						cb(cached_state)
					end)
				end

				if opts.schedule_update and cached_state ~= nil and cached_state:is_playing() then
					local remaining = cached_state:get_remaining_ms();

					if remaining ~= nil then
						-- Stop the old timer.
						if update_timer ~= nil then
							update_timer:close()
							update_timer = nil
						end

						update_timer = vim.uv.new_timer()

						if update_timer ~= nil then
							update_timer:start(remaining + UPDATE_DELAY, 0, function()
								update_timer:close()
								update_timer = nil

								vim.schedule(function()
									M.update_state(opts.notify_cb)
								end)
							end)
						end
					end
				end
			end
		)
	end
end

--- Returns the current update timer value.
function M.get_timer_ms()
	if update_timer ~= nil then
		return update_timer:get_due_in()
	else
		return nil
	end
end

--- Returns the cached liked track IDs.
function M.get_cached_state()
	return cached_state
end

--- Returns the cached state. Updates if required.
function M.get_state()
	if cached_state == nil then
		M.update_state()

		vim.wait(CMD_TIMEOUT, function()
			return cached_state ~= nil
		end)
	end

	return cached_state
end

--- Returns the cached liked track IDs.
function M.get_cached_liked()
	return cached_liked
end

--- Returns the cached liked track IDs. Updates if required.
function M.get_liked()
	if cached_liked == nil then
		M.update_liked()

		vim.wait(CMD_TIMEOUT, function()
			return cached_liked ~= nil
		end)
	end

	return cached_liked
end

function M.trigger_notify()
	M.update_state(opts.notify_cb)
end

--- Unlikes the current track.
function M.toggle_like()
	M.update_state(function()
		if not cached_liked then return end
		if not cached_state then return end

		if cached_state:is_liked() then
			run_cmd({ 'like', '-u' })
			cached_state._is_liked = false
			cached_liked[cached_state._track_id] = nil
		else
			run_cmd({ 'like' })
			cached_state._is_liked = true
			cached_liked[cached_state._track_id] = true
		end

		opts.notify_cb(cached_state)
	end)
end

--- Pause playback.
function M.pause()
	M.update_state(function()
		if not cached_state then return end

		run_cmd({ 'playback', 'pause' })
		cached_state._is_playing = false
		opts.notify_cb(cached_state)
	end)
end

--- Resume playback.
function M.play()
	M.update_state(function()
		if not cached_state then return end

		run_cmd({ 'playback', 'play' })
		cached_state._is_playing = true
		opts.notify_cb(cached_state)
	end)
end

--- Toggle pause.
function M.toggle_pause()
	M.update_state(function()
		if not cached_state then return end

		run_cmd({ 'playback', 'play-pause' })
		cached_state._is_playing = not cached_state._is_playing
		opts.notify_cb(cached_state)
	end)
end

--- Advances to the next track.
function M.next()
	run_cmd({ 'playback', 'next' }, function()
		vim.defer_fn(function()
			M.update_state(opts.notify_cb)
		end, UPDATE_DELAY)
	end)
end

--- Advances to the previous track.
function M.prev()
	run_cmd({ 'playback', 'previous' }, function()
		vim.defer_fn(function()
			M.update_state(opts.notify_cb)
		end, UPDATE_DELAY)
	end)
end

--- Sets the volume in percent.
function M.volume(percent)
	if percent < 0 or percent > 100 then
		return
	end

	M.update_state(function()
		if not cached_state then return end

		run_cmd({ 'playback', 'volume', percent })

		cached_state._volume = percent
		opts.notify_cb(cached_state)
	end)
end

--- Increases or decreases the volume by the given offset.
function M.change_volume(offset)
	if type(offset) ~= "number" then
		return
	end

	M.update_state(function()
		if not cached_state then return end

		run_cmd({ 'playback', 'volume', '--offset', '--', offset })
		cached_state._volume = cached_state._volume + offset

		if cached_state._volume < 0 then
			cached_state._volume = 0
		end

		if cached_state._volume > 100 then
			cached_state._volume = 100
		end

		opts.notify_cb(cached_state)
	end)
end

--- Searches using the given query.
function M.search(query, cb)
	run_cmd({ 'search', query }, function(res)
		if res.code == 0 then
			local data = vim.json.decode(res.stdout)

			if data ~= nil then
				if cb ~= nil then
					vim.schedule(function()
						cb(data)
					end)
				end
			end
		end

		if res.code == 124 then
			vim.schedule(function()
				vim.notify("Search timeout.")
			end)
		end
	end, SEARCH_TIMEOUT)
end

--- Toggles the shuffle mode.
function M.toggle_shuffle()
	M.update_state(function()
		if not cached_state then return end

		run_cmd({ 'playback', 'shuffle' })
		cached_state._is_shuffle = not cached_state._is_shuffle
		opts.notify_cb(cached_state)
	end)
end

--- Cycles the repeat mode.
function M.cycle_repeat()
	run_cmd({ 'playback', 'repeat' }, function()
		vim.defer_fn(function()
			M.update_state(opts.notify_cb)
		end, UPDATE_DELAY)
	end)
end

--- Starts a radio from with the given track.
function M.play_track(id)
	run_cmd({ 'playback', 'start', 'radio', '-i', id, 'track'}, function()
		vim.defer_fn(function()
			M.update_state(opts.notify_cb)
		end, UPDATE_DELAY)
	end)
end

--- Starts playing the given artist.
function M.play_artist(id)
	run_cmd({ 'playback', 'start', 'context', '-i', id, 'artist'}, function()
		vim.defer_fn(function()
			M.update_state(opts.notify_cb)
		end, UPDATE_DELAY)
	end)
end

--- Starts playing the given album.
function M.play_album(id)
	run_cmd({ 'playback', 'start', 'context', '-i', id, 'album'}, function()
		vim.defer_fn(function()
			M.update_state(opts.notify_cb)
		end, UPDATE_DELAY)
	end)
end

--- Opens a select for tracks matching a query.
function M.search_track(query, cb)
	if query == nil then
		query = vim.fn.input({ prompt = "Track: " })
	end

	if not query or query == '' then
		return
	end

	M.search(query, function(data)
		local sel_opts = { format_item = function(track)
			return track.name .. " by " .. track.artists[1].name
		end }
		vim.ui.select(data.tracks, sel_opts, cb or function(track)
			if track then
				M.play_track(track.id)
			else
				vim.notify("Selection aborted.")
			end
		end)
	end)
end

--- Opens a select for artists matching a query.
function M.search_artist(query, cb)
	if query == nil then
		query = vim.fn.input({ prompt = "Artist: " })
	end

	if not query or query == '' then
		return
	end

	M.search(query, function(data)
		local sel_opts = { format_item = function(artist)
			return artist.name
		end }
		vim.ui.select(data.artists, sel_opts, cb or function(artist)
			if artist then
				M.play_artist(artist.id)
			else
				vim.notify("Selection aborted.")
			end
		end)
	end)
end

--- Opens a select for albums matching a query.
function M.search_album(query, cb)
	if query == nil then
		query = vim.fn.input({ prompt = "Album: " })
	end

	if not query or query == '' then
		return
	end

	M.search(query, function(data)
		local sel_opts = { format_item = function(album)
			return album.name .. " by " .. album.artists[1].name
		end }
		vim.ui.select(data.albums, sel_opts, cb or function(album)
			if album then
				M.play_album(album.id)
			else
				vim.notify("Selection aborted.")
			end
		end)
	end)
end

return M
