-- Hyprland Lua config (v0.55+)
-- Migrated from hyprland.conf

local terminal = "konsole"
local fileManager = "dolphin"
local menu = "rofi -show drun"
local browser = "google-chrome-stable"
local mainMod = "SUPER"

hl.on("hyprland.start", function()
    hl.exec_cmd("/usr/lib/pam_kwallet_init")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    hl.exec_cmd("waybar & swaync & hypridle & hyprpaper")
    hl.exec_cmd("kwalletd6")
    hl.exec_cmd("hyprctl setcursor Future-cursors 24")
    hl.exec_cmd("kdeconnect-indicator")
    hl.exec_cmd("hyprsunset")
    hl.exec_cmd("dropbox start -i")
    hl.exec_cmd("clipse -listen")
end)

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "kde")

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 15,
        border_size = 4,
        col = {
            active_border = { colors = { "rgba(19f7ffee)", "rgba(19f7ffee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding = 5,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = true,
    },

    input = {
        kb_layout = "us,ara",
        kb_variant = "",
        kb_model = "",
        kb_options = "grp:alt_shift_toggle",
        kb_rules = "",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 4, direction = "up", action = "fullscreen", mode = "maximize" })
hl.gesture({ fingers = 4, direction = "down", action = "close" })

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind("ALT + Space", hl.dsp.exec_cmd(menu))

hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("~/.config/waybar/launch.sh"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/restore-workspaces.sh"))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("~/.config/hypr/scripts/set-wallpapers.sh"))

hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("konsole -e clipse"))

hl.bind(mainMod .. " + CTRL + S", hl.dsp.exec_cmd("systemctl poweroff"))
hl.bind(mainMod .. " + CTRL + R", hl.dsp.exec_cmd("systemctl reboot"))

hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("konsole -e ~/code/dotfiles/bin/ironcode"))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("konsole -e ~/code/dotfiles/bin/phdcode"))
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd("konsole -e ~/code/dotfiles/bin/supercode"))

hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("sh -c 'google-chrome-stable --profile-directory=Default --app=https://web.whatsapp.com'"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("slack"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("sh -c 'google-chrome-stable --profile-directory=Default --app=https://teams.microsoft.com'"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("sh -c 'google-chrome-stable --profile-directory=Default --app=https://outlook.office.com'"))

hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))

hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }))

hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.resize({ x = -50, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.resize({ x = 50, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.resize({ x = 0, y = -50, relative = true }))
hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.resize({ x = 0, y = 50, relative = true }))

hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("hyprlock"))

hl.bind(mainMod .. " + period", hl.dsp.focus({ workspace = "r+1" }))
hl.bind(mainMod .. " + comma", hl.dsp.focus({ workspace = "r-1" }))

hl.bind(mainMod .. " + SHIFT + period", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(mainMod .. " + SHIFT + comma", hl.dsp.window.move({ workspace = "r-1" }))

hl.bind(mainMod .. " + ALT + K", hl.dsp.window.move({ monitor = "+1" }))
hl.bind(mainMod .. " + ALT + J", hl.dsp.window.move({ monitor = "-1" }))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = tostring(i) }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = tostring(i) }))
end

hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("mouse:276", hl.dsp.window.drag(), { mouse = true })
hl.bind("mouse:275", hl.dsp.window.resize(), { mouse = true })

hl.bind("ALT + R", hl.dsp.submap("mouseMove"))

hl.define_submap("mouseMove", function()
    hl.bind("mouse:272", hl.dsp.window.drag(), { mouse = true })
    hl.bind("mouse:273", hl.dsp.window.resize(), { mouse = true })
    hl.bind("mouse:274", hl.dsp.window.close(), { mouse = true })

    hl.bind("mouse_down", hl.dsp.focus({ workspace = "r-1" }))
    hl.bind("mouse_up", hl.dsp.focus({ workspace = "r+1" }))

    hl.bind("Escape", hl.dsp.submap("reset"))
end)

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && paplay /usr/share/sounds/freedesktop/stereo/audio-volume-change.oga"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && paplay /usr/share/sounds/freedesktop/stereo/audio-volume-change.oga"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("~/.config/hypr/scripts/player_wrapper.sh next"), { locked = true })
hl.bind("End", hl.dsp.exec_cmd("~/.config/hypr/scripts/player_wrapper.sh next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("~/.config/hypr/scripts/player_wrapper.sh play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("~/.config/hypr/scripts/player_wrapper.sh play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("~/.config/hypr/scripts/player_wrapper.sh previous"), { locked = true })
hl.bind("Home", hl.dsp.exec_cmd("~/.config/hypr/scripts/player_wrapper.sh previous"), { locked = true })

hl.window_rule({
    name = "float-window-title-nmtui",
    match = {
        class = "^(org.kde.konsole)",
        title = "^(.*nmtui.*)",
    },
    float = true,
})

hl.window_rule({
    name = "float-nm-connection-editor",
    match = {
        class = "^(nm-connection-editor)$",
    },
    float = true,
})

hl.window_rule({
    name = "float-pulseaudio-control",
    match = {
        class = "^(org.pulseaudio.pavucontrol)",
    },
    float = true,
})

hl.window_rule({
    name = "suppress-event-maximize",
    match = {
        class = ".*",
    },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "nofocus",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

hl.window_rule({
    name = "float-clipse",
    match = {
        class = "^(org.kde.konsole)",
        title = "^(.*clipse.*)",
    },
    float = true,
})

hl.window_rule({
    name = "set-size-clipse",
    match = {
        class = "^(org.kde.konsole)",
        title = "^(.*clipse.*)",
    },
    size = { 496, 504 },
})

hl.window_rule({
    name = "move-cursor-middle-clipse",
    match = {
        class = "^(org.kde.konsole)",
        title = "^(.*clipse.*)",
    },
    move = { "cursor_x-(window_w*0.5)", "cursor_y-(window_w*0.5)" },
})

hl.window_rule({
    name = "border-color-neovim",
    match = {
        class = "^(org.kde.konsole)",
        title = "^(.*nvim.*)",
    },
    border_color = "rgb(FFFF00)",
})

hl.window_rule({
    name = "border-color-fullscreen",
    match = {
        fullscreen = true,
    },
    border_color = "rgb(FF0000)",
})

require("monitors")
require("workspaces")
