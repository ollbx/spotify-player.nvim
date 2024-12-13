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

Note: `spotify_player` currently needs to be in `PATH` for the plugin to work.

## Configuration

```lua
local opts = {
    notify_cb = function(state)
        -- Update status bar / notify whatever.
    end,

    -- If `true`, a state update is automatically requested at the end of the
    -- currently playing track, in order to trigger `notify_cb(state)`.
    schedule_update = true,
}
```

The default `notify_cb` will call `vim.notify` to show information about the current state / track.

## API

| Function                   | Description                                                             |
| -------------------------- | ----------------------------------------------------------------------- |
| `update_liked(cb)`         | Updates the list of liked tracks. Then calls `cb` with the data.        |
| `update_state(cb)`         | Updates the state. Then calls `cb` with the new state.                  |
| `get_liked()`              | Returns the list of liked tracks.                                       |
| `get_state()`              | Returns the current state.                                              |
| `trigger_notify()`         | Updates the state and then triggers the notify callback.                |
| `toggle_like()`            | Enables / disables "like" for the current track.                        |
| `pause()`                  | Pauses playback.                                                        |
| `play()`                   | Starts playback.                                                        |
| `toggle_pause()`           | Toggles between paused and playing state.                               |
| `next()`                   | Skips to the next track.                                                |
| `prev()`                   | Skips to the previous track.                                            |
| `volume(percent)`          | Sets the volume to the given level.                                     |
| `change_volume(offset)`    | Changes the volume by the given `offset` (positive or negative).        |
| `toggle_shuffle()`         | Enables / disables shuffle mode.                                        |
| `cycle_repeat()`           | Cycles between the available repeat modes (off, track, context).        |
| `search(query, cb)`        | Searches using the given `query`. Calls `cb` with the results.          |
| `play_track(id)`           | Plays the given track.                                                  |
| `play_artist(id)`          | Plays the given artist.                                                 |
| `play_album(id)`           | Plays the given album.                                                  |
| `search_track(query, cb)`  | Select a track with the given `query`. Calls `cb` with the selection.   |
|                            | Interactively asks for the query if `query` is `nil`.                   |
|                            | Plays the track if `cb` is `nil`.                                       |
| `search_artist(query, cb)` | Select an artist with the given `query`. Calls `cb` with the selection. |
|                            | Interactively asks for the query if `query` is `nil`.                   |
|                            | Plays the artist if `cb` is `nil`.                                      |
| `search_album(query, cb)`  | Select an album with the given `query`. Calls `cb` with the selection.  |
|                            | Interactively asks for the query if `query` is `nil`.                   |
|                            | Plays the album if `cb` is `nil`.                                       |

## State API

| Function                       | Description                                            |
| ------------------------------ | ------------------------------------------------------ |
| `state:get_repeat_mode()`      | Returns the current repeat mode (off, track, context). |
| `state:is_shuffle()`           | Returns `true` if shuffle is enabled.                  |
| `state:is_playing()`           | Returns `true` if music is currently playing.          |
| `state:is_liked()`             | Returns `true` if the current track is "liked".        |
| `state:get_track()`            | Returns the name of the current track.                 |
| `state:get_album()`            | Returns the name of the current album.                 |
| `state:get_artist()`           | Returns the name of the current artist.                |
| `state:get_track_id()`         | Returns the spotify ID of the current track.           |
| `state:get_album_id()`         | Returns the spotify ID of the current album.           |
| `state:get_artist_id()`        | Returns the spotify ID of the current artist.          |
| `state:get_volume()`           | Returns the current playback volume in percent.        |
| `state:get_device()`           | Returns the current playback device.                   |
| `state:get_elapsed_ms()`       | Returns the time elapsed since the last status update. |
| `state:get_position_ms()`      | Returns the playback position.                         |
| `state:get_position_percent()` | Returns the playback position in percent.              |
| `state:get_duration_ms()`      | Returns the track duration.                            |
| `state:get_remaining_ms()`     | Returns the remaining time in the current track.       |
