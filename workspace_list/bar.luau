--!nonstrict
-- Bar button that opens the workspace list panel.

barWidget.setGlyph("list")
barWidget.setTooltip(noctalia.tr("bar.tooltip"))

function onClick()
  noctalia.togglePanel("gdmsl/workspace_list:panel")
end
