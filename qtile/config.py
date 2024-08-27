# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import os
# import asyncio
import subprocess
from libqtile import bar, hook, layout, qtile
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
# from libqtile.utils import send_notification
# from libqtile.log_utils import logger
import colors
import socket

mod = "mod4"              # Sets mod key to SUPER/WINDOWS
myTerm = "konsole"      # My terminal of choice
myFileExploarer = "dolphin"      # My file exploarer of choice
myBrowser = "google-chrome-stable"       # My browser of choice
ironcode = "konsole -e ironcode"       # launch iRonCub code
phdcode = "konsole -e phdcode"       # launch PhD thesis latex
supercode = "konsole -e supercode"       # launch Robotology Superbuild code
screenshot = "scrot -f -s -e 'xclip -selection clipboard -t image/png -i $f'"       # take a rectangle screenshot and save it to clipboard

# Allows you to input a name when adding treetab section.
@lazy.layout.function
def add_treetab_section(layout):
    prompt = qtile.widgets_map["prompt"]
    prompt.start_input("Section name: ", layout.cmd_add_section)

# A function for hide/show all the windows in a group
@lazy.function
def minimize_all(qtile):
    for win in qtile.current_group.windows:
        if hasattr(win, "toggle_minimize"):
            win.toggle_minimize()
           
# A function for toggling between MAX and MONADTALL layouts
@lazy.function
def maximize_by_switching_layout(qtile):
    current_layout_name = qtile.current_group.layout.name
    if current_layout_name == 'monadtall':
        qtile.current_group.layout = 'max'
    elif current_layout_name == 'max':
        qtile.current_group.layout = 'monadtall'

@lazy.function
def kill_plasma_wallpaper(qtile):
    for window in qtile.current_group.windows:
        window_info = window.info()
        if ("plasmashell" in window_info["wm_class"]):
            if ("Desktop @ QRect" in window_info["name"]):
                window.kill()

# @lazy.function
# def focus_prev_group(qtile):
#     if qtile.currentWindow is not None:
#         i = qtile.groups.index(qtile.currentGroup)
#         # qtile.currentWindow.togroup(qtile.groups[i - 1].name)
#         lazy.group[i-1].name.toscreen()

@lazy.function
def window_to_previous_screen(qtile):
    i = qtile.screens.index(qtile.current_screen)
    if i != 0:
        group = qtile.screens[i - 1].group.name
        qtile.current_window.togroup(group)

@lazy.function
def window_to_next_screen(qtile):
    i = qtile.screens.index(qtile.current_screen)
    if i + 1 != len(qtile.screens):
        group = qtile.screens[i + 1].group.name
        qtile.current_window.togroup(group)

@lazy.function
def latest_group(qtile):
    qtile.current_screen.set_group(qtile.current_screen.previous_group)

keys = [
    # The essentials
    Key([mod], "Return", lazy.spawn(myTerm), desc="Terminal"),
    Key([mod], "b", lazy.spawn(myBrowser), desc='Web browser'),
    Key([mod], "e", lazy.spawn(myFileExploarer), desc='File exploarer'),
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "c", lazy.window.kill(), desc="Kill focused window"),
    Key([mod], "w", lazy.reload_config(), kill_plasma_wallpaper(), lazy.spawn("nitrogen --restore"), desc='Reset config and wallpapers'),
    Key([mod], "q", latest_group(), desc='Switch back to the previous group'),

    Key([mod], "r", lazy.spawn(ironcode), desc='launch iRonCub code'),
    Key([mod], "a", lazy.spawn(phdcode), desc='launch PhD thesis latex'),
    Key([mod], "s", lazy.spawn(supercode), desc='launch Robotology Superbuild code'),

    Key([mod], "p", lazy.spawn(screenshot), desc='Take a rectangle screenshot and save it to clipboard'),

    Key([mod, "control"], "r", lazy.spawn("konsole -e reboot"), desc="reboot"),
    Key([mod, "control"], "s", lazy.spawn("konsole -e poweroff"), desc="shutdown"),

    # Switch between windows
    # Some layouts like 'monadtall' only need to use j/k to move
    # through the stack, but other layouts like 'columns' will
    # require all four directions h/j/k/l to move around.
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),

    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h",
        lazy.layout.shuffle_left(),
        lazy.layout.move_left().when(layout=["treetab"]),
        desc="Move window to the left/move tab left in treetab"),

    Key([mod, "shift"], "l",
        lazy.layout.shuffle_right(),
        lazy.layout.move_right().when(layout=["treetab"]),
        desc="Move window to the right/move tab right in treetab"),

    Key([mod, "shift"], "j",
        lazy.layout.shuffle_down(),
        lazy.layout.section_down().when(layout=["treetab"]),
        desc="Move window down/move down a section in treetab"
    ),
    Key([mod, "shift"], "k",
        lazy.layout.shuffle_up(),
        lazy.layout.section_up().when(layout=["treetab"]),
        desc="Move window downup/move up a section in treetab"
    ),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([mod, "shift"], "space", lazy.layout.toggle_split(), desc="Toggle between split and unsplit sides of stack"),

    # Treetab prompt
    Key([mod, "shift"], "a", add_treetab_section, desc='Prompt to add new section in treetab'),

    # Grow/shrink windows left/right. 
    # This is mainly for the 'monadtall' and 'monadwide' layouts
    # although it does also work in the 'bsp' and 'columns' layouts.
    Key([mod], "equal",
        lazy.layout.grow_left().when(layout=["bsp", "columns"]),
        lazy.layout.grow().when(layout=["monadtall", "monadwide"]),
        desc="Grow window to the left"
    ),
    Key([mod], "minus",
        lazy.layout.grow_right().when(layout=["bsp", "columns"]),
        lazy.layout.shrink().when(layout=["monadtall", "monadwide"]),
        desc="Grow window to the left"
    ),

    # Grow windows up, down, left, right.  Only works in certain layouts.
    # Works in 'bsp' and 'columns' layout.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    Key([mod], "m", lazy.layout.maximize(), desc='Toggle between min and max sizes'),
    Key([mod], "t", lazy.window.toggle_floating(), desc='toggle floating'),
    Key([mod], "f", maximize_by_switching_layout(), lazy.window.toggle_fullscreen(), desc='toggle fullscreen'),
    Key([mod, "shift"], "m", minimize_all(), desc="Toggle hide/show all windows on current group"),

    # Switch focus of monitors
    Key([mod, "mod1"], "j", lazy.next_screen(), desc='Move focus to next monitor'),
    Key([mod, "mod1"], "k", lazy.prev_screen(), desc='Move focus to prev monitor'),

    # Move focused window to next/prev monitor
    Key([mod, "mod1"], "Down", window_to_next_screen(), lazy.next_screen(), desc='Move focus to next monitor'),
    Key([mod, "mod1"], "Up", window_to_previous_screen(), lazy.prev_screen(), desc='Move focus to prev monitor'),

    # temp
    Key([mod], "y", lazy.group["4"].toscreen(), desc='toggle floating'),
]

if socket.gethostname() == "gumby":
    groups = []
    group_names = ["1", "2", "3", "4", "5"]
    group_labels = ["1", "2", "3", "4", "5"]
    group_layouts = ["monadtall", "monadtall", "monadtall", "monadtall", "monadtall"]
else:
    groups = []
    group_names = ["1", "2", "3", "4", "5", "6", "7", "8", "9",]

    group_labels = ["1", "2", "3", "4", "5", "6", "7", "8", "9",]
    #group_labels = ["DEV", "WWW", "SYS", "DOC", "VBOX", "CHAT", "MUS", "VID", "GFX",]
    # group_labels = ["", "", "", "", "", "", "", "", "",]

    group_layouts = ["monadtall", "monadtall", "monadtall", "monadtall", "monadtall", "monadtall", "monadtall", "monadtall", "monadtall"]

for i in range(len(group_names)):
    groups.append(
        Group(
            name=group_names[i],
            layout=group_layouts[i].lower(),
            label=group_labels[i],
        ))
 
for i in groups:
    keys.extend(
        [
            # mod1 + letter of group = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc="Switch to group {}".format(i.name),
            ),
            # mod1 + Fx = move focused window to group, x is the number of the group {1-9}
            Key(
                [mod],
                f"F{i.name}",
                lazy.window.togroup(i.name, switch_group=False),
                desc="Move focused window to group {}".format(i.name),
            ),
        ]
    )

colors = colors.DoomOne

layout_theme = {"border_width": 4,
                "margin": 10,
                "border_focus": '#ff2d2d',
                "border_normal": colors[0]
                }

layouts = [
    #layout.Bsp(**layout_theme),
    #layout.Floating(**layout_theme)
    #layout.RatioTile(**layout_theme),
    #layout.VerticalTile(**layout_theme),
    #layout.Matrix(**layout_theme),
    layout.MonadTall(**layout_theme),
    #layout.MonadWide(**layout_theme),
    layout.Tile(
         shift_windows=True,
         border_width = 0,
         margin = 0,
         ratio = 0.335,
         ),
    layout.Max(
         border_width = 0,
         margin = 0,
         ),
    #layout.Stack(**layout_theme, num_stacks=2),
    #layout.Columns(**layout_theme),
    #layout.TreeTab(
    #     font = "Ubuntu Bold",
    #     fontsize = 11,
    #     border_width = 0,
    #     bg_color = colors[0],
    #     active_bg = colors[8],
    #     active_fg = colors[2],
    #     inactive_bg = colors[1],
    #     inactive_fg = colors[0],
    #     padding_left = 8,
    #     padding_x = 8,
    #     padding_y = 6,
    #     sections = ["ONE", "TWO", "THREE"],
    #     section_fontsize = 10,
    #     section_fg = colors[7],
    #     section_top = 15,
    #     section_bottom = 15,
    #     level_shift = 8,
    #     vspace = 3,
    #     panel_width = 240
    #     ),
    #layout.Zoomy(**layout_theme),
]

widget_defaults = dict(
    font="Ubuntu Bold",
    fontsize = 14,
    padding = 0,
    background=colors[0]
)

extension_defaults = widget_defaults.copy()

# For adding transparency to your bar, add (background="#00000000") to the "Screen" line(s)
# For ex: Screen(top=bar.Bar(widgets=init_widgets_screen2(), background="#00000000", size=24)),

def init_screens():
    return [Screen(top=bar.Gap(size=40)),
            Screen(top=bar.Gap(size=40)),
            Screen(top=bar.Gap(size=40))]
    # return [Screen(top=bar.Bar(widgets=init_widgets_screen1(), size=26)),
            # Screen(top=bar.Bar(widgets=init_widgets_screen2(), size=30)),
            # Screen(top=bar.Bar(widgets=init_widgets_screen2(), size=30))]

if __name__ in ["config", "__main__"]:
    screens = init_screens()

def window_to_prev_group(qtile):
    if qtile.currentWindow is not None:
        i = qtile.groups.index(qtile.currentGroup)
        qtile.currentWindow.togroup(qtile.groups[i - 1].name)

def window_to_next_group(qtile):
    if qtile.currentWindow is not None:
        i = qtile.groups.index(qtile.currentGroup)
        qtile.currentWindow.togroup(qtile.groups[i + 1].name)

def switch_screens(qtile):
    i = qtile.screens.index(qtile.current_screen)
    group = qtile.screens[i - 1].group
    qtile.current_screen.set_group(group)

mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = False
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    border_focus=colors[3],
    border_width=4,
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),   # gitk
        Match(wm_class="dialog"),         # dialog boxes
        Match(wm_class="download"),       # downloads
        Match(wm_class="error"),          # error msgs
        Match(wm_class="file_progress"),  # file progress boxes
        Match(wm_class='kdenlive'),       # kdenlive
        Match(wm_class="makebranch"),     # gitk
        Match(wm_class="maketag"),        # gitk
        Match(wm_class="notification"),   # notifications
        Match(wm_class='pinentry-gtk-2'), # GPG key password entry
        Match(wm_class="ssh-askpass"),    # ssh-askpass
        Match(wm_class="toolbar"),        # toolbars
        Match(wm_class="Yad"),            # yad boxes
        Match(title="branchdialog"),      # gitk
        Match(title='Confirmation'),      # tastyworks exit box
        Match(title='Qalculate!'),        # qalculate-gtk
        Match(title="pinentry"),          # GPG key password entry
        Match(title="tastycharts"),       # tastytrade pop-out charts
        Match(title="tastytrade"),        # tastytrade pop-out side gutter
        Match(title="tastytrade - Portfolio Report"), # tastytrade pop-out allocation
        Match(wm_class="tasty.javafx.launcher.LauncherFxApp"), # tastytrade settings
        Match(wm_class="plasmashell"),      # plasmashell
        Match(wm_class="plasma"),
        Match(title="plasma-desktop"),
        Match(title="desktop - Plasma"),
        Match(wm_class="win7"),
        Match(wm_class="krunner"),
        Match(wm_class="Kmix"),
        Match(wm_class="Klipper"),
        Match(wm_class="PlasmoidViewer"),
        Match(wm_class="spectacle"),
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

@hook.subscribe.startup_once
def start_once():
    home = os.path.expanduser('~')
    subprocess.call([home + '/.config/qtile/autostart.sh'])

# @hook.subscribe.restart
# def start():
#     lazy.spawn("kate").when_done()
#     qtile.current_group.layout_all()
#     # kill_plasma_wallpaper(qtile)

# @hook.subscribe.screen_change
# def screen_change(event):
#     # lazy.reload_config()
#     lazy.spawn(phdcode)

# @hook.subscribe.screens_reconfigured
# def screen_reconf():
#     lazy.spawn(phdcode)

# @hook.subscribe.client_new 
# def new_clinet(client):
#     if "krunner" in client.get_wm_class():
#         client.set_position_floating(1000,100)

# @hook.subscribe.user("my_custom_hook")
# def hooked_function():
#     logger.warning("custom hook received..")
#     lazy.spawn(phdcode)

# @hook.subscribe.screens_reconfigured
# def screen_reconf():
#     # send_notification("Qtile", "Screen reconfigured..")
#     # lazy.reload_config()
#     # kill_plasma_wallpaper(qtile)
#     # qtile.call_later(3, kill_plasma_wallpaper(qtile))
#     qtile.spawn("nitrogen --restore")
#     qtile.reload_config()
#     # send_notification("Qtile", "Updated Nitrogen..")
#     # qtile.call_later(10, send_notification("Qtile", "after sometime.."))

## Add hooks to move specific windows to desired groups
@hook.subscribe.client_new
def client_new(client):
    if socket.gethostname() == "gumby":
        if 'Spotify' in client.name:
            client.togroup("5", switch_group=True)
        # for the main MATLAB window, switch group
        if 'matlab' in client.name.lower():
            client.togroup("2", switch_group=True)
        # for other MATLAB windows, don't switch group
        elif any('matlab' in s.lower() for s in client._wm_class):
            client.togroup("2", switch_group=False)
        elif any('kontact' in s.lower() for s in client._wm_class):
            client.togroup("5", switch_group=False)
    else:
        # send_notification("Qtile", "Client - After some time ..")
        # send_notification("Qtile", f"Client name: {client.name} ..")
        if 'Spotify' in client.name:
            client.togroup("9", switch_group=True)
        # for the main MATLAB window, switch group
        if 'matlab' in client.name.lower():
            client.togroup("4", switch_group=True)
        # for other MATLAB windows, don't switch group
        elif any('matlab' in s.lower() for s in client._wm_class):
            client.togroup("4", switch_group=False)
        elif any('kontact' in s.lower() for s in client._wm_class):
            client.togroup("8", switch_group=False)

wmname = "LG3D"

