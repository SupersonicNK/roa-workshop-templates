__run();
/*============================================================================================================================\
    
    Supersonic's Automated Synced Variable Handler.
    
    Probably overengineered? But it's easy to use (I think), which was the goal (outside of allowing easier compatibility.)
    
    REQUIRED:
    	Call this user event from css_update.gml, near the bottom of the file but above any #defines.
    		(This will mean the synced variable is always written to on the frame you want to modify it.)
    	Call this user event from init.gml.
    	Add your variables into the `define_vars()` function below.
    OPTIONAL:
    	Call this user event from update.gml if you need to write while in playtest or during the match.
    	Call this user event from a results draw script if you need the synced variable on the results screen.
	    	NOTE: On the results screen, you must use `synced_var[player].my_variable` instead of `synced_var.my_variable`,
	    	as players share the same results screen object. This prevents possible conflicts.
	    
\============================================================================================================================*/

#define define_vars()

// Define your synced variables here!
// Example:
//		add_var( "my_variable", 4 );
// In this example, I'm adding a variable named my_variable, with a maximum value of 4.
// Synced variables can only be integers.
// After defining them here, you can then access these variables as synced_var.my_variable

add_var( "my_variable", 4 );

// SETTINGS
// Sets whether the update function will sanitize the synced variable data automatically.
// This prevents the variables from being set to values that they cannot be set to, like
// negative numbers, numbers with decimals, strings, etc.
#macro CHECK_ERRORS true 
// Sets whether the update function will modify the synced var value during matches.
#macro SET_SYNCVAR_DURING_MATCH false 
// Sets whether the update function will modify the synced var value on the results screen.
#macro SET_SYNCVAR_DURING_RESULTS false
// Sets whether to read from the synced var every frame. Otherwise it just reads on initializing.
#macro READ_EVERY_FRAME false 
// Sets whether to clean the synced var every time the character inits on the CSS. 
// This will prevent the variables from carrying between matches.
#macro CLEAR_ON_INIT false 
// Sets whether to do debug prints. This WILL spam your error log.
#macro VERBOSE false

//===============================================================================================================
//
//			Everything below here you should avoid editing unless you REALLY know what you're doing.
//
//===============================================================================================================
#define __run()
if ( "__synced_var_data" not in self || get_data_var() == noone || get_data_var().uuid != sprite_get("idle") ) __init();
__update()
#define __init()
var context;
var syncvar_name = "synced_var";
var datavar_name = "__synced_var_data";
var css_object = asset_get("cs_playerbg_obj");
var results_object = asset_get("draw_result_screen")
var online_css_room = asset_get("network_char_select")
var reset = false
// Assign Context
if (object_index == oTestPlayer || object_index == css_object) {
	print_verbose("Detected context as CSS.")
	context = CTX_CSS
	if datavar_name in self && variable_instance_get(self, datavar_name).char_name != get_char_info(player, INFO_STR_NAME) {
		// 100% a different character, always trigger reset.
		reset = true;
	}
} else if (object_index == oPlayer) {
	print_verbose("Detected context as Match.")
	context = CTX_MATCH
} else if (object_index == results_object) {
	print_verbose("Detected context as Results.")
	context = CTX_RESULTS
} else {
	print_verbose("Detected context as Unknown.")
}
// Set Instance Variables
__autosyncvar_context = context;
var s = {};
var d = {
	plr: (room == online_css_room ? 0 : player), // used in set/get synced var
	playtest:false, // True when player is in playtest.
	was_playtest:false, // True for one frame when player exits playtest.
	context:CTX_UNKNOWN,
	bits_used:0,
	vars:{}, // key: name, value: number of bits
	uuid:sprite_get("idle"), //for detecting character swaps *on* css to clear data.
	css_obj:css_object,
	res_obj:results_object,
	ocss_room:online_css_room,
	char_name:get_char_info(player, INFO_STR_NAME)
};

if (context == CTX_RESULTS) {
	if "synced_var" not in self {
		synced_var = [-4, -4, -4, -4, -4];
		__synced_var_data = [-4, -4, -4, -4, -4];
	}
	synced_var[player] = s
	__synced_var_data[player] = d;
} else {
	synced_var = s
	__synced_var_data = d
}
define_vars();
switch(context) {
	case CTX_CSS:
		if (room == online_css_room) d.plr = 0; // plr should always be 0 on the online css.
		print(d.plr)
		// Detect handoff
		if object_index == oTestPlayer {
			print_verbose("Player is in playtest, syncing to cs_playerbg_obj instance.")
			with (d.css_obj) {
				if datavar_name not in self continue; // object doesn't have data var, ignore it.
				if __synced_var_data.player == d.plr { // compare data var's player to css object's player
					other.__synced_var_data = __synced_var_data;
					other.synced_var = synced_var;
					__synced_var_data.playtest = true;
					break;
				}
			}
			// You can still write to the synced var while in playtest, and it will get updated.
			// The CSS will also see the new value, which is what the syncing code above was for.
		} else {
			if !CLEAR_ON_INIT && !reset {
				read_synced_var();
				// Check if malformed
				var err = error_check(false);
				if err {
					print_error("Error(s) found while loading synced var. Clearing values.")
					var keys = variable_instance_get_names(d.vars);
					for (var i = 0; i < array_length(keys); i++) {
						variable_instance_set(synced_var, keys[i], 0);
					}
				}
			}
		}
		break;
	case CTX_MATCH:
	case CTX_RESULTS:
	case CTX_UNKNOWN:
		read_synced_var();
		break;
}
#define __update()
var d = get_data_var();
var s = get_sync_var();
var vars = d.vars;
var k = variable_instance_get_names(vars);
if CHECK_ERRORS
	error_check();
switch (__autosyncvar_context) {
	case CTX_CSS:
		if object_index == d.css_obj {
			if d.playtest {
				d.playtest = false;
				d.was_playtest = true;
			} else if d.was_playtest {
				d.was_playtest = false;
			}
		}
		// Write
		write_synced_var(true);
		break;
	case CTX_MATCH:
		if SET_SYNCVAR_DURING_MATCH write_synced_var(true);
		if READ_EVERY_FRAME read_synced_var();
		break;
	case CTX_RESULTS:
		if SET_SYNCVAR_DURING_RESULTS write_synced_var(true);
		if READ_EVERY_FRAME read_synced_var();
		break;
	default:
	case CTX_UNKNOWN:
		// Assume it's only safe to read here.
		if READ_EVERY_FRAME read_synced_var();
		break;
}

#define get_num_bits(max_value) // Gets the num bits value for a given value.
if max_value == 0 return 0; // you don't need any bits to represent nothing
var bit_value;
var accum = 0;
for (var i = 0; i < 32; i++) {
	bit_value = power(2, i);
	accum += bit_value;
	if accum >= max_value {
		return i+1;
	}
}
#define print_error
/// #args ...

var str = "[AutoSyncVar] "
for (var i = 0; i < argument_count; i++) str += " "+string(argument[i])
print(str);

#define print_verbose
/// #args ...
if (!VERBOSE) {
	return;
}
var str = "[AutoSyncVar] "
for (var i = 0; i < argument_count; i++) str += " "+string(argument[i])
print(str);

#define write_synced_var(set)
var d = get_data_var();
var s = get_sync_var();
var vars = d.vars;
var k = variable_instance_get_names(vars);
var output = 0;
for (var i = array_length(k)-1; i >= 0; i--) {
	var key = k[i];
	var val = variable_instance_get(s, key);
	var shift = (i-1 >= 0) ? variable_instance_get(vars, k[i-1])[1] : 0;
	output = output | val;
	output = output << shift;
}
if set set_synced_var(d.plr, output)
return output
#define read_synced_var
var d = get_data_var();
var vars = d.vars;
var k = variable_instance_get_names(vars);
var read_target = get_synced_var(d.plr);
print_verbose(`Reading data from P${d.plr}'s syncvar: ${read_target}`)
var out = get_sync_var();
var chunk_offset = 0;
for (var i = 0; i < array_length(k); i++) {
	var len = variable_instance_get(vars, k[i])[1];
	var mask = ( 1 << len ) - 1
	variable_instance_set(out, k[i], real((read_target >> chunk_offset) & mask));
	chunk_offset += len;
}
print_verbose(`Syncvar from P${d.plr} output: ${out}`)

#define add_var(name, max_value)
var num_bits = get_num_bits(max_value);
var d = get_data_var()
if name in d.vars {
	print_error(`Cannot add duplicate variable ${name}.`)
	return;
}
if max_value == 0 {
	print_error(`Variable ${name} could not be added- max_value cannot be 0! That would be no data.`)
	return;
}
if d.bits_used + num_bits > 32 {
	print_error(`Variable ${name} could not be added- Too many bits in use! Current: ${d.bits_used}, Attempted: ${d.bits_used+num_bits}`)
	print_error(`Synced variables can only store 32 bits of data.`)
	return;
}
variable_instance_set(d.vars, name, [max_value, num_bits]);
variable_instance_set(get_sync_var(), name, 0);
d.bits_used += num_bits;

print_verbose(`Variable ${name} added, with a max value of ${max_value}. Bits in use: ${d.bits_used}`);

#define get_data_var()
return (__autosyncvar_context == CTX_RESULTS) ? __synced_var_data[player] : __synced_var_data;
#define get_sync_var()
return (__autosyncvar_context == CTX_RESULTS) ? synced_var[player] : synced_var;
#define error_check
var change_vars = argument_count > 0 ? argument[0] : true;
var d = get_data_var();
var s = get_sync_var();
var vars = d.vars;
var k = variable_instance_get_names(vars);
var error_found = false;
for (var i = 0; i < array_length(k); i++) {
	var key = k[i];
	var val = variable_instance_get(s, key);
	var max_val = variable_instance_get(vars, key)[0];
	// error handling / data sanitization
	if (!is_real(val)) {
		error_found = true;
		print_error(key, "cannot be a non-number value."+ (change_vars ? " Resetting to 0, was "+string(val) : ""))
		if !change_vars variable_instance_set(s, key, 0);
		continue;
	}
	if (floor(val) != val) {
		error_found = true;
		print_error(key, "cannot be a float value."+ (change_vars ? " Setting to "+string(floor(val))+", was "+string(val) : ""))
		if !change_vars variable_instance_set(s, key, floor(val));
		continue;
	}
	if (val > max_val) {
		error_found = true;
		print_error(key, "is above given max value."+ (change_vars ? " Resetting to 0, was "+string(val) : ""))
		if !change_vars variable_instance_set(s, key, 0);
		continue;
	}
}
return error_found


#macro CTX_CSS 0
#macro CTX_MATCH 1
#macro CTX_RESULTS 2
#macro CTX_UNKNOWN 3