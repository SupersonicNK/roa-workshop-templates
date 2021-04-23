# Delta Parallax's code stuff
Hello!
I am Delta Parallax, a Rivals of Aether modder, musician, and coder. This page is meant to give you access to some of the cool stuff I've learned about while making characters.

If you use *any* of the content here, please credit me accordingly! I love seeing where my work is used.

## 1. Additive Blending + Glow Effects

I discovered that using additive blending makes for a great "glow" or "brightening" effect. Additive blending takes two overlapping colors and adds them together, which can result in bright and vibrant colors.

Here is a simple template for it. Put this in any `draw` function.
```gml
var blend = gpu_get_blendmode(); //gets the current blend mode
gpu_set_blendmode(bm_add); //use additive blending for next draw_* calls
//do something
gpu_set_blendmode(blend); //goes back to whatever blend mode you were in.
```
For example, drawing a sprite of an opacity less than 1 with additive blending can yield interesting results.
```gml
...
draw_sprite_ext(sprite_index, image_index, x, y, spr_dir, image_yscale, 0, c_white, 0.5);
...
```
You can also try this out with radial light. I have created a function here that creates a radial glow around a point, with a certain radius, center and edge color (c1 and c2, respectively), alpha, and precision (I recommend >30 for the precision, any less and it'll just become a bunch of triangles).
*Note: This might lag on older computers.*
```gml
#define draw_glow(cx, cy, r, col1, col2, alpha, precision)

draw_primitive_begin(pr_trianglefan);
draw_vertex_color(cx, cy, col1, alpha);
var incre = (2*pi) / abs(precision);

for (var i = 0; i <= 2*pi; i+=incre)
{
    var pos;
    pos = [cos(i)*sign(precision), sin(i)*sign(precision)];
    draw_vertex_color(cx + (pos[0]*r), cy - (pos[1]*r), col2, 0);
}
draw_vertex_color(cx+(r*sign(precision)), cy, col2, 0);
draw_primitive_end();
```

I usually combine additive blending and `draw_glow()` to get a good feeling of brightness, like the glow is actually lighting up the space around it.
```gml
//Sinusuiodal pulsing
var phase, position;
phase = (get_gameplay_time()/30) mod (2*pi);
position = abs(sin(rad))*0.4 + 0.6;

//Blendmode
var blend = gpu_get_blendmode();
gpu_set_blendmode(bm_add);

//Draw the glow
var precision;
precision = (position-0.5)*40;
draw_glow(x, y, 15+(position*20), c_white, c_white, position*image_alpha, precision);

//Reset
gpu_set_blendmode(blend);
```

## 2. Custom Hitbox Sprites
Usually when making hitboxes, RoA's hitbox grid index `HG_SHAPE` only lets you choose between values of `0` (ellipse), `1` (rectangle), and `2` (rounded rectangle). However, these hitbox shapes can only be so effective, and sometimes it is more effective to use custom sprites.

**Here's how you can change the sprite and shape of a hitbox through code.**

First, make your hitbox sprite. It can be pure red `(255,0,0)` or you can make it other colors if you want to distinguish it from other ones. *This sprite must be 200x200px in order for it to scale correctly in-game.* After you have done that, put it in your character's `sprites` folder.

Next, you must change the offset of your sprite for it to be positioned correctly. Put this line in-game, changing `your_hitbox_sprite` to be the name of your hitbox sprite.
```gml
sprite_change_offset("your_hitbox_sprite",100,100);
```
After this, you must create a variable in `scripts/init.gml` for the hitbox object to reference, which contains the id of your new sprite. This variable can be called anything, but make sure you are consistent across all scripts you use it in.
*Again, change `your_hitbox_sprite` to be the name of your hitbox sprite.*
```gml
hb_sprite = sprite_get("your_hitbox_sprite");
```

Now this is where things get interesting: this next step will actually fit the hitbox to whatever condition you want. Say we want to change the hitbox sprite for all of our melee hitboxes. In `scripts/update.gml`, we would put the following code in.
```gml
with (asset_get("pHitBox")) //references all hitbox objects
{
	//checks if the hitbox is a melee one that we own
	if (player_id == other and type == 1)
	{
		sprite_index = other.hb_sprite; // changes the hitbox sprite
	}
}
```
After we refresh and open up the code, we will see that the hitboxes will have changed to our new custom sprite.
You can change the conditional inside the `with` statement to be anything you'd like.

## 3. Custom Parrystun
In Rivals, we have two types of parrystun which are used depending on the attack.
1. The first is *normal parrystun*, which is just a solid 40 frames of vulnerability after endlag.
2. The second is *extended parrystun*, which is proportional to the distance between the opponent and the parried player.

Both of these cover (and work well for) a wide range of scenarios, but unfortunately, they don't fit every case. What if you want base parrystun in addition to extended parrystun?

Here is a simple function for custom parrystun for use in `scripts/got_parried.gml`.
After putting this at the bottom of your script, you can use it by calling `custom_parrystun()`. If any argument is not supplied, it will use a default value.

You can change the base and the multiplier for different results.
```gml
#define custom_parrystun
var base, multiplier, distance, extended;

//Some base number, applied regardless of distance
base = argument_count < 1 ? 40 : argument0;

//Multiplier to the distance
multiplier = argument_count < 2 ? 0.08 : argument1;

//Distance away from the player that parried you
distance = distance_to_object(hit_player_obj); 

//Extended parrystun calculation
extended = floor(distance * multiplier); 

//Apply to parrystun
parry_lag = base + extended;
```
