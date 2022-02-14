# Supersonic's Advanced Skin Handler

## Features

- Multiple skins
- Low performance hit
- Caching
- Automatic offsets
- Easy skinned sprite loading

## Why?

The advanced skin template currently available by Muno was great, but it's very dated. It uses quite a few if statements to accomplish the job, and while it DOES work, it's definitely not ideal. Especially if you want to make multiple skins. It becomes a chore rather quickly.

With the way this handler works, each sprite is loaded based on a base name and a prefix or suffix. This makes it a lot easier to set up skins, not requiring you to manually set the sprites used on a per skin basis. I wouldn't call this new handler perfect, but I would personally call it a step up from what we had before.

## Basic Setup

For the most basic of characters/skins, the user event is pretty much plug and play. You'll need to dig a little deeper if you want to skin projectiles, articles, etc.

### Installation

1. [**Download the initialization user event here**](https://github.com/SupersonicNK/roa-workshop-templates/raw/master/advanced-skin-handler/scr/user_event15.gml) (right click the link -> save as). Rename it to any user_event between 0 and 15 that you aren't already using and put it into your `scripts` folder.
2. At the **bottom** of `load.gml`, insert the following function, replacing the `15` with the number you gave the user event: `user_event(15);`
3. From the user event, copy the portion of text between `//COPY START` and `//COPY END` from the user event to the very **bottom** of your `animation.gml` file. (If `animation.gml` does not exist, create it.)
4. At the top of `animation.gml`, add the following text:

   ```gml
   if (has_skin()) { //is there a skin equipped?
       sprite_index = skin_sprite(sprite_index); //get the skinned sprite
       basic_animations(); //correct the idle, walk, and dash animations
   }
   ```

   This is what actually allows the skin to work after initialization.

### Enabling your skin

For this, we'll assume you want your skin to be on alt number 15, for ease of explanation.

Important things to note: You **cannot** set the skin from `init.gml`, but you **can** from `load.gml`, the user event, or any other script that runs after `init.gml` such as `update.gml`, the `attacks` folder, etc. This is because of the order the scripts run in. `load.gml` runs after `init.gml`, and the user_event has to be in `load.gml` because it needs to access the offsets defined in it. So for this, we'll just use the user event to set the skin.

The area I recommend *defining* your skin in is the section labeled SKIN DEFINITION.
To define a skin, use the add_skin function as follows, where myskin is the name of the skin:

```gml
add_skin("myskin")
```

This will add the skin to the skin list, allowing it to be used.

There is a simple example present in the user event, but I'll still detail it here. Somewhere below the `precache();` function in the POST DEFINITION section, place the following code.

```gml
if (get_player_color(player) == 15) set_skin("myskin");
```

This first checks the palette the player has equipped. In this case, we picked **15**, which is the **16th** palette. If the player has the 16th palette equipped, then it sets their skin to the skin `myskin`.

If you want to enable a skin from another script, find the `#define set_skin` in `user_event15.gml` (or whatever user event you renamed the skin handler to), and copy it to the script you'd like to use it in. Then you can call set_skin from another script.

### Skinning Sprites

Once you've got the skin equippable as per the section above, now you just need to ensure that your files are named correctly! The naming convention is as follows:

`skinname_spritename`. So, in the case of our example, one sprite may be `myskin_idle`, with a filename of `myskin_idle_strip6.png`.

If the file is named correctly according to the skin, it should automatically load the skinned sprite. Otherwise, it'll load the default sprite instead.

## Advanced Setup

TODO.

## Change History

- 1.3:
  - Fixed set_skin just straight up not working. My bad.

- 1.2:
  - Fixed caching. No longer erroneously caches into the player object.

- 1.1:
  - You may now supply `sprite_get_skinned` and `skin_sprite` with a second argument, `skin`, which may be a skin's name or index.
  - Changed how skins are stored slightly to match how sprite names are stored, removing the requirement for a loop when getting a skin's data by name.

- 1.0:
    Released.
