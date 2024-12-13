# spotify-player.nvim

This is a simple plugin to control [spotify-player](https://github.com/aome510/spotify-player) through neovim.

## Example setup with lazy.nvim

```lua
local function mod()
	return require("spotify-player")
end

return {
	"ollbx/spotify-player.nvim",
	opts = {},
	keys = {
		{ "<leader>pp",  function() mod().toggle_pause() end,     desc = "Play/pause" },
		{ "<leader>pN",  function() mod().prev() end,             desc = "Previous" },
		{ "<leader>pn",  function() mod().next() end,             desc = "Next" },
		{ "<leader>p+",  function() mod().change_volume(10) end,  desc = "Volume up" },
		{ "<leader>p-",  function() mod().change_volume(-10) end, desc = "Volume down" },
		{ "<leader>pl",  function() mod().toggle_like() end,      desc = "Like" },
		{ "<leader>ps",  function() mod().toggle_shuffle() end,   desc = "Shuffle" },
		{ "<leader>pr",  function() mod().cycle_repeat() end,     desc = "Repeat" },
		{ "<leader>pft", function() mod().search_track() end,     desc = "Track" },
		{ "<leader>pfa", function() mod().search_artist() end,    desc = "Artist" },
		{ "<leader>pfl", function() mod().search_album() end,     desc = "Album" },
		{ "<leader>pi",  function() mod().trigger_notify() end,   desc = "Show info" },
	}
}
```

