# Supersonic's (code-based) Colored Hitboxes

## Features

- Set hitbox colors with a hitbox index
- Only requires 4 sprites
- Adds the knockback arrow to projectiles

**Note:** This system does not currently support custom hitbox shapes.
I will be attempting to implement them in the near future.

## Installation

1. [**Download the sprites from here and put them in your sprites folder.**](https://drive.google.com/drive/folders/13PaY_ngj2neB0xYNVLpUM0BGTrb5bX0U?usp=sharing) The transparent sprites here are actually the default hitbox sprites with an alpha of 1, making them almost invisible to the eye.
2. Paste the contents of the following code block into init.gml:

```gml
//Custom Hitbox Colors System (by @SupersonicNK)
HG_HITBOX_COLOR = 79; //This can be any number above 57 and below 100. It is recommended that you put this number below Munophone's starting_hg_index value, to prevent conflicts.

//Sprite Setup
//knockback arrow sprite
__kb_arrow_spr = asset_get("knock_back_arrow_spr")
//actual hitbox sprites
var w = 100
__hb_circle_t = sprite_get("hitbox_circle_trans");
    sprite_change_offset("hitbox_circle_trans",w,w);
    sprite_change_collision_mask("hitbox_circle_trans",false,0,0,0,0,0,0);
__hb_rect_t = sprite_get("hitbox_square_trans");
    sprite_change_offset("hitbox_square_trans",w,w);
    sprite_change_collision_mask("hitbox_square_trans",false,0,0,0,0,0,0);
__hb_r_rect_t = sprite_get("hitbox_rounded_rectangle_trans");
    sprite_change_offset("hitbox_rounded_rectangle_trans",w,w);
    sprite_change_collision_mask("hitbox_rounded_rectangle_trans",false,0,0,0,0,0,0);
__hb_hd_spr = [__hb_circle_t, __hb_rect_t, __hb_r_rect_t];
//drawn hitbox sprite
__hb_draw_spr = sprite_get("hitbox_shapes");
    sprite_change_offset("hitbox_shapes",w,w);
```

3. Add the following code to update.gml:

```gml
//Put this above all the #defines in your script
prep_hitboxes();

//Put this at the very bottom of the script, with the rest of your #defines.
#define prep_hitboxes
//Applies the hitbox sprites and prepares them to be drawn (with color!)
with (pHitBox) if player_id == other {
    if "col" not in self {
        with other {
            other.col = get_hitbox_value(other.attack, other.hbox_num, HG_HITBOX_COLOR);
            if other.col == 0 other.col = c_red;
            other.shape = get_hitbox_value(other.attack, other.hbox_num, HG_SHAPE)
            other.draw_colored = true;
            if other.type == 1
                other.sprite_index = __hb_hd_spr[other.shape];
            else if get_hitbox_value(other.attack, other.hbox_num, HG_PROJECTILE_MASK) == -1
                other.mask_index = __hb_hd_spr[other.shape];
            else 
                other.draw_colored = false;
            other.draw_spr = __hb_draw_spr;
        }
    }
}
```

4. Add the following code to debug_draw.gml (it works in any draw script, but debug_draw draws over everything but the hud, like the hitbox display does.):

```gml
//Put this above all the #defines in your script.
draw_colored_hitboxes();

//Put this at the very bottom of your script, with the rest of the #defines.
#define draw_colored_hitboxes
if get_match_setting(SET_HITBOX_VIS) {
    var arrowspr = __kb_arrow_spr
    with (pHitBox) if player_id == other && draw_colored {
        draw_sprite_ext(draw_spr, shape, x, y, image_xscale,image_yscale,0,col,0.5);
        var __kb_angle = kb_angle == 361 ? 45 : kb_angle;
        var angle = ((__kb_angle+90)*(hit_flipper==5?-1:1)*spr_dir)-90
        draw_sprite_ext(arrowspr, 0, x, y, 1,1,angle,-1,0.5);
    }
}
```

After that, the system should be functional!

## Usage

You can apply a hitbox color the same way you would apply a hitbox's other values:

`set_hitbox_value(AT_DAIR, 2, HG_HITBOX_COLOR, $FFFF00);`

As a quick heads up, GML uses the format BGR instead of RGB, so the color the above code makes is Cyan, rather than Yellow.
