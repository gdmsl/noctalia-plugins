--!nonstrict
-- Lists every workspace of the running compositor; click one to switch to it.
--
-- The list is read from the compositor's CLI each time the panel opens, so the
-- plugin needs no background service. Each backend turns its JSON into rows of
-- { label, output, focused, switch }, where switch is a list of argv commands
-- run in order.

local rows = {}
local errorText = nil

-- niri: `niri msg -j workspaces` gives idx (per output), an optional name and
-- the output. focus-workspace resolves an index on the focused monitor, so we
-- focus the workspace's monitor first. A name is unique, so it is used as the
-- reference when there is one.
local niri = {
  query = { { "niri", "msg", "-j", "workspaces" } },
  parse = function(results)
    local list = noctalia.json.decode(results[1]) or {}
    table.sort(list, function(a, b)
      if a.output ~= b.output then
        return (a.output or "") < (b.output or "")
      end
      return a.idx < b.idx
    end)
    local out = {}
    for _, ws in ipairs(list) do
      local ref = ws.name or tostring(ws.idx)
      table.insert(out, {
        label = ws.name or tostring(ws.idx),
        output = ws.output,
        focused = ws.is_focused,
        switch = {
          { "niri", "msg", "action", "focus-monitor", ws.output },
          { "niri", "msg", "action", "focus-workspace", ref },
        },
      })
    end
    return out
  end,
}

-- Hyprland: workspace ids are global, so a single dispatch is enough. Special
-- workspaces have negative ids and are left out.
local hyprland = {
  query = {
    { "hyprctl", "-j", "workspaces" },
    { "hyprctl", "-j", "activeworkspace" },
  },
  parse = function(results)
    local list = noctalia.json.decode(results[1]) or {}
    local active = noctalia.json.decode(results[2]) or {}
    table.sort(list, function(a, b)
      return a.id < b.id
    end)
    local out = {}
    for _, ws in ipairs(list) do
      if ws.id > 0 then
        table.insert(out, {
          label = ws.name,
          output = ws.monitor,
          focused = ws.id == active.id,
          switch = { { "hyprctl", "dispatch", "workspace", tostring(ws.id) } },
        })
      end
    end
    return out
  end,
}

local function backend()
  if noctalia.getenv("NIRI_SOCKET") ~= nil then
    return niri
  elseif noctalia.getenv("HYPRLAND_INSTANCE_SIGNATURE") ~= nil then
    return hyprland
  end
  return nil
end

-- Runs argv commands one after the other, then calls done with their stdouts,
-- or with nil and the stderr of the first one that failed.
local function runAll(commands, done)
  local outputs = {}
  local function step(i)
    if i > #commands then
      done(outputs)
      return
    end
    noctalia.runAsync(commands[i], function(result)
      if result.exitCode ~= 0 then
        done(nil, result.stderr)
        return
      end
      outputs[i] = result.stdout
      step(i + 1)
    end)
  end
  step(1)
end

local function render()
  local children = {
    ui.label({ text = noctalia.tr("panel.title"), fontSize = 16, fontWeight = "bold" }),
  }

  if errorText ~= nil then
    table.insert(children, ui.label({ text = errorText, color = "error" }))
  end

  -- The monitor name only helps when there is more than one.
  local outputs = {}
  local outputCount = 0
  for _, row in ipairs(rows) do
    if row.output ~= nil and not outputs[row.output] then
      outputs[row.output] = true
      outputCount += 1
    end
  end

  local items = {}
  for _, row in ipairs(rows) do
    local label = row.label
    if outputCount > 1 then
      label = `{label}  ·  {row.output}`
    end
    table.insert(items, ui.button({
      text = label,
      variant = row.focused and "primary" or "ghost",
      contentAlign = "start",
      onClick = function()
        runAll(row.switch, function(_, err)
          if err ~= nil then
            noctalia.log(err)
          end
        end)
        panel.close()
      end,
    }))
  end
  table.insert(children, ui.scroll({ flexGrow = 1, gap = 2, align = "stretch" }, items))

  panel.render(ui.column({ gap = 8, align = "stretch" }, children))
end

function onOpen(_context)
  local b = backend()
  if b == nil then
    rows = {}
    errorText = noctalia.tr("panel.unsupported")
    render()
    return
  end
  render()
  runAll(b.query, function(results, err)
    if results == nil then
      rows = {}
      errorText = err
    else
      rows = b.parse(results)
      errorText = nil
    end
    render()
  end)
end
