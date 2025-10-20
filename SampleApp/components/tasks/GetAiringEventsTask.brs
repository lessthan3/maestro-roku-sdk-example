sub init()
    m.top.id = "GetAiringEventsTask"
    m.top.functionName = "getAirings"
end sub

' Fetch airings from ESPN API
sub getAirings()
    ' Set params
    limit = 50

    dateNow = CreateObject("roDateTime")
    dateTo = CreateObject("roDateTime")
    dateTo.FromSeconds(dateNow.AsSeconds() + (4 * 24 * 60 * 60)) ' Add 2 days
    toDate = dateTo.asDateStringLoc("yMMdd")

    ' Make airing call
    url = "https://site.api.espn.com/apis/v2/events/airings?limit=" + limit.toStr() + "&toDate=" + toDate.toStr()

    request = CreateObject("roUrlTransfer")
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    request.SetUrl(url)

    ' Object to determin which leagues to grab based on legue guid
    ' https://docs.google.com/spreadsheets/d/1D92ZyOtUA4SabBBa4NJhM_hiDqLFRUKfO8sBl1FoHFY/edit?gid=1368023291#gid=1368023291

    events = {
        "ad4c3bd2-ddb6-3f8c-8abf-744855a08fa4": [], ' nfl
        "f74a6d24-af0c-30a0-bc20-e987c7093a68": [], ' wmba
    }

    ' handle response
    response = request.GetToString()
    if response <> invalid and response <> "" then
        ' Parse JSON response
        parsed = ParseJson(response)
        if parsed <> invalid and parsed.count > 0
            for each item in parsed.items
                if item.league.guid <> invalid and events.[item.league.guid] <> invalid
                    events.[item.league.guid].push(item)
                end if
            end for
        end if
    end if

    ' Update observer
    m.top.events = events
end sub
