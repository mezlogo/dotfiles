-- ~/.config/hypr/hyprland.lua
-- Rewritten from hyprland.conf to the new Lua API.

------------------
---- MONITORS ----
------------------

hl.monitor({ output = "DP-2",  mode = "preferred", position = "auto", scale = "auto" })
hl.monitor({ output = "DP-1",  mode = "preferred", position = "auto", scale = "auto" })
hl.monitor({ output = "",      mode = "preferred", position = "auto", scale = "auto" })
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 2 })

---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "wofi --show drun"
local mainMod     = "SUPER"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
  hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
  hl.exec_cmd("waybar")

  -- Clipboard history watchers
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")

  -- Start btop on workspace 5 silently
  hl.exec_cmd("hyprctl dispatch exec '[workspace 5 silent] kitty btop'")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("TERM", "kitty")
hl.env("SSH_AUTH_SOCK", "$XDG_RUNTIME_DIR/ssh-agent.socket")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
  general = {
    gaps_in  = 0,
    gaps_out = 0,
    border_size = 1,

    col = {
      active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
      inactive_border = "rgba(595959aa)",
    },

    resize_on_border = false,
    allow_tearing    = false,
    layout           = "dwindle",
  },

  decoration = {
    rounding = 0,
    shadow   = { enabled = false },
    blur     = { enabled = false },
  },

  animations = {
    enabled = false,
  },

  dwindle = {
    preserve_split = true,
  },

  master = {
    new_status = "master",
  },

  misc = {
    force_default_wallpaper = 0,
    disable_hyprland_logo   = true,
    background_color        = 0x000000,
    focus_on_activate       = false,
  },
})

---------------
---- INPUT ----
---------------

hl.config({
  input = {
    kb_layout    = "us,ru",
    kb_options   = "grp:win_space_toggle",
    follow_mouse = 0,
    sensitivity  = 0,
    mouse_refocus = false,

    touchpad = {
      natural_scroll = true,
    },
  },
})

---------------------
---- KEYBINDINGS ----
---------------------

-- Resize submap
hl.bind(mainMod .. " + r", hl.dsp.submap("resize"))

local rs = "resize"

hl.bind("Right", hl.dsp.window.resize({ x = 100,  y = 0   }), { repeating = true, submap = rs })
hl.bind("Left",  hl.dsp.window.resize({ x = -100, y = 0   }), { repeating = true, submap = rs })
hl.bind("Down",  hl.dsp.window.resize({ x = 0,    y = 100 }), { repeating = true, submap = rs })
hl.bind("Up",    hl.dsp.window.resize({ x = 0,    y = -100}), { repeating = true, submap = rs })

hl.bind("SHIFT + Right", hl.dsp.window.resize({ x = 10,  y = 0  }), { repeating = true, submap = rs })
hl.bind("SHIFT + Left",  hl.dsp.window.resize({ x = -10, y = 0  }), { repeating = true, submap = rs })
hl.bind("SHIFT + Down",  hl.dsp.window.resize({ x = 0,   y = 10 }), { repeating = true, submap = rs })
hl.bind("SHIFT + Up",    hl.dsp.window.resize({ x = 0,   y = -10}), { repeating = true, submap = rs })

hl.bind("Escape", hl.dsp.submap("reset"), { submap = rs })
hl.bind("Return", hl.dsp.submap("reset"), { submap = rs })

-- Main binds
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal .. " tmux new-session -A -s default"))
hl.bind(mainMod .. " + F",      hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V",      hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D",      hl.dsp.exec_cmd(menu))

-- Focus
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Workspaces
for i = 1, 10 do
  local key = i % 10 -- 10 maps to key 0
  hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, silent = true }))
end

-- Focus next floating window and bring to top
hl.bind(mainMod .. " + Tab", hl.dsp.exec_cmd("hyprctl dispatch cyclenext floating && hyprctl dispatch bringactivetotop"))

hl.config({
  binds = {
    workspace_back_and_forth = true,
  },
})

-- Screenshots
hl.bind("Print", hl.dsp.exec_cmd([[grim -g "$(slurp)" $HOME/Pictures/$(date +'%Y-%m-%d-%H-%M-%S.png')]]))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd([[grim -o "$(hyprctl -j monitors | jq -r '.[] | select(.focused) | .name')" $HOME/Pictures/$(date +'%Y-%m-%d-%H-%M-%S.png')]]))

-- Clipboard manager
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy"))

-- Move/resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Multimedia keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl set +10%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl set 10%-"), { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Push-to-talk / release
hl.bind(mainMod .. " + grave", hl.dsp.exec_cmd("$HOME/repos/mezlogo/forme/projects/asr_nemotron_wtype/push_to_talk_unix_client.sh"))
hl.bind(mainMod .. " + grave", hl.dsp.exec_cmd("$HOME/repos/mezlogo/forme/projects/asr_nemotron_wtype/release.sh"), { release = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
  name  = "jetbrains center floating",
  match = { class = "jetbrains-idea", float = true },
  center = true,
})

hl.window_rule({
  name  = "jetbrains suppress popup focus",
  match = { class = "jetbrains-idea", title = "^win.*" },
  no_initial_focus = true,
  suppress_event   = "activatefocus",
})

hl.workspace_rule({ workspace = "5", monitor = "eDP-1", default = true })
hl.workspace_rule({ workspace = "6", monitor = "eDP-1" })
