sub init()
    m.backgroundPoster = m.top.findNode("backgroundPoster")
    m.eventLabel = m.top.findNode("scheduleLabel")
    m.top.observeField("eventTime", "onEventTime")
end sub

sub onEventTime(event)
    m.eventLabel.text = event.getData()
    m.backgroundPoster.width = m.eventLabel.boundingRect().width + (2 * m.eventLabel.translation[0])
end sub
