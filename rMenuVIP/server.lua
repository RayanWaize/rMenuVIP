local ESX = nil

if not Config.newEsx then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
else
    ESX = exports["es_extended"]:getSharedObject()
end

RegisterServerEvent("rMenuVIP:getMyLevel")
AddEventHandler("rMenuVIP:getMyLevel", function()
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    MySQL.Async.fetchAll('SELECT * FROM allvip WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function (result)
        if result[1] then
            TriggerClientEvent("rMenuVIP:returnMyLevel", _src, result[1].level)
        else
            TriggerClientEvent("rMenuVIP:returnMyLevel", _src, 0)
        end
    end)
end)

RegisterServerEvent("rMenuVIP:receiveReward")
AddEventHandler("rMenuVIP:receiveReward", function()
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local reward = math.random(1, #Config.allReward)
    if Config.allReward[tonumber(reward)].type == "cash" then
        xPlayer.addAccountMoney('cash', Config.allReward[tonumber(reward)].amount)
        TriggerClientEvent("esx:showNotification", _src, Config.allReward[tonumber(reward)].notification)
    elseif Config.allReward[tonumber(reward)].type == "item" then
        xPlayer.addInventoryItem(Config.allReward[tonumber(reward)].name, Config.allReward[tonumber(reward)].amount)
        TriggerClientEvent("esx:showNotification", _src, Config.allReward[tonumber(reward)].notification)
    else
        TriggerClientEvent("esx:showNotification", _src, "~r~Une erreur est survenue veuillez contacter l'équipe")
    end
end)

RegisterCommand("setvip", function(source, args, rawCommand)
    local idPlayer = args[1]
    local levelVIP = args[2]
    if Config.levelVIP[tonumber(levelVIP)] then
        if source == 0 then
            if idPlayer then
                local xPlayer = ESX.GetPlayerFromId(idPlayer)
                if xPlayer then
                    MySQL.Async.fetchAll('SELECT identifier FROM allvip WHERE identifier = @identifier', {
                        ['@identifier'] = xPlayer.identifier
                    }, function (result)
                        if result[1] then
                            MySQL.Async.execute('UPDATE allvip SET level = @level WHERE identifier = @identifier', {
                                ['@identifier'] = xPlayer.identifier,
                                ['@level'] = tonumber(levelVIP)
                            }, function(rowsChange)
                                Wait(200)
                                TriggerClientEvent("rMenuVIP:returnMyLevel", idPlayer, levelVIP)
                                TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, Config.nameServer..' VIP', '~o~Informations~s~', "Bienvenue ! Merci à vous pour votre soutien vous venez de recevoir le VIP: "..Config.levelVIP[tonumber(levelVIP)], "CHAR_DAVE", 9)
                            end)
                        else
                            MySQL.Async.execute('INSERT INTO allvip (identifier, level) VALUES (@identifier, @level)', {
                                ['@identifier'] = xPlayer.identifier,
                                ['@level'] = tonumber(levelVIP)
                            }, function(rowsChange)
                                Wait(200)
                                TriggerClientEvent("rMenuVIP:returnMyLevel", idPlayer, levelVIP)
                                TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, Config.nameServer..' VIP', '~o~Informations~s~', "Bienvenue ! Merci à vous pour votre soutien vous venez de recevoir le VIP: "..Config.levelVIP[tonumber(levelVIP)], "CHAR_DAVE", 9)
                            end)
                        end
                    end)
                else
                    print("Nous arrivons pas à détecter joueur")
                end
            else
                print("Vous avez pas defini l'id du joueur")
            end
        else
            print("Vous pouvez pas faire cette commande ici")
        end
    else
        print("Ce niveau de VIP n'existe pas")
    end
end)