/*
    Player Tag Palette system (by @SupersonicNK)
    
    This template uses 1 bit in set_synced_var
    I would recommend using the template here if you're
    storing other data in set_synced_var:
    https://github.com/SupersonicNK/roa-workshop-templates/tree/master/generate-synced-var
*/
#macro DBG_PREFIX "[TAGPAL] "
#macro VERBOSE false
__run_script();

#define define_colors() 
{
/*
    Define your named alts via the add_named_alt function here.
    e.g. add_named_alt("exmple", 32);
    where "exmple" is the name, and 32 is the number of the alt
    in colors.gml. 
    (Yes, you can define alts past 31 in colors.gml! They're just typically
    not selectable. THIS IS SUPPORTED BY THE COLOR TOOL!)
*/
    add_named_alt("exmple", 32);
    
/*
    Change other variables here.
*/
    with (ssnk_tagpal) {
        // How many shade slots the character has. This helps prevent a possible crash.
        shade_count = 8; 
        // Sounds for enabling and disabling the tag palette.
        confirm_snd = asset_get("mfx_confirm");
        cancel_snd = asset_get("mfx_back");
        // Whether the css should flash when the tag palette is toggled.
        css_should_flash = true;
    }

}
// Below is the runner function for the other scripts.
#define player_tag_palettes
///(user_event, ?arg)
__ssnk_tagpal_scr = script_get_name(1);
__ssnk_tagpal_arg = argument_count > 1 ? argument[1] : 0;
user_event(argument[0]);
return "__ssnk_tagpal_res" in self ? __ssnk_tagpal_res : 0;

#define __system_init()
// Internal init. Do not touch.
var player = (room == 113) ? 0 : self.player;
ssnk_tagpal = {
    checked_status: false, // Whether the synced var number has been checked.
    enabled: false, // Whether a tag palette is being used
    active_clr: -1, // The number of the alt being used
    clrs: {}, // The name dictionary
    shade_count: 8,
    //css specific
    prev_name: get_player_name(player),
    cur_name: get_player_name(player),
    flash_timer: 0,
    flash_time: 15,
    confirm_snd: asset_get("mfx_confirm"),
    cancel_snd: asset_get("mfx_back"),
    css_should_flash: true,
    prev_alt: get_player_color(player),
    alt: get_player_color(player),
    button_hovered: false
};
__ssnk_tagpal_scr = "";
__ssnk_tagpal_arg = 0;
define_colors();
#define __init(arg)
var player = (room == 113) ? 0 : self.player;
__system_init();
var dat = ssnk_tagpal;
if (arg) {
    var name = get_player_name(player)
    var clr = __get_tag_clr(name);
    dat.active_clr = clr;
    if clr == -1 {
        printE(`Palette for tag ${name} not found.`)
    } else {
        dat.enabled = true;
        printD(`Loaded palette ${clr} for tag ${name}.`);
    }
}
#define __css_init(arg)
__system_init();
var dat = ssnk_tagpal;
dat.prev_name = dat.cur_name;
dat.enabled = false;
dat.active_clr = __get_tag_clr(dat.cur_name);

return dat.enabled;
printD("css_init ran successfully.")
#define __css_update(arg)
if "ssnk_tagpal" not in self {__css_init(arg)}
var x = floor(self.x), y = floor(self.y);
var dat = ssnk_tagpal;
dat.cur_name = get_player_name(player);
dat.flash_timer -= dat.flash_timer > 0;
if (dat.cur_name != dat.prev_name) {
    dat.prev_name = dat.cur_name;
    dat.enabled = false;
    dat.active_clr = -1;
    
    var pal = __get_tag_clr(dat.cur_name);
    if pal != -1 {
        dat.flash_timer = dat.flash_time;
        dat.enabled = true;
        dat.active_clr = pal;
        sound_play(dat.confirm_snd);
    }
}
dat.alt = get_player_color(player);
if (dat.active_clr != -1) {
    if (dat.alt != dat.prev_alt && dat.enabled) {
        dat.enabled = false;
        sound_play(dat.cancel_snd);
    }
}

var cx = get_instance_x(cursor_id);
var cy = get_instance_y(cursor_id);
dat.button_hovered = point_in_rect(cx, cy, 
    x+80-(string_width(get_player_name(player))/2),
    y+77*2+1,
    x+80+14+(string_width(get_player_name(player))),
    y+(79+6)*2+1)
if dat.button_hovered {
    suppress_cursor = true;
    if menu_a_pressed {
        dat.enabled = !dat.enabled;
        sound_play(dat.enabled ? dat.confirm_snd : dat.cancel_snd);
        dat.flash_timer = dat.flash_time;
    }
}
dat.prev_alt = dat.alt;
return dat.enabled;
#define __css_draw(arg)
var dat = ssnk_tagpal;
var x = floor(self.x), y = floor(self.y);
//white flash
if (dat.flash_timer > 0 && dat.css_should_flash) {
    gpu_push_state();
    gpu_set_fog(true, c_white, 0, 1)
    //gpu_set_blendmode(bm_add)
    draw_sprite_ext(get_char_info(player,INFO_CHARSELECT),0,x+8,y+8,2,2,0,-1,dat.flash_timer/dat.flash_time)
    gpu_pop_state();
}

//icon/button
if dat.active_clr != -1 {
    draw_set_font(asset_get("roundFont")) //ensure correct font for string width
    //draw_set_halign(fa_center)
    //draw_text_transformed_color(x+55*2,y+(74*2),get_player_name(player),1,1,0,c_green,c_green,c_green,c_green,1);
    draw_sprite_ext(sprite_get("ssnk_tagpal_icon"),0,(x+90)-(string_width(get_player_name(player))/2),(y+78*2)+1,2,2,0,dat.enabled?$66ff99:(dat.button_hovered?$dddddd:c_gray),1);
}

#define __results_draw_portrait(arg)
if "ssnk_tagpal" in self exit;
__system_init();
var dat = ssnk_tagpal;
if (arg) {
    var name = get_player_name(player)
    var clr = __get_tag_clr(name);
    dat.active_clr = clr;
    if clr == -1 {
        printE(`Palette for tag ${name} not found.`)
    } else {
        dat.enabled = true;
        printD(`Loaded palette ${clr} for tag ${name}.`);
    }
}

#define __init_shader(arg)
//print("init_shader")
if "ssnk_tagpal" not in self {
    __init(arg);
};
var dat = ssnk_tagpal;
if (!dat.enabled) return -1; //no tag palette.
var alt = dat.active_clr;
for (var i = 0; i < dat.shade_count; i++) {
    var r = get_color_profile_slot_r(alt,i),
        g = get_color_profile_slot_g(alt,i),
        b = get_color_profile_slot_b(alt,i)
    set_character_color_slot(i,r,g,b);
    set_article_color_slot(i,r,g,b);
}
return alt;
#define __run_script()
if (__ssnk_tagpal_scr != "")
    __ssnk_tagpal_res = script_execute(script_get_index(`__${__ssnk_tagpal_scr}`), __ssnk_tagpal_arg);
#define __get_tag_clr(name)
return variable_instance_get(ssnk_tagpal.clrs, string_lower(name), -1);
#define printD(str)
if VERBOSE print(`${DBG_PREFIX}${str}`);
#define printE(str)
print(`${DBG_PREFIX}${str}`);
#define point_in_rect(px,py,x1,y1,x2,y2)
return (px >= x1 && px <= x2) && (py >= y1 && py <= y2)
#define add_named_alt(name, color_slot)
variable_instance_set(ssnk_tagpal.clrs, string_lower(name), color_slot);
printD(`Tag ${name} registered as alt ${color_slot}.`);