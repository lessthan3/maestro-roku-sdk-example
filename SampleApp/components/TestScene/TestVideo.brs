sub init()
    m.top.id = "TestVideo"
    m.video = m.top.findNode("video")
    m.video.observeField("position", "onPositionChanged")
    m.video.notificationInterval = 1
    m.settingConfig = m.top.findNode("settingConfig")
    m.settingConfig.observeField("itemSelected", "onItemSelected")
    playVideo()
    initSDK()
end sub
function playVideo()
    videoContent = createObject("RoSGNode", "ContentNode")
    videoContent.streamformat = "auto"
    videoContent.url = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
    videoContent.title = ""
    m.video.content = videoContent
    m.video.control = "play"
end function

function minVideo()
    m.video.width = 1184
    m.video.height = 666
    m.video.translation = [50, 200]
end function

function maxVideo()
    m.video.width = 1920
    m.video.height = 1080
    m.video.translation = [0, 0]
end function

sub onShowPanel(event)
    isPanelShown =  event.getData()
    if isPanelShown
        minVideo()
        m.lib.callFunc("setPanelFocus")
    else
         m.settingConfig.setFocus(true)
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    handled = false

    if press
        if key = "back"
            m.settingConfig.setFocus(true)
            handled = true
        else if key = "left"
            m.settingConfig.setFocus(true)
            handled = true
        end if
    end if

    return handled
end function

sub initSDK()
    'Init a component library and set your desired version number
    m.componentLibrary = createObject("rosgNode", "ComponentLibrary")
    m.componentLibrary.uri = "https://roku-sdk.us-central1-master.gcp.maestro.io/4.1.11/maestrokit.zip"
    m.componentLibrary.observeField("loadStatus", "onLibraryLoadStatusChanged")
end sub

function onLibraryLoadStatusChanged()
  if (m.componentLibrary.loadStatus = "ready")
    'Create a version of the pannel and set observers.
    m.lib = createObject("rosgNode", "MaestroPanelLib:MaestroPanel")
    m.lib.observeField("showPanel", "onShowPanel")
    m.lib.observeField("handleLoadingSceneAction", "onHandleLoadingSceneAction")
    'add panel to your scene
    m.top.appendChild(m.lib)
    finishSetup()
  end if
end function

sub finishSetup()
    m.lib.observeField("showPanel", "onShowPanel")
    'configure the SDK with your siteID and pageID, these ID's can be found on your maestro site in the browser
    m.lib.config ={
        "siteID": "66956c7680975a8bb6bf8f75",
        "pageId": "68f7b3bc543627ba334e0104",
        "useProdEnv": false
    }
    'set focus to the buttons or your custom UI
    m.settingConfig.setFocus(true)
end sub

sub cleanup()
    maxVideo()
    m.top.removeChild(m.lib )
    m.lib = invalid
end sub

sub onDestroySDK()
    m.lib.callFunc("destroySDK")
end sub

sub onItemSelected(event)
  index = event.getData()
  action = m.settingConfig.content.getChild(index)?.title
    'handlers for the actions to show and hide the panel
  if action = "ShowPanel"
    m.lib.showPanel = true
    m.lib.callFunc("setPanelFocus")
    minVideo()

  else if action = "HidePanel"
    m.lib.showPanel = false
    maxVideo()
  end if
end sub

sub onHandleLoadingSceneAction(event)
  action = event.getData()
  'handler to return focus to your custom UI when the user exist the panel
  if action = "returnFocus"
    maxVideo()
    m.settingConfig.setFocus(true)
  end if
end sub