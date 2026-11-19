# noctalia-plugins

My plugins for the [Noctalia](https://noctalia.dev) shell.

| Plugin | Description |
| --- | --- |
| [Workspace List](workspace_list/) | A bar button that opens a list of every workspace, to switch by name. |

## Install

Add this repo as a plugin source, then enable the plugins you want:

```sh
noctalia msg plugins source add gdmsl git https://github.com/gdmsl/noctalia-plugins
noctalia msg plugins enable gdmsl/workspace_list
```

Or do the same from **Settings → Plugins → Add source**.

## Development

Add a checkout as a `path` source. Edits to `.luau` files reload on save;
manifest changes need a config reload.

```sh
noctalia msg plugins source add gdmsl-dev path ~/Personal/Code/noctalia-plugins
```

`catalog.toml` lists every plugin so Noctalia can show them without cloning
the repo. Keep it in sync with each `plugin.toml`.
