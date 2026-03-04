# cmdGoPostal

A GoPostal delivery job resource for FiveM servers running the ESX framework. Players pick up packages at the depot, load them into a van, and deliver them to randomized drop-off locations across the map. Faster deliveries earn higher pay and tips.

## Features

- **Package Pickup & Loading** — Packages spawn randomly around the depot. Players pick them up with a carry animation and load them into the van's rear.
- **Randomized Routes** — Each job selects 1–3 random drop-off points from a pool of 20 locations. A GPS route guides the player to each stop.
- **Door Delivery** — At each stop, players take a package from the van, walk to the door marker, knock, and deliver.
- **Speed Bonus** — Pay scales with delivery speed. A configurable multiplier rewards faster completion (up to +45% by default).
- **Tip System** — Deliveries completed under a time threshold award random cash tips via inventory or account fallback.
- **Carry Animation** — Full box-carry animation with attached prop while holding a package.
- **Bilingual** — Built-in locale support for German (`de`) and English (`en`).
- **Vehicle Key Integration** — Automatically grants/revokes van keys via `cmdVehiclekeys` or customize your keylock script!.
- **Clean Cleanup** — All spawned entities (van, packages, props, blips) are removed on job end, player disconnect, or resource stop.

## Dependencies

| Resource | Purpose |
|----------|---------|
| [es_extended](https://github.com/esx-framework/esx_core) | ESX framework |
| [ox_lib](https://github.com/overextended/ox_lib) | Callbacks, model loading |
| [ox_inventory](https://github.com/overextended/ox_inventory) | Tip item delivery |
| [oxmysql](https://github.com/overextended/oxmysql) | MySQL adapter |

## Installation

1. Place `cmdGoPostal` into your resources directory.
2. Ensure all dependencies are started before this resource.
3. Add `ensure cmdGoPostal` to your `server.cfg` (or place it inside a bracket folder that is already ensured).
4. Configure `config.lua` to your liking.

## Configuration

All settings are in `config.lua`:

| Key | Default | Description |
|-----|---------|-------------|
| `Config.Locale` | `'en'` | Language — `'de'` or `'en'` |
| `Config.JobName` | `'gopostal'` | Internal job name |
| `Config.NPC` | `vec4(...)` | Depot NPC position & heading |
| `Config.NPCModel` | `s_m_m_postal_01` | NPC ped model |
| `Config.VanModel` | `boxville2` | Delivery van model |
| `Config.VanSpawn` | `vec4(...)` | Van spawn position |
| `Config.PackageModel` | `prop_cs_cardbox_01` | Package prop model |
| `Config.PackageSpawnCenter` | `vec4(...)` | Center point for package spawning |
| `Config.PackageSpawnRadius` | `5.5` | Radius around center for random package placement |
| `Config.PackageCountMin` | `1` | Minimum packages per job |
| `Config.PackageCountMax` | `3` | Maximum packages per job |
| `Config.PayMin` | `100` | Minimum base pay per delivery |
| `Config.PayMax` | `400` | Maximum base pay per delivery |
| `Config.SpeedTargetSecondsPerStop` | `55` | Target seconds per stop for speed bonus calculation |
| `Config.SpeedBonusMaxPct` | `0.45` | Maximum speed bonus multiplier (45%) |
| `Config.TipEnabled` | `true` | Enable/disable tip system |
| `Config.TipThresholdSecondsPerStop` | `45` | Seconds-per-stop threshold to earn a tip |
| `Config.TipMin` | `25` | Minimum tip amount |
| `Config.TipMax` | `120` | Maximum tip amount |
| `Config.DropPoints` | 20 locations | Pool of delivery destinations |

## How It Works

1. Player approaches the GoPostal NPC at the depot and opens the menu (E key).
2. Player selects **Start** — a van spawns and 1–3 packages appear nearby.
3. Player picks up each package (carry animation) and loads them into the van's rear.
4. Once all packages are loaded, a GPS route is set to the first drop-off.
5. At each stop, player takes a package from the van, walks to the door marker, and delivers (knock animation + doorbell sound).
6. Pay is awarded per delivery. Speed bonus and tips are calculated based on elapsed time.
7. After all deliveries, the player is routed back to the depot. Talking to the NPC and selecting **Stop** ends the job and cleans up all entities.

## File Structure

```
cmdGoPostal/
├── fxmanifest.lua   # Resource manifest
├── config.lua       # Configuration & locale strings
├── client.lua       # Client-side logic (NPC, van, packages, UI, animations)
├── server.lua       # Server-side logic (job state, pay calculation, callbacks)
└── README.md
```

## License

This resource is part of the Origins Roleplay server resource pack.
