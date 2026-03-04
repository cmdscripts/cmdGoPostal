local ESX = exports['es_extended']:getSharedObject()

local Jobs = {}

local function inJob(src)
  return Jobs[src] ~= nil
end

local function pickRandomDropPoints(count)
  local pool = {}
  for i = 1, #Config.DropPoints do pool[i] = i end

  local chosen = {}
  for i = 1, count do
    if #pool == 0 then break end
    local idx = math.random(1, #pool)
    local pick = pool[idx]
    table.remove(pool, idx)
    chosen[#chosen + 1] = Config.DropPoints[pick]
  end
  return chosen
end

lib.callback.register('gopostal:startJob', function(src)
  if inJob(src) then
    return { ok = false, msg = L('already_in_job') }
  end

  local count = math.random(Config.PackageCountMin, Config.PackageCountMax)
  local drops = pickRandomDropPoints(count)

  Jobs[src] = {
    packageCount = count,
    loaded = 0,
    out = 0,
    delivered = 0,
    earned = 0,
    tips = 0,
    startMs = GetGameTimer(),
    drops = drops
  }

  return {
    ok = true,
    packageCount = count,
    drops = drops,
    van = Config.VanSpawn
  }
end)

lib.callback.register('gopostal:registerVan', function(src, plate)
  local st = Jobs[src]
  if not st then return false end
  plate = tostring(plate):gsub('%s+', '')
  st.plate = plate
  exports['cmdVehiclekeys']:GiveVehicleKey(src, plate, 'boxville2')
  return true
end)

lib.callback.register('gopostal:finishJob', function(src)
  if not Jobs[src] then
    return { ok = false, msg = L('no_active_job') }
  end
  local st = Jobs[src]
  if st.plate then
    exports['cmdVehiclekeys']:RemoveVehicleKey(src, st.plate)
  end
  Jobs[src] = nil
  return { ok = true }
end)

lib.callback.register('gopostal:storePackage', function(src)
  local st = Jobs[src]
  if not st then return { ok = false } end
  if st.loaded >= st.packageCount then return { ok = false } end
  st.loaded = st.loaded + 1
  return { ok = true, loaded = st.loaded, total = st.packageCount }
end)

lib.callback.register('gopostal:takePackage', function(src)
  local st = Jobs[src]
  if not st then return { ok = false } end
  if st.loaded <= 0 then return { ok = false } end
  st.loaded = st.loaded - 1
  st.out = st.out + 1
  return { ok = true, loaded = st.loaded, out = st.out, total = st.packageCount }
end)

local function calcSpeedMultiplier(seconds, target, maxPct)
  if seconds <= 0 then return 1.0 end
  local diff = target - seconds
  if diff <= 0 then return 1.0 end
  local pct = diff / target
  if pct > 1.0 then pct = 1.0 end
  return 1.0 + (pct * maxPct)
end

lib.callback.register('gopostal:deliverOne', function(src, dropIndex)
  local xPlayer = ESX.GetPlayerFromId(src)
  if not xPlayer then return { ok = false } end

  local st = Jobs[src]
  if not st then return { ok = false } end
  if st.out <= 0 then return { ok = false, msg = L('no_package_hand') } end
  if dropIndex ~= (st.delivered + 1) then return { ok = false } end

  st.out = st.out - 1
  st.delivered = st.delivered + 1

  local elapsedSec = (GetGameTimer() - st.startMs) / 1000
  local secPerStop = elapsedSec / st.delivered

  local basePay = math.random(Config.PayMin, Config.PayMax)
  local mult = calcSpeedMultiplier(secPerStop, Config.SpeedTargetSecondsPerStop, Config.SpeedBonusMaxPct)
  local pay = math.floor(basePay * mult)

  st.earned = st.earned + pay
  xPlayer.addAccountMoney('money', pay)

  local tip = 0
  if Config.TipEnabled and secPerStop <= Config.TipThresholdSecondsPerStop then
    tip = math.random(Config.TipMin, Config.TipMax)
    local added = exports.ox_inventory:AddItem(src, Config.TipItem, tip)
    if not added then
      xPlayer.addAccountMoney('money', tip)
    end
    st.tips = st.tips + tip
  end

  local done = (st.delivered >= st.packageCount)
  return {
    ok = true,
    pay = pay,
    tip = tip,
    delivered = st.delivered,
    total = st.packageCount,
    done = done
  }
end)

AddEventHandler('playerDropped', function()
  local src = source
  local st = Jobs[src]
  if st and st.plate then
    exports['cmdVehiclekeys']:RemoveVehicleKey(src, st.plate)
  end
  Jobs[src] = nil
end)
