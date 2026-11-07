' ExampleStatsPanel: a panel of your own in the Maestro panel's tab strip. Override the
' plain-named functions of MaestroCustomPanel; call emitEngage / emitCardFocus for analytics
' and requestFocusReturn to hand focus back to the tab bar. Never redefine an mcp* function.

sub init()
    ' What the SDK shows for this panel.
    m.top.panelType = "exampleStats"                         ' unique: letters, digits, _
    m.top.title = "Statss"                                    ' the tab label
    m.top.iconUri = "pkg:/images/ExampleStatsPanelNavIcon.png" ' 36x36, in this channel
    m.top.order = 0                                          ' first tab; -1 = after the SDK's own

    m.heading = m.top.findNode("heading")
    m.clock = m.top.findNode("clock")
    m.rows = m.top.findNode("rows")
    m.rows.observeFieldScoped("itemFocused", "onRowFocused")
    m.rows.observeFieldScoped("itemSelected", "onRowSelected")
    m.heading.text = "Stats"
    m.clock.text = "waiting for the player clock"
end sub

' The SDK calls it when the tab first shows: fetch for m.top.eventID and draw.
sub getData(params = invalid as dynamic)
    eventId = m.top.eventID
    if eventId = "" then eventId = "(no event)"
    m.heading.text = "Stats - " + eventId

    content = createObject("roSGNode", "ContentNode")
    for each row in ["Possession  54%", "Shots on target  7", "Corners  5"]
        item = content.createChild("ContentNode")
        item.title = row
    end for
    m.rows.content = content
end sub

' A new event on screen: fetch again.
sub onEventIdChanged(eventId as string)
    getData()
end sub

' The player moved (epoch ms as a string, at most twice a second).
sub onTimeCodeChanged(timeCode as string)
    if timeCode = "" then return
    m.clock.text = "player clock " + timeCode
end sub

' Focus came in from the tab bar.
sub onFocusEntered()
    m.rows.setFocus(true)
end sub

sub onRowFocused(event as object)
    emitCardFocus("statRow", event.getData())
end sub

sub onRowSelected(event as object)
    emitEngage("select", "statRow", { card_index: event.getData() })
end sub

' Up on the first row leaves the panel; every other key the SDK handles (Back, long OK).
function onKeyEvent(key as string, press as boolean) as boolean
    if press and key = "up" and m.rows.hasFocus() and m.rows.itemFocused = 0
        requestFocusReturn()
        return true
    end if
    return false
end function
