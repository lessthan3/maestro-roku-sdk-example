sub init()
    m.top.id = "TestVideo"
    m.video = m.top.findNode("video")
    m.video.observeField("position", "onPositionChanged")
    m.video.notificationInterval = 1
    playVideo()
end sub
function playVideo()
    videoContent = createObject("RoSGNode", "ContentNode")
    videoContent.streamformat = "auto"
    videoContent.url = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
    videoContent.title = ""
    m.video.content = videoContent
    m.video.control = "play"
end function
