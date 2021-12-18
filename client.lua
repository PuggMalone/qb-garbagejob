local QBCore = exports['qb-core']:GetCoreObject()
local onJob = false
local trashAmt = nil
local jobID = 0
local Zones = {}
local baseJob = nil
local missZone = nil
local missLabel = nil
local garbagebag
local vehicle
local trashAmt = 0
local npcSpawned = false
local NPC
local people = 1
local holdingTrash = false

CreateThread(function()
    for k in pairs(Config.Zones) do
        Zones[#Zones+1] = k
    end
end)

-- Functions

local function getVehicleInDirection(coordFrom, coordTo)
    local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, PlayerPedId(), 0)
    local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
    return vehicle
end

local function hasTrash()
    holdingTrash = true
    CreateThread(function()
        local ped = PlayerPedId()
        while hasTrash do
            Wait(0)
            if IsControlJustReleased(0,38) and IsPedOnFoot(ped) then
                local playerPed = PlayerPedId()
                local coords = GetEntityCoords(playerPed)
                if IsAnyVehicleNearPoint(coords, 9.0) then
                    local coordA = GetEntityCoords(playerPed, 1)
                    local coordB = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
                    vehicle = getVehicleInDirection(coordA, coordB)
                    local boot = GetEntityBoneIndexByName(vehicle,'boot')
                    local bootDst = GetWorldPositionOfEntityBone(vehicle,boot)
                    local dst = #(GetEntityCoords(PlayerPedId()) - bootDst)
                    if dst < 3.0 and GetVehicleDoorAngleRatio(vehicle,5) ~= 0 and IsVehicleModel(vehicle,'trash2') then
                        if DoesEntityExist(garbagebag) and trashAmt < Config.TrashAmt then
                            TriggerServerEvent('gl-garbage:depositTrash',jobID)
                            DeleteEntity(garbagebag)
                            holdingTrash = false
                        end
                    end
                end
            end
        end
    end)
end

-- Spawn NPC

CreateThread(function()
    blip = AddBlipForCoord(-321.77,-1545.84,30.02)
    SetBlipSprite(blip, 318)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 5)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Garbage")
    EndTextCommandSetBlipName(blip)
    -- while true do
    --     Wait(1000)
    --     local garCoords = vector3(-321.77,-1545.84,30.02)
    --     local pedCoords = GetEntityCoords(PlayerPedId())
    --     local dst = #(garCoords - pedCoords)
    --     if dst < 200 and npcSpawned == false then
    --         TriggerEvent('gl-garbage:spawnNPC',garCoords,353.24)
    --         npcSpawned = true
    --     end
    --     if dst >= 201  then
    --         npcSpawned = false
    --         DeleteEntity(NPC)
    --     end
    -- end
end)

-- Spawn Boss NPC
RegisterNetEvent('gl-garbage:spawnNPC',function(coords,heading)
    local hash = `s_m_y_garbage`
    NPC = CreatePed(5, hash, coords, heading, false, false)
    FreezeEntityPosition(NPC, true)
    SetEntityInvincible(NPC, true)
    SetBlockingOfNonTemporaryEvents(NPC, true)
    SetModelAsNoLongerNeeded(hash)
    TaskStartScenarioInPlace(NPC,'WORLD_HUMAN_HANG_OUT_STREET')
    exports['qb-target']:AddEntityZone('NPC', NPC, {
    name="NPC",
    debugPoly=false,
    useZ = true
    }, {
    options = {
        {
            event = 'gl-garbage:getJob',
            icon = "fas fa-clipboard",
            label = "Start Shift",
        },
        {
            event = 'gl-garbage:joinMultiJob',
            icon = "fas fa-clipboard",
            label = "Join A Shift",
        },
        {
            event = 'gl-garbage:endJob',
            icon = "fas fa-clipboard",
            label = "End Shift",
        },
        {
            event = 'gl-garbage:turnInVoucher',
            icon = "fas fa-clipboard",
            label = "Redeem Voucher",
        },
    },
        distance = 2.5
    })
end)


-- RegisterNetEvent('gl-garbage:turnInVoucher',function()
--     local voucherMenu = {}
--     for k, v in pairs(Config.VoucherList) do
--         voucherMenu[#voucherMenu + 1] = {
--             header = v.label,
--             txt = "Get " .. v.amount .. " " ..  v.label,
--             params = {
--                 event = 'gl-garbage:redeemMaterial',
--                 args = {
--                     choice = v.databasename,
--                     amount = v.amount
--                 }
--             }
--         }
--     end
--     exports['qb-menu']:openMenu(voucherMenu)
-- end)

RegisterNetEvent('gl-garbage:redeemMaterial',function(data)
    choice = data.choice
    amount = data.amount
    TriggerServerEvent('gl-garbage:redeemMaterial',choice,amount)
end)

RegisterNetEvent('gl-garbage:getJob',function()
    if not onJob then
        local coords = vector4(-315.18, -1534.67, 27.65, 350.24)	
                QBCore.Functions.SpawnVehicle("trash2", function(veh)
                    SetVehicleNumberPlateText(veh, "POLICE2"..tostring(math.random(1000, 9999)))
                    exports['lj-fuel']:SetFuel(veh, 100.0)
                    SetEntityHeading(veh, coords.w)
                    -- TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                    TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
                    SetVehicleEngineOn(veh, true, true)
                    SetVehicleDirtLevel(veh, 15)
                    SetVehicleLivery(veh, 2)
                end, coords, true)
        onJob = true
        jobID = math.random(10000,99999)
        baseJob = Config.Zones[Zones[math.random(#Zones)]]
        missZone = baseJob.Zone
        missLabel = baseJob.Label
        people = 1
        QBCore.Functions.Notify("Head to " .. missLabel .. ' area and pick up ' .. Config.TrashAmt .. ' loads of trash')
        TriggerServerEvent('qb-phone:server:sendNewMail', {
            sender = "Garbage Manager",
            subject = "Trash Route",
            message = "Head to " .. missLabel .. ' area and pick up ' .. Config.TrashAmt .. ' loads of trash. Your Job ID is ' .. jobID,
        })
        QBCore.Functions.Notify("Your Job ID is " .. jobID)
        exports['qb-target']:AddTargetModel(Config.Bins, {
            options = {
                {
                    event = "gl-garbage:searchBin",
                    icon = "fas fa-clipboard",
                    label = "Grab Trash",
                },

            },
            distance = 1.0
        })
        TriggerServerEvent('gl-garbage:makeMultiJob',jobID,missZone)
        zoneBlip = AddBlipForRadius(baseJob.Coords, 400.0)
        SetBlipSprite(zoneBlip,9)
        SetBlipColour(zoneBlip,49)
        SetBlipAlpha(zoneBlip,75)
        Wait(120000)
        RemoveBlip(zoneBlip)
    end
end)

RegisterNetEvent('gl-garbage:newJobID',function(ID)
    jobID = ID
end)

RegisterNetEvent('gl-garbage:endJob',function()
    if onJob then
        TriggerServerEvent('gl-garbage:cashOut',jobID,people)
    end
end)

RegisterNetEvent('gl-garbage:cashedOut',function(ID,people)
    if jobID == ID then
        QBCore.Functions.Notify('You/Your jobmates have cashed out')
        jobID = nil
        onJob = false
        exports['qb-target']:RemoveZone(Config.Bins)
        RemoveBlip(zoneBlip)
        TriggerServerEvent('gl-garbage:getPaid', trashAmt, people)
        people = 1
        trashAmt = 0
        DeleteEntity(vehicle)
    end
    -- if DoesEntityExist(vehicle) then
    --     DeleteEntity(vehicle)
    -- end
end)

RegisterNetEvent('gl-garbage:joinMultiJob',function()
    local keyboard = exports["qb-input"]:ShowInput({
        header = "Enter Job ID",
        submitText = "Submit",
        inputs = {
            {
                isRequired = true,
                type = 'number',
                txt = "Job ID",
                name = 'jobid'
            },
        }
    })
    if keyboard then
        TriggerServerEvent('gl-garbage:joinMultiJob', keyboard.jobid)
    end
end)

RegisterNetEvent('gl-garbage:joinedMultiJob',function(ID,zone)
    jobID = ID
    QBCore.Functions.Notify('You have joined Job ID ' .. jobID)
    missZone = zone
    missLabel = zone
    onJob = true
    exports['qb-target']:AddTargetModel(Config.Bins, {
        options = {
            {
                event = "gl-garbage:searchBin",
                icon = "fas fa-clipboard",
                label = "Grab Trash",
            },
        },
        distance = 1.0
    })
end)

RegisterNetEvent('gl-garbage:updatePeople',function(ID)
    if jobID == ID then
        people = people + 1
        QBCore.Functions.Notify('Another person has joined the job')
    end
end)

RegisterNetEvent('gl-garbage:searchBin',function()
    zoneCoords = GetEntityCoords(PlayerPedId())
    zoneName = GetNameOfZone(zoneCoords)
    if zoneName == missZone then
    local dumpster

    for i = 1, #Config.Bins do
        dumpster = GetClosestObjectOfType(zoneCoords.x,zoneCoords.y,zoneCoords.z, 0.8, Config.Bins[i], true, false, false)
        if dumpster ~= 0 then
        objId = ObjToNet(dumpster)
        TriggerServerEvent('gl-garbage:checkBin',objId)
        end
    end

    else
        QBCore.Functions.Notify('You need to be in ' .. missLabel)
    end
end)

RegisterNetEvent('gl-garbage:getTrash',function()
    if DoesEntityExist(garbagebag) then
        QBCore.Functions.Notify('Cannot carry any more trash', 'error')
    else
        QBCore.Functions.Notify('Press E at the back of the truck to deposit')
        garbagebag = CreateObject(`hei_prop_heist_binbag`, 0, 0, 0, true, true, true)
        AttachEntityToEntity(garbagebag, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.15, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true) -- object is attached to right hand
        hasTrash()
    end
end)

RegisterNetEvent('gl-garbage:depositTrashClient',function(ID)
    if jobID == ID then
        trashAmt = trashAmt + 1
        QBCore.Functions.Notify(trashAmt .. ' / ' .. Config.TrashAmt .. ' Completed')
        if trashAmt == Config.TrashAmt then
            TriggerServerEvent('gl-garbage:jobDone',jobID)
            DeleteEntity(garbagebag)
        end
    end
end)

RegisterNetEvent('gl-garbage:depositTrashToServer',function()
    local boot = GetEntityBoneIndexByName(vehicle,'boot')
    local bootDst = GetWorldPositionOfEntityBone(vehicle,boot)
    local dst = #(GetEntityCoords(PlayerPedId()) - bootDst)
    if dst < 3.0 and GetVehicleDoorAngleRatio(vehicle,5) ~= 0 then
        if DoesEntityExist(garbagebag) and trashAmt < Config.TrashAmt then
        TriggerServerEvent('gl-garbage:depositTrash',jobID)
        DeleteEntity(garbagebag)
        end
    end
end)

RegisterCommand('jobid', function()
    QBCore.Functions.Notify('Your job ID is ' .. jobID)
end)

