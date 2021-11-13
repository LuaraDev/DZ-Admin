local ESX = nil
TriggerEvent('esx:getSharedObject', function(obj)  ESX = obj  end)
StopResource("es_admin2")
Bans = {}

Citizen.CreateThread(function()
    Citizen.Wait(200)
    TriggerEvent("dz-admin:server:executeAction", "goto")
    TriggerEvent("dz-admin:server:executeAction", "bring")
    TriggerEvent("dz-admin:server:executeAction", "freeze")
    TriggerEvent("dz-admin:server:executeAction", "noclip")
    TriggerEvent("dz-admin:server:executeAction", "slay")
    TriggerEvent("dz-admin:server:executeAction", "revive")
    TriggerEvent("dz-admin:server:executeAction", "kick")
    TriggerEvent("dz-admin:server:executeAction", "ban")
    TriggerEvent("dz-admin:server:executeAction", "bringall")
    TriggerEvent("dz-admin:server:executeAction", "reviveall")
    TriggerEvent("dz-admin:server:executeAction", "kickall")
end)

ESX.RegisterServerCallback("dz-admin:server:getGroup", function(source, cb, type)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    local isAllowed = false
    for k, v in pairs(DZ.Groups[type]) do
        if v == Player.getGroup() then
            isAllowed = true
        end
    end

    cb(isAllowed)
end)

RegisterCommand("admin", function(source)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    if Player ~= nil then
        if Player.getGroup() == "admin" or Player.getGroup() == "superadmin" then
            TriggerClientEvent("dz-admin:client:openMenu", src)
        end
    end
end)

RegisterServerEvent("dz-admin:server:executeAction")
AddEventHandler("dz-admin:server:executeAction", function(type)
    print("[dz-admin] Successfully created ".. "dz-admin:server:"..type.. " event.")
    RegisterServerEvent("dz-admin:server:"..type)
    AddEventHandler("dz-admin:server:"..type, function(Target, Reason)
        local src = source
        Target = tonumber(Target)
        if type == "bring" then
            local Ped = GetPlayerPed(src)
            local Position = GetEntityCoords(Ped)
            TriggerClientEvent("dz-admin:client:"..type, Target, Position)
            DiscordLogging(src, GetPlayerName(src), "[dz-admin] Action Executed", GetPlayerName(src).." has been executed `bring` action.", "4094899")
            return
        elseif type == "goto" then
            TriggerClientEvent("dz-admin:client:"..type, src, Target)
            DiscordLogging(src, GetPlayerName(src), "[dz-admin] Action Executed", GetPlayerName(src).." has been executed `goto` action.", "4094899")
            return
        elseif type == "kick" then
            if Reason == "" then Reason = "No Reason" end
            DiscordLogging(src, GetPlayerName(src), "[dz-admin] Action Executed", GetPlayerName(src).." has been executed `kick` action.", "4094899")
            DropPlayer(Target, '[dz-admin | dz-security.live] You have been kicked out from "'..DZ.ServerName..'" for reason: "'..Reason..'".')
            TriggerClientEvent("dz-admin:client:updatePlayers", -1)
            return
        elseif type == "ban" then
            if Reason == "" then Reason = "No Reason" end
            DiscordLogging(src, GetPlayerName(src), "[dz-admin] Action Executed", GetPlayerName(src).." has been executed `ban` action.", "4094899")
            Bans[GetPlayerIdentifiers(Target)[1]] = { reason = Reason }
            val = Bans
            SaveResourceFile(GetCurrentResourceName(), "server/bans.json", json.encode(val), -1)
            DropPlayer(Target, '[dz-admin | dz-security.live] You were been banned from "'..DZ.ServerName..'" for reason: "'..Reason..'".')
            TriggerClientEvent("dz-admin:client:updatePlayers", -1)
            return
        end

        if type == "bringall" then
            local Ped = GetPlayerPed(src)
            local Position = GetEntityCoords(Ped)
            TriggerClientEvent("dz-admin:client:bring", -1, Position)
            print("[dz-admin] Bring-All action was executed by ("..GetPlayerName(src).." | "..GetPlayerIdentifiers(src)[1]..").")
            DiscordLogging(src, GetPlayerName(src), "[dz-admin] Action Executed", GetPlayerName(src).." has been executed `Bring-All` action.", "4094899")
            return
        elseif type == "reviveall" then
            TriggerClientEvent("dz-admin:client:revive", -1)
            print("[dz-admin] Revive-All action was executed by ("..GetPlayerName(src).." | "..GetPlayerIdentifiers(src)[1]..").")
            DiscordLogging(src, GetPlayerName(src), "[dz-admin] Action Executed", GetPlayerName(src).." has been executed `Revive-All` action.", "4094899")
            return
        elseif type == "kickall" then
            TriggerClientEvent("dz-admin:client:kickAll", -1)
            print("[dz-admin] Kick-All action was executed by ("..GetPlayerName(src).." | "..GetPlayerIdentifiers(src)[1]..").")
            DiscordLogging(src, GetPlayerName(src), "[dz-admin] Action Executed", GetPlayerName(src).." has been executed `Kick-All` action.", "4094899")
            return
        end

        TriggerClientEvent("dz-admin:client:"..type, Target)
        DiscordLogging(src, GetPlayerName(src), "[dz-admin] Action Executed", GetPlayerName(src).." has been executed `"..type.."` action.", "4094899")
    end)
end)

RegisterServerEvent("dz-admin:server:kickAll")
AddEventHandler("dz-admin:server:kickAll", function()
    local src = source
    DropPlayer(src, "[KickAll-Function Executed] You have been kicked out from "..DZ.ServerName..".")
end)

function LoadBans()
    CreateThread(function()
        Wait(500)
        local path = LoadResourceFile(GetCurrentResourceName(), "server/bans.json")
        local result = json.decode(path)
        if result then Bans = result end
    end)
end

LoadBans()
AddEventHandler('playerDropped', function () TriggerClientEvent("dz-admin:client:updatePlayers", -1) end)
AddEventHandler('playerConnecting', function(user, kickr, deferrals)
    LoadBans()
    deferrals.defer()
    Wait(0)
    deferrals.update("[dz-admin | dz-security.live] Welcome to "..DZ.ServerName..", Your info is being checked.")
    local src = source
    local Identifier = GetPlayerIdentifiers(src)[1]
    if Bans[Identifier] then
        deferrals.done("[dz-admin | dz-security.live] You're banned from this server for reason: "..Bans[Identifier]["reason"])
        CancelEvent()
        return
    else deferrals.done() end
end)

RegisterCommand("unban", function(source, args)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    local Target = args[1]
    if Player ~= nil then
        if Player.getGroup() == "admin" or Player.getGroup() == "superadmin" then
            if Bans[Target] then
                Bans[Target] = nil
                val = Bans
                SaveResourceFile(GetCurrentResourceName(), "server/bans.json", json.encode(val), -1)
                LoadBans()
            else
                print("player isnt banned")
            end
        end
    end
end)

function DiscordLogging(source, PlayerName, Title, Desc, Color)
    local PInfo = FetchInformation(source)
    local embed = {
        {
            ["color"] = Color,
            ["title"] = Title,
            ["description"] = Desc,
            ["fields"] = {
                { ["name"] = "Players Identifiers", ["value"] = "The information below is information we were able to get on the player.", ["inline"] = false },
            	{ ["name"] = "Discord", ["value"] = PInfo[2] .. "\n[<@"..PInfo[2]..">]", ["inline"] = true },
            	{ ["name"] = "Steam Name", ["value"] = GetPlayerName(source), ["inline"] = true },
                { ["name"] = "Steam Hex", ["value"] = "steam:"..PInfo[1], ["inline"] = true }, },
	        ["footer"] = { ["text"] = "Powered by Development Zone | dz-security.live", },
        }
    }
    PerformHttpRequest(DZ.DiscordLogging, function(err, text, headers) end, 'POST', json.encode({username = "Discord Logs", embeds = embed}), { ['Content-Type'] = 'application/json' })
end

function FetchInformation(source)
    local SteamHex = "Unknown"
    local Discord = "Unknown"
    local PData = {SteamHex, Discord}
    for key, value in pairs(GetPlayerIdentifiers(source))do
        if string.sub(value, 1, string.len("steam:")) == "steam:" then
            SteamHex = value:gsub("steam:", "")
            PData[1] = SteamHex
        elseif string.sub(value, 1, string.len("discord:")) == "discord:" then
            Discord = value:gsub("discord:", "")
            PData[2] = Discord
        end
    end
    return PData
end
