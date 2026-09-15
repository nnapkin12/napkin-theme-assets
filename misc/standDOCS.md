Stand Lua API Documentation
Table of Contents

    About Developing Stand Luas
    Types
    Global Variables
    Menu Functions
    Players Functions
    Entities Functions
    Chat Functions
    DirectX Functions
    Util Functions
    V3 Functions
    Lang Functions
    Filesystem Functions
    Async HTTP Functions
    Memory Functions
    Profiling Functions

§ About Developing Stand Luas
Game Natives

This Stand Lua API that is described in this document is developed with the game's own scripting features in mind, which are at your fingertips with just a call to util.require_natives.

You can find a nice viewer for the game's native functions at nativedb.dotindustries.dev, which is powered by alloc8or's nativedb data.
Runtime Settings

We highly recommend using Stand > Lua Scripts > Settings > Presets > Developer and/or reviewing all the Lua runtime settings available to you, as they can help you write more polished and less buggy code.
Language

Stand uses Pluto which adds new features, improvements, and optimisations while being compatible with existing Lua code.

If nothing else, you should at least get Pluto Syntax Highlighting so you can properly view .pluto files.
Bindings

Stand also provides Soup Lua Bindings.
Examples

You can get our example scripts via the repository: Stand > Lua Scripts > Repository > Example Scripts
§ Types
Vector3

A v3 instance or a table with x, y & z fields of type number.
Colour

A table with r, g, b & a fields of type number with values between 0.0 and 1.0.

Functions that take this as a parameter also support 4 floats instead of it, which is more performant.
Label

A string or the return value of lang.register.
CommandAny

Not an actual type, but the base for CommandRef and CommandUniqPtr, which both support the following operations:

    .menu_name — shorthand for menu.get_menu_name/menu.set_menu_name
    .command_names — shorthand for menu.get_command_names/menu.set_command_names
    .help_text — shorthand for menu.get_help_text/menu.set_help_text
    .name_for_config — shorthand for menu.get_name_for_config/menu.set_name_for_config
    :getPhysical() — shorthand for menu.get_physical
    :equals(CommandAny) — returns a boolean that indicates if this CommandAny refers to the same command as another CommandAny instance

CommandRef

A reference to a command in Stand. Supports all of CommandAny's operations as well as:

    :isValid() — shorthand for menu.is_ref_valid
    :refByRelPath() — shorthand for menu.ref_by_rel_path
    :delete() — shorthand for menu.delete
    :defaultAndDelete() — shorthand for menu.default_and_delete
    :detach() — shorthand for menu.detach
    :attach(...) — shorthand for menu.attach
    :attachAfter(...) — shorthand for menu.attach_after
    :attachBefore(...) — shorthand for menu.attach_before
    :focus() — shorthand for menu.focus
    :isFocused() — shorthand for menu.is_focused
    :getApplicablePlayers() — shorthand for menu.get_applicable_players
    :getParent() — shorthand for menu.get_parent
    :getType() — shorthand for menu.get_type
    :getChildren() — shorthand for menu.get_children
    :getFocus() — shorthand for menu.list_get_focus
    :getFocusPhysical() — shorthand for menu.list_get_focus_physical
    :trigger() — shorthand for menu.trigger_command
    :onTickInViewport(...) — shorthand for menu.on_tick_in_viewport
    :onFocus(...) — shorthand for menu.on_focus
    :onBlur(...) — shorthand for menu.on_blur
    :removeHandler(...) — shorthand for menu.remove_handler
    :getState() — shorthand for menu.get_state
    :getDefaultState() — shorthand for menu.get_default_state
    :setState(...) — shorthand for menu.set_state
    :applyDefaultState() — shorthand for menu.apply_default_state
    :recursivelyApplyDefaultState() — shorthand for menu.recursively_apply_default_state
    :setListActionOptions(...) — shorthand for menu.set_list_action_options
    :setTextsliderOptions(...) — shorthand for menu.set_textslider_options
    :addValueReplacement(...) — shorthand for menu.add_value_replacement
    :setTemporary() — shorthand for menu.set_temporary
    .visible — shorthand for menu.get_visible/menu.set_visible
    .value — shorthand for menu.get_value/menu.set_value
    .min_value — shorthand for menu.get_min_value/menu.set_min_value
    .max_value — shorthand for menu.get_max_value/menu.set_max_value
    .step_size — shorthand for menu.get_step_size/menu.set_step_size
    .precision — shorthand for menu.get_precision/menu.set_precision
    .indicator_type — shorthand for menu.get_indicator_type/menu.set_indicator_type
    .target — shorthand for menu.get_target/menu.set_target
    :list(...) — shorthand for menu.list
    :action(...) — shorthand for menu.action
    :toggle(...) — shorthand for menu.toggle
    :toggle_loop(...) — shorthand for menu.toggle_loop
    :slider(...) — shorthand for menu.slider
    :slider_float(...) — shorthand for menu.slider_float
    :click_slider(...) — shorthand for menu.click_slider
    :click_slider_float(...) — shorthand for menu.click_slider_float
    :list_select(...) — shorthand for menu.list_select
    :list_action(...) — shorthand for menu.list_action
    :text_input(...) — shorthand for menu.text_input
    :colour(...) — shorthand for menu.colour
    :rainbow(...) — shorthand for menu.rainbow
    :inline_rainbow(...) — shorthand for menu.inline_rainbow
    :divider(...) — shorthand for menu.divider
    :readonly(...) — shorthand for menu.readonly
    :readonly_name(...) — shorthand for menu.readonly_name
    :hyperlink(...) — shorthand for menu.hyperlink
    :textslider(...) — shorthand for menu.textslider
    :textslider_stateful(...) — shorthand for menu.textslider_stateful
    :player_list_players_shortcut(...) — shorthand for menu.player_list_players_shortcut
    :link(...) — shorthand for menu.link

CommandUniqPtr

Holds a detached command. Detached commands don't exist in the menu in any way, and are not usable via the command box.

Supports all of CommandAny's operations as well as:

    :ref() — returns a CommandRef to the command

§ Global Variables
SCRIPT_NAME

A string containing the name of your script (this excludes .lua).
SCRIPT_FILENAME

A string containing the name of your script file.
SCRIPT_RELPATH

A string containing the path to your script file from the Lua Scripts folder.
SCRIPT_MANUAL_START

A bool indicating if your script was started in direct response to a user action.
SCRIPT_SILENT_START

A bool indicating if a silent start of your script is desired.
§ Menu Functions
CommandRef menu.my_root()

Returns a reference to the list that your script gets when it is started.
CommandRef menu.player_root(int player_id)

Returns a reference to the list that the given player owns. Note that the returned reference may be invalid even if called in an on_join handler.
CommandRef menu.shadow_root()

Using return value of this function to create a command produces a detached commmand (CommandUniqPtr) instead of a CommandRef.
CommandRef menu.ref_by_path(string path, ?int tree_version = nil)

Returns a reference to any command in Stand using a path such as Self>Immortality. Note that the path has to be in English (UK) and using the no-space greater-than separator.

Providing a tree version is optional but highly recommended for future-proofing. You can find this in any tree config file, such as your profile.
CommandRef menu.ref_by_rel_path(int base, string path)
CommandRef menu.ref_by_command_name(string command_name)

Note that this should not be used every tick to avoid low performance.
CommandRef|CommandUniqPtr menu.list(CommandRef parent, Label menu_name, table<any, string> command_names = {}, Label help_text = "", ?function on_click = nil, ?function on_back = nil, ?function on_active_list_update = nil)
CommandRef|CommandUniqPtr menu.action(CommandRef parent, Label menu_name, table<any, string> command_names, Label help_text, function on_click, ?function on_command = nil, ?string syntax = nil, int perm = COMMANDPERM_USERONLY)

perm may be any of:

    COMMANDPERM_FRIENDLY
    COMMANDPERM_NEUTRAL
    COMMANDPERM_SPAWN
    COMMANDPERM_RUDE
    COMMANDPERM_AGGRESSIVE
    COMMANDPERM_TOXIC
    COMMANDPERM_USERONLY

Your on_click function will be called with click_type and effective_issuer. The click type could be any of:

    CLICK_MENU
    CLICK_COMMAND
    CLICK_HOTKEY
    CLICK_BULK
    CLICK_AUTO
    CLICK_SCRIPTED
    CLICK_WEB
    CLICK_WEB_COMMAND
    CLICK_CHAT_ALL
    CLICK_CHAT_TEAM

And could match any or neither of these bitflags:

    CLICK_FLAG_AUTO
    CLICK_FLAG_CHAT
    CLICK_FLAG_WEB

Your on_command function will be called with the provided arguments, click_type, and effective_issuer. If on_command is not provided, commands will be redirected to on_click.
CommandRef|CommandUniqPtr menu.toggle(CommandRef parent, Label menu_name, table<any, string> command_names, Label help_text, function on_change, bool default_on = false, int perm = COMMANDPERM_USERONLY)

Your on_change function will be called with on and click_type.
CommandRef|CommandUniqPtr menu.toggle_loop(CommandRef parent, Label menu_name, table<any, string> command_names, Label help_text, function on_tick, ?function on_stop = nil, int perm = COMMANDPERM_USERONLY)

Your on_tick function will be called every tick that the toggle is checked; you should not call util.yield in this context.
CommandRef|CommandUniqPtr menu.slider(CommandRef parent, Label menu_name, table<any, string> command_names, Label help_text, int min_value, int max_value, int default_value, int step_size, function on_change)
CommandRef|CommandUniqPtr menu.slider_float(CommandRef parent, Label menu_name, table<any, string> command_names, Label help_text, int min_value, int max_value, int default_value, int step_size, function on_change)

Your on_change function will be called with value, prev_value and click_type.

Note that the float variant is practically identical except the last 2 digits are indicated to be numbers after the decimal point. The precision can be changed with menu.set_precision.
CommandRef|CommandUniqPtr menu.click_slider(CommandRef parent, Label menu_name, table<any, string> command_names, Label help_text, int min_value, int max_value, int default_value, int step_size, function on_click)
CommandRef|CommandUniqPtr menu.click_slider_float(CommandRef parent, Label menu_name, table<any, string> command_names, Label help_text, int min_value, int max_value, int default_value, int step_size, function on_click)

Your on_click function will be called with value and click_type.

Note that the float variant is practically identical except the last 2 digits are indicated to be numbers after the decimal point. The precision can be changed with menu.set_precision.
CommandRef|CommandUniqPtr menu.list_select(CommandRef parent, Label menu_name, table<any, string> command_names, Label help_text, table<int, table> options, int default_value, function on_change)

options must be table of list action item data. List action item data is an index-based table that contains value, menu_name, command_names, help_text, and category. Value and menu_name are mandatory.

Your on_change function will be called with the option's value, the option's menu_name, the previous option's value, and click_type as parameters.

menu.my_root():list_select("list_select", {}, "", {
    {1, "Uno"},
    {2, "Dos"},
    {3, "Tres"},
}, 1, function(value, menu_name, prev_value, click_type)
    util.toast("Value changed to " .. lang.get_localised(menu_name) .. " (" .. value .. ")")
end)

CommandRef|CommandUniqPtr menu.list_action(CommandRef parent, Label menu_name, table<any, string> command_names, Label help_text, table<int, table> options, function on_item_click)

options must be table of list action item data. List action item data is an index-based table that contains value, menu_name, command_names, help_text, and category. Value and menu_name are mandatory.

Your on_item_click function will be called with the option's value, the option's menu_name, and click_type as parameters.

menu.my_root():list_action("list_action", {}, "", {
    {1, "Uno"},
    {2, "Dos"},
    {3, "Tres"},
}, function(value, menu_name, click_type)
    util.toast("Clicked on " .. lang.get_localised(menu_name) .. " (" .. value .. ")")
end)

CommandRef|CommandUniqPtr menu.text_input(CommandRef parent, Label menu_name, table<any, string> command_names, Label help_text, function on_change, string default_value = "")

Your on_change function will be called with the string and click type.
CommandRef|CommandUniqPtr menu.colour(CommandRef parent, Label menu_name, table<any, string> command_names, Label help_text, Colour default, bool transparency, function on_change)
CommandRef|CommandUniqPtr menu.colour(CommandRef parent, Label menu_name, table<any, string> command_names, Label help_text, number default_r, number default_g, number default_b, number default_a, bool transparency, function on_change)

Your on_change function will be called with Colour and click type.

menu.my_root():colour(lang.find_builtin("Colour"), {}, "", 1.0, 0.0, 1.0, 1.0, false, function(colour, click_type)
    -- ...
end)

CommandRef|CommandUniqPtr menu.rainbow(CommandRef colour_command)

Creates a rainbow slider for the given colour command. This should be called right after creating the colour command.
CommandRef|CommandUniqPtr menu.inline_rainbow(CommandRef colour_command)

Creates a rainbow slider inside of the given colour command. This should be called right after creating the colour command.
CommandRef|CommandUniqPtr menu.divider(CommandRef parent, Label menu_name)
CommandRef|CommandUniqPtr menu.readonly(CommandRef parent, Label menu_name, string value = "")

Pairs well with menu.on_tick_in_viewport and menu.set_value.
CommandRef|CommandUniqPtr menu.readonly_name(CommandRef parent, Label menu_name)

Pairs well with menu.on_tick_in_viewport and menu.set_menu_name.
CommandRef|CommandUniqPtr menu.hyperlink(CommandRef parent, Label menu_name, string link, Label help_text = "")
CommandRef|CommandUniqPtr menu.textslider(CommandRef parent, Label menu_name, table<any, string> command_names, Label help_text, table<int, Label> options, function on_click)

We highly recommend using menu.list_action instead of this, unless the options are really unimportant.

Your on_click function will be called with the option's index, the option's value, and click_type as parameters.
CommandRef|CommandUniqPtr menu.textslider_stateful(CommandRef parent, Label menu_name, table<any, string> command_names, Label help_text, table<int, Label> options, function on_click)

We highly recommend using menu.list_select instead of this, unless the options are really unimportant.

Your on_click function will be called with the option's index, the option's value, and click_type as parameters.
CommandRef|CommandUniqPtr menu.player_list_players_shortcut(CommandRef parent, Label menu_name, string command_name, bool single_only = false)
CommandRef|CommandUniqPtr menu.link(CommandRef parent, CommandRef target, bool show_address_in_corner = false)
void menu.apply_command_states()

Loads state & hotkeys for commands you've created without needing to yield, although note that your script is always expected to create all (stateful) commands within the first 100 ticks.
void menu.delete(CommandRef command)
void menu.default_and_delete(CommandRef command)
CommandRef menu.replace(CommandRef old, CommandUniqPtr new)
CommandUniqPtr menu.detach(CommandRef command)
CommandRef menu.attach(CommandRef parent, CommandUniqPtr command)
CommandRef menu.attach_after(CommandRef|CommandUniqPtr anchor, CommandUniqPtr command)
CommandRef menu.attach_before(CommandRef|CommandUniqPtr anchor, CommandUniqPtr command)
bool menu.is_ref_valid(CommandRef ref)

Returns if the referenced command still exists.
void menu.focus(CommandRef command)
bool menu.is_focused(CommandRef command)
table<int, int> menu.get_applicable_players(CommandRef command, ?bool include_user = nil)
CommandRef menu.get_parent(CommandRef command)
int menu.get_type(CommandRef command)

The type may equal one of these values:

    COMMAND_LINK
    COMMAND_ACTION
    COMMAND_ACTION_ITEM
    COMMAND_INPUT
    COMMAND_TEXTSLIDER
    COMMAND_TEXTSLIDER_STATEFUL
    COMMAND_READONLY_NAME
    COMMAND_READONLY_VALUE
    COMMAND_READONLY_LINK
    COMMAND_DIVIDER
    COMMAND_LIST
    COMMAND_LIST_CUSTOM_SPECIAL_MEANING
    COMMAND_LIST_PLAYER
    COMMAND_LIST_COLOUR
    COMMAND_LIST_HISTORICPLAYER
    COMMAND_LIST_READONLY
    COMMAND_LIST_REFRESHABLE
    COMMAND_LIST_CONCEALER
    COMMAND_LIST_SEARCH
    COMMAND_LIST_NAMESHARE
    COMMAND_LIST_ACTION
    COMMAND_LIST_SELECT
    COMMAND_TOGGLE_NO_CORRELATION
    COMMAND_TOGGLE
    COMMAND_TOGGLE_CUSTOM
    COMMAND_SLIDER
    COMMAND_SLIDER_FLOAT
    COMMAND_SLIDER_RAINBOW

List types will return a non-zero value if ANDed with COMMAND_FLAG_LIST.

Additionally, if you AND the type with COMMAND_FULLTYPEFLAG, you may find the result to equal one of the following:

    COMMAND_FLAG_LIST
    COMMAND_FLAG_LIST_ACTION
    COMMAND_FLAG_TOGGLE
    COMMAND_FLAG_SLIDER

Note that not all commands in Stand are physical, e.g. COMMAND_LINK can only take on the appearance of another command. You can use type >= COMMAND_FIRST_PHYSICAL to check if a command type is physical.
table<int, CommandRef> menu.get_children(CommandRef list)
CommandRef menu.list_get_focus(CommandRef list)
CommandRef menu.list_get_focus_physical(CommandRef list)
int menu.collect_garbage()

Removes invalidated weakrefs from an internal vector. Stand does this automatically, but if you bulk-delete-or-replace commands, you might want to call this right after.
bool menu.is_open()
number, number menu.get_position()

Returns the menu grid origin x & y.
number, number, number, number menu.get_main_view_position_and_size()

Returns x, y, width, & height for the current main view (active list, warning, etc.).
CommandRef menu.get_current_menu_list()

Returns a reference to the current menu list, which ignores the context menu.
CommandRef menu.get_current_ui_list()

Returns a reference to the current UI list, which can include the context menu.
string menu.get_active_list_cursor_text(bool even_when_disabled = false, bool even_when_inappropriate = false)

Returns the cursor text of the current UI list.
bool menu.are_tabs_visible()
void menu.show_command_box(string prefill)
void menu.show_command_box_click_based(int click_type, string prefill)
void menu.trigger_commands(string input)

Note that this should not be used every tick to avoid low performance.
void menu.trigger_command(CommandRef command, string arg)
bool menu.command_box_is_open()
number, number, number, number menu.command_box_get_dimensions()

Returns x, y, width, & height.
bool menu.is_in_screenshot_mode()
int menu.on_tick_in_viewport(CommandRef command, function callback)
int menu.on_focus(CommandRef command, function callback)
int menu.on_blur(CommandRef command, function callback)
bool menu.remove_handler(CommandRef command, int handler_id)
Label menu.get_physical(CommandRef|CommandUniqPtr command)

If command points to a link, its target is returned. Otherwise, command is returned.
Label menu.get_menu_name(CommandRef|CommandUniqPtr command)

You might want to use lang.get_string on the return value.
table<int, string> menu.get_command_names(CommandRef|CommandUniqPtr command)
Label menu.get_help_text(CommandRef|CommandUniqPtr command)

You might want to use lang.get_string on the return value.
int menu.get_help_text(CommandRef|CommandUniqPtr command)
string menu.get_name_for_config(CommandRef|CommandUniqPtr command)
bool menu.get_visible(CommandRef command)
int|bool|string menu.get_value(CommandRef command)
int menu.get_min_value(CommandRef command)
int menu.get_max_value(CommandRef command)
int menu.get_step_size(CommandRef command)
int menu.get_precision(CommandRef command)

For float sliders.
int menu.get_indicator_type(CommandRef command)

For lists. See menu.set_indicator_type for possible values.
CommandRef menu.get_target(CommandRef command)

For links.
string menu.get_state(CommandRef command)
string menu.get_default_state(CommandRef command)
string menu.set_state(CommandRef command, string state)
string menu.apply_default_state(CommandRef command)
string menu.recursively_apply_default_state(CommandRef list)
void menu.set_menu_name(CommandRef|CommandUniqPtr command, Label menu_name)
void menu.set_command_names(CommandRef|CommandUniqPtr command, table<any, string> command_names)
void menu.set_help_text(CommandRef|CommandUniqPtr command, Label help_text)
void menu.set_name_for_config(CommandRef|CommandUniqPtr command, string name_for_config)

If empty (which is the default), the name for config is the English (UK) translation of the menu_name, but if you change the menu_name of a command or have multiple commands in the same list with the same name, this will help the state and hotkeys system to keep the association.
void menu.set_visible(CommandRef command, bool visible)
void menu.set_value(CommandRef command, int|bool|string value)
void menu.set_min_value(CommandRef command, int min_value)
void menu.set_max_value(CommandRef command, int max_value)
void menu.set_step_size(CommandRef command, int step_size)
void menu.set_precision(CommandRef command, int precision)

For float sliders.
void menu.set_indicator_type(CommandRef command, int indicator_type)

For lists. Possible values for indicator_type:

    LISTINDICATOR_ARROW
    LISTINDICATOR_ARROW_IF_CHILDREN
    LISTINDICATOR_OFF
    LISTINDICATOR_ON

void menu.set_target(CommandRef command, CommandRef target)

For links.
void menu.set_list_action_options(CommandRef command, table<int, table> options)

Also works for list_select.
void menu.set_textslider_options(CommandRef command, table<int, Label> options)
void menu.add_value_replacement(CommandRef command, int value, string replacement)

For number sliders.
void menu.set_temporary(CommandRef command)

Commands marked as "temporary" will not have state or hotkey options and can't be added to "Saved Commands." However, they will still have their state set to default in the script stop process.
void menu.show_warning(CommandRef command, int click_type, string message, function proceed_callback, ?function cancel_callback = nil, bool skippable = false)

skippable will not have an effect when "Force Me To Read Warnings" is disabled.
int menu.get_activation_key_hash()

Returns a 32-bit integer derived from the user's activation key. 0 if no activation key.
int menu.get_edition()

Returns a value between 0 and 3 depending on the user's edition.
table<string, string> menu.get_version()
full 	"Stand 0.93.1" 	"Stand 0.93.1-preview1"
version 	"0.93.1" 	"0.93.1-preview1"
version_target 	"0.93.1" 	"0.93.1"
branch 	nil 	"preview1"
brand 	"Stand" 	"Stand"
game 	"1.67-3028" 	"1.67-3028"
§ Players Functions
void players.add_command_hook(function callback)

Registers a function to be called when a player should have script features added. Your callback will be called with the player id and player root as arguments.

Note that although your callback may yield, it should create all player commands in the same tick as it is called.
int players.on_join(function callback)

Registers a function to be called when a player joins the session. Your callback will be called with the player id as argument.

Note that although your callback may yield, it should create all player commands in the same tick as it is called.
int players.on_leave(function callback)

Registers a function to be called when a player leaves the session. Your callback will be called with the player id and name as arguments.
void players.dispatch_on_join()

Calls your join handler(s) for every player that is already in the session.
bool players.exists(int player_id)

Checks if a player with the given id is in session.
int players.user()

Alternative to the PLAYER.PLAYER_ID native.
int players.user_ped()

Alternative to the PLAYER.PLAYER_PED_ID native.
table<int, int> players.list(bool include_user = true, bool include_friends = true, bool include_strangers = true)

Returns an index-based table with all matching player ids.
table<int, int> players.list_only(bool include_user = false, bool include_friends = false, bool include_crew_members = false, bool include_org_members = false, bool include_modders = false, bool include_likely_modders = false)

Returns an index-based table with all matching player ids.
table<int, int> players.list_except(bool exclude_user = false, bool exclude_friends = false, bool exclude_crew_members = false, bool exclude_org_members = false, bool exclude_modders = false, bool exclude_likely_modders = false)

Returns an index-based table with all matching player ids.
table<int, int> players.list_all_with_excludes(bool include_user = false)

Like players.list but using Players > All Players > Excludes.
int players.get_host()
int players.get_script_host()
table<int, int> players.get_focused()

Returns an index-based table containing the ids of all players focused in the menu.
string players.get_name(int player_id, bool ignore_streamer_spoof = false)
int players.get_rockstar_id(int player_id)
int players.get_ip(int player_id)

Returns 4294967295 if unknown.
string players.get_ip_string(int player_id)

Returns 255.255.255.255 if unknown.
int players.get_port(int player_id)

Returns 0 if unknown.
int players.get_connect_ip(int player_id)

Returns 4294967295 if the player is not connected via P2P.
int players.get_connect_port(int player_id)

Returns 0 if the player is not connected via P2P.
int players.get_lan_ip(int player_id)

Returns 4294967295 if unknown.
int players.get_lan_port(int player_id)

Returns 0 if unknown.
bool players.are_stats_ready(int player_id)
int players.get_rank(int player_id)
int players.get_rp(int player_id)
int players.get_money(int player_id)
int players.get_wallet(int player_id)
int players.get_bank(int player_id)
number players.get_kd(int player_id)
int players.get_kills(int player_id)
int players.get_deaths(int player_id)
int players.get_language(int player_id)

Returns the same as the LOCALIZATION.GET_CURRENT_LANGUAGE native.
bool players.is_using_controller(int player_id)
string players.get_name_with_tags(int player_id)
string players.get_tags_string(int player_id)
bool players.is_godmode(int player_id)
bool players.is_marked_as_modder(int player_id)

Returns true if the player has the "Modder" tag.
bool players.is_marked_as_modder_or_admin(int player_id)

Returns true if the player has the "Modder or Admin" tag.
bool players.is_marked_as_admin(int player_id)

Returns true if the player has the "Admin" tag.
bool players.is_marked_as_attacker(int player_id)
bool players.is_otr(int player_id)
bool players.is_out_of_sight(int player_id)
bool players.is_in_interior(int player_id)
bool players.is_typing(int player_id)
bool players.is_using_vpn(int player_id)
bool players.is_visible(int player_id)
string players.get_host_token(int player_id)

Returns the player's host token as a decimal string.
string players.get_host_token_hex(int player_id)

Returns the player's host token as a 16-character padded hex string.
number players.get_host_queue_position(int player_id)

Returns the position or 0 if not applicable.
table<int, int> players.get_host_queue(bool include_user = true, bool include_friends = true, bool include_strangers = true)

Returns an index-based table with all matching player ids, sorted in ascending host queue order.
int players.get_boss(int player_id)

Returns -1 if not applicable.
int players.get_org_type(int player_id)

Returns -1 for none, 0 for CEO, or 1 for Motorcycle Club.
int players.get_org_colour(int player_id)

Returns -1 if not applicable. If you want the HUD colour, add 192 to the return value.
string players.clan_get_motto(int player_id)
userdata players.get_position(int player_id)

Works at all distances.
bool players.is_in_vehicle(int player_id)

Works at all distances.
int players.get_vehicle_model(int player_id)

Works at all distances in many cases, but best when the user is close to them.
bool players.is_using_rc_vehicle(int player_id)
?int players.get_bounty(int player_id)

Returns the value of the player's bounty or nil.
void players.send_sms(int recipient, string text)

Receipient must be a friend or member of the same non-Rockstar crew; doesn't work on self. Message must be 1-255 characters.
Vector3 players.get_cam_pos(int player_id)
Vector3 players.get_cam_rot(int player_id)
int players.get_spectate_target(int player_id)

Returns a player id or -1 if not applicable.
number, number, number, bool players.get_waypoint(int player_id)

Returns X, Y, Z, and a bool to indicate if the Z is guessed. Z will always be guessed for remote players.
int players.get_net_player(int player_id)

The address of the player's CNetGamePlayer/rage::netPlayer instance or 0.
int players.set_wanted_level(int player_id, int wanted_level)
int players.give_pickup_reward(int player_id, string|int reward)

Valid rewards can be found in pickups.meta <Rewards> blocks. Some examples are REWARD_HEALTH, REWARD_ARMOUR, REWARD_WEAPON_PISTOL, and REWARD_AMMO_PISTOL. Only works on remote players.
number players.get_weapon_damage_modifier(int player_id)
number players.get_melee_weapon_damage_modifier(int player_id)
CommandRef players.add_detection(int player_id, Label name, int toast_flags = TOAST_DEFAULT, int severity = 100)
int players.on_flow_event_done(function callback)

players.on_flow_event_done(function(p, name, extra)
    name = lang.get_localised(name)
    if extra then
        name ..= " ("
        name ..= extra
        name ..= ")"
    end
    util.toast(players.get_name(p)..": "..name)
end)

void players.teleport_2d(int player_id, number x, number y)
void players.teleport_3d(int player_id, number x, number y, number z)
?int players.get_millis_since_discovery(int player_id)
CommandRef players.detections_root(int player_id)
§ Entities Functions
int entities.create_ped(int type, int hash, Vector3 pos, number heading)

A wrapper for the PED.CREATE_PED native. Returns INVALID_GUID on failure.
int entities.create_vehicle(int hash, Vector3 pos, number heading)

A wrapper for the VEHICLE.CREATE_VEHICLE native. Returns INVALID_GUID on failure.
int entities.create_object(int hash, Vector3 pos)

A wrapper for the OBJECT.CREATE_OBJECT_NO_OFFSET native. Returns INVALID_GUID on failure.
int entities.get_user_vehicle_as_handle(bool include_last_vehicle = true)

Returns INVALID_GUID if vehicle not found.
int entities.get_user_vehicle_as_pointer(bool include_last_vehicle = true)

Returns 0 if vehicle not found.
int entities.get_user_personal_vehicle_as_handle()
int entities.handle_to_pointer(int handle)

Returns the address of the entity with the given script handle.
bool entities.has_handle(int addr)

Returns the entity with the given address has a script handle.
int entities.pointer_to_handle(int addr)

Returns a script handle for the entity with the given address. If the entity does not have a script handle, one will be assigned to it. Note that script handles are a limited resource and allocating too many of them can cause the game to become unstable or even crash.
table<int, int> entities.get_all_vehicles_as_handles()

This will force a script handle to be allocated for all vehicles. Note that script handles are a limited resource and allocating too many of them can cause the game to become unstable or even crash.
table<int, int> entities.get_all_vehicles_as_pointers()
table<int, int> entities.get_all_peds_as_handles()

This will force a script handle to be allocated for all peds. Note that script handles are a limited resource and allocating too many of them can cause the game to become unstable or even crash.
table<int, int> entities.get_all_peds_as_pointers()
table<int, int> entities.get_all_objects_as_handles()

This will force a script handle to be allocated for all objects. Note that script handles are a limited resource and allocating too many of them can cause the game to become unstable or even crash.
table<int, int> entities.get_all_objects_as_pointers()
table<int, int> entities.get_all_pickups_as_handles()

This will force a script handle to be allocated for all pickups. Note that script handles are a limited resource and allocating too many of them can cause the game to become unstable or even crash.
table<int, int> entities.get_all_pickups_as_pointers()
void entities.delete(int handle_or_ptr)

This will handle control requests on its own, and force deletion locally if control cannot be obtained.

Note that deleting some entities causes other entities to get deleted as well (e.g. deleting weapons deletes their attachments) which can be problematic if you're iterating over entity pointers to delete them as some of the subsequent pointers can go stale. Handles don't have this issue because they get invalidated when the respective entity is deleted.
int entities.get_model_hash(int handle_or_ptr)
int entities.get_model_uhash(int handle_or_ptr)
Vector3 entities.get_position(int addr)

The result might be less precise than the native counterpart.
Vector3 entities.get_rotation(int addr)

The result might be less precise than the native counterpart.
number entities.get_health(int handle_or_ptr)
number entities.get_upgrade_value(int handle_or_ptr, int modType)
number entities.get_upgrade_max_value(int handle_or_ptr, int modType)
number entities.set_upgrade_value(int handle_or_ptr, int modType, int value)
int entities.get_current_gear(int addr)

Only applicable to vehicles.
void entities.set_current_gear(int addr, int current_gear)

Only applicable to vehicles.
int entities.get_next_gear(int addr)

Only applicable to vehicles.
void entities.set_next_gear(int addr, int next_gear)

Only applicable to vehicles.
number entities.get_rpm(int addr)

Only applicable to vehicles.
void entities.set_rpm(int addr, float rpm)

Only applicable to vehicles.
number entities.get_gravity(int addr)

Only applicable to vehicles.
number entities.set_gravity(int addr, number gravity)

Only applicable to vehicles.
number entities.set_gravity_multiplier(int addr, number gravity_multiplier)

Only applicable to vehicles.
number entities.get_boost_charge(int addr)

Only applicable to vehicles. Returns a value between 0.0 and 1.25.
int entities.get_draw_handler(int addr)

Returns a pointer or 0.
int entities.vehicle_draw_handler_get_pearlecent_colour(int addr)
int entities.vehicle_draw_handler_get_wheel_colour(int addr)
bool entities.get_vehicle_has_been_owned_by_player(int addr)
int entities.get_player_info(int addr)

Only applicable to peds.
int entities.player_info_get_game_state(int addr)
int entities.get_weapon_manager(int addr)

Only applicable to peds.
int entities.get_head_blend_data(int handle_or_ptr)
?int entities.get_net_object(int handle_or_ptr)

Returns a pointer to the entity's rage::netObject. Returns 0 or nil if not applicable, depending on nullptr preference.
int entities.get_owner(int handle_or_ptr)

Returns the ID of the player that owns this entity.
void entities.set_can_migrate(int handle_or_ptr, bool can_migrate)

Prevents ambient ownership changes so that only explicit requests will be processed.
bool entities.get_can_migrate(int handle_or_ptr)
void entities.give_control(int handle_or_ptr, int player)
int entities.vehicle_get_handling(int addr)
int entities.handling_get_subhandling(int handling_addr, int type)

Type:

    0 = HANDLING_TYPE_BIKE
    1 = HANDLING_TYPE_FLYING
    2 = HANDLING_TYPE_VERTICAL_FLYING
    3 = HANDLING_TYPE_BOAT
    4 = HANDLING_TYPE_SEAPLANE
    5 = HANDLING_TYPE_SUBMARINE
    6 = HANDLING_TYPE_TRAIN
    7 = HANDLING_TYPE_TRAILER
    8 = HANDLING_TYPE_CAR
    9 = HANDLING_TYPE_WEAPON

You can view the relevant handling types for your current vehicle by opening with the Handling Editor: Vehicle > Movement > Handling Editor.
void entities.detach_wheel(int handle_or_ptr, int wheel_index)
Vector3 entities.get_bomb_bay_position(int handle_or_ptr)
bool entities.is_player_ped(int handle_or_ptr)
bool entities.is_invulnerable(int handle_or_ptr)
bool entities.request_control(int handle_or_ptr, int timeout = 2000)
This internally calls util.yield. Returns false if control could not be attained within timeout.
§ Chat Functions
int chat.on_message(function callback)

Registers a function to be called when a chat message is sent:

chat.on_message(function(sender, reserved, text, team_chat, networked, is_auto)
    -- Do stuff...
end)

void chat.send_message(string text, bool team_chat, bool add_to_local_history, bool networked)

As you might be aware, messages have a limit of 140 UTF-16 characters. However, that is only true for the normal input, as you can use up to 255 UTF-8 characters over the network, and many more for the local history. If your message-to-be-networked exceeds 255 UTF-8 characters, Stand will split it into multiple.

Like all chat messages sent via Stand, the text may have the following sequences replaced: ${nl}, ${name}, ${ip}, ${geoip.isp}, ${geoip.country}, ${geoip.region}, ${geoip.city}
void chat.send_targeted_message(int recipient, int sender, string text, bool team_chat)

sender will only be respected when recipient == players.user(), otherwise sender will be forced to players.user().
int chat.get_state()

Possible return values:

    0 = Closed
    1 = Writing in team chat
    2 = Writing in all chat

bool chat.is_open()
void chat.open()
void chat.close()
string chat.get_draft()

Returns the message that the user is currently drafting or an empty string if not applicable.
void chat.ensure_open_with_empty_draft(bool team_chat)
void chat.add_to_draft(string appendix)
void chat.remove_from_draft(int characters)
table<int, table<string, any>> chat.chat.get_history()

util.create_tick_handler(function()
    for chat.get_history() as msg do
        local str = msg.sender_name.." ["..(msg.team_chat ? "TEAM" : "ALL")..(msg.is_auto ? ", AUTO" : "").."] "..msg.contents
        if msg.time ~= 0 then
            str = "["..os.date('%H:%M:%S', msg.time).."] "..str
        end
        util.draw_debug_text(str)
    end
end)

§ DirectX Functions

Any X and Y value must be between 0.0 to 1.0.

The draw functions are in the HUD coordinate space, which is superimposed 1920x1080. You can also append _client to any draw function, e.g. draw_line_client to draw in client coordinate space, which is based on the game window size.
int directx.create_texture(string path)

An absolute path is recommended, e.g. by using filesystem.resources_dir().
?bool directx.has_texture_loaded(int id)

Returns nil if the texture is still queued. Otherwise, returns true or false depending on if loading suceeded.
int, int directx.get_texture_dimensions(int id)
string directx.get_texture_character(int id)

Returns a string that can be used in text rendered by Stand via DirectX to display the given texture.
void directx.draw_texture(int id, number sizeX, number sizeY, number centerX, number centerY, number posX, number posY, number rotation, Colour colour)

Draws the given texture this tick if it has loaded.
void directx.draw_texture(int id, any reserved1, any reserved2, int ms, number sizeX, number sizeY, number centerX, number centerY, number posX, number posY, number rotation, Colour colour)

Draws the given texture for ms milliseconds. Note that the texture may not appear immediately if it's still loading.
void directx.draw_texture_by_points(int id, number x1, number y1, number x2, number y2, Colour colour)

Draws the given texture this tick if it has loaded.
userdata directx.create_font(string path)
void directx.draw_text(number x, number y, string text, int alignment, number scale, Colour colour, bool force_in_bounds = false, ?userdata font = nil, ?Vector3 draw_origin_3d = v3())

alignment can be any of:

    ALIGN_TOP_LEFT
    ALIGN_TOP_CENTRE
    ALIGN_TOP_RIGHT
    ALIGN_CENTRE_LEFT
    ALIGN_CENTRE
    ALIGN_CENTRE_RIGHT
    ALIGN_BOTTOM_LEFT
    ALIGN_BOTTOM_CENTRE
    ALIGN_BOTTOM_RIGHT

void directx.draw_rect(number x, number y, number width, number height, Colour colour)
void directx.draw_line(number x1, number y1, number x2, number y2, Colour colour)
void directx.draw_line(number x1, number y1, number x2, number y2, Colour colour1, Colour colour2)
void directx.draw_triangle(number x1, number y1, number x2, number y2, number x3, number y3, Colour colour)
void directx.draw_circle(number x, number y, number radius, Colour colour, int part = -1)

The part may optionally be a number between 0-3, inclusive, in which case it will only draw the bottom right, bottom left, top left, or top right part of the circle, respectively.
number, number directx.get_client_size()
number, number directx.get_text_size(string text, number scale = 1.0, ?userdata font = nil)

Returns width and height.
number, number directx.pos_hud_to_client(number x, number y)
number, number directx.size_hud_to_client(number x, number y)
number, number directx.pos_client_to_hud(number x, number y)
number, number directx.size_client_to_hud(number x, number y)
int directx.blurrect_new()
void directx.blurrect_free(int instance)

Frees an instance. This is automatically done for all instances your script has allocated but not freed once it finishes.
void directx.blurrect_draw(int instance, number x, number y, number width, number height, int strength)

Prefer to use 1 instance per region, as any draw with a different size requires the buffers to be reallocated.

strength should be around 4 and can't exceed 255.
§ Util Functions
void util.require_natives(int|string version, ?string flavour)

Loads the natives lib with the provided version, installing it from the repository if needed.
void util.execute_in_os_thread(function func)

Executes the given function in an OS thread to avoid holding up the game for expensive tasks like using require on a big file, creating lots of commands, or performing expensive calculations. Note that this will hold up your entire script, and calling natives or certain api functions in this context may lead to instabilities.
void util.require_no_lag(string file)

Like require, but in an OS thread, to avoid holding up the game. Might not work for every library.
thread util.create_tick_handler(function func)

Registers the parameter-function to be called every tick until it returns false.

util.create_tick_handler(function()
    -- Code that runs every tick...
end)

bool util.try_run(function func)
void util.keep_running()

Prevents Stand cleaning up your script for being idle. This is implicit when you create commands, register event handlers, or use the async_http API.
void util.yield(?int wake_in_ms = nil)

Pauses the execution of the calling thread until the next tick or in wake_in_ms milliseconds.

If you're gonna create a "neverending" loop, don't forget to yield:

while true do
    -- Code that runs every tick...
    util.yield()
end

For simple loops, you should prefer util.create_tick_handler.
bool, bool util.can_continue()

The first bool remains true until your script is being stopped. You generally won't need to check against this as the runtime will handle the stop process, but in special situations like execute_in_os_thread, you might like to check against this to see if you want to continue with an expensive operation.

The second bool indicates if a silent stop of your script has been requested.
void util.set_busy(bool busy)
thread util.create_thread(function thread_func, ...)

Creates the kind of thread that your script gets when it is created, or one of your callbacks is invoked, which is just another coroutine that gets resumed every tick and is expected to yield or return.
void util.stop_thread()

Stops the calling thread.
void util.shoot_thread(thread thrd)

Stops the given thread.
bool util.is_scheduled_in(thread thrd)

Checks if the given thread is still being resumed every tick.
void util.restart_script()

Goes through the script stop process, freshly loads the contents of the script file, and starts the main thread again. Note that the thread scheduler stays as-is, so this restart is different from a stop-and-start.
void util.stop_script()
void util.on_pre_stop(function func)
void util.on_stop(function func)

Script stop process:

    on_pre_stop handlers are called.
    Default state is applied to all commands (Change callbacks may be called at this point with CLICK_BULK).
    on_stop handlers are called.

Note that yielding and creating threads are not available during the stop process.
void util.toast(string message, int bitflags = TOAST_DEFAULT)

Shows a notifications.

Possible bitflags:

    TOAST_ABOVE_MAP — Uses Stand notifications if enabled
    TOAST_CONSOLE
    TOAST_FILE
    TOAST_WEB
    TOAST_CHAT
    TOAST_CHAT_TEAM
    TOAST_DEFAULT — Equal to (TOAST_ABOVE_MAP | TOAST_WEB)
    TOAST_LOGGER — Equal to (TOAST_CONSOLE | TOAST_FILE)
    TOAST_ALL — Equal to (TOAST_DEFAULT | TOAST_LOGGER)

Note that the chat flags are mutually exclusive.
void util.log(string message)

Alias for util.toast(message, TOAST_LOGGER)
void util.draw_debug_text(string text)

Draws the given text for the current tick using the "Info Text" system.
void util.draw_centred_text(string text)
void util.show_corner_help(string message)

Shorthand for

util.BEGIN_TEXT_COMMAND_IS_THIS_HELP_MESSAGE_BEING_DISPLAYED(message)
if not HUD.END_TEXT_COMMAND_IS_THIS_HELP_MESSAGE_BEING_DISPLAYED(0) then
    util.BEGIN_TEXT_COMMAND_DISPLAY_HELP(message)
    HUD.END_TEXT_COMMAND_DISPLAY_HELP(0, false, true, -1)
end

void util.replace_corner_help(string message, string replacement_message)

Shorthand for

util.BEGIN_TEXT_COMMAND_IS_THIS_HELP_MESSAGE_BEING_DISPLAYED(message)
if HUD.END_TEXT_COMMAND_IS_THIS_HELP_MESSAGE_BEING_DISPLAYED(0) then
    util.BEGIN_TEXT_COMMAND_DISPLAY_HELP(replacement_message)
    HUD.END_TEXT_COMMAND_DISPLAY_HELP(0, false, true, -1)
end

void util.set_local_player_wanted_level(int wanted_level)

Replacement for

PLAYER.SET_PLAYER_WANTED_LEVEL_NO_DROP(PLAYER.PLAYER_ID(), wanted_level, false)
PLAYER.SET_PLAYER_WANTED_LEVEL_NOW(PLAYER.PLAYER_ID(), false)

using pointers to avoid potentially tripping anti-cheat.
int util.joaat(string text)

This produces the kind of hash used pretty much everywhere in GTA. Although note that even tho this is named JOAAT, this uses RAGE's version of JOAAT — the most notable difference is that the input is computed as lowercase.
int util.ujoaat(string text)

Similar to util.joaat, but returns an unsigned number:

util. joaat("stand") --> -830507952
util.ujoaat("stand") --> 3464459344

string util.reverse_joaat(int hash)

Returns an empty string if the given hash is not found in Stand's dictionaries.
bool util.is_this_model_a_blimp(int|string model)
bool util.is_this_model_an_object(int|string model)
bool util.is_this_model_a_submarine(int|string model)
bool util.is_this_model_a_submarine_car(int|string model)
bool util.is_this_model_a_trailer(int|string model)
table<int, table> util.get_vehicles()

Returns an index-based table with a table for each vehicle in the game. The inner tables contain name, manufacturer, and class.

class is a signed JOAAT hash with the following possible keys: off_road, sport_classic, military, compacts, sport, muscle, motorcycle, open_wheel, super, van, suv, commercial, plane, sedan, service, industrial, helicopter, boat, utility, emergency, cycle, coupe, rail

class is guaranteed to be a valid builtin language label.
table<int, string> util.get_objects()

Returns an index-based table with a string for each object.
table<int, table> util.get_weapons()

Returns an index-based table with a table for each weapon in the game. The inner tables contain hash, label_key, category, & category_id. Note that the categories are specific to Stand.
void util.BEGIN_TEXT_COMMAND_DISPLAY_TEXT(string message)

Replacement for

HUD.BEGIN_TEXT_COMMAND_DISPLAY_TEXT("STRING")
HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(message)

which increases your message's character limit.
void util._BEGIN_TEXT_COMMAND_LINE_COUNT(string message)

Replacement for

HUD._BEGIN_TEXT_COMMAND_LINE_COUNT("STRING")
HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(message)

which increases your message's character limit.
void util.BEGIN_TEXT_COMMAND_IS_THIS_HELP_MESSAGE_BEING_DISPLAYED(string message)

Replacement for

HUD.BEGIN_TEXT_COMMAND_IS_THIS_HELP_MESSAGE_BEING_DISPLAYED("STRING")
HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(message)

which increases your message's character limit.
void util.BEGIN_TEXT_COMMAND_DISPLAY_HELP(string message)

Replacement for

HUD.BEGIN_TEXT_COMMAND_DISPLAY_HELP("STRING")
HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(message)

which increases your message's character limit.
void util._BEGIN_TEXT_COMMAND_GET_WIDTH(string message)

Replacement for

HUD._BEGIN_TEXT_COMMAND_GET_WIDTH("STRING")
HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(message)

which increases your message's character limit.
void util.BEGIN_TEXT_COMMAND_THEFEED_POST(string message)

Replacement for

HUD.BEGIN_TEXT_COMMAND_THEFEED_POST("STRING")
HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(message)

which increases your message's character limit.
int util.get_rp_required_for_rank(int rank)
int util.get_session_players_bitflag()
void util.trigger_script_event(int session_player_bitflags, table<any, int> args, bool reinterpret_floats = false)

args[1] should be the event hash (f_0), args[2] is ignored, args[3] and onwards is the data (f_3 and onwards).

session_player_bitflags has a bit set to 1 for every player that should receive the script event; you can use util.get_session_players_bitflag() if you intend for everyone to receive the script event or use 1 << player_id to target individual players.

reinterpret_floats changes the behaviour when an argument is a float to push it as a float instead of casting it to an int.
int util.current_time_millis()
int util.current_unix_time_seconds()

Returns how many seconds have passed since the UNIX epoch (00:00:00 UTC on 1 January 1970).
bool util.remove_handler(int handler_id)
bool util.is_session_started()
bool util.is_session_transition_active()
int util.get_char_slot()
bool, number util.get_ground_z(number x, number y, number z_hint = 1000.0)

The most precise way to get the ground Z coordinate which respects water.

The ground Z will be below the z_hint.

If the bool return value is true, the number is the ground Z. If not, you should try again next tick. You may want to count the calls you made and abort after a certain amount of calls with the bool being false.
bool util.spoof_script(string|int script, function func)

If the provided script is not running, your function is not called and this returns false.
bool util.spoof_script_thread(int thread_id, function func)

If the script thread was not found, your function is not called and this returns false.
bool util.remove_blip(int blip)
bool util.arspinner_is_enabled()
void util.arspinner_enable()
void util.arspinner_disable()
bool util.graceland_is_enabled()
void util.graceland_enable()
void util.graceland_disable()
bool util.is_bigmap_active()
void util.copy_to_clipboard(string text, bool notify = true)
string util.get_clipboard_text()
table<string,string> util.read_colons_and_tabs_file(string file)

Allows you to read a file in the colons and tabs format, which is what Stand uses for profiles, hotkeys, etc.
void util.write_colons_file(string file, table<string,string> data)

Allows you to write a file in the colons and tabs format.
void util.draw_ar_beacon(Vector3 pos)
void util.draw_box(Vector3 pos, Vector3 rot, Vector3 dimensions, int r, int g, int b, int a = 255)

Draws a box with 3d rotation using polys. Note that backfaceculling applies to the inside.
void util.draw_sphere(Vector3 pos, int radius, int r, int g, int b, int a = 255, int quality = 40)

Draws a sphere using polys. Note that backfaceculling applies to the inside.
bool util.request_script_host(string|int script)
bool util.give_script_host(string|int script, int player)
bool util.register_file(string path)

Registers the given file in the game so it can be used with natives, e.g. util.register_file(filesystem.resources_dir() .. "myscript.ytd") will allow you to use "myscript" as a texture dict for GRAPHICS natives.
string util.get_label_text(int|string label_key)

Same as HUD._GET_LABEL_TEXT except it will bypass any replacements Stand might be making.
string util.register_label(string text)

Registers a label, such that it can be used with HUD._GET_LABEL_TEXT and other natives.
bool util.is_key_down(int|string vk)

vk int values can be found at https://docs.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes

vk may also be a string (A-Z, 0-9, a space, or F1-F24).
int util.call_foreign_function(int addr, int|userdata|string ...)
string util.get_rtti_name(int inst_addr)
string util.get_rtti_hierarchy(int inst_addr)
void util.set_particle_fx_asset(int|string hash)
int util.blip_handle_to_pointer(int blip_handle)
int util.get_blip_display(int blip_handle)
void util.teleport_2d(number x, number y)
bool util.is_interaction_menu_open()
int util.on_transition_finished(function callback)
int util.get_closest_hud_colour(int target_r, int target_g, int target_b, int target_a = 255)
bool util.is_soup_netintel_inited()
int util.on_pad_shake(function callback)

util.on_pad_shake(function(light_duration, light_intensity, heavy_duration, heavy_intensity, delay_after_this_one)
    -- Do stuff...
end)

void util.request_model(int|string model, int timeout = 2000)

Attempts to load the given model within timeout milliseconds or throws an error.
void util.open_folder(string path)
bool util.set_nullptr_preference(bool use_nil = true)

How Stand should behave when it has to return a nullptr to you.

    false is the old behaviour, which is just returning the int 0.
    true is the new behaviour, which will return nil instead of an int, to simplify comparisons.

This currently affects the following functions:

    entities.get_user_vehicle_as_pointer
    entities.handle_to_pointer
    entities.handling_get_subhandling
    entities.get_net_object
    util.blip_handle_to_pointer
    util.get_model_info
    memory.script_global
    memory.script_local
    memory.scan
    memory.scan_script

Returns the previous value.
int util.get_tps()
bool, ?string util.get_session_code()

local function get_session_code_for_user()
    local applicable, code = util.get_session_code()
    if applicable then
        if code then
            return code
        end
        return "Please wait..."
    end
    return "N/A"
end

?int util.stat_get_type(int|string stat)
?int util.stat_get_int64(int|string stat)
void util.stat_set_int64(int|string stat, int value)
int util.new_toast_config(CommandRef list, int bitflags = 0, table<any, string> command_names_prefix = {})
int util.toast_config_get_flags(int tc)

local tc
menu.my_root():action("Show Notification", {}, "", function()
    util.toast("Here is the notification!", util.toast_config_get_flags(tc))
end)
menu.my_root():divider(lang.find_builtin("Notifications"))
tc = util.new_toast_config(menu.my_root(), TOAST_DEFAULT)

int util.get_model_info(int|string hash)

Returns the address of the CModelInfo for the given hash or 0 if not loaded.
bool util.is_valid_file_name(string name, bool allow_folder)
number, number, number util.rgb2hsv(number r, number g, number b)
number, number, number util.hsv2rgb(number h, number s, number v)
number util.calculate_luminance(number r, number g, number b)
number util.calculate_contrast(number r1, number g1, number b1, number r2, number g2, number b2)
bool util.is_contrast_sufficient(number r1, number g1, number b1, number r2, number g2, number b2)
void util.set_waypoint(Vector3 pos)

An extended version of HUD.SET_NEW_WAYPOINT that includes the Z axis for features like Stand's AR Waypoint.
void util.set_cam_quaternion(int cam, number x, number y, number z, number w)
bool util.get_screen_coord_from_world_coord_no_adjustment(number fWorldX, number fWorldY, number fWorldZ, number pOutScreenX, number pOutScreenY)

Alternative to GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD that does not do adjustments for multihead monitor configs.

util.require_natives()

util.create_tick_handler(function()
    local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())

    local v2 = memory.alloc(8)
    if util.get_screen_coord_from_world_coord_no_adjustment(pos.x, pos.y, pos.z, v2, v2 + 4) then
        util.draw_debug_text(memory.read_float(v2) .. ", " .. memory.read_float(v2 + 4))
    else
        util.draw_debug_text("Off-screen!")
    end
end)

string util.utf8_to_utf16(string utf8)
string util.utf16_to_utf8(string utf16)
table<int, table>, bool util.get_gps_route(int slot)

Gets the GPS route information for the given slot. Slot 0 is waypoint.

The first return value is an index-based table of tables. Each inner table contains x, y, z and junction. Junction nodes should be ignored when drawing a line to avoid jaggedness.

The second return value indicates if the route is partial.
bool util.sc_is_blocked(int rockstar_id)

The result of this may sometimes lag behind your actual Social Club block list. This seems to be a Social Club bug.
void util.sc_block(int rockstar_id)

May not succeed if called in bulk. Try to combine this with util.sc_is_blocked.
void util.sc_unblock(int rockstar_id)

May not succeed if called in bulk. Try to combine this with util.sc_is_blocked.
thread util.play_wav(string path)

Spins up a new thread to play the sound. Once util.is_scheduled_in on the return value becomes false, the playback has finished.
void util.ui3dscene_set_element_2d_position(int slot, float x, float y)

Note that this is in client coordinate space.
void util.ui3dscene_set_element_2d_size(int slot, float width, float height)

Note that this is in client coordinate space.
void util.ui3dscene_set_element_background_colour(int slot, Colour colour)
?int util.ip_from_string(string str)
string util.ip_to_string(int ip)
?table util.ip_get_as(int ip)

Returns a table containing number, handle, & name. Returns nil if netIntel is not inited yet or no such data is available for the given IP.
?table util.ip_get_location(int ip)

Returns a table containing country_code, state, & city. Returns nil if netIntel is not inited yet or no such data is available for the given IP.
§ V3 Functions
userdata v3.new(float x, float y, float z)
userdata v3.new(Vector3 pos)
userdata v3.new()

Creates a new v3 instance, which can be used anywhere a Vector3 or Vector3* is accepted.

As an alternative to v3.new(...), you can also use v3(...).

Furthermore, all following functions can be called on a v3 instance using the : syntax.
float, float, float v3.get(userdata|int addr)
float v3.getX(userdata|int addr)
float v3.getY(userdata|int addr)
float v3.getZ(userdata|int addr)
float v3.getHeading(userdata|int addr)
userdata|int v3.set(userdata|int addr, float x, float y, float z)
userdata|int v3.setX(userdata|int addr, float x)
userdata|int v3.setY(userdata|int addr, float y)
userdata|int v3.setZ(userdata|int addr, float z)
userdata|int v3.reset(userdata|int addr)
userdata|int v3.add(userdata|int a, userdata|int b)

Adds b to a. Returns a.
userdata|int v3.sub(userdata|int a, userdata|int b)

Subtracts b from a. Returns a.
userdata|int v3.mul(userdata|int a, number f)

Multiplies a by f. Returns a.
userdata|int v3.div(userdata|int a, number f)

Divides a by f. Returns a.
userdata|int v3.addNew(userdata|int a, userdata|int b)

Returns a new instance with the result of a + b.
userdata|int v3.subNew(userdata|int a, userdata|int b)

Returns a new instance with the result of a - b.
userdata|int v3.mulNew(userdata|int a, number f)

Returns a new instance with the result of a * f.
userdata|int v3.divNew(userdata|int a, number f)

Returns a new instance with the result of a / f.
bool v3.eq(userdata|int a, userdata|int b)
number v3.magnitude(userdata|int a)

Alternatively, you can use the # syntax on a v3 instance to get its magnitude.
number v3.distance(userdata|int a, userdata|int b)
userdata|int v3.abs(userdata|int addr)

Ensures that every axis is positive.
void v3.sum(userdata|int addr)
float v3.min(userdata|int addr)

Returns the value of the smallest axis.
float v3.max(userdata|int addr)

Returns the value of the biggest axis.
number v3.dot(userdata|int a, int b)
userdata|int v3.normalise(userdata|int addr)
userdata v3.crossProduct(userdata|int a, int b)

The result is a new instance.
userdata v3.toRot(userdata|int addr)

The result is a new instance with rotation data.
userdata v3.lookAt(userdata|int a, int b)

The result is a new instance with rotation data.
userdata v3.toDir(userdata|int addr)

The result is a new instance with direction data. The direction vector will have a magnitude of 1 / it is a unit vector, so you can safely multiply it.

Note that Stand expects/uses what is rotation order 2 for RAGE.
string v3.toString(userdata|int addr)
§ Lang Functions
string lang.get_current()

Returns the current menu language, which could be a 2-letter language code, "en-us", "sex", "uwu", or "hornyuwu".
bool lang.is_code_valid(string lang_code)
string lang.get_code_for_soup(string lang_code)
bool lang.is_automatically_translated(string lang_code)
bool lang.is_english(string lang_code)
int lang.register(string text)
void lang.set_translate(string lang_code)

Starts the process of translating labels. lang_code must be a 2-letter language code or "sex".
void lang.translate(int label, string text)
int lang.find(string text, string lang_code = "en")

Finds an existing label using its text. Returns 0 if not found. lang_code must be a 2-letter language code or "sex".

Note that if there are multiple possible results, it is basically random which one is returned.
int lang.find_builtin(string text, string lang_code = "en")

Similar to lang.find but limited to labels Stand has registered.
int lang.find_registered(string text, string lang_code = "en")

Similar to lang.find but limited to labels your script has registered.
string lang.get_string(Label label, string lang_code = "en")

lang_code must be a 2-letter language code, "en-us", "sex", "uwu", or "hornyuwu".
string lang.get_localised(Label label)

Similar to lang.get_string but always using the current menu language.
bool lang.is_mine(int label)

Returns true if the given label was registered by the calling script.
bool lang.is_builtin(int label)
?string lang.get_country_name(string country_code, string lang_code)
§ Filesystem Functions
string filesystem.appdata_dir()

Possible return value: C:\Users\John\AppData\Roaming\
string filesystem.stand_dir()

Possible return value: C:\Users\John\AppData\Roaming\Stand\
string filesystem.scripts_dir()

Possible return value: C:\Users\John\AppData\Roaming\Stand\Lua Scripts\
string filesystem.resources_dir()

Possible return value: C:\Users\John\AppData\Roaming\Stand\Lua Scripts\resources\

That is the directory dedicated to static content for scripts, e.g. a logo.
string filesystem.store_dir()

Possible return value: C:\Users\John\AppData\Roaming\Stand\Lua Scripts\store\

That is the directory dedicated to dynamic content for scripts, e.g. user configuration that can't be dealt with by proper usage of the state system.

This function also creates the "store" directory if it doesn't exist.
bool filesystem.exists(string path)
bool filesystem.is_regular_file(string path)
bool filesystem.is_dir(string path)
void filesystem.mkdir(string path)
void filesystem.mkdirs(string path)
table<int, string> filesystem.list_files(string path)

Returns an index-based table with all files in the given directory.

for filesystem.list_files(filesystem.scripts_dir()) as path do
    util.log(path)
end

Note that directories in the resulting table don't end on a \.
§ Async HTTP Functions
bool async_http.have_access()
void async_http.init(string host, string ?path = nil, ?function success_func = nil, ?function fail_func = nil)

This will make a GET request unless you use async_http.set_post before calling async_http.dispatch.

On success, your success_func will be called with body, header_fields, status_code.

If the request failed to go through, your fail_func will be called with reason which is a string.

Note that neither function will be called if your script stops before the request finishes as their lifetimes are independent.
void async_http.dispatch()

Finish building the async http request and carry it out in separate OS thread.
void async_http.set_post(string content_type, string payload)

Changes the request method, adds Content-Type and Content-Length headers, and sets the payload.

Examples of content_type:

    application/json
    application/x-www-form-urlencoded; charset=UTF-8

void async_http.add_header(string key, string value)
void async_http.set_method(string method)
void async_http.prefer_ipv6()
§ Memory Functions
int memory.script_global(int global)

Returns the address of the given script global. Beware that script globals get reallocated upon "forcequit".
int memory.script_local(string|int script, int local)

Returns the address of the given script local or 0 if the script was not found.
userdata memory.alloc(int size = 24)

The default size is 24 so it can fit a Vector3.

The returned userdata supports the following operations: :readByte, :readUbyte, :readShort, :readUshort, :readInt, :readUint, :readLong, :readFloat, :readString, :readVector3, :readBinaryString, :writeByte, :writeUbyte, :writeShort, :writeUshort, :writeInt, :writeUint, :writeLong, :writeFloat, :writeString, :writeVector3, :writeBinaryString
userdata memory.alloc_int()

Alias for memory.alloc(4).
userdata memory.alloc_float()

Alias for memory.alloc(4).
int memory.scan(string pattern)
int memory.scan(string module_name, string pattern)

Scans the game's memory for the given IDA-style pattern. This is an expensive call so ideally you'd only ever scan for a pattern once and then use the resulting address until your script finishes.
?int memory.scan_script(string|int script, string pattern)

Scans the given script's code for the given IDA-style pattern. Returns no values if the script was not found.
int memory.rip(int addr)

Follows an offset from the instruction pointer ("RIP") at the given address.

So, whereas in C++ you might do something like this:

memory::scan("4C 8D 05 ? ? ? ? 48 8D 15 ? ? ? ? 48 8B C8 E8 ? ? ? ? 48 8D 15 ? ? ? ? 48 8D 4C 24 20 E8").add(3).rip().as<const char*>();

You'd do this in Lua (with a check for null-pointer because we're smart):

local addr = memory.scan("4C 8D 05 ? ? ? ? 48 8D 15 ? ? ? ? 48 8B C8 E8 ? ? ? ? 48 8D 15 ? ? ? ? 48 8D 4C 24 20 E8")
if addr == 0 then
    util.toast("pattern scan failed")
else
    util.toast(memory.read_string(memory.rip(addr + 3)))
end

lightuserdata memory.addrof(userdata ud)
int memory.read_byte(int|userdata addr)

Reads an 8-bit integer at the given address.
int memory.read_ubyte(int|userdata addr)

Reads an unsigned 8-bit integer at the given address.
int memory.read_short(int|userdata addr)

Reads a 16-bit integer at the given address.
int memory.read_ushort(int|userdata addr)

Reads an unsigned 16-bit integer at the given address.
int memory.read_int(int|userdata addr)

Reads a 32-bit integer at the given address.
int memory.read_uint(int|userdata addr)

Reads an unsigned 32-bit integer at the given address.
int memory.read_long(int|userdata addr)

Reads a 64-bit integer at the given address.
number memory.read_float(int|userdata addr)
string memory.read_string(int|userdata addr)
Vector3 memory.read_vector3(int|userdata addr)
string memory.read_binary_string(int|userdata addr, int size)
void memory.write_byte(int|userdata addr, int value)

Writes an 8-bit integer to the given address.
void memory.write_ubyte(int|userdata addr, int value)

Writes an unsigned 8-bit integer to the given address.
void memory.write_short(int|userdata addr, int value)

Writes a 16-bit integer to the given address.
void memory.write_ushort(int|userdata addr, int value)

Writes an unsigned 16-bit integer to the given address.
void memory.write_int(int|userdata addr, int value)

Writes a 32-bit integer to the given address.
void memory.write_uint(int|userdata addr, int value)

Writes an unsigned 32-bit integer to the given address.
void memory.write_long(int|userdata addr, int value)

Writes a 64-bit integer to the given address.
void memory.write_float(int|userdata addr, number value)
void memory.write_string(int|userdata addr, string value)
void memory.write_vector3(int|userdata addr, Vector3 value)
void memory.write_binary_string(int|userdata addr, string value)
string memory.get_name_of_this_module()
int memory.tunable(int|string hash)

Returns the address of the tunable with the given hash. The implementation of this function may call util.yield.

This function returns the address of a script global — beware that script globals get reallocated upon "forcequit".
int memory.tunable_offset(int|string hash)

Returns the offset (the part after .f_) of the tunable with the given hash. The implementation of this function may call util.yield.
§ Profiling Functions
void profiling.once(string name, function func)

Executes the given function and prints the time it took to your log.
void profiling.tick(string name, function func)

Executes the given function and shows the time it took via the info text/debug text.


Stand Command Box Documentation
How to access it

    Stand Command Box. The classic, accessed by pressing in-game — this keybind can be changed with Stand > Settings > Keyboard Input Scheme > Command Box.
    Chat. If you wanna flex to your teammates or even the whole session, you can use Online > Chat > Commands to have Stand listen to a specific prefix to execute a command — and even allow friends and strangers to use it!
    Web. You can use Stand > Open Web Interface and find an everpresent command box at the top of the web interface.

Other Players

Stand's command box is obviously very powerful, so in order to prevent your friends from trolling you by using !unload, every command knows what to do when someone else issued it, even if that is just refusing to operate. As for the commands that do operate for other players, you can find them by searching for "Can be used by other players" in the Command List.
Processing
Multiple Commands

Most commands have a limit on the amount of parameters they take, so when you run , the command will take "off" as its only parameter, which means that gets treated as a separate command. However, if we just wanted to toggle aimbot and triggerbot, we would have to use a semicolon () to separate them like , as otherwise the command would think "triggerbot" is its parameter. Also note that while you're using semicolon-separation, any invalid commands will still allow valid commands to get executed.
Automatic Completion

Stand only needs the unambigious start of a command in order to execute it, as to allow you to be more creative with your usage of the command box. An example of this would be using instead of .
Automatic Collapsing

You may have noticed that there are some commands which have a similar functionality and the same prefix, specifically commands for players and weather commands. These commands support automatic collapsing.

To give you an example: would be ambigious because multiple commands start with "bounty", but luckily for us, "bounty" uses automatic collapsing, which means that the would-be-parameter "all" is added to the command itself, such that it collapses into and becomes an unambigious and valid command.
