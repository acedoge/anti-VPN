
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local player = source
    local name, setKickReason, deferrals = name, setKickReason, deferrals
    local identifier = GetPlayerIdentifiers(player)
    local playerIP
    deferrals.defer()
    Wait(0)
    deferrals.update(string.format("%s님 서버에 접속하신 것을 환영합니다.", name))
    -- 플레이어의 여러 식별정보 중 ip 정보가 담긴 문자열 찾기
    for i, v in pairs(identifier) do
        if string.find(v, "ip") then
            playerIP = v:sub(4)
            break
        end
    end
    -- 버그, 스푸핑, fivem서버 문제로 ip 식별이 안될경우를 대비합니다
    if not playerIP then
        deferrals.done('IP정보를 식별할 수 없습니다.')
    else
        -- ip-api.com 홈페이지의 return type이 json인 api를 호출하여 json 으로 정보를 받아옵니다
        PerformHttpRequest("http://ip-api.com/json/" .. playerIP .. "?fields=proxy", function(err, text, headers)
            if tonumber(err) == 200 then -- 성공적으로 API를 호출하였을 경우
                local tbl = json.decode(text) -- json정보를 table로 풀어서 넣음
                if tbl["proxy"] == false then -- proxy 상태가 false인게 VPN 미사용 상태이므로 접속시키기
                    deferrals.done()
                else -- boolean type은 true or false이므로 false의 상태는 정상 나머지 true의 경우
                    deferrals.done("VPN 사용이 감지되었습니다. VPN 종료 후 다시 접속해주세요.")
                end
            else
                -- API호출 즉 VPN 검사에 실패하였을 경우 플레이어 접속을 멈추고 싶을때 아래 주석을 제거해주세요.
                -- deferrals.done("API 호출에 실패하였습니다.")
                
                -- 콘솔에 오류코드 로그 남기기
                print('IP: '..playerIP..' 의 VPN상태를 보는도중 오류가 발생하였습니다. 오류코드 : '..err)
            end
        end)
    end

end)