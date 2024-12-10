# spotify-player.nvim

This is a simple plugin to control [spotify-player](https://github.com/aome510/spotify-player) through neovim.

## Example setup with lazy.nvim

```lua
local function print_info()
	require("spotify-player").print_info()
end

local function like()
	require("spotify-player").like()
	vim.defer_fn(print_info, 100)
end

local function unlike()
	require("spotify-player").unlike()
	vim.defer_fn(print_info, 100)
end

local function volume_down()
	require("spotify-player").change_volume(-10)
	vim.defer_fn(print_info, 100)
end

local function volume_up()
	require("spotify-player").change_volume(10)
	vim.defer_fn(print_info, 100)
end

local function play_pause()
	require("spotify-player").play_pause()
	vim.defer_fn(print_info, 100)
end

local function prev()
	require("spotify-player").prev()
	vim.defer_fn(print_info, 1500)
end

local function next()
	require("spotify-player").next()
	vim.defer_fn(print_info, 1500)
end

local function search_track()
	local p = require("spotify-player");
	p.search_track(function(track)
		if track then
			p.play_track(track.id)
			vim.defer_fn(print_info, 1500)
		end
	end)
end

local function search_artist()
	local p = require("spotify-player");
	p.search_artist(function(artist)
		if artist then
			p.play_artist(artist.id)
			vim.defer_fn(print_info, 1500)
		end
	end)
end

local function search_album()
	local p = require("spotify-player");
	p.search_album(function(album)
		if album then
			p.play_album(album.id)
			vim.defer_fn(print_info, 1500)
		end
	end)
end

return {
	"ollbx/spotify-player.nvim",
	keys = {
		{ "<leader>pp",  play_pause,    desc = "Play/pause" },
		{ "<leader>pr",  prev,          desc = "Previous" },
		{ "<leader>pn",  next,          desc = "Next" },
		{ "<leader>p+",  volume_up,     desc = "Volume up" },
		{ "<leader>p-",  volume_down,   desc = "Volume down" },
		{ "<leader>pl",  like,          desc = "Like" },
		{ "<leader>pu",  unlike,        desc = "Unlike" },
		{ "<leader>pst", search_track,  desc = "Track" },
		{ "<leader>psa", search_artist, desc = "Artist" },
		{ "<leader>psl", search_album,  desc = "Album" },
		{ "<leader>pi",  print_info,    desc = "Show info" },
	}
}
