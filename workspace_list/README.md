# Workspace List

A bar button that opens a list of every workspace. Click one to switch to it.

It helps when you have many named workspaces and the workspaces widget no
longer fits the bar: set the workspaces widget to the `focus_hint` style to
shrink it, and use this list to jump by name.

## Plugin

| Field | Value |
| --- | --- |
| ID | `gdmsl/workspace_list` |
| Entries | Bar widget: `bar`; panel: `panel` |
| Compositors | niri, Hyprland |

## Usage

Add the `bar` widget to your bar. Clicking it opens the panel, which lists the
workspaces of every monitor and highlights the focused one. Each row shows the
workspace name, or its index when it has none. With more than one monitor, the
row also shows which monitor the workspace is on.

The list is read with `niri msg` or `hyprctl` each time the panel opens.
Hyprland's special workspaces are not listed.

Open the panel from a keybinding or a script:

```sh
noctalia msg panel-toggle gdmsl/workspace_list:panel
```

## Notes

Requires `plugin_api = 42` (Noctalia 5.4.0 or newer).
