# MaestroCustomPanel

The base of a panel a Roku channel builds itself and shows in the Maestro SDK's tab strip. Plain BrightScript
with no SDK dependency: copy this folder into your channel (`components/maestro/MaestroCustomPanel/`), extend
the component, create it and hand it to the SDK with `addPanelToEvent`. The SDK side is
[MaestroPanel.customPanels.md](../../../src/components/maestroPanel/MaestroPanel.customPanels.md).

```xml
<component name="MyStatsPanel" extends="MaestroCustomPanel">
    <script type="text/brightscript" uri="MyStatsPanel.brs" />
    <children>
        <Label id="heading" translation="[40, 24]" />
        <LabelList id="rows" translation="[40, 120]" itemSize="[640, 56]" />
    </children>
</component>
```

```brs
sub init()
    m.top.panelType = "myStats"                          ' unique: letters, digits, _; not an SDK panel's name
    m.top.title = "My Stats"                             ' the tab label
    m.top.iconUri = "pkg:/images/myStatsNavIcon.png"     ' 36x36, in your channel
    m.top.order = 0                                      ' first tab; -1 = after the SDK's own
    m.rows = m.top.findNode("rows")
    m.rows.observeFieldScoped("itemFocused", "onRowFocused")
    m.rows.observeFieldScoped("itemSelected", "onRowSelected")
end sub
sub getData(params = invalid as dynamic)                 ' the tab first shows: fetch for m.top.eventID, draw
end sub
sub onFocusEntered() : m.rows.setFocus(true) : end sub   ' focus came in from the tab bar
sub onRowFocused(event) : emitCardFocus("statRow", event.getData()) : end sub
sub onRowSelected(event) : emitEngage("select", "statRow") : end sub
function onKeyEvent(key as string, press as boolean) as boolean
    if press and key = "up" and m.rows.itemFocused = 0 then requestFocusReturn() : return true
    return false                                         ' the SDK handles the rest (Back, long OK)
end function
```

```brs
' Once the SDK's MaestroPanel is in the scene (before or after its config: both work):
panel = createObject("roSGNode", "MyStatsPanel")
m.maestroPanel.callFunc("addPanelToEvent", {
    node: panel, panelType: panel.panelType, title: panel.title
    iconUri: panel.callFunc("stagedIconUri"), order: panel.order
})
```

## What happens, in order

1. `addPanelToEvent`: the node goes into the SDK's panel container, its `id` becomes `panelType`, and `name`,
   `client`, `clientConfig`, `eventID`, `timeCode` are written to it. Its tab appears at `order`.
2. `getData()` when the tab first shows (or at once, when the SDK fetches on build).
3. `visible` follows the tab. Down from the tab bar focuses the panel (`focusable` is set here) →
   `onFocusEntered()`.
4. `onEventIdChanged` on a stream switch, `onTimeCodeChanged` as the player moves (twice a second at most).
5. `showError(...)` puts the SDK's error view in the panel's place; `reloadPanel()` brings the panel back.
6. `endSession()` at the end of the session; `removePanelFromEvent` or the SDK's `destroySDK` take the node out
   (focus goes back to the tab bar if the viewer was inside).

## Contract

| Kind | Name | What |
| --- | --- | --- |
| set in init | `panelType`, `title`, `iconUri`, `order` | Read by the SDK at the add. `panelType` is also the node id and analytics e2 / e3; `title` e4. |
| written by the SDK | `name`, `client`, `clientConfig`, `eventID`, `timeCode`, `displayQRCodes`, `visible` | `eventID` `""` on a multi-event page; `timeCode` epoch ms as a string, `""` before the first tick. |
| override | `getData(params)` | Fetch and draw, for `m.top.eventID`. |
| override | `onEventIdChanged(id)`, `onTimeCodeChanged(tc)`, `onFocusEntered()` | A new event (the Pulse facts reset), the player clock, focus in. |
| override | `onKeyEvent(key, press)` | Return false for a key the panel does not use, OK included: a short OK stays in the panel, a long one closes it, Back and Up (with nothing above) go to the tab bar. |
| call | `emitEngage(action, target, metadata?)` | An engage beacon: e5 = action, e6 = target. |
| call | `emitCardFocus(card, index, list?)` · `clearCardFocus()` | A card_focus beacon once focus rests 300 ms. |
| call | `requestFocusReturn()` | Focus back to the SDK's tab bar. |
| call | `mcpTimer(seconds, callbackName, repeat?)` | A timer `endSession` stops. |
| call | `stagedIconUri()` · `stagedUri(uri)` | A `pkg:/` file copied to `tmp:/`, where the SDK can load it (see Icons). |
| call | `showError(title, subTitle?, iconUri?, width?, height?)` · `reloadPanel()` | The SDK's error view (an icon, a title, a line under it) in the panel's place; `reloadPanel` clears it and calls `getData`. The view has no retry control: offer your own. |
| set | `errorData` | What `showError` sets: `{ title, subTitle, uri?, width?, height? }`; invalid shows the panel again. |
| Pulse | `panel_view`, `panel_engage` | Set here on first show / first focus; SDK rules keyed on `panelType` read them. |

## Rules

- **`mcp` is reserved.** The base's scripts and yours share one scope (as every SceneGraph parent and child
  do): a function of yours named like one of the base's replaces it. Override only the plain names above.
- **An `endSession` override calls `mcpEndSession()`**, or the base's timers keep running.
- **No SDK helpers.** The node runs in your channel; only its interface crosses to the SDK.
- **`id` is the SDK's**: it writes `panelType` there.
- **Icons:** the SDK draws the tab (and the error view) from inside its component library, where your `pkg:/`
  path does not resolve. `stagedIconUri()` copies the icon to `tmp:/maestroCustomPanel_<panelType>_<file>` and
  returns that path (`stagedUri(uri)` does it for any file); an `http(s)://` uri is returned as it is. Call it
  at the add, after `iconUri` and `panelType` are set.
- **`panelType` is the spec's:** the SDK writes the type it was given back to the field at the add.
- **Update:** copy the folder again from the SDK's `src-host/core/MaestroCustomPanel`
  (`npm run custom-panel:publish` writes it, with a version file, into `maestro-roku-sdk-example`). Do not edit
  the copy.
