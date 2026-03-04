local ESX = exports['es_extended']:getSharedObject()

local state = {
  active = false,
  carrying = false,
  carryEntity = nil,
  van = nil,
  packages = {},
  packageCount = 0,
  loaded = 0,
  delivered = 0,
  drops = {},
  currentDrop = 1,
  routeBlip = nil,
  depotBlip = nil,
  allLoaded = false,
  returning = false
}

local function n(msg)
  ESX.ShowNotification(msg)
end

local function h(msg)
  ESX.ShowHelpNotification(msg, true, true, 1)
end

local function loadModel(model)
  if type(model) == 'string' then model = joaat(model) end
  lib.requestModel(model, 10000)
  return model
end

local function requestAnimDict(dict)
  lib.requestAnimDict(dict, 10000)
end

local function clearRouteBlip()
  if state.routeBlip then
    RemoveBlip(state.routeBlip)
    state.routeBlip = nil
  end
end

local function setRouteBlipToCoords(x, y, z, label)
  clearRouteBlip()

  local blip = AddBlipForCoord(x, y, z)
  SetBlipSprite(blip, 1)
  SetBlipScale(blip, 0.9)
  SetBlipRoute(blip, true)
  SetBlipRouteColour(blip, 5)
  SetBlipAsShortRange(blip, false)

  BeginTextCommandSetBlipName('STRING')
  AddTextComponentString(label or 'GoPostal')
  EndTextCommandSetBlipName(blip)

  state.routeBlip = blip
  SetNewWaypoint(x, y)
end

local function setDropRoute(index)
  local d = state.drops[index]
  if not d then return end
  setRouteBlipToCoords(d.x, d.y, d.z, ('GoPostal %d/%d'):format(index, #state.drops))
end

local function setDepotRoute()
  local p = Config.NPC
  setRouteBlipToCoords(p.x, p.y, p.z, L('blip_dropoff'))
end

local function ensureDepotBlip()
  if state.depotBlip then return end
  local p = Config.NPC
  local blip = AddBlipForCoord(p.x, p.y, p.z)
  SetBlipSprite(blip, 478)
  SetBlipScale(blip, 0.7)
  SetBlipAsShortRange(blip, true)
  BeginTextCommandSetBlipName('STRING')
  AddTextComponentString(L('blip_depot'))
  EndTextCommandSetBlipName(blip)
  state.depotBlip = blip
end

local function spawnNpc()
  local m = loadModel(Config.NPCModel)
  local p = Config.NPC
  local ped = CreatePed(4, m, p.x, p.y, p.z - 1.0, p.w, false, true)
  SetEntityInvincible(ped, true)
  FreezeEntityPosition(ped, true)
  SetBlockingOfNonTemporaryEvents(ped, true)
  return ped
end

local function spawnVan()
  local m = loadModel(Config.VanModel)
  local v = Config.VanSpawn
  local veh = CreateVehicle(m, v.x, v.y, v.z, v.w, true, false)
  SetVehicleOnGroundProperly(veh)
  SetEntityAsMissionEntity(veh, true, true)
  SetVehicleDoorsLocked(veh, 1)
  return veh
end

local function rndInCircle(radius)
  local a = math.random() * math.pi * 2.0
  local r = math.sqrt(math.random()) * radius
  return math.cos(a) * r, math.sin(a) * r
end

local function spawnPackages(count)
  local m = loadModel(Config.PackageModel)
  local c = Config.PackageSpawnCenter
  local list = {}

  for i = 1, count do
    local ox, oy = rndInCircle(Config.PackageSpawnRadius)
    local x, y, z = c.x + ox, c.y + oy, c.z
    local obj = CreateObject(m, x, y, z - 0.95, true, true, false)
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
    SetEntityAsMissionEntity(obj, true, true)
    list[#list + 1] = obj
  end

  return list
end

local function getRearTrunkPos(veh)
  local bone = GetEntityBoneIndexByName(veh, 'platelight')
  if bone ~= -1 then
    return GetWorldPositionOfEntityBone(veh, bone)
  end
  return GetOffsetFromEntityInWorldCoords(veh, 0.0, -2.6, 0.2)
end

local function startCarryAnim()
  local ped = PlayerPedId()
  requestAnimDict('anim@heists@box_carry@')
  TaskPlayAnim(ped, 'anim@heists@box_carry@', 'idle', 2.0, 2.0, -1, 49, 0.0, false, false, false)
end

local function stopCarryAnim()
  local ped = PlayerPedId()
  StopAnimTask(ped, 'anim@heists@box_carry@', 'idle', 2.0)
end

local function attachCarryProp()
  local m = loadModel(Config.PackageModel)
  local ped = PlayerPedId()
  local obj = CreateObject(m, 0.0, 0.0, 0.0, true, true, false)
  SetEntityAsMissionEntity(obj, true, true)
  local bone = GetPedBoneIndex(ped, 28422)
  AttachEntityToEntity(obj, ped, bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
  state.carryEntity = obj
  state.carrying = true
  startCarryAnim()
end

local function detachCarryProp()
  if state.carryEntity and DoesEntityExist(state.carryEntity) then
    DeleteEntity(state.carryEntity)
  end
  state.carryEntity = nil
  state.carrying = false
  stopCarryAnim()
end

local function cleanupJob()
  clearRouteBlip()

  if state.carryEntity and DoesEntityExist(state.carryEntity) then
    DeleteEntity(state.carryEntity)
  end

  for i = 1, #state.packages do
    local e = state.packages[i]
    if e and DoesEntityExist(e) then
      DeleteEntity(e)
    end
  end

  if state.van and DoesEntityExist(state.van) then
    DeleteVehicle(state.van)
  end

  state.active = false
  state.carrying = false
  state.carryEntity = nil
  state.van = nil
  state.packages = {}
  state.packageCount = 0
  state.loaded = 0
  state.delivered = 0
  state.drops = {}
  state.currentDrop = 1
  state.allLoaded = false
  state.returning = false
end

local function playDoorKnockAndBuzz()
  local ped = PlayerPedId()
  requestAnimDict('timetable@jimmy@doorknock@')
  TaskPlayAnim(ped, 'timetable@jimmy@doorknock@', 'knockdoor_idle', 2.0, 2.0, 1100, 49, 0.0, false, false, false)
  Wait(250)
  PlaySoundFrontend(-1, 'DOOR_BUZZ', 'MP_PLAYER_APARTMENT', true)
  Wait(850)
  StopAnimTask(ped, 'timetable@jimmy@doorknock@', 'knockdoor_idle', 2.0)
end

local function startJob()
  local res = lib.callback.await('gopostal:startJob', false)
  if not res or not res.ok then
    n((res and res.msg) or L('start_failed'))
    return
  end

  cleanupJob()

  state.active = true
  state.packageCount = res.packageCount
  state.drops = res.drops
  state.van = spawnVan()
  local plate = GetVehicleNumberPlateText(state.van)
  lib.callback.await('gopostal:registerVan', false, plate)
  state.packages = spawnPackages(state.packageCount)
  state.currentDrop = 1
  state.loaded = 0
  state.delivered = 0
  state.allLoaded = false
  state.returning = false

  n(L('job_started', state.packageCount))
end

local function finishJob()
  if not state.active then
    n(L('not_in_job'))
    return
  end

  lib.callback.await('gopostal:finishJob', false)
  cleanupJob()
  n(L('job_finished'))
end

local function openNpcMenu()
  local elements = { { label = L('menu_info'), value = 'info' } }

  if not state.active then
    elements[#elements + 1] = { label = L('menu_start'), value = 'start' }
  else
    elements[#elements + 1] = { label = L('menu_stop'), value = 'stop' }
  end

  ESX.UI.Menu.CloseAll()
  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'gopostal_menu', {
    title = L('menu_title'),
    align = 'top-left',
    elements = elements
  }, function(data, menu)
    if data.current.value == 'info' then
      ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'gopostal_info', {
        title = L('menu_info'),
        align = 'top-left',
        elements = {
          { label = L('info_1'), value = 'x1' },
          { label = L('info_2'), value = 'x2' },
          { label = L('info_3'), value = 'x3' },
          { label = L('info_4'), value = 'x4' },
          { label = L('info_5'), value = 'x5' },
          { label = L('info_6'), value = 'x6' }
        }
      }, function() end, function(_, m2) m2.close() end)
    elseif data.current.value == 'start' then
      menu.close()
      startJob()
    elseif data.current.value == 'stop' then
      menu.close()
      finishJob()
    end
  end, function(_, menu)
    menu.close()
  end)
end

local npcPed = nil

CreateThread(function()
  ensureDepotBlip()
  npcPed = spawnNpc()

  while true do
    local ped = PlayerPedId()
    local pcoords = GetEntityCoords(ped)
    local wait = 500
    local shown = false

    if state.carrying then
      wait = 0
      if not IsEntityPlayingAnim(ped, 'anim@heists@box_carry@', 'idle', 3) then
        startCarryAnim()
      end
    end

    local npcPos = vec3(Config.NPC.x, Config.NPC.y, Config.NPC.z)
    if #(pcoords - npcPos) <= 2.2 then
      wait = 0
      shown = true
      if IsControlJustPressed(0, Config.InteractKey) then
        openNpcMenu()
        Wait(250)
      end
    end

    if state.active then
      if not shown and not state.carrying and not state.allLoaded then
        for i = 1, #state.packages do
          local obj = state.packages[i]
          if obj and DoesEntityExist(obj) then
            local ocoords = GetEntityCoords(obj)
            if #(pcoords - ocoords) <= Config.PackagePickupDistance then
              wait = 0
              h(L('prompt_pickup'))
              shown = true
              if IsControlJustPressed(0, Config.InteractKey) then
                DeleteEntity(obj)
                state.packages[i] = nil
                attachCarryProp()
                n(L('pkg_picked_up'))
                Wait(150)
              end
              break
            end
          end
        end
      end

      if state.van and DoesEntityExist(state.van) then
        local rear = getRearTrunkPos(state.van)
        local dist = #(pcoords - rear)

        if dist <= Config.VanStoreDistance then
          wait = 0

          if state.carrying and not state.allLoaded then
            h(L('prompt_store'))
            shown = true
            if IsControlJustPressed(0, Config.InteractKey) then
              local res = lib.callback.await('gopostal:storePackage', false)
              if res and res.ok then
                detachCarryProp()
                state.loaded = res.loaded
                if state.loaded >= state.packageCount then
                  state.allLoaded = true
                  n(L('all_loaded'))
                  setDropRoute(state.currentDrop)
                else
                  n(L('pkg_stored', res.loaded, res.total))
                end
              else
                n(L('store_failed'))
              end
              Wait(150)
            end
          elseif not state.carrying and state.allLoaded and not state.returning and state.currentDrop <= #state.drops then
            h(L('prompt_take'))
            shown = true
            if IsControlJustPressed(0, Config.InteractKey) then
              local res = lib.callback.await('gopostal:takePackage', false)
              if res and res.ok then
                state.loaded = res.loaded
                attachCarryProp()
                n(L('pkg_taken'))
              else
                n(L('no_packages'))
              end
              Wait(150)
            end
          end
        end
      end

      if not state.returning and state.allLoaded and state.currentDrop <= #state.drops then
        local d = state.drops[state.currentDrop]
        local dpos = vec3(d.x, d.y, d.z)

        if #(pcoords - dpos) <= 35.0 then
          wait = 0
          DrawMarker(1, d.x, d.y, d.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.3, 1.3, 1.2, 255, 255, 255, 140, false, true, 2, false, nil, nil, false)
        end

        if #(pcoords - dpos) <= Config.DoorDropDistance then
          wait = 0
          if state.carrying then
            h(L('prompt_deliver'))
            shown = true
            if IsControlJustPressed(0, Config.InteractKey) then
              playDoorKnockAndBuzz()

              local res = lib.callback.await('gopostal:deliverOne', false, state.currentDrop)
              if res and res.ok then
                detachCarryProp()
                state.delivered = res.delivered

                local msg = L('delivered', res.delivered, res.total, res.pay)
                if res.tip and res.tip > 0 then
                  msg = msg .. L('delivered_tip', res.tip)
                end
                n(msg)

                state.currentDrop = state.currentDrop + 1
                if res.done then
                  state.returning = true
                  n(L('all_delivered'))
                  setDepotRoute()
                else
                  setDropRoute(state.currentDrop)
                end
              else
                n((res and res.msg) or L('deliver_failed'))
              end
              Wait(150)
            end
          else
            h(L('prompt_get_pkg'))
            shown = true
          end
        end
      end
    end

    Wait(wait)
  end
end)

AddEventHandler('onResourceStop', function(res)
  if res ~= GetCurrentResourceName() then return end
  cleanupJob()
  if npcPed and DoesEntityExist(npcPed) then DeleteEntity(npcPed) end
  ESX.UI.Menu.CloseAll()
  if state.depotBlip then RemoveBlip(state.depotBlip) end
end)
