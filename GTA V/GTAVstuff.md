## Nnapkin12's GTA V stuff.

GTA V Legacy (PC) story-mode Stand Lua. Natives `1663599433`. A lot of this is copied / rewritten from other people, parked here for permalinks.

## Scripts

### [MultiPurposeTool](MPT.lua)


## Vehicle Tree

DNR: **spawn DLC/Modded/Drift Vehicles, Vehicle Appearance features**

- **Make this car drift** (`mptdrift`) — while sitting in a car, this either spawns to the drift model of your car if it has one, otherwise it puts drift tires on.
- **Randomize appearance** (`mptrandlook`) / **Spec appearance** (`mptspeclook`) — fully randomize appearance of your vehicle vs matching colours / nicer rims / slammed street cars, also add liveries sometimes.
- **Spawn 5 cars** (`mptspawn5`) — five random modded/DLC cars in a row, also lists the vehicle names in a toast. Next spawn only deletes cars still sitting there; if you sat in one or drove it off 5meters or over, it wont despawn.
- **Spawn 5 cars DRIFT** (`mptspawndrift5`) — same as spawn 5 cars, drift models only, tires already on.
- **Drift cars** (`mptdriftcars`) — Spawn vehicles from the full drift list for this game build.
- **Clear lineup** (`mptclearspot`) — deletes cars spawned with mptspawn5/mptspawndrift5, keeps cars you took. Unloading this script does not delete them.

## World tree

- Clock: presets for morning / mid day / afternoon / dusk / night. Hour slider, lock, clock speed.
- Weather: clear, rain, thunder, snow, etc. Clouds, skybox off, blackout.

## Graphic FIX tree

DNR: **shaders, LOD, distance blur, shadows** — turn Enable on first.

- **Enable** (`graphicfixon`) — master switch. Off restores vanilla shader / LOD / shadows / model budget.
- **Look** (`graphicfixstyle`) — Off (vanilla), **Clear sky** (`intnofog`, the 'good graphics' one), Filmic (heavy Rockstar grade).
- **LOD** (`graphicfixlod`) — 100 is vanilla, 200–300 is the usual upgrade, 1000 is extreme and eats FPS.
- **Sharper distance** (`graphicfixsharp`) — kills distance blur so far trees / buildings stay crisp.
- **Better shadows** (`graphicfixshadows`) — longer cascade shadows. Costs FPS at night and in the city.
- **Keep HD models loaded** (`graphicfixhd`) — stops peds/cars swapping to low-detail as soon as they get a bit far.
- **Turn off Lance God graphics** (`graphicfixfixlance`) — kills Lance's shader steal, then re-applies this tree if Enable is still on a personal feature i put cs.

### [Real Names](IRLCarNames.lua)

## Real Names

DNR: **swap HUD / pause-menu names to real-life cars and guns** (`Karin Futo` → `Toyota AE86…`). v4.0.0, credits harleenquinzzel / xm4ddy.

- **Apply vehicle names** (`rcn`) — rewrites car labels. Takes a few seconds.
- **Apply weapon names** (`rwn`) — same for guns.
- **Restore vehicle names** (`dcn`) — back to Rockstar names (warning prompt).
- **Restore weapon names** (`dwn`) — same for guns.


## others

### [Drift Tune Vehicles list](GTAdrift.md)

Spawn-name cheat sheet: in-game name, normal code, drift code.
