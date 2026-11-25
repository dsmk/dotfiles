#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=false
if [[ ${1:-} == "-n" ]]; then
    DRY_RUN=true
fi

set_gsetting() {
    local schema=$1 key=$2 value=$3 current

    current=$(gsettings get "$schema" "$key")
    if [[ "$current" != "$value" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            printf 'Would run:'
            printf ' %q' gsettings set "$schema" "$key" "$value"
            printf '\n'
        else
            gsettings set "$schema" "$key" "$value"
        fi
    fi
}

# Use the exact desktop-file IDs installed on your system.
FIREFOX_ID="org.mozilla.firefox.desktop"
KITTY_ID="kitty.desktop"
TEAMS_ID="com.github.IsmaelMartinez.teams_for_linux.desktop"
SLACK_ID="com.slack.Slack.desktop"
CHROME_ID="com.google.Chrome.desktop"

# Super+1..5 activate favorites in this order.
# Slack intentionally appears twice, so Super+4 and Super+5 both activate it.
set_gsetting org.gnome.shell favorite-apps \
    "['$FIREFOX_ID', '$KITTY_ID', '$TEAMS_ID', '$SLACK_ID', '$CHROME_ID']"

for n in {1..5}; do
    set_gsetting org.gnome.shell.keybindings \
        "switch-to-application-$n" "['<Super>$n']"
done

# Use fixed, numbered workspaces.
set_gsetting org.gnome.mutter dynamic-workspaces false
set_gsetting org.gnome.desktop.wm.preferences num-workspaces 10                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          10
 
# Switch workspaces with Ctrl+Alt+1..9, and Ctrl+Alt+0 for workspace 10.
for n in {1..9}; do
    set_gsetting org.gnome.desktop.wm.keybindings \
        "switch-to-workspace-$n" "['<Super><Shift>$n']"
    set_gsetting org.gnome.desktop.wm.keybindings \
        "move-to-workspace-$n" "['<Super><Alt>$n']"
done

set_gsetting org.gnome.desktop.wm.keybindings \
    switch-to-workspace-10 "['<Super><Shift>0']"
set_gsetting org.gnome.desktop.wm.keybindings \
    move-to-workspace-10 "['<Super><Alt>0']"

# Basic keyboard tiling.
set_gsetting org.gnome.mutter.keybindings \
    toggle-tiled-left "['<Super>Left']"
set_gsetting org.gnome.mutter.keybindings \
    toggle-tiled-right "['<Super>Right']"

# GNOME's keyboard-driven move/resize operations.
set_gsetting org.gnome.desktop.wm.keybindings \
    begin-move "['<Alt>F7']"
set_gsetting org.gnome.desktop.wm.keybindings \
    begin-resize "['<Alt>F8']"

# Register two custom shortcuts.
#
# NOTE: This sets the custom-keybindings list to these two entries. If you
# already use GNOME custom shortcuts, add their paths to this list as well.
project_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/project-picker/"
toolbox_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/kitty-toolbox/"

set_gsetting org.gnome.settings-daemon.plugins.media-keys \
    custom-keybindings "['$project_path', '$toolbox_path']"

custom_schema="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding"

set_gsetting "$custom_schema:$project_path" name "'Open a VS Code project'"
#set_gsetting "$custom_schema:$project_path" command "'$HOME/.local/bin/vscode-zenity'"
set_gsetting "$custom_schema:$project_path" command "kitty -T 'VS Code project picker' vscode-kitty"
set_gsetting "$custom_schema:$project_path" binding "'<Super><Shift>p'"

set_gsetting "$custom_schema:$toolbox_path" name "'Open Kitty in dev toolbox'"
set_gsetting "$custom_schema:$toolbox_path" command "kitty -T 'DEV' toolbox enter dev"
set_gsetting "$custom_schema:$toolbox_path" binding "'<Super><Shift>t'"
exit

echo "GNOME configuration:"
gsettings get org.gnome.mutter dynamic-workspaces
gsettings get org.gnome.mutter num-workspaces
gsettings get org.gnome.desktop.wm.keybindings switch-to-workspace-1
gsettings get org.gnome.desktop.wm.keybindings move-to-workspace-1
gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings
gsettings get "$custom_schema:$project_path" binding
gsettings get "$custom_schema:$toolbox_path" binding