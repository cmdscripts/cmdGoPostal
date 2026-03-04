Config = {}

Config.Locale = 'en' -- 'de' or 'en'

Config.JobName = 'gopostal'

Config.NPC = vec4(78.8671, 112.5604, 81.1682, 159.8248)

Config.NPCModel = `s_m_m_postal_01`

Config.VanModel = `boxville2`
Config.VanSpawn = vec4(70.1266, 122.5523, 79.1750, 160.0561)

Config.PackageModel = `prop_cs_cardbox_01`
Config.PackageSpawnCenter = vec4(61.5251, 125.8183, 79.2253, 338.5266)
Config.PackageSpawnRadius = 5.5
Config.PackageCountMin = 1
Config.PackageCountMax = 3

Config.InteractKey = 38

Config.VanStoreDistance = 2.6
Config.PackagePickupDistance = 1.6
Config.DoorDropDistance = 1.6

Config.PayMin = 100
Config.PayMax = 400

Config.SpeedTargetSecondsPerStop = 55
Config.SpeedBonusMaxPct = 0.45

Config.TipEnabled = true
Config.TipThresholdSecondsPerStop = 45
Config.TipMin = 25
Config.TipMax = 120
Config.TipItem = 'money'

Config.DropPoints = {
  vec4(113.25, -1037.54, 29.27, 160.0),
  vec4(54.43, -1873.12, 22.81, 320.0),
  vec4(-34.06, -1847.13, 26.19, 50.0),
  vec4(257.21, -1723.54, 29.66, 140.0),
  vec4(440.71, -1706.89, 29.71, 320.0),
  vec4(126.72, -1930.06, 21.38, 40.0),
  vec4(-122.32, -1459.55, 33.82, 50.0),
  vec4(-318.77, -1471.49, 30.55, 270.0),
  vec4(-704.76, -1143.62, 10.82, 0.0),
  vec4(-1105.31, -1527.18, 4.62, 120.0),
  vec4(-1336.77, -1146.53, 6.73, 90.0),
  vec4(-1245.48, -1358.06, 3.99, 300.0),
  vec4(-928.35, -293.91, 39.73, 120.0),
  vec4(-820.42, 268.11, 86.39, 0.0),
  vec4(-1469.92, -657.62, 29.37, 220.0),
  vec4(-1550.21, -401.21, 41.99, 230.0),
  vec4(-1007.12, -486.77, 38.97, 30.0),
  vec4(-560.23, 402.36, 101.80, 0.0),
  vec4(-372.21, 427.78, 110.90, 270.0),
  vec4(318.32, 562.73, 154.54, 200.0)
}


Config.Lang = {
  de = {
    -- Blips
    blip_depot        = 'Go Postal',
    blip_dropoff      = 'GoPostal Abgabe',

    -- NPC Menu
    menu_title        = 'GoPostal',
    menu_info         = 'Info',
    menu_start        = 'Starten',
    menu_stop         = 'Beenden',

    -- Info menu items
    info_1            = '• Pakete aufheben & in den Van laden',
    info_2            = '• Wenn alles geladen ist: Route erscheint',
    info_3            = '• Am Ziel: Paket aus dem Van holen',
    info_4            = '• Zur Tür bringen & abgeben',
    info_5            = '• Schneller = mehr Lohn + Trinkgeld',
    info_6            = '• Nach allen Lieferungen zurück zum Depot',

    -- Prompts
    prompt_pickup     = 'Drücke ~INPUT_CONTEXT~ um aufzuheben',
    prompt_store      = 'Drücke ~INPUT_CONTEXT~ um reinzupacken',
    prompt_take       = 'Drücke ~INPUT_CONTEXT~ um ein Paket rauszuholen',
    prompt_deliver    = 'Drücke ~INPUT_CONTEXT~ um abzugeben',
    prompt_get_pkg    = 'Hol ein Paket aus dem Van',

    -- Notifications
    job_started       = 'GoPostal gestartet: %d Pakete',
    job_finished      = 'Job beendet.',
    pkg_picked_up     = 'Paket aufgehoben.',
    pkg_stored        = 'Im Van: %d/%d',
    all_loaded        = 'Alle Pakete geladen. Route wurde gesetzt.',
    store_failed      = 'Konnte nicht einladen.',
    pkg_taken         = 'Paket rausgeholt.',
    no_packages       = 'Keine Pakete mehr im Van.',
    delivered         = 'Geliefert %d/%d | +$%d',
    delivered_tip     = ' | Trinkgeld: $%d',
    all_delivered     = 'Alle Lieferungen erledigt. Zurück zum Depot.',
    deliver_failed    = 'Konnte nicht abgeben.',
    start_failed      = 'Konnte nicht starten.',
    not_in_job        = 'Du bist in keinem Job.',

    -- Server
    already_in_job    = 'Du bist bereits im Job.',
    no_active_job     = 'Du bist in keinem Job.',
    no_package_hand   = 'Du hast kein Paket in der Hand.',
  },

  en = {
    -- Blips
    blip_depot        = 'Go Postal',
    blip_dropoff      = 'GoPostal Drop-off',

    -- NPC Menu
    menu_title        = 'GoPostal',
    menu_info         = 'Info',
    menu_start        = 'Start',
    menu_stop         = 'Stop',

    -- Info menu items
    info_1            = '• Pick up packages & load them into the van',
    info_2            = '• Once everything is loaded: route appears',
    info_3            = '• At destination: take a package from the van',
    info_4            = '• Bring it to the door & deliver',
    info_5            = '• Faster = more pay + tips',
    info_6            = '• After all deliveries return to depot',

    -- Prompts
    prompt_pickup     = 'Press ~INPUT_CONTEXT~ to pick up',
    prompt_store      = 'Press ~INPUT_CONTEXT~ to load into van',
    prompt_take       = 'Press ~INPUT_CONTEXT~ to take a package',
    prompt_deliver    = 'Press ~INPUT_CONTEXT~ to deliver',
    prompt_get_pkg    = 'Get a package from the van',

    -- Notifications
    job_started       = 'GoPostal started: %d packages',
    job_finished      = 'Job finished.',
    pkg_picked_up     = 'Package picked up.',
    pkg_stored        = 'In van: %d/%d',
    all_loaded        = 'All packages loaded. Route set.',
    store_failed      = 'Could not load package.',
    pkg_taken         = 'Package taken.',
    no_packages       = 'No packages left in the van.',
    delivered         = 'Delivered %d/%d | +$%d',
    delivered_tip     = ' | Tip: $%d',
    all_delivered     = 'All deliveries done. Return to depot.',
    deliver_failed    = 'Could not deliver.',
    start_failed      = 'Could not start.',
    not_in_job        = 'You are not in a job.',

    -- Server
    already_in_job    = 'You are already in a job.',
    no_active_job     = 'You are not in a job.',
    no_package_hand   = 'You don\'t have a package.',
  },
}

function L(key, ...)
  local str = Config.Lang[Config.Locale] and Config.Lang[Config.Locale][key]
  if not str then
    str = Config.Lang['de'] and Config.Lang['de'][key] or key
  end
  if select('#', ...) > 0 then
    return str:format(...)
  end
  return str
end