var cursor_x = instance_exists(cursor_id) ? get_instance_x(cursor_id) : -1
var cursor_y = instance_exists(cursor_id) ? get_instance_y(cursor_id) : -1

switch (css_state) {
    case 0:
        // Your CSS draw code should go here!
        
        
        // .. and end here.
        break;
    //==========================================================================
    //#region Infobox
    //==========================================================================
    case 1:
        shader_end();
        var y = ystart;
	    var c_hud = get_player_hud_color(player);
	    // BG
    	draw_rectangle_color(x+8, y, x+220, y+200, c_black, c_black, c_black, c_black, false)
    	draw_sprite_ext(sprite_get("css_infobg"), 0, x-2, y-2, 2, 2, 0, c_hud, 1);
    	// Header Line
    	draw_line_width_color(x+7, y+12, x+211, y+12, 2, c_black, c_hud);
    	// Header preview sprite
    	draw_sprite(sprite_get("css_infobox_preview"), 0, x+2, y-10)
    	
    	// Draw the name and version on the side.
    	draw_set_valign(fa_bottom);
    	draw_set_halign(fa_right);
    	draw_set_font(asset_get("tinyFont"))
    	draw_text_transformed_color(x-4, y+4, version_str, 2, 2, 90, c_hud, c_hud, c_hud, c_hud, 0.5)
    	
    	draw_set_halign(fa_left);
    	draw_text_transformed_color(x-4, y+200, char_name, 2, 2, 90, c_hud, c_hud, c_hud, c_hud, 0.5)
    	
    	// Actual infobox text
    	draw_set_valign(fa_top);
    	draw_set_font(asset_get("fName"))
    	draw_text_ext_color(x+10, y+22, infobox_text, 18, 999, c_white, c_white, c_white, c_white, 1)
    	// Header Text
    	draw_set_halign(fa_right);
    	draw_set_font(asset_get("roundFont"))
    	draw_text_ext_color(x+211, y-10, infobox_headers[infobox_page], 18, 999, c_white, c_white, c_white, c_white, 1)

    	// Buttons
    	draw_set_font(asset_get("fName")) // Set font for string_width to work
    	var page_text = `PAGE ${infobox_page+1}/${array_length(infobox_pages)}`
    	draw_debug_text(x+148 - string_width(page_text) / 2, y+186, page_text)
    	draw_sprite_ext(sprite_get("css_button_left"), clamp(infobox_button_left_state, 0, 2), x+8, y+178, 2, 2, 0, -1, 1);
    	draw_sprite_ext(sprite_get("css_button_right"), clamp(infobox_button_right_state, 0, 2), x+60, y+178, 2, 2, 0, -1, 1);
    	draw_sprite_ext(sprite_get("css_button_close"), clamp(infobox_button_close_state, 0, 1), x+184, y+178, 2, 2, 0, -1, 1);
        break;
    //==========================================================================
    //#endregion
    //==========================================================================
}