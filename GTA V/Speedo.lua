-- Speedo.lua
-- Story-mode Stand script. Every native here is from natives-1663599433
-- and every Stand call is from the Stand Lua API.
--
-- MPH uses ENTITY.GET_ENTITY_SPEED (m/s) * 2.236936, as written in that
-- native's comment. Gear uses entities.get_current_gear. Fill uses
-- entities.get_rpm. Arc is drawn with directx.draw_triangle.
--
-- SET_TEXT_EDGE is a nullsub in this native dump, so the black border is
-- HUD.SET_TEXT_OUTLINE only.

util.require_natives(1663599433)

--==============================================================================
-- STATE
--==============================================================================

local root = menu.my_root()

-- X/Y are the centre of the gauge. HUD is 1920x1080, so a visual circle
-- must scale X by 9/16 or the ring looks like an oval.
local ASPECT = 1080 / 1920
local SWEEP = math.rad(270)
local START_A = math.rad(225)
local RED_FROM = 0.82

local cfg = {
    enabled = true,
    x = 880,
    y = 780,
    scale = 70,
    font = 7,
}

local shown_rpm = 0.0

local COL_TRACK = {r = 1, g = 1, b = 1, a = 0.12}
local COL_TRACK_RED = {r = 0.75, g = 0.08, b = 0.08, a = 0.28}
local COL_FILL = {r = 1, g = 1, b = 1, a = 0.92}
local COL_FILL_RED = {r = 1, g = 0.16, b = 0.14, a = 1.0}
local COL_GLOW = {r = 1, g = 1, b = 1, a = 0.08}

--==============================================================================
-- HELPERS
--==============================================================================

local function exists(ent)
    return ent ~= nil and ent ~= 0 and ent ~= INVALID_GUID and ENTITY.DOES_ENTITY_EXIST(ent)
end

local function current_vehicle()
    local ped = players.user_ped()
    if not PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
        return 0, 0
    end
    local veh = entities.get_user_vehicle_as_handle(false)
    if not exists(veh) then
        return 0, 0
    end
    local addr = entities.handle_to_pointer(veh)
    if addr == 0 then
        return 0, 0
    end
    return veh, addr
end

local function gear_label(gear)
    if gear == 0 then
        return "R"
    end
    return tostring(gear)
end

local function clamp01(n)
    if n < 0 then
        return 0
    end
    if n > 1 then
        return 1
    end
    return n
end

local function arc_point(cx, cy, radius, angle)
    return cx + math.cos(angle) * radius * ASPECT, cy - math.sin(angle) * radius
end

local function angle_at(t)
    return START_A - (SWEEP * t)
end

local function draw_thick_arc(cx, cy, r_in, r_out, t0, t1, colour)
    if t1 <= t0 then
        return
    end
    local steps = math.max(6, math.floor((t1 - t0) * 64))
    for i = 0, steps - 1 do
        local a = angle_at(t0 + (t1 - t0) * (i / steps))
        local b = angle_at(t0 + (t1 - t0) * ((i + 1) / steps))
        local x1, y1 = arc_point(cx, cy, r_out, a)
        local x2, y2 = arc_point(cx, cy, r_out, b)
        local x3, y3 = arc_point(cx, cy, r_in, b)
        local x4, y4 = arc_point(cx, cy, r_in, a)
        directx.draw_triangle(x1, y1, x2, y2, x3, y3, colour)
        directx.draw_triangle(x1, y1, x3, y3, x4, y4, colour)
    end
end

local function draw_gta_text(text, x, y, scale, font)
    HUD.SET_TEXT_FONT(font)
    HUD.SET_TEXT_SCALE(scale, scale)
    HUD.SET_TEXT_COLOUR(255, 255, 255, 255)
    HUD.SET_TEXT_OUTLINE()
    HUD.SET_TEXT_CENTRE(true)
    HUD.SET_TEXT_JUSTIFICATION(0)
    util.BEGIN_TEXT_COMMAND_DISPLAY_TEXT(text)
    HUD.END_TEXT_COMMAND_DISPLAY_TEXT(x, y, 0)
end

local function draw_hud()
    local veh, addr = current_vehicle()
    if veh == 0 then
        shown_rpm = 0.0
        return
    end

    local cx = cfg.x / 1000.0
    local cy = cfg.y / 1000.0
    local size = cfg.scale / 100.0
    local radius = 0.050 + (size * 0.055)
    local font = cfg.font
    local mph = math.floor((ENTITY.GET_ENTITY_SPEED(veh) * 2.236936) + 0.5)
    local gear = entities.get_current_gear(addr)
    local rpm = clamp01(entities.get_rpm(addr))
    shown_rpm = shown_rpm + ((rpm - shown_rpm) * 0.32)

    local r_out = radius
    local r_in = radius * 0.78
    local r_glow = radius * 1.06

    draw_thick_arc(cx, cy, r_in, r_glow, 0.0, 1.0, COL_GLOW)
    draw_thick_arc(cx, cy, r_in, r_out, 0.0, RED_FROM, COL_TRACK)
    draw_thick_arc(cx, cy, r_in, r_out, RED_FROM, 1.0, COL_TRACK_RED)

    if shown_rpm > 0.004 then
        local fill = shown_rpm
        if fill > RED_FROM then
            draw_thick_arc(cx, cy, r_in, r_out, 0.0, RED_FROM, COL_FILL)
            draw_thick_arc(cx, cy, r_in, r_out, RED_FROM, fill, COL_FILL_RED)
        else
            draw_thick_arc(cx, cy, r_in, r_out, 0.0, fill, COL_FILL)
        end
    end

    local text_scale = 0.38 + (size * 0.22)
    local line_h = HUD.GET_RENDERED_CHARACTER_HEIGHT(text_scale, font)
    draw_gta_text(tostring(mph), cx, cy - (line_h * 0.85), text_scale, font)
    draw_gta_text(gear_label(gear), cx, cy + (line_h * 0.25), text_scale * 0.72, font)
end

--==============================================================================
-- MENU
--==============================================================================

menu.toggle(root, "Enable", {"speedo"}, "3/4 RPM ring. MPH and gear sit in the middle. Fill is entities.get_rpm.", function(on)
    cfg.enabled = on
end, true)

menu.divider(root, "Position")

menu.slider(root, "X", {"speedox"}, "Centre of the gauge. 1000 is the right edge.", 0, 1000, cfg.x, 5, function(value)
    cfg.x = value
end)

menu.slider(root, "Y", {"speedoy"}, "Centre of the gauge. 1000 is the bottom edge.", 0, 1000, cfg.y, 5, function(value)
    cfg.y = value
end)

menu.divider(root, "Look")

menu.slider(root, "Scale", {"speedoscale"}, "Ring size and text size together.", 20, 120, cfg.scale, 5, function(value)
    cfg.scale = value
end)

menu.slider(root, "Font", {"speedofont"}, "SET_TEXT_FONT id, 0 to 7. 7 is the thick GTA number font.", 0, 7, cfg.font, 1, function(value)
    cfg.font = value
end)

--==============================================================================
-- TICK
--==============================================================================

util.create_tick_handler(function()
    if cfg.enabled then
        draw_hud()
    end
    return true
end)

if not SCRIPT_SILENT_START then
    util.toast("Speedo loaded")
end
