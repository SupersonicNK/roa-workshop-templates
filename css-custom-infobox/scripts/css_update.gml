var cursor_x = instance_exists(cursor_id) ? get_instance_x(cursor_id) : -1
var cursor_y = instance_exists(cursor_id) ? get_instance_y(cursor_id) : -1

// Failsafe. DON'T remove this. 116 is the F5 key, which reloads the character.
if (keyboard_lastkey == 116) {
	css_state = 0;
	keyboard_lastkey = 0;
}
switch(css_state) {
    case 0:
        drawing_custom = false; // This stops the article from moving the object.
        if infobox_button_update(cursor_x, cursor_y) break;
        // Your CSS update code should go here!
        
        
        
        // .. and end here.
        break;
    //==========================================================================
    //#region Infobox
    //==========================================================================
    case 1:
        var temp_y = ystart
        drawing_custom = true;
        suppress_cursor = true;
		var hovering_left  = point_in_rect(cursor_x, cursor_y, x+7,   temp_y+177, x+7+52,   temp_y+177+26)
		var hovering_right = point_in_rect(cursor_x, cursor_y, x+60,  temp_y+177, x+60+52,  temp_y+177+26)
		var hovering_close = point_in_rect(cursor_x, cursor_y, x+184, temp_y+177, x+184+30, temp_y+177+26)
		
		if (menu_b_pressed || (menu_a_pressed && hovering_close)) {
			css_state = 0
			drawing_custom = false;
			sound_play(asset_get("mfx_return_cursor"), false, 0)
			break;
		}
		
		if (infobox_button_left_state < 2) infobox_button_left_state = hovering_left
		else infobox_button_left_state--;
		if (infobox_button_right_state < 2) infobox_button_right_state = hovering_right
		else infobox_button_right_state--;
		if (infobox_button_close_state < 2) infobox_button_close_state = hovering_close
		else infobox_button_close_state--;
		
		var page_changed = false;
		if infobox_text == "" page_changed = true;
		
		if (menu_lb_pressed || (menu_a_pressed && hovering_left)) {
			infobox_page--;
			page_changed = true;
			if menu_a_pressed infobox_button_left_state = 5;
			sound_play(asset_get("mfx_option"), false, 0)
		}
		if (menu_rb_pressed || (menu_a_pressed && hovering_right)) {
			infobox_page = (infobox_page + 1) % array_length(infobox_pages)
			page_changed = true;
			if menu_a_pressed infobox_button_right_state = 5;
			sound_play(asset_get("mfx_option"), false, 0)
		}
		
		if (infobox_page < 0) {
			infobox_page = array_length(infobox_pages)-1
		}
		if (page_changed) {
			draw_set_font(asset_get("fName")) // set font for accurate string measurement
			infobox_text = break_string(infobox_pages[infobox_page], 202, 1)
		}
        break;
    //==========================================================================
    //#endregion
    //==========================================================================
}

//==============================================================================
//#region Depth Hack
//==============================================================================
y = ystart
depth = 0
if ( not instance_exists(depth_fixer) ) {
    var found = false
    with asset_get(depth_fixer_articletype) {
        if (other.depth_fixer_identifier in self && target == other) {
            other.depth_fixer = self
            found = true
            break
        }
    }
    // Generates a new article when one is not found.
    if (!found) {
        depth_fixer = instance_create(0, 0, depth_fixer_articletype)
        depth_fixer.num = "_css_fix" // this is how article_css_fix_update.gml gets run.
        // set an identifier. we need an identifier variable because
        // you might ALSO be using this article object for real things.
        variable_instance_set(depth_fixer, depth_fixer_identifier, true)
        depth_fixer.target = self
    }
}
//==============================================================================
//#endregion
//==============================================================================
#define infobox_button_update(cursor_x, cursor_y)
///Handles the infobox button and returns true if pressed, false if not.
if (get_player_color(player) == $808080) return false; // Cpu, no infobox.
var hovering_info_button = css_state == 0 && point_in_rect(cursor_x, cursor_y, x+109, y+177, x+140, y+200)

if (hovering_info_button) {
	suppress_cursor = true;
	if menu_a_pressed {
		css_state = 1
		drawing_custom = true;
		infobox_page = 0;
		infobox_text = "";
		sound_play(asset_get("mfx_option"), false, 0)
		return true
	}
}
return false

// Utilities
#define break_string(str, w, h)
// Breaks a string by word, rather than by character, preventing partial words
// in line breaks.
var final_str = "";
var line = 0;
var len = string_length(final_str);
var prev_char = "";
var char = "";
var newline = "
"
for (var i = 1; i <= string_length(str); i++) {
    char = string_char_at(str,i);
    if string_width(final_str+char) > w {
    	// Crawl for start of word
    	for (var j = i; j > 0; j--) {
    		if string_char_at(final_str, j) == " " || string_char_at(final_str, j) == newline {
    			if j == i {
    				final_str = string_delete(final_str,len,1);
        			final_str += newline + char;
    				break;
    			}
    			var temp_str = string_copy(final_str, j+1, i-j) // The "wrapped" word
    			final_str = string_copy(final_str, 1, j-1)
    			final_str += newline + temp_str + char;
    			j = 0;
    		}
    	}
    	line++;
    } else {
        final_str += char;
    }
    
    len = string_length(final_str);
}
return final_str;
#define point_in_rect (px, py, x1, y1, x2, y2)
///Returns true if a point (px, py) is within the given rectangle.
return 
    px == clamp(px, min(x1,x2), max(x1,x2)) && 
    py == clamp(py, min(y1,y2), max(y1,y2))
