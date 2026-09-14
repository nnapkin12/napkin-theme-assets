-- GraphicFIX.lua
-- Story-mode Stand script. Natives are from natives-1663599433.
-- Everything starts off default.
-- clear sky looks best for graphics, with all checkboxes applied. LOD anything above 200 does alot of preformance damage atleast for my specs.

util.require_natives(1663599433)

local root = menu.list(menu.my_root(), "Graphic FIX", {"graphicfix"}, "Game renderer tweaks. All options start off so they apply when you turn them on. Keep ReShade on. Turn off LanceScript God graphics.")

local cfg = {
    enabled = false,
    look = 1,
    lod = 1.00,
    sharp_distance = false,
    better_shadows = false,
    hd_models = false,
}

local LOOKS = {
    "Off",
    "Clear sky",
    "Filmic",
}

local LOOK_SHADER = {
    "off",
    "intnofog",
    "ng_filmic01",
}

local applied_look = nil

local function apply_look(name)
    menu.trigger_commands("shader " .. name)
    applied_look = name
end

local function apply_lod(scale)
    menu.trigger_commands("lodscale " .. string.format("%.2f", scale))
end

local function restore()
    apply_look("off")
    apply_lod(1.00)
    GRAPHICS.CLEAR_TIMECYCLE_MODIFIER()
    GRAPHICS.CASCADE_SHADOWS_CLEAR_SHADOW_SAMPLE_TYPE()
    STREAMING.SET_REDUCE_PED_MODEL_BUDGET(true)
    STREAMING.SET_REDUCE_VEHICLE_MODEL_BUDGET(true)
end

menu.toggle(root, "Enable", {"graphicfixon"}, "Master switch. Turn this on first, then turn on the options you want.", function(on)
    cfg.enabled = on
    if on then
        apply_look(LOOK_SHADER[cfg.look])
        apply_lod(cfg.lod)
        if cfg.hd_models then
            STREAMING.SET_REDUCE_PED_MODEL_BUDGET(false)
            STREAMING.SET_REDUCE_VEHICLE_MODEL_BUDGET(false)
        end
    else
        restore()
    end
end, false)

menu.list_select(root, "Look", {"graphicfixstyle"}, "Off is default. Clear sky is Lance intnofog. Filmic is a strong Rockstar filter (can look like a full-screen grade).", LOOKS, 1, function(index)
    cfg.look = index
    if cfg.enabled then
        apply_look(LOOK_SHADER[index])
    end
end)

menu.slider(root, "LOD", {"graphicfixlod"}, "This is real LOD scale. 100 is vanilla. 200-300 is the usual upgrade. 1000 is extreme and will hurt FPS.", 100, 1000, 100, 25, function(value)
    cfg.lod = value / 100.0
    if cfg.enabled then
        apply_lod(cfg.lod)
    end
end)

menu.toggle(root, "Sharper distance", {"graphicfixsharp"}, "Cuts the game's distance blur so far trees and buildings stay crisp.", function(on)
    cfg.sharp_distance = on
end, false)

menu.toggle(root, "Better shadows", {"graphicfixshadows"}, "Longer, cleaner cascade shadows. Costs FPS at night and in the city.", function(on)
    cfg.better_shadows = on
    if not on then
        GRAPHICS.CASCADE_SHADOWS_CLEAR_SHADOW_SAMPLE_TYPE()
    end
end, false)

menu.toggle(root, "Keep HD models loaded", {"graphicfixhd"}, "Stops the game from swapping people and cars to low-detail models as soon.", function(on)
    cfg.hd_models = on
    if cfg.enabled then
        STREAMING.SET_REDUCE_PED_MODEL_BUDGET(not on)
        STREAMING.SET_REDUCE_VEHICLE_MODEL_BUDGET(not on)
    end
end, false)

menu.action(root, "Turn off Lance God graphics", {"graphicfixfixlance"}, "Sets shader off and lodscale 1, then re-applies this script if Enable is on.", function()
    menu.trigger_commands("shader off")
    menu.trigger_commands("lodscale 1.00")
    applied_look = nil
    if cfg.enabled then
        apply_look(LOOK_SHADER[cfg.look])
        apply_lod(cfg.lod)
    end
    util.toast("Lance God graphics cleared")
end)

util.create_tick_handler(function()
    if not cfg.enabled then
        return true
    end

    STREAMING.OVERRIDE_LODSCALE_THIS_FRAME(cfg.lod)

    if cfg.sharp_distance then
        GRAPHICS.SET_DISTANCE_BLUR_STRENGTH_OVERRIDE(0.0)
    end

    if cfg.better_shadows then
        GRAPHICS.CASCADE_SHADOWS_ENABLE_ENTITY_TRACKER(true)
        GRAPHICS.CASCADE_SHADOWS_SET_CASCADE_BOUNDS_SCALE(1.15)
        GRAPHICS.CASCADE_SHADOWS_SET_ENTITY_TRACKER_SCALE(10.0)
        GRAPHICS.CASCADE_SHADOWS_SET_AIRCRAFT_MODE(true)
        GRAPHICS.CASCADE_SHADOWS_SET_DYNAMIC_DEPTH_MODE(true)
        GRAPHICS.CASCADE_SHADOWS_SET_DYNAMIC_DEPTH_VALUE(5.0)
        GRAPHICS.CASCADE_SHADOWS_SET_SHADOW_SAMPLE_TYPE("dither_4x4")
    end

    if cfg.hd_models then
        STREAMING.SET_REDUCE_PED_MODEL_BUDGET(false)
        STREAMING.SET_REDUCE_VEHICLE_MODEL_BUDGET(false)
    end

    return true
end)

util.on_pre_stop(function()
    restore()
end)

if not SCRIPT_SILENT_START then
    util.toast("Graphic FIX loaded — all effects off")
end
