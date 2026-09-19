-- Manual.lua
-- Story-mode Stand script. Every native here is from natives-1663599433
-- and every Stand call is from the Stand Lua API.
--
-- There is no SET_VEHICLE_CURRENT_GEAR in natives-1663599433.
-- Hold: snap current+next only if current actually left the held gear.
-- Do not rewrite next_gear every tick. Do not pin RPM; that made every
-- upshift play the same tone.
-- Do not run LanceScript's Manual Transmission at the same time.
--
-- Stand command hotkeys do not take controller buttons (B is cancel).
-- Stick clicks are read with PAD on PLAYER_CONTROL (padIndex 0).
-- Control ids come from the table linked on DISABLE_CONTROL_ACTION
-- (pastebin.com/JEkxhZ7R / FiveM controls):
--   86 = INPUT_VEH_HORN        = L3
--   79 = INPUT_VEH_LOOK_BEHIND = R3

util.require_natives(1663599433)

--==============================================================================
-- STATE
--==============================================================================

local root = menu.my_root()

-- 86 and 79 are listed in the DISABLE_CONTROL_ACTION native comment.
local CONTROL_L3 = 86
local CONTROL_R3 = 79

local cfg = {
    enabled = true,
    allow_reverse = true,
    max_gear = 8,
    pad_sticks = true,
    swap_sticks = false,
}

-- Last gear we asked the car to hold. Nil when you are not in a road vehicle.
local held = nil

--==============================================================================
-- HELPERS
--==============================================================================

local function exists(ent)
    return ent ~= nil and ent ~= 0 and ent ~= INVALID_GUID and ENTITY.DOES_ENTITY_EXIST(ent)
end

local function is_road_vehicle(veh)
    local hash = ENTITY.GET_ENTITY_MODEL(veh)
    return VEHICLE.IS_THIS_MODEL_A_CAR(hash)
        or VEHICLE.IS_THIS_MODEL_A_BIKE(hash)
        or VEHICLE.IS_THIS_MODEL_A_QUADBIKE(hash)
end

local function current_vehicle()
    local ped = players.user_ped()
    if not PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
        return 0, 0
    end
    local veh = entities.get_user_vehicle_as_handle(false)
    if not exists(veh) or not is_road_vehicle(veh) then
        return 0, 0
    end
    local addr = entities.handle_to_pointer(veh)
    if addr == 0 then
        return 0, 0
    end
    return veh, addr
end

local function engage_gear(addr, gear)
    held = gear
    entities.set_current_gear(addr, gear)
    entities.set_next_gear(addr, gear)
end

local function hold_gear(addr, gear)
    held = gear
    if entities.get_current_gear(addr) == gear then
        return
    end
    local rpm = entities.get_rpm(addr)
    entities.set_current_gear(addr, gear)
    entities.set_next_gear(addr, gear)
    entities.set_rpm(addr, rpm)
end

-- GET_ENTITY_SPEED_VECTOR(..., true) comment: +y is forward, -y is reverse.
-- Block reverse while still rolling forward so it does not slam into R.
local function can_go_reverse(veh)
    if not cfg.allow_reverse then
        return false
    end
    if ENTITY.GET_ENTITY_SPEED(veh) > 3.0 then
        return false
    end
    local vel = ENTITY.GET_ENTITY_SPEED_VECTOR(veh, true)
    return vel.y <= 1.0
end

local function clamp_range(gear)
    if gear < 0 then
        gear = 0
    end
    if gear > cfg.max_gear then
        gear = cfg.max_gear
    end
    if gear == 0 and not cfg.allow_reverse then
        gear = 1
    end
    return gear
end

local function shift(dir)
    local veh, addr = current_vehicle()
    if addr == 0 then
        return
    end
    local cur = held
    if cur == nil then
        cur = entities.get_current_gear(addr)
    end
    local nxt = clamp_range(cur + dir)
    if nxt == 0 and not can_go_reverse(veh) then
        nxt = 1
    end
    engage_gear(addr, nxt)
end

-- DISABLE_CONTROL_ACTION must be called every frame. After that, the press
-- only shows up on IS_DISABLED_CONTROL_JUST_PRESSED.
local function stick_clicked(control)
    PAD.DISABLE_CONTROL_ACTION(0, control, true)
    return PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, control)
end

local function poll_controller()
    if not cfg.pad_sticks then
        return
    end
    if menu.is_open() then
        return
    end
    local up = CONTROL_L3
    local down = CONTROL_R3
    if cfg.swap_sticks then
        up = CONTROL_R3
        down = CONTROL_L3
    end
    local pressed_up = stick_clicked(up)
    local pressed_down = stick_clicked(down)
    if pressed_up and not pressed_down then
        shift(1)
    elseif pressed_down and not pressed_up then
        shift(-1)
    end
end

--==============================================================================
-- MENU
--==============================================================================

local gear_up = menu.action(root, "Gear up", {"gearup"}, "Test click, or command box: gearup. Controller uses L3 while this script is on. Stand Hotkey does not accept controller buttons.", function()
    shift(1)
end)
menu.set_name_for_config(gear_up, "manual_gear_up")

local gear_down = menu.action(root, "Gear down", {"geardown"}, "Test click, or command box: geardown. Controller uses R3 while this script is on. Stand Hotkey does not accept controller buttons.", function()
    shift(-1)
end)
menu.set_name_for_config(gear_down, "manual_gear_down")

menu.divider(root, "Manual")

menu.toggle(root, "Enable", {"manualon"}, "Holds the current gear so the auto box cannot shift. Use Gear up / Gear down.", function(on)
    cfg.enabled = on
    if not on then
        held = nil
    end
end, true)

menu.toggle(root, "Allow reverse", {"manualrev"}, "Lets Gear down reach R when you are almost stopped. Reverse is gear 0.", function(on)
    cfg.allow_reverse = on
end, true)

menu.slider(root, "Max gear", {"manualmax"}, "There is no documented high-gear getter. Raise this for 8-speed cars. Lower it if a car accepts a fake extra gear.", 1, 8, cfg.max_gear, 1, function(value)
    cfg.max_gear = value
    if held ~= nil and held > value then
        held = value
    end
end)

menu.divider(root, "Controller")

menu.toggle(root, "L3 / R3 shift", {"manualpad"}, "L3 upshifts, R3 downshifts. Those clicks will not honk or look behind while this is on.", function(on)
    cfg.pad_sticks = on
end, true)

menu.toggle(root, "Swap sticks", {"manualswap"}, "R3 up, L3 down.", function(on)
    cfg.swap_sticks = on
end, false)

--==============================================================================
-- TICK
--==============================================================================

util.create_tick_handler(function()
    if not cfg.enabled then
        return true
    end
    local _, addr = current_vehicle()
    if addr == 0 then
        held = nil
        return true
    end
    if held == nil then
        held = clamp_range(entities.get_current_gear(addr))
    else
        held = clamp_range(held)
    end
    hold_gear(addr, held)
    poll_controller()
    return true
end)

if not SCRIPT_SILENT_START then
    util.toast("Manual loaded — L3 up, R3 down")
end
