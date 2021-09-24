RegisterNUICallback('close', function(data)
    SetNuiFocus(false, false)
end)

RegisterNUICallback('execute-action', function(data)
    ESX.TriggerServerCallback("dz-admin:server:getGroup", function(allow)
        if allow == true then
            if data.type == "kick" or data.type == "ban" then
                if data.reason ~= "" or data.reason ~= nil then
                    TriggerServerEvent("dz-admin:server:"..data.type, data.id, data.reason)
                else
                    TriggerServerEvent("dz-admin:server:"..data.type, data.id, "No Reason")
                end
                return
            end
            TriggerServerEvent("dz-admin:server:"..data.type, data.id)
        end
    end, "self")
end)

RegisterNUICallback('execute-all-action', function(data)
    ESX.TriggerServerCallback("dz-admin:server:getGroup", function(allow)
        if allow == true then
            TriggerServerEvent("dz-admin:server:"..data.type)
        end
    end, "all")
end)

function FetchPlayers()
	local PlayerList = {}
	for i = 0, 255 do 
        if NetworkIsPlayerActive(i) then 
            table.insert(PlayerList, { id = GetPlayerServerId(i), name = GetPlayerName(i) }) 
        end 
    end
    
	return PlayerList
end