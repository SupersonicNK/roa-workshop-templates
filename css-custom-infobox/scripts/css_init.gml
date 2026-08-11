//#region INFOBOX RELATED
// This is the stuff you should edit.

char_name = get_char_info(player, INFO_STR_NAME)
//char_name = "Sandbert" // if your character's name is too long, you can set this manually.

version_str = `${get_char_info(player, INFO_VER_MAJOR)}.${get_char_info(player, INFO_VER_MINOR)}`

depth_fixer_articletype = "obj_article3" // If article3 doesn't work for you, you can change this.
depth_fixer_identifier = "sandbert_depth_fixer"

infobox_headers = []
infobox_pages   = []

//#region Infobox Text
infobox_headers[0] = "WHAT IS THIS";
infobox_pages  [0] = 
"A custom infobox! You can use this! For free!

I'm not going to pretend it's easy to use, though.";

infobox_headers[1] = "WHY IS THIS";
infobox_pages  [1] = 
"Did you know the game's infoboxes don't work correctly online?

That's why. Also, there's no 3 page limit here.";

infobox_headers[2] = "HOW IS THIS"
infobox_pages  [2] = 
"Very hacky code involving an article and a game of tug-of-war.

There's an article shoving the CSS object offscreen, while css_update.gml puts it back onscreen.  -->"

infobox_headers[3] = "HOW IS THIS 2"
infobox_pages  [3] = 
"Because css_update happens to run AFTER css_draw, this results in the object drawing offscreen but being able to fix its position on reload or if you deselect the character. -->"

infobox_headers[4] = "HOW IS THIS 3"
infobox_pages  [4] =
"This one hack makes this possible to make a pretty infobox rework with no real compromise!


TL;DR: funny hack make thing possible"
//#endregion

// The stuff you.. probably shouldn't edit. You can if you want, though. I won't stop you.
css_state = 0;
// States:
// 0 - Base CSS
// 1 - Custom Infobox
// .. You can add your own, if you want

// Drawing hack variables
drawing_custom = false; 
// When this is true, the css box object will reposition 
// itself offscreen and change its depth. You can use this to create your own
// css pages if you want to!
depth_fixer = noone;
base_depth = depth;

// Internal Infobox Variables
infobox_page = 0; // Currently selected infobox page
infobox_text = "" // Current infobox text. This is what actually gets drawn, which includes the line breaks.

// Button States
infobox_button_close_state = 0;
infobox_button_left_state = 0;
infobox_button_right_state = 0;

// Custom infobox by Soup! (SupersonicNK)
//#endregion