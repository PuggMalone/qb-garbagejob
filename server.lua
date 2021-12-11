local QBCore = exports['qb-core']:GetCoreObject()
local searchedBins = {}
local curjobs = {}
local jobzones = {}

local function addToSet(set, key)
    set[key] = true
end

local function tableHasKey(table, key)
    return table[key] ~= nil
end

local function removeKey(key)
    local value = curjobs[key]
    if (value == nil) then
        return
    end
    curjobs[key] = nil
    jobzones[value] = nil
end

local function addValue(key, value)
    if (value == nil) then
        removeKey(key)
        return
    end
    curjobs[key] = value
    jobzones[value] = key
end

local function getValue(key)
    return curjobs[key]
end

RegisterNetEvent('gl-garbage:makeMultiJob', function(jobID, zone)
    local hasValue = getValue(jobID)
    if hasValue then
        newID = math.random(10000, 99999)
        addValue(newID, zone)
        TriggerClientEvent('gl-garbage:newJobID', source, newID)
        TriggerClientEvent("QBCore:Notify", source, "Job ID was in progress, your new job ID is " .. newID)
    else
        addValue(jobID, zone)
    end
end)

RegisterNetEvent('gl-garbage:joinMultiJob', function(ID)
    jobID = tonumber(ID)
    local doesJobExist = getValue(jobID)
    if doesJobExist then
        zone = getValue(jobID)
        TriggerClientEvent('gl-garbage:joinedMultiJob', source, jobID, zone)
        TriggerClientEvent('gl-garbage:updatePeople', -1, jobID)
    else
        TriggerClientEvent("QBCore:Notify", source, "Job ID does not exist", 'error')
    end
end)

RegisterNetEvent('gl-garbage:checkBin', function(netID)
    local searched = tableHasKey(searchedBins, netID)
    if not searched then
        addToSet(searchedBins, netID)
        TriggerClientEvent('gl-garbage:getTrash', source)
    end
end)

RegisterNetEvent('gl-garbage:depositTrash', function(jobID)
    TriggerClientEvent('gl-garbage:depositTrashClient', -1, jobID)
end)

RegisterNetEvent('gl-garbage:cashOut', function(jobID, people)
    amtPeople = people
    TriggerClientEvent('gl-garbage:cashedOut', -1, jobID, amtPeople)
end)

RegisterNetEvent('gl-garbage:getPaid', function(trash, people)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local Money = (trash * Config.Payout) / people
    xPlayer.Functions.AddMoney('cash', Money)
    local rng = math.random(0, 10)
    if trash >= 10 then
        if rng >= 5 then
            xPlayer.Functions.AddItem('recvoucher', 1)
        end
    end
end)

RegisterNetEvent('gl-garbage:redeemMaterial', function(choice, amount)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local voucher = xPlayer.Functions.GetItemByName('recvoucher')
    if voucher and voucher.amount > 0 then
        xPlayer.Functions.RemoveItem('recvoucher', 1)
        xPlayer.Functions.Additem(choice, amount)
    end
end)

RegisterNetEvent('gl-garbage:jobDone', function(jobID)
    TriggerClientEvent("QBCore:Notify", source, "Finished, return to trash master", 'success')
end)

-- RegisterNetEvent("qb-metelscrap:server:scrap")
-- AddEventHandler("qb-metelscrap:server:scrap", function()
-- 	local src = source
-- 	local Player = QBCore.Functions.GetPlayer(src)
-- 	local metalscrap = "metalscrap"
	
-- 	if Player.Functions.GetItemByName('metalscrap') ~= nil and Player.Functions.GetItemByName('metalscrap').amount >=
--         item then
--         local amount = Config.materials
--         local item = 5
--         local price = math.random(200, 500)
--         Player.Functions.AddMoney("cash", price, "sold-items")
-- 		Player.Functions.RemoveItem("metalscrap")
-- 		TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['metalscrap'], "remove")
-- 	else
-- 		TriggerClientEvent('QBCore:Notify', src, 'You have no metalscrap to sell..', 'error')
-- 	end
-- end)