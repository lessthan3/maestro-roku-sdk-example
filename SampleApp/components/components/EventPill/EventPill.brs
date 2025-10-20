sub init()
    m.top.id = "EventPill"
    m.top.observeField("startTime", "onStartTime")
end sub

sub onStartTime(event as object)
    nowDateTime = CreateObject("roDateTime")
    nowDateTime.Mark()
    nowSeconds = nowDateTime.AsSeconds()

    starttime = event.getData()
    startDateTime = CreateObject("roDateTime")
    startDateTime.FromISO8601String(starttime)
    startSeconds = startDateTime.AsSeconds()

    if nowSeconds < startSeconds
        ' Schedule
        m.eventPill = CreateObject("roSGNode", "ScheduledPill")
        m.eventPill.eventTime = startDateTime.asTimeStringLoc("short") + " " + startDateTime.asDateStringLoc("y MM dd")
    else
        ' Live
        m.eventPill = CreateObject("roSGNode", "LivePill")
    end if

    m.eventPill.translation = [0, 20]
    m.top.appendChild(m.eventPill)

end sub


