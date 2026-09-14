## Nnapkin12's GTA V stuff.

This folder is my GTA V Legacy (PC) stuff(story mode). Everything here is meant to run under **Stand** as Lua, Natives are pinned to `natives-1663599433`. I did not invent the entire vehicle-to-real-life mapping from scratch: the names list started from other people's work (harleenquinzzel / xm4ddy) and got rewritten so it would actually load without crashing.

 The drift markdown is just a lookup table so I do not have to open Lua every time I forget a spawn name.



## Scripts


### [Multi Purpose Tool](MPT.lua) (`MPT.lua`)

root menu called **Vehicle**.

This is the script i made when I wanted to look for unique cars. there is a car spawner and it is scoped for DLC cars, sports cars, modded cars (NON-npc cars).

**features:**

1. **Make this car drift** (`mptdrift`) — You have to be sitting in a car. If that car has an LS Car Meet / Chop Shop drift sibling, it swaps you into that model in place: same position, heading, paint, extras, etc. If you are already in a drift model, it just turns drift tires on. If there is no named drift version, it falls back to enabling drift tires / reduced grip on the car you are already in, and toasts why.

2. **Spawn 5 cars** (`mptspawn5`) —  Parks five random DLC / Modded Online-looking cars in a row in front of you, facing you. The cars also spawn with random street-looking paint job (stock combo, indexed colors, or a custom RGB pulled from a small palette of dirty / dark / metallic street colors), random dirt, random plate style, sometimes tinted windows. A toast lists the five names so you can read the names of cars you just spawned. (Deletes the previous lineup if you already used it)

3. **Drift cars** submenu (`mptdriftcars`) — List of every drift model this game build can spawn. Hardcoded LS Car Meet / Chop Shop mappings plus a scan of `util.get_vehicles()` for anything named `drift*` or `yosemite2`. spawn in front of you with drift tires already on.

4. **Clear lineup** (`mptclearspot`) — Deletes only cars this script spawned. Unload does **not** delete them; it just releases them into the world so they do not vanish when you stop the script.

**How the spotting pool is filtered (this is the whole point of the script):**

Everyday story-mode traffic is blacklisted so you do not keep rolling Aseas, Staniers, Blistas, Burritos, taxis, cop cars, ambulances, etc. There is a second deny list for flying cars, weaponized stuff, tanks, stretch limos, taxis again, and a few other junk spawn names. Name matching also dumps anything with `police`, `sheriff`, `trailer`, or `truck` in the model string. Allowed classes are sport / super / muscle / coupe / sport classic / sedan / SUV / compacts. Bikes, quads, trailers, and submarine cars are skipped even if they get through class checks.

The result is supposed to feel like modded/cool cars rather than NPC traffic. If the pool comes up empty (wrong build, natives failed, whatever) it toasts `No spotting cars found`.

**Drift model mapping:**

Internal table `BASE_TO_DRIFT` maps vanilla spawn names to LS Car Meet / Chop Shop drift spawn names. Examples: `euros` → `drifteuros`, `jester4` → `driftjester`, `yosemite` → `yosemite2` (Yosemite is the weird one that does not use the `drift` prefix), `waltonl35` / `l35` / `walton` all go to `driftwalton`. If a car is not in the table, the script guesses `drift` + the current model name and checks whether that model actually exists in the game files. HSW is treated as a shop upgrade, not a spawn name, so it is not in this table.


**Stand command names:**

| Command | What it does |
| :--- | :--- |
| `mptdrift` | Convert current car / slap drift tires on |
| `mptspawn5` | New 5-car spotting lineup |
| `mptclearspot` | Delete spawned lineup |
| `mptspawner` | Open the Spawner list |
| `mptdriftcars` | Open the full drift-model list |
| `mptdriftspawn<model>` | Spawn one specific drift car |

On load it toasts `Multi Purpose Tool loaded` unless Stand silent-start is on.


### [Real Names](IRLCarNames.lua) (`IRLCarNames.lua`)

Again Stand Lua, Story mode. File on disk is `IRLCarNames.lua`; the script header still calls it `RealNames.lua` from the og. Version **4.0.0**.

This replaces in-game GXT labels with real-life names so the HUD, pause menu, and vehicle select stop saying eg. "Karin Futo" and start saying "Toyota AE86 Corolla Levin '83" (or whatever the mapped string is). Same idea for weapons: Assault Rifle becomes Type 56-2, Heavy Sniper becomes Barrett M107A1, etc.

**Why this rewrite exists:** the original list had a broken auto-updater. That is the `soup.json.encode` crash and the `'unexpected symbol near end'` error that used to fire on the DCN restore warning. This copy drops the updater entirely. Labels are applied locally through Stand's `addlabel` / `edit<KEY>` / `remove<KEY>` commands, yielding every 10 entries so the game does not hitch itself crazuy while hundreds of strings get rewritten.

**How labels work ( if a name looks wrong):**

The keys are the game's `gameName` GXTs, **not** spawn codes. Several models share one label, so editing `TAMPA` changes every vehicle that uses that GXT. Manufacturer prefixes (Albany, Annis, Benefactor, Karin, Vapid, …) are blanked out on purpose so you do not get "Karin Toyota AE86…" stacked on the car name. `EMPEROR` as a manufacturer is skipped because that same GXT is also the Cadillac DeVille sedan.

The car table is grouped by Rockstar manufacturer, then mapped to the real brand people actually mean: Annis → Nissan/Mazda, Benefactor → Mercedes, Bravado → Dodge, Declasse → Chevrolet (with some Ford Hoonigan exceptions), Dinka → Honda/Toyota, Karin → Toyota/Mitsubishi/Subaru, Pegassi → Lamborghini/Pagani/Ducati, Pfister → Porsche, Ubermacht → BMW, Vapid → Ford, and so on. Aircraft, boats, military, bikes, and random DLC junk are in there too, not just street cars. Drift variants have their own rows (`DRIFTEUROS` = Nissan 370Z (Drift), `DRIFTFUTO` = Toyota AE86 Sprinter Trueno (Drift), etc.).

Weapons are a shorter second table of `WT_*` keys covering shotguns, rifles, pistols, SMGs, launchers, snipers, unarmed, and a handful of extras. It is not every weapon in the game; it is the set that was worth renaming.

**Menu / commands:**

| Command | What it does |
| :--- | :--- |
| `rcn` | Apply vehicle names. Takes a few seconds. Toast when done. |
| `rwn` | Apply weapon names. |
| `dcn` | Restore vanilla vehicle names (warning prompt). |
| `dwn` | Restore vanilla weapon names (warning prompt). |
| `rndef` | Opens the restore submenu. |

Nothing is applied automatically on load. You have to hit Apply. Unload does not restore vanilla names either; use the restore actions if you want Rockstar strings back. On load it toasts `Real Names loaded. Use Apply vehicle names (rcn).`

Credits in the file: original list "harleenquinzzel, thanks xm4ddy".


### [Graphic FIX](GraphicFIX.lua) (`GraphicFIX.lua`)

 Renderer / timecycle / LOD tweaks. Everything starts **off**.

This make gta not look like a 2013 fog wall

**Options:**

- **Enable** (`graphicfixon`) — Master switch. restores shader off, LOD 1.00, clears the timecycle modifier, clears cascade shadow sample type, and puts ped/vehicle model budget reduction back on.

- **Look** (`graphicfixstyle`) — `Off` (vanilla), **Clear sky** (clears everything up. `intnofog` shader), **Filmic** (`ng_filmic01`, a strong Rockstar full-screen grade). Clear sky is the best one that makes things look "better quality".

- **LOD** (`graphicfixlod`) — Real LOD scale, 100–1000, step 25. 100 is vanilla. 200–300 is the usual upgrade. Anything above ~200 already costs FPS on my specs; 1000 is extreme. The tick handler also calls `OVERRIDE_LODSCALE_THIS_FRAME` so other scripts cannot quietly undo it.

- **Sharper distance** (`graphicfixsharp`) — Sets distance blur strength to 0 so far trees and buildings stay good looking instead of melting.

- **Better shadows** (`graphicfixshadows`) — Longer, cleaner cascade shadows: entity tracker on, cascade bounds scaled up, aircraft mode, dynamic depth, `dither_4x4` sample type. Costs FPS at night and in the city. Turning it off clears the shadow sample type.

- **Keep HD models loaded** (`graphicfixhd`) — Stops the game from yeeting peds and cars down to low-detail models as soon as they are a little far away. Also applied every tick while Enable is on, because the game likes to reset this.

- **Turn off Lance God graphics** (`graphicfixfixlance`) — Forces `shader off` and `lodscale 1`, then re-applies this script's look/LOD if Enable is still on. (this was a personal feature i added for a diferent script).

On unload it restores defaults. On load it toasts `Graphic FIX loaded — all effects off`.

**Suggested combo:** Enable + Clear sky + LOD around 200–300 + Sharper distance + Better shadows + HD models


## others


### [Drift Tune Vehicles list](GTAdrift.md) (`GTAdrift.md`)

sheet for GTA V Legacy PC drift-tune spawn names.

Table columns are in-game name, standard model code, and drift-tune model code. Some cars have no street counterpart and are listed as standalone (`drifttampa`, `yosemite2`, `driftwalton`).



## info
- **Commands cheat sheet:** `mptdrift`, `mptspawn5`, `mptclearspot`, `rcn`, `rwn`, `dcn`, `dwn`, `graphicfixon`, `graphicfixstyle`, `graphicfixlod`, `graphicfixsharp`, `graphicfixshadows`, `graphicfixhd`, `graphicfixfixlance`.
