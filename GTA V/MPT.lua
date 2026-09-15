-- MPT.lua
-- Multi Purpose Tool for story-mode Stand.
-- Natives are from natives-1663599433. Stand API only.
--
-- Add new root sections the same way Vehicle / World / Graphic FIX are set up below.
-- any Stand commands wrapped with local buttons so the menu doesnt jump around.
--

util.require_natives(1663599433)

--==============================================================================
-- STATE
--==============================================================================

local root = menu.my_root()
-- Lineup entries: { ent, x, y }. Cars still near x,y get replaced.
-- Cars you sat in or drove off are dropped from this list and left in the world.
local spawned = {}
local spot_pool = {}
local drift_catalog = {}

-- Horizontal metres from spawn point. Under this = still sitting in the row.
local SITTING_RADIUS = 4.0
local SITTING_RADIUS_SQ = SITTING_RADIUS * SITTING_RADIUS

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

-- Coordinated looks for Spec appearance.
-- paint: 0 normal, 1 metallic, 2 pearl, 3 matte, 4 metal, 5 chrome
-- p / s / pearl / wheel are 0-159 colour indices. xenon 0-12. tint 1 black, 2 dark smoke, 5 limo.
local SPEC_LOOKS = {
    {paint = 1, p = 0,   s = 0,   pearl = 0,   wheel = 0,   xenon = 0,  tint = 1, smoke = {20, 20, 20}},
    {paint = 3, p = 0,   s = 0,   pearl = 0,   wheel = 0,   xenon = 0,  tint = 1, smoke = {16, 16, 16}},
    {paint = 1, p = 147, s = 0,   pearl = 0,   wheel = 0,   xenon = 0,  tint = 1, smoke = {18, 18, 18}},
    {paint = 1, p = 111, s = 111, pearl = 112, wheel = 4,   xenon = 0,  tint = 2, smoke = {220, 220, 220}},
    {paint = 1, p = 112, s = 111, pearl = 111, wheel = 0,   xenon = 0,  tint = 2, smoke = {210, 210, 210}},
    {paint = 1, p = 4,   s = 0,   pearl = 111, wheel = 0,   xenon = 0,  tint = 1, smoke = {40, 40, 40}},
    {paint = 1, p = 7,   s = 7,   pearl = 4,   wheel = 0,   xenon = 0,  tint = 1, smoke = {36, 36, 36}},
    {paint = 1, p = 27,  s = 0,   pearl = 28,  wheel = 0,   xenon = 8,  tint = 1, smoke = {90, 8, 8}},
    {paint = 1, p = 29,  s = 0,   pearl = 35,  wheel = 0,   xenon = 8,  tint = 1, smoke = {80, 10, 10}},
    {paint = 1, p = 70,  s = 0,   pearl = 73,  wheel = 0,   xenon = 2,  tint = 1, smoke = {8, 16, 70}},
    {paint = 1, p = 64,  s = 0,   pearl = 68,  wheel = 4,   xenon = 1,  tint = 2, smoke = {10, 20, 80}},
    {paint = 1, p = 50,  s = 0,   pearl = 55,  wheel = 0,   xenon = 3,  tint = 1, smoke = {8, 40, 16}},
    {paint = 1, p = 38,  s = 0,   pearl = 0,   wheel = 0,   xenon = 7,  tint = 1, smoke = {90, 40, 8}},
    {paint = 1, p = 88,  s = 0,   pearl = 0,   wheel = 0,   xenon = 5,  tint = 1, smoke = {90, 80, 10}},
    {paint = 1, p = 37,  s = 0,   pearl = 99,  wheel = 37,  xenon = 6,  tint = 2, smoke = {80, 60, 16}},
    {paint = 1, p = 145, s = 0,   pearl = 71,  wheel = 0,   xenon = 11, tint = 1, smoke = {40, 8, 60}},
    {paint = 1, p = 92,  s = 0,   pearl = 0,   wheel = 0,   xenon = 4,  tint = 1, smoke = {20, 80, 12}},
    {paint = 2, p = 111, s = 4,   pearl = 0,   wheel = 0,   xenon = 0,  tint = 2, smoke = {200, 200, 200}},
    {paint = 1, p = 28,  s = 0,   pearl = 111, wheel = 111, xenon = 8,  tint = 1, smoke = {70, 8, 8}},
    {paint = 1, p = 0,   s = 27,  pearl = 0,   wheel = 0,   xenon = 8,  tint = 1, smoke = {24, 24, 24}},
    {paint = 1, p = 0,   s = 4,   pearl = 0,   wheel = 4,   xenon = 0,  tint = 1, smoke = {20, 20, 20}},
    {paint = 3, p = 111, s = 0,   pearl = 0,   wheel = 0,   xenon = 0,  tint = 1, smoke = {30, 30, 30}},
}

local BODY_MODS = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
local COSMETIC_MODS = {25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 39, 40, 41, 42, 43, 44, 45, 46}

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

local function pick_from_pool(pool, count)
    local picks = {}
    local used = {}
    if type(pool) ~= "table" or #pool == 0 or count < 1 then
        return picks
    end
    local attempts = math.max(count * 8, #pool)
    for _ = 1, attempts do
        if #picks >= count then
            break
        end
        local info = pool[math.random(1, #pool)]
        if info and info.hash and not used[info.hash] then
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

local function entry_ent(entry)
    if type(entry) ~= "table" then
        return 0
    end
    return entry.ent or 0
end

-- True if this lineup car should survive the next spawn: you are in it, or it left its slot.
local function car_was_taken(entry)
    local ent = entry_ent(entry)
    if not exists(ent) then
        return true
    end
    if PED.IS_PED_IN_VEHICLE(player_ped(), ent, false) then
        return true
    end
    local pos = ENTITY.GET_ENTITY_COORDS(ent, true)
    local dx = pos.x - entry.x
    local dy = pos.y - entry.y
    return (dx * dx + dy * dy) >= SITTING_RADIUS_SQ
end

-- Deletes cars still parked in the last row. Leaves taken cars in the world and forgets them.
local function clear_sitting_lineup()
    local kept = 0
    for i = 1, #spawned do
        local entry = spawned[i]
        if car_was_taken(entry) then
            if exists(entry_ent(entry)) then
                kept = kept + 1
            end
        else
            delete_ent(entry_ent(entry))
        end
    end
    spawned = {}
    return kept
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
        release_ent(entry_ent(spawned[i]))
    end
    spawned = {}
end

local function remember(ent)
    if not exists(ent) then
        return
    end
    local pos = ENTITY.GET_ENTITY_COORDS(ent, true)
    spawned[#spawned + 1] = {
        ent = ent,
        x = pos.x,
        y = pos.y,
    }
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

local function spawn_lineup(count, pool, empty_msg, toast_prefix, with_drift_tires)
    if type(pool) ~= "table" or #pool == 0 then
        util.toast(empty_msg or "No spotting cars found")
        return
    end

    local kept = clear_sitting_lineup()

    local picks = pick_from_pool(pool, count)
    local names = {}
    local mid = (count + 1) * 0.5

    for i = 1, #picks do
        local info = picks[i]
        if request_model(info.hash) then
            local veh = spawn_vehicle_in_front(info.hash, 180.0, (i - mid) * 5.8, 11.0)
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(info.hash)
            if exists(veh) then
                dress_car(veh)
                if with_drift_tires then
                    apply_drift_tires(veh, false)
                end
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
    local msg = (toast_prefix or "Spot: ") .. table.concat(names, "  |  ")
    if kept > 0 then
        msg = msg .. "  (kept " .. tostring(kept) .. " you took)"
    end
    util.toast(msg)
end

local function spawn_spot_lineup(count)
    if #spot_pool == 0 then
        build_spot_pool()
    end
    spawn_lineup(count, spot_pool, "No spotting cars found", "Spot: ", false)
end

local function spawn_drift_lineup(count)
    -- Catalog is filled at load. Do not call build_drift_catalog here: it is a later local.
    spawn_lineup(count, drift_catalog, "No drift cars found", "Drift: ", true)
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
-- APPEARANCE
--==============================================================================

local function pick_one(list)
    return list[math.random(1, #list)]
end

local function ensure_mod_kit(veh)
    if VEHICLE.GET_NUM_MOD_KITS(veh) > 0 then
        VEHICLE.SET_VEHICLE_MOD_KIT(veh, 0)
        return true
    end
    return false
end

local function mod_count(veh, mod_type)
    local n = VEHICLE.GET_NUM_VEHICLE_MODS(veh, mod_type)
    if type(n) ~= "number" or n < 1 then
        return 0
    end
    return n
end

-- prefer: "any" random, "max" last slot, "high" upper half (usually the fuller kits).
local function pick_mod(veh, mod_type, prefer)
    local n = mod_count(veh, mod_type)
    if n < 1 then
        return -1
    end
    local index
    if prefer == "max" then
        index = n - 1
    elseif prefer == "high" then
        local start = math.max(0, math.floor(n * 0.5))
        index = math.random(start, n - 1)
    else
        index = math.random(0, n - 1)
    end
    if VEHICLE.IS_VEHICLE_MOD_GEN9_EXCLUSIVE(veh, mod_type, index) then
        if index > 0 then
            index = index - 1
        end
    end
    return index
end

local function apply_mod(veh, mod_type, index, custom_tires)
    if index == nil or index < 0 then
        VEHICLE.REMOVE_VEHICLE_MOD(veh, mod_type)
        return
    end
    VEHICLE.SET_VEHICLE_MOD(veh, mod_type, index, custom_tires == true)
end

local function apply_mod_list(veh, types, prefer, custom_tires)
    for i = 1, #types do
        apply_mod(veh, types[i], pick_mod(veh, types[i], prefer), custom_tires)
    end
end

local function clear_paint(veh)
    VEHICLE.CLEAR_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh)
    VEHICLE.CLEAR_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh)
end

local function apply_indexed_paint(veh, look)
    clear_paint(veh)
    VEHICLE.SET_VEHICLE_MOD_COLOR_1(veh, look.paint, look.p, look.pearl)
    VEHICLE.SET_VEHICLE_MOD_COLOR_2(veh, look.paint, look.s)
    VEHICLE.SET_VEHICLE_COLOURS(veh, look.p, look.s)
    VEHICLE.SET_VEHICLE_EXTRA_COLOURS(veh, look.pearl, look.wheel)
    VEHICLE.SET_VEHICLE_EXTRA_COLOUR_5(veh, look.p)
    VEHICLE.SET_VEHICLE_EXTRA_COLOUR_6(veh, look.s)
end

local function apply_custom_paint(veh, rgb, wheel)
    local r, g, b = clamp_byte(rgb[1]), clamp_byte(rgb[2]), clamp_byte(rgb[3])
    local dr = clamp_byte(math.floor(r * 0.45))
    local dg = clamp_byte(math.floor(g * 0.45))
    local db = clamp_byte(math.floor(b * 0.45))
    VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh, r, g, b)
    VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh, dr, dg, db)
    VEHICLE.SET_VEHICLE_EXTRA_COLOURS(veh, 0, wheel or 0)
end

local function set_neons(veh, on, r, g, b)
    for i = 0, 3 do
        VEHICLE.SET_VEHICLE_NEON_ENABLED(veh, i, on)
    end
    if on then
        VEHICLE.SET_VEHICLE_NEON_COLOUR(veh, r, g, b)
    end
end

local function apply_extras(veh, chance)
    for extra = 0, 20 do
        if VEHICLE.DOES_EXTRA_EXIST(veh, extra) then
            -- Native is inverted: true disables the extra.
            VEHICLE.SET_VEHICLE_EXTRA(veh, extra, math.random() >= chance)
        end
    end
end

local function apply_livery(veh, chance)
    if math.random() > chance then
        apply_mod(veh, 48, -1, false)
        if VEHICLE.GET_VEHICLE_LIVERY_COUNT(veh) > 0 then
            VEHICLE.SET_VEHICLE_LIVERY(veh, 0)
        end
        return
    end
    local kit_n = mod_count(veh, 48)
    local old_n = VEHICLE.GET_VEHICLE_LIVERY_COUNT(veh)
    if kit_n > 0 then
        apply_mod(veh, 48, pick_mod(veh, 48, "any"), false)
    elseif old_n > 1 then
        VEHICLE.SET_VEHICLE_LIVERY(veh, math.random(0, old_n - 1))
    end
    local old2 = VEHICLE.GET_VEHICLE_LIVERY2_COUNT(veh)
    if old2 > 1 and math.random() < 0.45 then
        VEHICLE.SET_VEHICLE_LIVERY2(veh, math.random(0, old2 - 1))
    end
end

local function apply_wheels(veh, smart)
    local hash = ENTITY.GET_ENTITY_MODEL(veh)
    local is_bike = VEHICLE.IS_THIS_MODEL_A_BIKE(hash)
    local class = VEHICLE.GET_VEHICLE_CLASS(veh)
    local types
    if is_bike then
        types = {6}
    elseif not smart then
        types = {0, 1, 2, 3, 4, 5, 7, 8, 9, 11, 12}
    elseif class == 2 or class == 9 then
        types = {3, 4}
    elseif class == 4 then
        types = {1, 5, 11}
    elseif class == 7 then
        types = {0, 7, 11}
    elseif class == 5 then
        types = {1, 5, 7}
    else
        types = {0, 5, 7, 11, 12}
    end

    VEHICLE.SET_VEHICLE_WHEEL_TYPE(veh, pick_one(types))
    local n = mod_count(veh, 23)
    if n < 1 then
        for i = 1, #types do
            VEHICLE.SET_VEHICLE_WHEEL_TYPE(veh, types[i])
            n = mod_count(veh, 23)
            if n > 0 then
                break
            end
        end
    end
    local prefer = smart and "high" or "any"
    apply_mod(veh, 23, pick_mod(veh, 23, prefer), true)
    if is_bike then
        apply_mod(veh, 24, pick_mod(veh, 24, prefer), true)
    end
end

local function apply_stance(veh, smart)
    local class = VEHICLE.GET_VEHICLE_CLASS(veh)
    local n = mod_count(veh, 15)
    if n < 1 then
        return
    end
    if not smart then
        apply_mod(veh, 15, pick_mod(veh, 15, "any"), false)
        return
    end
    -- Street / sport / muscle / coupe get slammed. SUVs and off-road stay a bit higher.
    if class == 2 or class == 9 then
        apply_mod(veh, 15, math.max(0, math.floor((n - 1) * 0.5)), false)
    else
        apply_mod(veh, 15, n - 1, false)
    end
end

local function streetish(veh)
    local class = VEHICLE.GET_VEHICLE_CLASS(veh)
    if class >= 0 and class <= 7 then
        return true
    end
    local name = model_name_from_hash(ENTITY.GET_ENTITY_MODEL(veh))
    return name ~= nil and is_drift_model_name(name)
end

local function apply_random_appearance(veh)
    ensure_mod_kit(veh)
    apply_mod_list(veh, BODY_MODS, "any", false)
    apply_mod_list(veh, COSMETIC_MODS, "any", false)
    apply_stance(veh, false)
    apply_wheels(veh, false)
    apply_livery(veh, 0.85)
    apply_extras(veh, 0.5)

    local roll = math.random()
    if roll < 0.45 then
        apply_indexed_paint(veh, {
            paint = math.random(0, 5),
            p = math.random(0, 159),
            s = math.random(0, 159),
            pearl = math.random(0, 159),
            wheel = math.random(0, 159),
        })
    elseif roll < 0.75 then
        local c = math.random(0, 159)
        apply_indexed_paint(veh, {
            paint = math.random(0, 3),
            p = c,
            s = math.random() < 0.5 and c or math.random(0, 159),
            pearl = math.random(0, 159),
            wheel = math.random(0, 159),
        })
    else
        apply_custom_paint(veh, pick_one(STREET_PAINT), math.random(0, 159))
    end

    VEHICLE.SET_VEHICLE_WINDOW_TINT(veh, math.random(0, 6))
    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(veh, math.random(0, 5))
    VEHICLE.SET_VEHICLE_DIRT_LEVEL(veh, math.random() * 12.0)
    VEHICLE.TOGGLE_VEHICLE_MOD(veh, 22, true)
    VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(veh, math.random(0, 12))
    VEHICLE.TOGGLE_VEHICLE_MOD(veh, 20, true)
    VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(veh, math.random(0, 255), math.random(0, 255), math.random(0, 255))
    if math.random() < 0.55 then
        set_neons(veh, true, math.random(0, 255), math.random(0, 255), math.random(0, 255))
    else
        set_neons(veh, false, 0, 0, 0)
    end
end

local function apply_spec_appearance(veh)
    ensure_mod_kit(veh)
    apply_mod_list(veh, BODY_MODS, "high", false)
    apply_mod_list(veh, COSMETIC_MODS, "high", false)
    apply_stance(veh, true)
    apply_wheels(veh, true)
    VEHICLE.REMOVE_VEHICLE_MOD(veh, 38)

    local class = VEHICLE.GET_VEHICLE_CLASS(veh)
    local name = model_name_from_hash(ENTITY.GET_ENTITY_MODEL(veh)) or ""
    local livery_chance = 0.15
    if is_drift_model_name(name) then
        livery_chance = 0.80
    elseif class == 4 or class == 6 then
        livery_chance = 0.70
    elseif class == 0 or class == 1 or class == 3 or class == 5 then
        livery_chance = 0.55
    elseif class == 7 then
        livery_chance = 0.20
    elseif streetish(veh) then
        livery_chance = 0.45
    end
    apply_livery(veh, livery_chance)
    apply_extras(veh, 0.72)

    local look = pick_one(SPEC_LOOKS)
    if math.random() < 0.22 then
        local rgb = pick_one(STREET_PAINT)
        apply_custom_paint(veh, rgb, look.wheel)
        look = {
            paint = 1,
            p = look.p,
            s = look.s,
            pearl = 0,
            wheel = look.wheel,
            xenon = look.xenon,
            tint = look.tint,
            smoke = {rgb[1], rgb[2], rgb[3]},
        }
    else
        apply_indexed_paint(veh, look)
    end

    VEHICLE.SET_VEHICLE_WINDOW_TINT(veh, look.tint)
    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(veh, pick_one({0, 1, 4, 5}))
    VEHICLE.SET_VEHICLE_DIRT_LEVEL(veh, math.random() < 0.8 and (math.random() * 1.2) or (math.random() * 3.5))
    VEHICLE.TOGGLE_VEHICLE_MOD(veh, 22, true)
    VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(veh, look.xenon)
    VEHICLE.TOGGLE_VEHICLE_MOD(veh, 20, true)
    VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(veh, look.smoke[1], look.smoke[2], look.smoke[3])
    if livery_chance >= 0.70 and math.random() < 0.25 then
        set_neons(veh, true, look.smoke[1], look.smoke[2], look.smoke[3])
    else
        set_neons(veh, false, 0, 0, 0)
    end
end

local function restyle_current(smart)
    local veh = current_car()
    if veh == 0 then
        util.toast("Get in a car first")
        return
    end
    if smart then
        apply_spec_appearance(veh)
        util.toast("Spec appearance applied")
    else
        apply_random_appearance(veh)
        util.toast("Appearance randomized")
    end
end

--==============================================================================
-- MENU
--==============================================================================

-- BEGIN VEHICLE
local vehicle_root = menu.list(root, "Vehicle", {"mptvehicle"}, "Vehicle Options")

menu.action(vehicle_root, "Make this car drift", {"mptdrift"}, "Make any car Drift-tuned. Must be sitting in a car. If it has an LS Car Meet / Chop Shop drift model, you get that car. If not, drift tires go on the one you are in.", function()
    make_current_car_drift()
end)

menu.action(vehicle_root, "Randomize appearance", {"mptrandlook"}, "Must be sitting in a car. Random paint, mods, wheels, tint, extras, livery, neons. Chaos on purpose.", function()
    restyle_current(false)
end)

menu.action(vehicle_root, "Spec appearance", {"mptspeclook"}, "Must be sitting in a car. Matching colours, nicer rims, lowered on street cars, fuller body kits, livery more often on sport / muscle / drift.", function()
    restyle_current(true)
end)

local spawner_root = menu.list(vehicle_root, "Spawner", {"mptspawner"}, "Spawn cars in front of you.")

menu.action(spawner_root, "Spawn 5 cars", {"mptspawn5"}, "Parks 5 random DLC / GTA Online cars. Replaces cars if you press more than once, but If you sat in one or drove it off 5meters or more, it stays.", function()
    spawn_spot_lineup(5)
end)

menu.action(spawner_root, "Spawn 5 cars DRIFT", {"mptspawndrift5"}, "Same as Spawn 5 cars, but LS Car Meet / Chop Shop drift models only. Drift tires already on aswell.", function()
    spawn_drift_lineup(5)
end)

local drift_list_root = menu.list(spawner_root, "Drift cars", {"mptdriftcars"}, "List of Every drift model this game build can spawn.")

menu.action(spawner_root, "Clear lineup", {"mptclearspot"}, "Deletes cars still sitting in the last row. Cars you took stay in the world.", function()
    local kept = clear_sitting_lineup()
    if kept > 0 then
        util.toast("Lineup cleared — left " .. tostring(kept) .. " you took")
    else
        util.toast("Lineup cleared")
    end
end)
-- END VEHICLE

--==============================================================================
-- WORLD (thin Stand wrappers)
--==============================================================================

-- Clock hours. Afternoon is 15 so it stays distinct from dusk.
local CLOCK_PRESETS = {
    {"Morning", "mpttimemorning", 6, false},
    {"Mid day", "mpttimemidday", 12, false},
    {"Afternoon", "mpttimeafternoon", 15, false},
    {"Dusk", "mpttimedusk", 19, false},
    {"Night", "mpttimenight", 22, false},
    {"Pitch black", "mpttimepitch", 0, true},
}

local WEATHER_SET = {
    {"normal", "Don't Override"},
    {"extrasunny", "Extra Sunny"},
    {"clear", "Clear"},
    {"clouds", "Clouds"},
    {"smog", "Smog"},
    {"foggy", "Foggy"},
    {"overcast", "Overcast"},
    {"rain", "Rain"},
    {"thunder", "Thunder"},
    {"clearing", "Clearing"},
    {"neutral", "Neutral"},
    {"snow", "Snow"},
    {"blizzard", "Blizzard"},
    {"snowlight", "Snowlight"},
    {"xmas", "Xmas"},
    {"halloween", "Clear Halloween"},
    {"rainhalloween", "Rainy Halloween"},
    {"snowhalloween", "Snowy Halloween"},
}

local function stand_run(input)
    menu.trigger_commands(input)
end

-- Ignore Stand applying default state on load so the script does not stomp the clock.
local function user_click(click_type)
    return click_type ~= CLICK_BULK and click_type ~= CLICK_AUTO
end

local function set_clock_hour(hour, pitch)
    stand_run("time " .. tostring(hour))
    if pitch then
        stand_run("blackout on")
        stand_run("locktime on")
    else
        stand_run("blackout off")
    end
end

-- BEGIN WORLD
local world_root = menu.list(root, "World", {"mptworld"}, "Clock and weather. Local buttons that fire Stand commands.")

local clock_root = menu.list(world_root, "Clock", {"mptworldclock"}, "Local clock. Presets plus an hour slider.")

for i = 1, #CLOCK_PRESETS do
    local row = CLOCK_PRESETS[i]
    local label, cmd, hour, pitch = row[1], row[2], row[3], row[4]
    local help
    if pitch then
        help = "Sets time " .. tostring(hour) .. ", locks the clock, and turns blackout on."
    else
        help = "Sets time to " .. tostring(hour) .. ":00. Turns blackout off if pitch black left it on."
    end
    menu.action(clock_root, label, {cmd}, help, function()
        set_clock_hour(hour, pitch)
        util.toast("Clock: " .. label)
    end)
end

menu.slider(clock_root, "Hour", {"mptclockhour"}, "Fires Stand time. Scroll or press Enter and type 0-23.", 0, 23, 12, 1, function(value, _prev, click_type)
    if user_click(click_type) then
        stand_run("time " .. tostring(value))
    end
end)

menu.toggle(clock_root, "Lock time", {"mptlocktime"}, "Fires stand locktime. Stops the clock from advancing.", function(on, click_type)
    if user_click(click_type) then
        stand_run(on and "locktime on" or "locktime off")
    end
end, false)

menu.toggle(clock_root, "Smooth transition", {"mpttimesmooth"}, "Fires timesmoothing.", function(on, click_type)
    if user_click(click_type) then
        stand_run(on and "timesmoothing on" or "timesmoothing off")
    end
end, false)

menu.slider(clock_root, "Clock speed", {"mptclockspeed"}, "Fires clockspeed. 1 is slowest. Vanilla-ish is low. High values rip through the day.", 1, 3999, 1, 1, function(value, _prev, click_type)
    if user_click(click_type) then
        stand_run("clockspeed " .. tostring(value))
    end
end)

menu.toggle(clock_root, "Use system time", {"mptsystime"}, "Fires systime. Uses your PC clock.", function(on, click_type)
    if user_click(click_type) then
        stand_run(on and "systime on" or "systime off")
    end
end, false)

local weather_root = menu.list(world_root, "Weather", {"mptworldweather"}, "Local weather. Same values as Stand Atmosphere, without leaving this script.")

local weather_options = {}
for i = 1, #WEATHER_SET do
    weather_options[i] = {i, WEATHER_SET[i][2]}
end

menu.list_action(weather_root, "Set weather", {"mptsetweather"}, "Fires Stand's weather command.", weather_options, function(value)
    local row = WEATHER_SET[value]
    if row then
        stand_run("weather " .. row[1])
        util.toast("Weather: " .. row[2])
    end
end)

local CLOUD_SET = {
    {"normal", "Don't Override"},
    {"altostratus", "Altostratus"},
    {"cirrus", "Cirrus"},
    {"cirrocumulus", "Cirrocumulus"},
    {"clear 01", "Clear 01"},
    {"cloudy 01", "Cloudy 01"},
    {"cloudy 02", "Cloudy 02"},
    {"contrails", "Contrails"},
    {"horizon", "Horizon"},
    {"horizonband1", "Horizon Band 1"},
    {"horizonband2", "Horizon Band 2"},
    {"horizonband3", "Horizon Band 3"},
    {"nimbus", "Nimbus"},
    {"puffs", "Puffs"},
    {"rain", "Rain"},
    {"shower", "Shower"},
    {"snowy 01", "Snowy 01"},
    {"stormy 01", "Stormy 01"},
    {"stratocumulus", "Stratocumulus"},
    {"stripey", "Stripey"},
    {"wispy", "Wispy"},
}

local cloud_options = {}
for i = 1, #CLOUD_SET do
    cloud_options[i] = {i, CLOUD_SET[i][2]}
end

menu.list_action(weather_root, "Clouds", {"mptclouds"}, "Fires Stand's clouds command.", cloud_options, function(value)
    local row = CLOUD_SET[value]
    if row then
        stand_run("clouds " .. row[1])
        util.toast("Clouds: " .. row[2])
    end
end)

menu.toggle(weather_root, "Disable skybox", {"mptnosky"}, "Fires nosky.", function(on, click_type)
    if user_click(click_type) then
        stand_run(on and "nosky on" or "nosky off")
    end
end, false)

menu.list_select(weather_root, "Blackout", {"mptblackout"}, "Fires blackout. Pitch black preset uses Enabled.", {
    {1, "Disabled"},
    {2, "Enabled"},
    {3, "Enabled, Including Vehicles"},
}, 1, function(value, _name, _prev, click_type)
    if not user_click(click_type) then
        return
    end
    if value == 1 then
        stand_run("blackout off")
    elseif value == 2 then
        stand_run("blackout on")
    else
        stand_run("blackout vehicles")
    end
end)
-- END WORLD

--==============================================================================
-- GRAPHIC FIX
--==============================================================================

local gfx = {
    enabled = false,
    look = 1,
    lod = 1.00,
    sharp_distance = false,
    better_shadows = false,
    hd_models = false,
}

local GFX_LOOK_SHADER = {
    "off",
    "intnofog",
    "ng_filmic01",
}

local function gfx_apply_look(name)
    stand_run("shader " .. name)
end

local function gfx_apply_lod(scale)
    stand_run("lodscale " .. string.format("%.2f", scale))
end

local function gfx_restore()
    gfx_apply_look("off")
    gfx_apply_lod(1.00)
    GRAPHICS.CLEAR_TIMECYCLE_MODIFIER()
    GRAPHICS.CASCADE_SHADOWS_CLEAR_SHADOW_SAMPLE_TYPE()
    STREAMING.SET_REDUCE_PED_MODEL_BUDGET(true)
    STREAMING.SET_REDUCE_VEHICLE_MODEL_BUDGET(true)
end

-- BEGIN GRAPHIC FIX
local gfx_root = menu.list(root, "Graphic FIX", {"graphicfix"}, "Renderer tweaks. All options start off.")

menu.toggle(gfx_root, "Enable", {"graphicfixon"}, "Master switch. Turn this on first, then turn on the options you want.", function(on)
    gfx.enabled = on
    if on then
        gfx_apply_look(GFX_LOOK_SHADER[gfx.look])
        gfx_apply_lod(gfx.lod)
        if gfx.hd_models then
            STREAMING.SET_REDUCE_PED_MODEL_BUDGET(false)
            STREAMING.SET_REDUCE_VEHICLE_MODEL_BUDGET(false)
        end
    else
        gfx_restore()
    end
end, false)

menu.list_select(gfx_root, "Look", {"graphicfixstyle"}, "Off is default. Clear sky is intnofog looks the best. Filmic is a strong Rockstar filter.", {
    {1, "Off"},
    {2, "Clear sky"},
    {3, "Filmic"},
}, 1, function(value)
    gfx.look = value
    if gfx.enabled then
        gfx_apply_look(GFX_LOOK_SHADER[value])
    end
end)

menu.slider(gfx_root, "LOD", {"graphicfixlod"}, "Real LOD scale. 100 is vanilla. 200-300 is the usual upgrade. Above 200 already costs FPS on a lot of PCs. 1000 is extreme.", 100, 1000, 100, 25, function(value)
    gfx.lod = value / 100.0
    if gfx.enabled then
        gfx_apply_lod(gfx.lod)
    end
end)

menu.toggle(gfx_root, "Sharper distance", {"graphicfixsharp"}, "Cuts the game's distance blur so far trees and buildings stay crisp.", function(on)
    gfx.sharp_distance = on
end, false)

menu.toggle(gfx_root, "Better shadows", {"graphicfixshadows"}, "Longer, cleaner cascade shadows. Costs FPS at night and in the city.", function(on)
    gfx.better_shadows = on
    if not on then
        GRAPHICS.CASCADE_SHADOWS_CLEAR_SHADOW_SAMPLE_TYPE()
    end
end, false)

menu.toggle(gfx_root, "Keep HD models loaded", {"graphicfixhd"}, "Stops the game from swapping people and cars to low-detail models as soon.", function(on)
    gfx.hd_models = on
    if gfx.enabled then
        STREAMING.SET_REDUCE_PED_MODEL_BUDGET(not on)
        STREAMING.SET_REDUCE_VEHICLE_MODEL_BUDGET(not on)
    end
end, false)

menu.action(gfx_root, "Turn off Lance God graphics", {"graphicfixfixlance"}, "Sets shader off and lodscale 1, then re-applies this tree if Enable is on.", function()
    stand_run("shader off")
    stand_run("lodscale 1.00")
    if gfx.enabled then
        gfx_apply_look(GFX_LOOK_SHADER[gfx.look])
        gfx_apply_lod(gfx.lod)
    end
    util.toast("Lance God graphics cleared")
end)
-- END GRAPHIC FIX

util.create_tick_handler(function()
    if not gfx.enabled then
        return true
    end
    STREAMING.OVERRIDE_LODSCALE_THIS_FRAME(gfx.lod)
    if gfx.sharp_distance then
        GRAPHICS.SET_DISTANCE_BLUR_STRENGTH_OVERRIDE(0.0)
    end
    if gfx.better_shadows then
        GRAPHICS.CASCADE_SHADOWS_ENABLE_ENTITY_TRACKER(true)
        GRAPHICS.CASCADE_SHADOWS_SET_CASCADE_BOUNDS_SCALE(1.15)
        GRAPHICS.CASCADE_SHADOWS_SET_ENTITY_TRACKER_SCALE(10.0)
        GRAPHICS.CASCADE_SHADOWS_SET_AIRCRAFT_MODE(true)
        GRAPHICS.CASCADE_SHADOWS_SET_DYNAMIC_DEPTH_MODE(true)
        GRAPHICS.CASCADE_SHADOWS_SET_DYNAMIC_DEPTH_VALUE(5.0)
        GRAPHICS.CASCADE_SHADOWS_SET_SHADOW_SAMPLE_TYPE("dither_4x4")
    end
    if gfx.hd_models then
        STREAMING.SET_REDUCE_PED_MODEL_BUDGET(false)
        STREAMING.SET_REDUCE_VEHICLE_MODEL_BUDGET(false)
    end
    return true
end)

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
    gfx_restore()
end)

build_spot_pool()
build_drift_catalog()
fill_drift_menu()

if not SCRIPT_SILENT_START then
    util.toast("Multi Purpose Tool loaded")
end
