local ESX = nil
local myLevel = nil
local xeonLight = false
local WindowCar = true
local takeReward = false
local object = {}

if not Config.newEsx then
    Citizen.CreateThread(function()
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    
        while ESX == nil do Citizen.Wait(100) end
    
        while ESX.GetPlayerData().job == nil do
            Citizen.Wait(10)
        end
    
        ESX.PlayerData = ESX.GetPlayerData()
    end)
else
    ESX = exports["es_extended"]:getSharedObject()
end

CreateThread(function()
    while true do
        Wait(Config.timeRefreshReward)
        takeReward = true
    end
end)

local function GoodName(hash)
    if hash == GetHashKey("prop_roadcone02a") then
        return "Cone"
    elseif hash == GetHashKey("prop_barrier_work05") then
        return "Barrière"
    else
        return hash
    end
end

local function RequestModels(modelHash)
	if not HasModelLoaded(modelHash) and IsModelInCdimage(modelHash) then
		RequestModel(modelHash)

        while not HasModelLoaded(modelHash) do
			Citizen.Wait(1)
		end
	end
end

local function SpawnObject(model, coords, cb)
	local model = GetHashKey(model)

	Citizen.CreateThread(function()
		RequestModels(model)
        Wait(1)
		local obj = CreateObject(model, coords.x, coords.y, coords.z, true, false, true)

		if cb then
			cb(obj)
		end
	end)
end

local function SpawnObj(obj)
    local playerPed = PlayerPedId()
	local coords, forward = GetEntityCoords(playerPed), GetEntityForwardVector(playerPed)
    local objectCoords = (coords + forward * 1.0)
    local Ent = nil

    SpawnObject(obj, objectCoords, function(obj)
        SetEntityCoords(obj, objectCoords, 0.0, 0.0, 0.0, 0)
        SetEntityHeading(obj, GetEntityHeading(playerPed))
        PlaceObjectOnGroundProperly(obj)
        Ent = obj
        Wait(1)
    end)
    Wait(1)
    while Ent == nil do Wait(1) end
    SetEntityHeading(Ent, GetEntityHeading(playerPed))
    PlaceObjectOnGroundProperly(Ent)
    local placed = false
    while not placed do
        Citizen.Wait(1)
        local coords, forward = GetEntityCoords(playerPed), GetEntityForwardVector(playerPed)
        local objectCoords = (coords + forward * 2.0)
        SetEntityCoords(Ent, objectCoords, 0.0, 0.0, 0.0, 0)
        SetEntityHeading(Ent, GetEntityHeading(playerPed))
        PlaceObjectOnGroundProperly(Ent)
        SetEntityAlpha(Ent, 170, 170)

        if IsControlJustReleased(1, 38) then
            placed = true
        end
    end

    FreezeEntityPosition(Ent, true)
    SetEntityInvincible(Ent, true)
    ResetEntityAlpha(Ent)
    local NetId = NetworkGetNetworkIdFromEntity(Ent)
    table.insert(object, NetId)

end


local function RemoveObj(id, k)
    Citizen.CreateThread(function()
        SetNetworkIdCanMigrate(id, true)
        local entity = NetworkGetEntityFromNetworkId(id)
        NetworkRequestControlOfEntity(entity)
        local test = 0
        while test > 100 and not NetworkHasControlOfEntity(entity) do
            NetworkRequestControlOfEntity(entity)
            Wait(1)
            test = test + 1
        end
        SetEntityAsNoLongerNeeded(entity)

        local test = 0
        while test < 100 and DoesEntityExist(entity) do 
            SetEntityAsNoLongerNeeded(entity)
            TriggerServerEvent("DeleteEntity", NetworkGetNetworkIdFromEntity(entity))
            DeleteEntity(entity)
            DeleteObject(entity)
            if not DoesEntityExist(entity) then 
                table.remove(object, k)
            end
            SetEntityCoords(entity, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0)
            Wait(1)
            test = test + 1
        end
    end)
end

local function setPlayerPed(ped)
    local player = PlayerId()
    local modelPed = ped
    RequestModel(modelPed)
    while not HasModelLoaded(modelPed) do
        Wait(100)
    end
    SetPlayerModel(player, modelPed)
    SetModelAsNoLongerNeeded(modelPed)
end

local function rMenuVIPKeyboard(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    blockinput = true
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Wait(0)
    end 
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        blockinput = false
        return result
    else
        Wait(500)
        blockinput = false
        return nil
    end
end

RegisterNetEvent('rMenuVIP:returnMyLevel')
AddEventHandler('rMenuVIP:returnMyLevel', function(result)
	myLevel = result
end)

local function getMyLevel()
    TriggerServerEvent("rMenuVIP:getMyLevel")
    while myLevel == nil do RageUI.Text({message = "~y~Chargement de votre niveau"}) Wait(1) end
    if myLevel == 0 then
        ESX.ShowNotification("Vous n'etes pas VIP")
    end
end

local function menuVIP()
    local menuP = RageUI.CreateMenu("VIP", Config.nameServer)

    local menuCar = RageUI.CreateSubMenu(menuP, "VIP", Config.nameServer)
    local menuCarPlateColor = RageUI.CreateSubMenu(menuCar, "VIP", Config.nameServer)
    local menuCarColorXenon = RageUI.CreateSubMenu(menuCar, "VIP", Config.nameServer)
    local menuCarColorWindow = RageUI.CreateSubMenu(menuCar, "VIP", Config.nameServer)



    local menuPed = RageUI.CreateSubMenu(menuP, "VIP", Config.nameServer)
    local menuWeapon = RageUI.CreateSubMenu(menuP, "VIP", Config.nameServer)

    local menuProps = RageUI.CreateSubMenu(menuP, "VIP", Config.nameServer)
    local menuDeleteProps = RageUI.CreateSubMenu(menuProps, "VIP", Config.nameServer)
        RageUI.Visible(menuP, not RageUI.Visible(menuP))
            while menuP do
            Citizen.Wait(0)
            RageUI.IsVisible(menuP, true, true, true, function()
            if myLevel == nil then
                RageUI.Separator("Chargement en cours....")
            elseif myLevel == 0 then
                RageUI.CloseAll()
            else
                RageUI.Separator("~o~Votre niveau de VIP:~s~ ~y~"..Config.levelVIP[tonumber(myLevel)])
                RageUI.Separator("~b~Que voulez vous faire ?")
                
                if not IsPedSittingInAnyVehicle(PlayerPedId()) then
                    RageUI.ButtonWithStyle("Menu Véhicule", "Vous devez être dans un véhicule", {RightBadge = RageUI.BadgeStyle.Lock}, true, function(_, _, s) end)
                else
                    if tonumber(myLevel) >= tonumber(Config.accessForVIP.menuCar) then
                        RageUI.ButtonWithStyle("Menu Véhicule", nil, {}, true, function(_, _, s) end, menuCar)
                    end
                end
                if tonumber(myLevel) >= tonumber(Config.accessForVIP.menuPed) then
                    RageUI.ButtonWithStyle("Menu Peds", nil, {}, true, function(_, _, s) end, menuPed)
                end
                if tonumber(myLevel) >= tonumber(Config.accessForVIP.menuWeapon) then
                    RageUI.ButtonWithStyle("Menu Arme(s)", nil, {}, true, function(_, _, s) end, menuWeapon)
                end
                if tonumber(myLevel) >= tonumber(Config.accessForVIP.menuProps) then
                    RageUI.ButtonWithStyle("Menu Props", nil, {}, true, function(_, _, s) end, menuProps)
                end
                if takeReward then
                    RageUI.ButtonWithStyle("Récupérer ma récompense",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            TriggerServerEvent("rMenuVIP:receiveReward")
                            takeReward = false
                        end
                    end)
                else
                    RageUI.ButtonWithStyle("Récupérer ma récompense", nil, {RightBadge = RageUI.BadgeStyle.Lock}, true, function(_, _, s) end)
                end
            end

            end)

            RageUI.IsVisible(menuCar, true, true, true, function()
                RageUI.Separator("~b~Que voulez vous faire ?")


                RageUI.ButtonWithStyle("Nettoyer le véhicule",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        if IsPedSittingInAnyVehicle(PlayerPedId()) then
                            WashDecalsFromVehicle(GetVehiclePedIsUsing(PlayerPedId()), 1.0)
                            ESX.ShowNotification("Votre véhicule est propre")
                        else
                            ESX.ShowNotification("Vous n'êtes pas dans un véhicule")
                        end
                    end
                end)

                RageUI.Separator('~o~↓ Gestion plaques ↓')

                RageUI.ButtonWithStyle("Nom plaque",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        if IsPedSittingInAnyVehicle(PlayerPedId()) then
                            local newPlate = rMenuVIPKeyboard("Nom plaque ?", "", 20)
                            if newPlate ~= nil then
                                SetVehicleNumberPlateText(GetVehiclePedIsUsing(PlayerPedId()), newPlate)
                            else
                                ESX.ShowNotification("Vous ne pouvez pas laisser vide")
                            end
                        else
                            ESX.ShowNotification("Vous n'êtes pas dans un véhicule")
                        end
                    end
                end)

                RageUI.ButtonWithStyle("Menu couleurs plaque", nil, {}, true, function(_, _, s) end, menuCarPlateColor)
                
                RageUI.Line()

                RageUI.Checkbox("Activer/Desactiver phares xénon",nil, xeonLight,{},function(Hovered,Ative,Selected,Checked)
                    if Selected then
                        xeonLight = Checked
                        if Checked then
                            if IsPedSittingInAnyVehicle(PlayerPedId()) then
                                local pVeh = GetVehiclePedIsIn(PlayerPedId(), true)
                                ToggleVehicleMod(pVeh, 22, true)
                                SetVehicleHeadlightsColour(GetVehiclePedIsUsing(PlayerPedId()), -1)
                            else
                                ESX.ShowNotification("Vous n'êtes pas dans un véhicule")
                            end
                        else
                            if IsPedSittingInAnyVehicle(PlayerPedId()) then
                                local pVeh = GetVehiclePedIsIn(PlayerPedId(), true)
                                ToggleVehicleMod(pVeh, 22, false)
                            else
                                ESX.ShowNotification("Vous n'êtes pas dans un véhicule")
                            end
                        end
                    end
                end)

                RageUI.ButtonWithStyle("Menu couleurs phares xénon", nil, {}, true, function(_, _, s) end, menuCarColorXenon)

                RageUI.Line()

                RageUI.Checkbox("Ouvrir/Fermer les fenêtres",nil, WindowCar,{},function(Hovered,Ative,Selected,Checked)
                    if Selected then
                        WindowCar = Checked
                        if Checked then
                            if IsPedSittingInAnyVehicle(PlayerPedId()) then
                                local pVeh = GetVehiclePedIsIn(PlayerPedId(), true)
                                for i = 0,7,1 do
                                    RollUpWindow(pVeh, i)
                                    FixVehicleWindow(pVeh, i)
                                end
                            else
                                ESX.ShowNotification("Vous n'êtes pas dans un véhicule")
                            end
                        else
                            if IsPedSittingInAnyVehicle(PlayerPedId()) then
                                local pVeh = GetVehiclePedIsIn(PlayerPedId(), true)
                                RollDownWindows(pVeh)
                            else
                                ESX.ShowNotification("Vous n'êtes pas dans un véhicule")
                            end
                        end
                    end
                end)

                RageUI.ButtonWithStyle("Menu couleurs fenêtres", nil, {}, true, function(_, _, s) end, menuCarColorWindow)
            end)

            RageUI.IsVisible(menuCarPlateColor, true, true, true, function()

                RageUI.Separator("~y~↓ Couleurs disponible ↓")

                for k,v in pairs(Config.plateColor) do
                    RageUI.ButtonWithStyle(v.label,nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            if IsPedSittingInAnyVehicle(PlayerPedId()) then
                                SetVehicleNumberPlateTextIndex(GetVehiclePedIsUsing(PlayerPedId()), v.indexColor)
                            else
                                ESX.ShowNotification("Vous n'êtes pas dans un véhicule")
                            end
                        end
                    end)
                end

            end)

            RageUI.IsVisible(menuCarColorXenon, true, true, true, function()

                RageUI.Separator("~y~↓ Couleurs disponible ↓")

                for k,v in pairs(Config.xenonColor) do
                    RageUI.ButtonWithStyle(v.label,nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            if IsPedSittingInAnyVehicle(PlayerPedId()) then
                                -- SetVehicleXenonLightsColor
                                SetVehicleHeadlightsColour(GetVehiclePedIsUsing(PlayerPedId()), v.indexColor)
                            else
                                ESX.ShowNotification("Vous n'êtes pas dans un véhicule")
                            end
                        end
                    end)
                end

            end)

            RageUI.IsVisible(menuCarColorWindow, true, true, true, function()

                RageUI.Separator("~y~↓ Couleurs disponible ↓")

                for k,v in pairs(Config.windowColor) do
                    RageUI.ButtonWithStyle(v.label,nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            if IsPedSittingInAnyVehicle(PlayerPedId()) then
                                SetVehicleModKit(GetVehiclePedIsIn(PlayerPedId()), 0)
                                SetVehicleWindowTint(GetVehiclePedIsIn(PlayerPedId()), v.indexColor)
                            else
                                ESX.ShowNotification("Vous n'êtes pas dans un véhicule")
                            end
                        end
                    end)
                end

            end)

            RageUI.IsVisible(menuPed, true, true, true, function()

                RageUI.ButtonWithStyle("Redevenir normal",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
                            local isMale = skin.sex == 0
                            TriggerEvent('skinchanger:loadDefaultModel', isMale, function()
                                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                                    TriggerEvent('skinchanger:loadSkin', skin)
                                    TriggerEvent('esx:restoreLoadout')
                                end)
                            end)
                        end)                
                    end
                end)


                RageUI.Separator("~b~↓ Ped disponible ↓")

                for k,v in pairs(Config.allPeds) do
                    RageUI.ButtonWithStyle(v.label,nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            setPlayerPed(v.modelPed)
                        end
                    end)
                end

            end)

            RageUI.IsVisible(menuWeapon, true, true, true, function()

                RageUI.Separator("~b~Camouflages Arme(s)")

                RageUI.Separator("~y~↓ Couleurs disponible ↓")

                for k,v in pairs(Config.tintWeapon) do
                    RageUI.ButtonWithStyle(v.label,nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            if IsPedSittingInAnyVehicle(PlayerPedId()) then
                                ESX.ShowNotification("Vous ne pouvez pas faire cette action dans un véhicule")
                            else
                                SetPedWeaponTintIndex(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), v.indexColor)
                            end
                        end
                    end)
                end

            end)
            

            RageUI.IsVisible(menuProps, true, true, true, function()

                RageUI.ButtonWithStyle("~r~Menu suppression", nil, {}, true, function(_, _, s) end, menuDeleteProps)

                RageUI.Separator("~b~↓ Props disponible ↓")

                for k,v in pairs(Config.allProps) do
                    RageUI.ButtonWithStyle(v.label, "Appuyer sur [~g~E~w~] pour poser l'objet", {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            if IsPedSittingInAnyVehicle(PlayerPedId()) then
                                ESX.ShowNotification("Vous ne pouvez pas faire cette action dans un véhicule")
                            else
                                SpawnObj(v.modelProps)
                            end
                        end
                    end)
                end

            end)

            RageUI.IsVisible(menuDeleteProps, true, true, true, function()

                for k,v in pairs(object) do
                    if GoodName(GetEntityModel(NetworkGetEntityFromNetworkId(v))) == 0 then table.remove(object, k) end
                    RageUI.ButtonWithStyle("Object: "..GoodName(GetEntityModel(NetworkGetEntityFromNetworkId(v))).." ["..v.."]", "Appuyer sur [~g~E~w~] pour supprimer l'objet", {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Active then
                            if not IsPedSittingInAnyVehicle(PlayerPedId()) then
                                local entity = NetworkGetEntityFromNetworkId(v)
                                local ObjCoords = GetEntityCoords(entity)
                                DrawMarker(0, ObjCoords.x, ObjCoords.y, ObjCoords.z+1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 255, 0, 170, 1, 0, 2, 1, nil, nil, 0)
                            end
                        end
                        if Selected then
                            if IsPedSittingInAnyVehicle(PlayerPedId()) then
                                ESX.ShowNotification("Vous ne pouvez pas faire cette action dans un véhicule")
                            else
                                RemoveObj(v, k)
                            end
                        end
                    end)
                end
            end)


            if not RageUI.Visible(menuP) and not RageUI.Visible(menuCar) and not RageUI.Visible(menuCarColorWindow) and not RageUI.Visible(menuCarColorXenon) and not RageUI.Visible(menuCarPlateColor) and not RageUI.Visible(menuPed) and not RageUI.Visible(menuWeapon) and not RageUI.Visible(menuProps) and not RageUI.Visible(menuDeleteProps) then
            menuP = RMenu:DeleteType("menuP", true)
        end
    end
end


if Config.openWithKeyboard then
    Keys.Register('F3', 'rMenuVIP', 'Ouvrir notre menu VIP', function()
        getMyLevel() menuVIP()
    end)
end

if Config.openWithCommand then
    RegisterCommand("menuvip", function()
        getMyLevel() menuVIP()
    end)
end

TriggerEvent('chat:addSuggestion', '/menuvip', 'Ouvrir notre menu VIP', {})