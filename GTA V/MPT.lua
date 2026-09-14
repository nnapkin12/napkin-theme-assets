-- MPT.lua
-- Multi Purpose Tool for story-mode Stand.
-- Natives are from natives-1663599433. Stand API only.
--
-- Add new root sections the same way Vehicle is set up below.

util.require_natives(1663599433)

--==============================================================================
-- STATE
--==============================================================================

local root = menu.my_root()
local spawned = {}
local spot_pool = {}
local drift_catalog = {}

local ground_z = memory.alloc(4)
local col_a = memory.alloc(4)
local col_b = memory.alloc(4)
local rgb_r = memory.alloc(4)
local rgb_g = memory.alloc(4)
local rgb_b = memory.alloc(4)

--==============================================================================
-- DATA
--==============================================================================

-- Everyday NPC traffic. The spotter skips these so you see DLC / Online cars.
local BASIC_TRAFFIC = {
    asea = true, asea2 = true, asterope = true, emperor = true, emperor2 = true,
    emperor3 = true, fugitive = true, glendale = true, ingot = true, intruder = true,
    premier = true, primo = true, regina = true, romero = true, schafter2 = true,
    stanier = true, stratum = true, stretch = true, surge = true, tailgater = true,
    warrener = true, washington = true, blista = true, dilettante = true,
    dilettante2 = true, issi2 = true, panto = true, prairie = true, rhapsody = true,
    cogcabrio = true, exemplar = true, f620 = true, felon = true, felon2 = true,
    jackal = true, oracle = true, oracle2 = true, sentinel = true, sentinel2 = true,
    windsor = true, zion = true, zion2 = true, baller = true, baller2 = true,
    bjxl = true, cavalcade = true, cavalcade2 = true, dubsta = true, dubsta2 = true,
    fq2 = true, granger = true, gresley = true, habanero = true, huntley = true,
    landstalker = true, mesa = true, mesa3 = true, patriot = true, radius = true,
    rocoto = true, seminole = true, serrano = true, bison = true, bison2 = true,
    bison3 = true, bobcatxl = true, burrito = true, burrito2 = true, burrito3 = true,
    burrito4 = true, burrito5 = true, camper = true, gburrito = true, journey = true,
    minivan = true, paradise = true, pony = true, pony2 = true, rumpo = true,
    rumpo2 = true, speedo = true, speedo2 = true, surfer = true, surfer2 = true,
    taco = true, youga = true, taxi = true, sadler = true, sadler2 = true,
    rancherxl = true, rancherxl2 = true, rebel = true, rebel2 = true, sandking = true,
    sandking2 = true, picador = true, bodhi2 = true, dloader = true, kalahari = true,
    bfinjection = true, blade = true, buccaneer = true, dominator = true, dukes = true,
    gauntlet = true, phoenix = true, ruiner = true, sabregt = true, slamvan = true,
    stallion = true, vigero = true, virgo = true, buffalo = true, buffalo2 = true,
    futo = true, fusilade = true, penumbra = true, sultan = true, schafter = true,
    manana = true, peyote = true, pigalle = true, tornado = true, tornado2 = true,
    tornado3 = true, tornado4 = true, police = true, police2 = true, police3 = true,
    police4 = true, policeold1 = true, policeold2 = true, policet = true,
    sheriff = true, sheriff2 = true, fbi = true, fbi2 = true, pranger = true,
    ambulance = true, firetruk = true, riot = true, pbus = true, lguard = true,
}

local DENY_NAME = {
    deluxo = true, oppressor = true, oppressor2 = true, ruiner2 = true, ruiner3 = true,
    vigilante = true, scramjet = true, toreador = true, stromberg = true,
    thruster = true, voltic2 = true, boxville5 = true, nightshark = true,
    menacer = true, insurgent = true, insurgent2 = true, insurgent3 = true,
    technical = true, technical2 = true, technical3 = true, khanjali = true,
    apc = true, halftrack = true, minitank = true, rhino = true, crusader = true,
    barracks = true, barracks2 = true, barracks3 = true, riot2 = true,
    limo2 = true, patriot2 = true, stretch = true, taxi = true,
}

local ALLOW_CLASS = {
    [util.joaat("sport")] = true,
    [util.joaat("super")] = true,
    [util.joaat("muscle")] = true,
    [util.joaat("coupe")] = true,
    [util.joaat("sport_classic")] = true,
    [util.joaat("sedan")] = true,
    [util.joaat("suv")] = true,
    [util.joaat("compacts")] = true,
}

-- LS Car Meet / Chop Shop drift models. HSW is a shop upgrade, not a spawn name.
local BASE_TO_DRIFT = {
    euros = "drifteuros",
    remus = "driftremus",
    zr350 = "driftzr350",
    vorschlaghammer = "driftvorschlag",
    gauntlet4 = "driftgauntlet4",
    tampa = "drifttampa",
    yosemite = "yosemite2",
    waltonl35 = "driftwalton",
    l35 = "driftwalton",
    walton = "driftwalton",
    chavos = "driftchavos",
    chavosv6 = "driftchavos",
    jester3 = "driftjester3",
    jester4 = "driftjester",
    fr36 = "driftfr36",
    turismo2 = "driftturismo",
    futo = "driftfuto",
    futo2 = "driftfuto2",
    cypher = "driftcypher",
    sentinel = "driftsentinel",
    sentinel2 = "driftsentinel2",
    dominator8 = "driftdominator8",
    dominator9 = "driftdominator9",
    nebula = "driftnebula",
    cheburek = "driftcheburek",
    coquette = "driftcoquette",
    hardy = "drifthardy",
    keitora = "driftkeitora",
    rt3000 = "driftrt3000",
    elegy = "driftelegy",
}

local STREET_PAINT = {
    {18, 20, 22}, {28, 32, 38}, {48, 50, 54}, {90, 14, 14}, {16, 40, 88},
    {208, 208, 206}, {10, 10, 10}, {138, 30, 24}, {22, 72, 40}, {176, 158, 42},
    {72, 78, 88}, {158, 158, 162}, {8, 26, 68}, {112, 42, 14}, {200, 198, 190},
    {64, 12, 16}, {36, 60, 48}, {24, 24, 28}, {180, 180, 184}, {120, 20, 28},
}

--==============================================================================
-- HELPERS
--==============================================================================

local function exists(ent)
    return ent ~= nil and ent ~= 0 and ent ~= INVALID_GUID and ENTITY.DOES_ENTITY_EXIST(ent)
end

local function delete_ent(ent)
    if exists(ent) then
        entities.delete(ent)
    end
end

local function player_ped()
    return players.user_ped()
end

local function heading_to_dir(heading)
    local rad = math.rad(heading)
    return -math.sin(rad), math.cos(rad)
end

local function clamp_byte(n)
    if n < 0 then
        return 0
    end
    if n > 255 then
        return 255
    end
    return n
end

local function pretty_label(key)
    if key == nil then
        return ""
    end
    local text = util.get_label_text(key)
    if text == nil or text == "" or text == "NULL" then
        return tostring(key)
    end
    return text
end

local function model_in_game(hash)
    return STREAMING.IS_MODEL_IN_CDIMAGE(hash)
        and STREAMING.IS_MODEL_VALID(hash)
        and STREAMING.IS_MODEL_A_VEHICLE(hash)
end

local function model_name_from_hash(hash)
    local name = util.reverse_joaat(hash)
    if type(name) == "string" and name ~= "" then
        return string.lower(name)
    end
    return nil
end

local function is_drift_model_name(name)
    return name == "yosemite2" or name:sub(1, 5) == "drift"
end

local function display_vehicle_name(name, maker_key)
    local label = pretty_label(name)
    if label == name then
        label = pretty_label(string.upper(name))
    end
    local maker = pretty_label(maker_key)
    if maker ~= "" and maker ~= "NULL" and maker ~= tostring(maker_key) then
        return maker .. " " .. label
    end
    return label
end

local function request_model(hash)
    if STREAMING.HAS_MODEL_LOADED(hash) then
        return true
    end
    local ok = pcall(util.request_model, hash, 1800)
    return ok and STREAMING.HAS_MODEL_LOADED(hash)
end

local function ground_at(x, y, z)
    if MISC.GET_GROUND_Z_FOR_3D_COORD(x, y, z + 8.0, ground_z, false, false) then
        return memory.read_float(ground_z)
    end
    return z
end

local function current_car()
    local ped = player_ped()
    if not PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
        return 0
    end
    local veh = entities.get_user_vehicle_as_handle(false)
    if not exists(veh) then
        return 0
    end
    local hash = ENTITY.GET_ENTITY_MODEL(veh)
    if not VEHICLE.IS_THIS_MODEL_A_CAR(hash) then
        return 0
    end
    return veh
end

local function apply_drift_tires(veh, force_slip)
    if VEHICLE.GET_NUM_MOD_KITS(veh) > 0 then
        VEHICLE.SET_VEHICLE_MOD_KIT(veh, 0)
    end
    VEHICLE.SET_DRIFT_TYRES(veh, true)
    if force_slip then
        VEHICLE.SET_VEHICLE_REDUCE_GRIP(veh, true)
        VEHICLE.SET_VEHICLE_REDUCE_GRIP_LEVEL(veh, 2)
    else
        VEHICLE.SET_VEHICLE_REDUCE_GRIP(veh, false)
    end
end

local function copy_look(from_veh, to_veh)
    VEHICLE.GET_VEHICLE_COLOURS(from_veh, col_a, col_b)
    VEHICLE.SET_VEHICLE_COLOURS(to_veh, memory.read_int(col_a), memory.read_int(col_b))
    VEHICLE.GET_VEHICLE_EXTRA_COLOURS(from_veh, col_a, col_b)
    VEHICLE.SET_VEHICLE_EXTRA_COLOURS(to_veh, memory.read_int(col_a), memory.read_int(col_b))

    if VEHICLE.GET_IS_VEHICLE_PRIMARY_COLOUR_CUSTOM(from_veh) then
        VEHICLE.GET_VEHICLE_CUSTOM_PRIMARY_COLOUR(from_veh, rgb_r, rgb_g, rgb_b)
        VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(to_veh, memory.read_int(rgb_r), memory.read_int(rgb_g), memory.read_int(rgb_b))
    end
    if VEHICLE.GET_IS_VEHICLE_SECONDARY_COLOUR_CUSTOM(from_veh) then
        VEHICLE.GET_VEHICLE_CUSTOM_SECONDARY_COLOUR(from_veh, rgb_r, rgb_g, rgb_b)
        VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(to_veh, memory.read_int(rgb_r), memory.read_int(rgb_g), memory.read_int(rgb_b))
    end

    VEHICLE.SET_VEHICLE_WINDOW_TINT(to_veh, VEHICLE.GET_VEHICLE_WINDOW_TINT(from_veh))
    VEHICLE.SET_VEHICLE_DIRT_LEVEL(to_veh, VEHICLE.GET_VEHICLE_DIRT_LEVEL(from_veh))
    local livery = VEHICLE.GET_VEHICLE_LIVERY(from_veh)
    if livery >= 0 then
        VEHICLE.SET_VEHICLE_LIVERY(to_veh, livery)
    end

    for extra = 0, 20 do
        if VEHICLE.DOES_EXTRA_EXIST(from_veh, extra) and VEHICLE.DOES_EXTRA_EXIST(to_veh, extra) then
            VEHICLE.SET_VEHICLE_EXTRA(to_veh, extra, not VEHICLE.IS_VEHICLE_EXTRA_TURNED_ON(from_veh, extra))
        end
    end
end

local function drift_name_for(base_name)
    if is_drift_model_name(base_name) then
        return base_name
    end
    local mapped = BASE_TO_DRIFT[base_name]
    if mapped and model_in_game(util.joaat(mapped)) then
        return mapped
    end
    local guess = "drift" .. base_name
    if model_in_game(util.joaat(guess)) then
        return guess
    end
    return nil
end

--==============================================================================
-- SPAWNER
--==============================================================================

local function name_denied(name)
    if BASIC_TRAFFIC[name] or DENY_NAME[name] then
        return true
    end
    if name:find("police", 1, true) or name:find("sheriff", 1, true) then
        return true
    end
    if name:find("trailer", 1, true) or name:find("truck", 1, true) then
        return true
    end
    return false
end

local function model_is_spot_car(hash)
    if not model_in_game(hash) or not VEHICLE.IS_THIS_MODEL_A_CAR(hash) then
        return false
    end
    if VEHICLE.IS_THIS_MODEL_A_BIKE(hash) or VEHICLE.IS_THIS_MODEL_A_QUADBIKE(hash) then
        return false
    end
    if util.is_this_model_a_trailer(hash) or util.is_this_model_a_submarine_car(hash) then
        return false
    end
    local class = VEHICLE.GET_VEHICLE_CLASS_FROM_NAME(hash)
    return class >= 0 and class <= 7
end

local function build_spot_pool()
    spot_pool = {}
    local ok, list = pcall(util.get_vehicles)
    if not ok or type(list) ~= "table" then
        return
    end
    for i = 1, #list do
        local info = list[i]
        if type(info) == "table" and info.name then
            local name = string.lower(info.name)
            if not name_denied(name) and ALLOW_CLASS[info.class] then
                local hash = util.joaat(name)
                if model_is_spot_car(hash) then
                    spot_pool[#spot_pool + 1] = {
                        hash = hash,
                        name = name,
                        label = display_vehicle_name(info.name, info.manufacturer),
                    }
                end
            end
        end
    end
end

local function pick_spot_cars(count)
    local picks = {}
    local used = {}
    if #spot_pool == 0 then
        return picks
    end
    for _ = 1, count * 8 do
        if #picks >= count then
            break
        end
        local info = spot_pool[math.random(1, #spot_pool)]
        if not used[info.hash] then
            used[info.hash] = true
            picks[#picks + 1] = info
        end
    end
    return picks
end

local function dress_car(veh)
    local roll = math.random()
    if roll < 0.40 then
        local n = VEHICLE.GET_NUMBER_OF_VEHICLE_COLOURS(veh)
        if n > 1 then
            VEHICLE.SET_VEHICLE_COLOUR_COMBINATION(veh, math.random(0, n - 1))
        else
            local c = math.random(0, 159)
            VEHICLE.SET_VEHICLE_COLOURS(veh, c, math.random() < 0.6 and c or math.random(0, 159))
        end
    elseif roll < 0.78 then
        local a = math.random(0, 159)
        local b = math.random() < 0.65 and a or math.random(0, 159)
        VEHICLE.SET_VEHICLE_COLOURS(veh, a, b)
        VEHICLE.SET_VEHICLE_EXTRA_COLOURS(veh, math.random(0, 159), math.random(0, 159))
    else
        local p = STREET_PAINT[math.random(1, #STREET_PAINT)]
        local j = math.random(-14, 14)
        local r, g, b = clamp_byte(p[1] + j), clamp_byte(p[2] + j), clamp_byte(p[3] + j)
        VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh, r, g, b)
        VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh, r, g, b)
        VEHICLE.SET_VEHICLE_EXTRA_COLOURS(veh, math.random(0, 159), math.random(0, 159))
    end
    VEHICLE.SET_VEHICLE_DIRT_LEVEL(veh, math.random() < 0.7 and (math.random() * 2.2) or (math.random() * 6.5))
    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(veh, math.random(0, 5))
    if math.random() < 0.35 then
        VEHICLE.SET_VEHICLE_WINDOW_TINT(veh, math.random(1, 5))
    end
end

local function clear_spawned()
    for i = 1, #spawned do
        delete_ent(spawned[i])
    end
    spawned = {}
end

local function release_ent(ent)
    if not exists(ent) then
        return
    end
    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, false, true)
    memory.write_int(col_a, ent)
    ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(col_a)
end

local function release_spawned()
    for i = 1, #spawned do
        release_ent(spawned[i])
    end
    spawned = {}
end

local function remember(ent)
    if exists(ent) then
        spawned[#spawned + 1] = ent
    end
end

local function spawn_vehicle_in_front(hash, heading_offset, lateral, ahead)
    local ped = player_ped()
    local pos = ENTITY.GET_ENTITY_COORDS(ped, true)
    local heading = ENTITY.GET_ENTITY_HEADING(ped)
    local fx, fy = heading_to_dir(heading)
    local rx, ry = fy, -fx
    local x = pos.x + fx * (ahead or 11.0) + rx * (lateral or 0.0)
    local y = pos.y + fy * (ahead or 11.0) + ry * (lateral or 0.0)
    local z = ground_at(x, y, pos.z)
    local veh = entities.create_vehicle(hash, v3.new(x, y, z + 0.4), heading + (heading_offset or 180.0))
    if exists(veh) then
        VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(veh, 5.0)
        VEHICLE.SET_VEHICLE_ENGINE_ON(veh, false, true, false)
        VEHICLE.SET_VEHICLE_HANDBRAKE(veh, false)
        VEHICLE.SET_VEHICLE_NEEDS_TO_BE_HOTWIRED(veh, false)
    end
    return veh
end

local function spawn_lineup(count)
    if #spot_pool == 0 then
        build_spot_pool()
    end
    if #spot_pool == 0 then
        util.toast("No spotting cars found")
        return
    end

    clear_spawned()

    local picks = pick_spot_cars(count)
    local names = {}
    local mid = (count + 1) * 0.5

    for i = 1, #picks do
        local info = picks[i]
        if request_model(info.hash) then
            local veh = spawn_vehicle_in_front(info.hash, 180.0, (i - mid) * 5.8, 11.0)
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(info.hash)
            if exists(veh) then
                dress_car(veh)
                remember(veh)
                names[#names + 1] = info.label
            end
        else
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(info.hash)
        end
        util.yield(0)
    end

    if #names == 0 then
        util.toast("Spawn failed — try again")
        return
    end
    util.toast("Spot: " .. table.concat(names, "  |  "))
end

--==============================================================================
-- DRIFT
--==============================================================================

local function add_drift_entry(seen, name, maker)
    name = string.lower(name)
    if seen[name] then
        return
    end
    local hash = util.joaat(name)
    if not model_in_game(hash) then
        return
    end
    seen[name] = true
    drift_catalog[#drift_catalog + 1] = {
        name = name,
        hash = hash,
        label = display_vehicle_name(name, maker),
    }
end

local function build_drift_catalog()
    drift_catalog = {}
    local seen = {}

    for _, drift_name in pairs(BASE_TO_DRIFT) do
        add_drift_entry(seen, drift_name)
    end
    add_drift_entry(seen, "yosemite2")
    add_drift_entry(seen, "drifttampa")
    add_drift_entry(seen, "driftwalton")

    local ok, list = pcall(util.get_vehicles)
    if ok and type(list) == "table" then
        for i = 1, #list do
            local info = list[i]
            if type(info) == "table" and info.name then
                local name = string.lower(info.name)
                if is_drift_model_name(name) then
                    add_drift_entry(seen, name, info.manufacturer)
                end
            end
        end
    end

    table.sort(drift_catalog, function(a, b)
        return a.label < b.label
    end)
end

local function spawn_drift_car(info)
    if not request_model(info.hash) then
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(info.hash)
        util.toast("Could not load " .. info.label)
        return
    end
    local veh = spawn_vehicle_in_front(info.hash, 180.0, 0.0, 8.0)
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(info.hash)
    if not exists(veh) then
        util.toast("Could not spawn " .. info.label)
        return
    end
    dress_car(veh)
    apply_drift_tires(veh, false)
    remember(veh)
    util.toast(info.label)
end

local function make_current_car_drift()
    local veh = current_car()
    if veh == 0 then
        util.toast("Get in a car first")
        return
    end

    local hash = ENTITY.GET_ENTITY_MODEL(veh)
    local name = model_name_from_hash(hash)
    if not name then
        apply_drift_tires(veh, true)
        util.toast("Drift tires on — this car has no named drift model")
        return
    end

    if is_drift_model_name(name) then
        apply_drift_tires(veh, false)
        util.toast("This is already the drift model — drift tires on")
        return
    end

    local drift_name = drift_name_for(name)
    if not drift_name then
        apply_drift_tires(veh, true)
        util.toast("No LS Car Meet drift version — drift tires added")
        return
    end

    local drift_hash = util.joaat(drift_name)
    if not request_model(drift_hash) then
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(drift_hash)
        apply_drift_tires(veh, true)
        util.toast("Could not load the drift model — drift tires added instead")
        return
    end

    local pos = ENTITY.GET_ENTITY_COORDS(veh, true)
    local heading = ENTITY.GET_ENTITY_HEADING(veh)
    local speed = ENTITY.GET_ENTITY_SPEED(veh)
    local new_veh = entities.create_vehicle(drift_hash, pos, heading)
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(drift_hash)
    if not exists(new_veh) then
        apply_drift_tires(veh, true)
        util.toast("Swap failed — drift tires added instead")
        return
    end

    copy_look(veh, new_veh)
    VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(new_veh, 5.0)
    VEHICLE.SET_VEHICLE_ENGINE_ON(new_veh, true, true, false)
    apply_drift_tires(new_veh, false)
    PED.SET_PED_INTO_VEHICLE(player_ped(), new_veh, -1)
    if speed > 1.0 then
        VEHICLE.SET_VEHICLE_FORWARD_SPEED(new_veh, speed)
    end
    delete_ent(veh)
    util.toast("Swapped to " .. display_vehicle_name(drift_name))
end

--==============================================================================
-- MENU
--==============================================================================

-- BEGIN VEHICLE
local vehicle_root = menu.list(root, "Vehicle", {"mptvehicle"}, "Cars you are driving, plus spawners.")

menu.action(vehicle_root, "Make this car drift", {"mptdrift"}, "Must be sitting in a car. If it has an LS Car Meet / Chop Shop drift model, you get that car. If not, drift tires go on the one you are in.", function()
    make_current_car_drift()
end)

local spawner_root = menu.list(vehicle_root, "Spawner", {"mptspawner"}, "Park cars in front of you.")

menu.action(spawner_root, "Spawn 5 cars", {"mptspawn5"}, "Replaces the last lineup with 5 random DLC / GTA Online cars.", function()
    spawn_lineup(5)
end)

local drift_list_root = menu.list(spawner_root, "Drift cars", {"mptdriftcars"}, "Every drift model this game build can spawn.")

menu.action(spawner_root, "Clear lineup", {"mptclearspot"}, "Deletes cars this spawner created.", function()
    clear_spawned()
    util.toast("Lineup cleared")
end)
-- END VEHICLE

local function fill_drift_menu()
    if #drift_catalog == 0 then
        menu.action(drift_list_root, "No drift cars found", {}, "This game build did not list any drift models.", function() end)
        return
    end
    for i = 1, #drift_catalog do
        local info = drift_catalog[i]
        menu.action(drift_list_root, info.label, {"mptdriftspawn" .. info.name}, "Spawn this drift car in front of you.", function()
            spawn_drift_car(info)
        end)
    end
end

--==============================================================================
-- LIFECYCLE
--==============================================================================

util.on_pre_stop(function()
    -- Leave spawned cars in the world. Clear lineup is the delete button.
    release_spawned()
end)

build_spot_pool()
build_drift_catalog()
fill_drift_menu()

if not SCRIPT_SILENT_START then
    util.toast("Multi Purpose Tool loaded")
end
