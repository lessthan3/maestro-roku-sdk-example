sub Main()
    showMarkupSGScreen()
end sub

sub showMarkupSGScreen()

    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)
    input = CreateObject("roInput")
    input.SetMessagePort(m.port)
    scene = screen.CreateScene("TestScene")
    screen.show()
    ' vscode_rdb_on_device_component_entry

    while(true)
        msg = wait(0, m.port)
	    msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        else if msgType = "roInputEvent"
            if msg.IsInput()
                info = msg.GetInfo()
                if invalid <> info.setLocalIp
                    localIpAddress = ""
                    if "true" = info.setLocalIp
                        localIpAddress = info.source_ip_addr
                    end if
                    reg = CreateObject("roRegistry")
                    regSec = CreateObject("roRegistrySection", "devInfo")
                    regSec.write("localIpAddress", localIpAddress)
                else if invalid <> info.flushRegistry
                    reg = CreateObject("roRegistry")
                    for each section in reg.getSectionList()
                        sec = createObject("roRegistrySection", section)
                        for each key in sec.getKeyList()
                            sec.delete(key)
                        end for
                        sec.flush()
                    end for
                    reg = invalid
                end if
            end if
        end if
    end while
end sub

