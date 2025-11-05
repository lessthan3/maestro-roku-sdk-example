sub init()
  m.settingConfig = m.top.findNode("settingConfig")
  m.settingConfig.observeField("itemSelected", "onItemSelected")
  m.hintText = m.top.findNode("hintText")

  m.top.observeField("focusedChild", "onFocusChange")
  m.top.observeField("MaestroKit", "onlibrary")
  m.top.observeField("automationLog", "addLogLabel")
  m.top.observeField("selectedVersion", "onVersionSelected")

  m.logTitleLable = m.top.findNode("logTitleLable")
  m.logsGroup = m.top.findNode("logsGroup")

end sub

sub onItemSelected(event)
  index = event.getData()
  action = m.settingConfig.content.getChild(index)?.title

  if action = "ShowPanel"
    m.lib.showPanel = true
    m.lib.callFunc("setPanelFocus")
    ' minVideo()

  else if action = "HidePanel"
    m.lib.showPanel = false
    ' maxVideo()
  end if
end sub

function handleDevPanelKeyPress(key as string) as boolean
  handled = false

  if key = "right"
    m.lib.callFunc("setPanelFocus")
    handled = true
  end if
  return handled
end function

function onKeyEvent(key as string, press as boolean) as boolean
  handled = false
  if (press)
    if m.settingConfig.hasFocus()
      handled = handleDevPanelKeyPress(key)
    end if
  end if
  return handled
end function

sub onHandleLoadingSceneAction(event)
  action = event.getData()
  if action = "returnFocus"
    m.settingConfig.setFocus(true)
  end if
end sub

sub onLibKeyAction(event)
  action = event.getData()
  if action = "overLaySelected"
    'minVideo()
  else if action = "setFocusOnSettingConfig"
    m.settingConfig.setFocus(true)
  end if
end sub

sub onFocusChange(event)
  focusNode = event.getData()
  if focusNode <> invalid and focusNode.id = "TestHarness"
    m.settingConfig.setFocus(true)
  end if

end sub


sub onlibrary(event)
  if event.getData() <> invalid
    if m.lib <> invalid
      m.lib.unobserveFieldScoped("handleLoadingSceneAction")
      m.lib = invalid
    end if

    m.lib = event.getData()
    m.top.unObserveField("MaestroKit")
    m.lib.observeField("handleLoadingSceneAction", "onHandleLoadingSceneAction")
  end if
end sub

sub addLogLabel(text)
    config = {
        width: 1000,
        wrap: true,
        lineSpacing: -3
    }
    logLable = createObject("roSGNode", "Label")
    logLable.update(config)
    logLable.text = text.getData()
    m.logsGroup.appendChild(logLable)
end sub