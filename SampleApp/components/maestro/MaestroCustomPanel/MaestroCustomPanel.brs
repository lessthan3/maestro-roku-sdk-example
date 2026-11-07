' MaestroCustomPanel: the base of a host-built panel the Maestro SDK shows as a tab.
'
' A subclass (<component name="MyPanel" extends="MaestroCustomPanel">) sets panelType, title,
' iconUri and order in its init, draws its children, and overrides the plain-named functions
' below. Everything prefixed mcp is the base's own and must not be redefined: the base's
' scripts and the subclass's share one scope (as every SceneGraph parent and child do), so a
' subclass function of the same name replaces the base's.
'
' What the SDK does with it, in order (MaestroCustomPanel.md has the whole contract):
'   1. addPanelToEvent: the node is placed in the SDK's panel container, its id set to
'      panelType, and name, client, clientConfig, eventID and timeCode written to it.
'   2. getData() when the tab first shows (or at once, when the SDK fetches on build).
'   3. visible toggles with the tab; focus enters from the tab bar when focusable is true.
'   4. errorData set here shows the SDK's error view in the panel's place; invalid brings it back.
'   5. endSession() when the session ends, removePanelFromEvent or destroySDK remove it.

sub init()
    m.mcpTimers = [] ' timers made with mcpTimer, stopped by endSession
    m.mcpInFocusChain = false
    ' The SDK moves focus down from a tab only to a focusable panel.
    m.top.focusable = true

    mcpObserve(m.top, "focusedChild", "mcpOnFocusedChild")
    mcpObserve(m.top, "visible", "mcpOnVisible")
    mcpObserve(m.top, "eventID", "mcpOnEventId")
    mcpObserve(m.top, "timeCode", "mcpOnTimeCode")
    mcpObserve(m.top, "panelType", "mcpOnPanelType")
end sub

' ── Override points ──────────────────────────────────────────────────────────

' Fetch and draw. The SDK calls it when the tab first shows; eventID, timeCode and
' clientConfig are set by then.
'
' @param {dynamic} params - unused, kept for the SDK's call shape
sub getData(params = invalid as dynamic)
end sub

' The event on screen changed (a stream switch): fetch again for the new one.
'
' @param {string} eventId
sub onEventIdChanged(eventId as string)
end sub

' The player moved, at most twice a second. "" before the first tick.
'
' @param {string} timeCode - epoch ms as a string
sub onTimeCodeChanged(timeCode as string)
end sub

' Focus came into this panel from the tab bar: focus the first control.
sub onFocusEntered()
end sub

' Keys while this panel has focus. Return false for a key the panel does not use: the SDK
' then handles it (Back and Up return focus to the tab bar, long OK closes the panel).
'
' @param {string} key
' @param {boolean} press
' @return {boolean} true when handled here
function onKeyEvent(key as string, press as boolean) as boolean
    return false
end function

' ── Helpers the subclass calls ───────────────────────────────────────────────

' An engage beacon: the viewer acted on something in the panel.
'
' @param {string} action - what was done (select, expand, collapse, link...)
' @param {string} target - what it was done to (a card or control name)
' @param {dynamic} metadata - optional extra fields for the beacon
sub emitEngage(action as string, target = "" as string, metadata = invalid as dynamic)
    payload = { action: action, target: target }
    if mcpIsAa(metadata) then payload.metadata = metadata
    m.top.panelEngage = payload
end sub

' Focus rested on a card: the SDK sends a card_focus beacon once it has stayed 300 ms.
'
' @param {string} card - the card's name
' @param {integer} cardIndex - its position in its list
' @param {string} list - the list's name; the panel's id when empty
sub emitCardFocus(card as string, cardIndex as integer, list = "" as string)
    if list = "" then list = m.top.id
    m.top.panelCardFocus = { list: list, card: card, card_index: cardIndex }
end sub

' No card has focus any more (focus left the list).
sub clearCardFocus()
    m.top.panelCardFocus = {}
end sub

' A key that should leave the panel: the SDK puts focus back on its tab bar.
sub requestFocusReturn()
    m.top.requestFocusReturn = true
end sub

' A timer the base stops at the end of the session.
'
' @param {float} duration - seconds
' @param {string} callbackName - the function to call on fire
' @param {boolean} repeat
' @return {roSGNode} the started Timer
function mcpTimer(duration as float, callbackName as string, repeat = false as boolean) as object
    timer = createObject("roSGNode", "Timer")
    timer.duration = duration
    timer.repeat = repeat
    timer.observeFieldScoped("fire", callbackName)
    m.mcpTimers.push(timer)
    timer.control = "start"
    return timer
end function

' Something went wrong: the SDK's error view (an icon, a title and a line under it) takes the
' panel's place until errorData is cleared. The view has no retry control of its own; a panel
' that can try again offers one and calls reloadPanel.
'
' @param {string} title
' @param {string} subTitle
' @param {string} iconUri - http(s), or a pkg:/ image of this channel (staged with stagedUri)
' @param {integer} width - the icon's size on screen; 0 for no icon
' @param {integer} height
sub showError(title as string, subTitle = "" as string, iconUri = "" as string, width = 0 as integer, height = 0 as integer)
    m.top.errorData = { title: title, subTitle: subTitle, uri: stagedUri(iconUri), width: width, height: height }
end sub

' The error is over, or the panel is trying again: clears errorData and calls getData.
sub reloadPanel()
    m.top.errorData = invalid
    getData()
end sub

' ── Called by the SDK ────────────────────────────────────────────────────────

' The session is over. A subclass that overrides this calls mcpEndSession().
sub endSession()
    mcpEndSession()
end sub

sub mcpEndSession()
    for each timer in m.mcpTimers
        timer.control = "stop"
    end for
    m.mcpTimers = []
end sub

' The icon uri to give addPanelToEvent. The SDK draws the tab icon from inside its own
' component library, where a pkg:/ path of the host channel does not resolve, so a pkg:/
' icon is copied to tmp:/ (one filesystem for the whole channel) and that path returned.
' http(s):// and tmp:/ uris are returned as they are. Call it at the addPanelToEvent call
' site, after iconUri and panelType are set.
'
' @return {string} the uri to hand the SDK, or "" when iconUri is empty
function stagedIconUri() as string
    return stagedUri(m.top.iconUri)
end function

' A file of this channel where the SDK can load it: a pkg:/ uri is copied to
' tmp:/maestroCustomPanel_<panelType>_<file name>; anything else (http(s)://, tmp:/, "") is
' returned as it is. The copy is made again on every call.
'
' @param {dynamic} uri
' @return {string} the uri to hand the SDK
function stagedUri(uri as dynamic) as string
    if not mcpIsStringWithLength(uri) then return ""
    if Left(uri, 5) <> "pkg:/" then return uri

    key = m.top.panelType
    if key = "" then key = m.top.subType()
    staged = "tmp:/maestroCustomPanel_" + key + "_" + mcpFileName(uri)

    ' roFileSystem exists on the main and task threads only; a node's scripts run on the
    ' render thread, where roByteArray still reads and writes files.
    bytes = createObject("roByteArray")
    if bytes.ReadFile(uri) and bytes.WriteFile(staged) then return staged
    return uri
end function

' ── Observers ────────────────────────────────────────────────────────────────

' Focus entering the panel is the Pulse "engage" fact, and the subclass's cue to focus a control.
sub mcpOnFocusedChild(event as object)
    inChain = m.top.isInFocusChain()
    if inChain and not m.mcpInFocusChain
        if not mcpIsTrue(m.top.panel_engage) then m.top.panel_engage = true
        onFocusEntered()
    end if
    m.mcpInFocusChain = inChain
end sub

' Shown for the first time is the Pulse "view" fact.
sub mcpOnVisible(event as object)
    if mcpIsTrue(event.getData()) and not mcpIsTrue(m.top.panel_view) then m.top.panel_view = true
end sub

' A new event resets the Pulse facts (as the SDK's own base panel does), then the subclass hears it.
sub mcpOnEventId(event as object)
    eventId = event.getData()
    if not mcpIsString(eventId) then return
    m.top.panel_view = false
    m.top.panel_engage = false
    onEventIdChanged(eventId)
end sub

sub mcpOnTimeCode(event as object)
    timeCode = event.getData()
    if not mcpIsString(timeCode) then return
    onTimeCodeChanged(timeCode)
end sub

' The id the SDK keys the panel by; set early so a log line names the panel before it is added.
sub mcpOnPanelType(event as object)
    panelType = event.getData()
    if mcpIsStringWithLength(panelType) and m.top.id = "" then m.top.id = panelType
end sub

' @param {string} uri
' @return {string} "icon.png" for "pkg:/images/icon.png"
function mcpFileName(uri as string) as string
    for i = Len(uri) to 1 step -1
        if Mid(uri, i, 1) = "/" then return Mid(uri, i + 1)
    end for
    return uri
end function
