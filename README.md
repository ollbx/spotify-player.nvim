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
	require("spotify-player").search_track(function()
		vim.defer_fn(print_info, 1500)
	end)
end

return {
	"ollbx/spotify-player.nvim",
	keys = {
		{ "<leader>p",  nil,          desc = "Spotify" },
		{ "<leader>ps", play_pause,   desc = "Play/pause" },
		{ "<leader>pp", prev,         desc = "Previous" },
		{ "<leader>pn", next,         desc = "Next" },
		{ "<leader>p+", volume_up,    desc = "Volume up" },
		{ "<leader>p-", volume_down,  desc = "Volume down" },
		{ "<leader>pl", like,         desc = "Like" },
		{ "<leader>pu", unlike,       desc = "Unlike" },
		{ "<leader>pf", search_track, desc = "Find track" },
		{ "<leader>pi", print_info,   desc = "Show info" },
	}
}
