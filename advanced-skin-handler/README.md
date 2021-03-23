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
3. Copy the portion of text between `//COPY START` and `//COPY END` from the user event to your `animation.gml` file, paste it at the very bottom of the file.
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

There is a simple example present in the user event, but I'll still detail it here. Somewhere below the `precache();` function in the POST DEFINITION section, place the following code.
```gml
if (get_player_color(player) == 15) set_skin("myskin");
```
This first checks the palette the player has equipped. In this case, we picked **15**, which is the **16th** palette. If the player has the 16th palette equipped, then it sets their skin to the skin `myskin`.

   