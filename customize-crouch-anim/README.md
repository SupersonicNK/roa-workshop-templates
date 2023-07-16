# Customizable Crouch Startup/Recovery

https://github.com/SupersonicNK/roa-workshop-templates/assets/63344191/e556ebd5-f95f-4b40-9022-8013dbe5af68

character used in demo: [Tester (by Bar-Kun)](https://steamcommunity.com/sharedfiles/filedetails/?id=2859046287&searchtext=tester)

## Features

- Customize duration of crouch startup and recovery animations.
- ...that's it.

## Installation

1. Paste the following code into `init.gml`:

    ```gml
    // Crouch Animation Start/End Customization by @SupersonicNK
    crouch_start_time = 12; // time in frames it takes for crouch start to stop.
    crouch_end_time = 12; // time in frames it takes for crouch stop to stop. interruptable.

    // Custom Crouch Internal Variables (managed by the code)
    ccrouch_playing = false; // whether the custom crouch animation is playing
    ccrouch_phase = 0; // 0 = start, 1 = loop, 2 = uncrouch
    ccrouch_timer = 0; // timer for the crouch anim
    ccrouch_percent = 0; // 0-1, used to calculate what frame to use when rapidly crouching and uncrouching
    ```

2. Paste the following code into `animation.gml`:

    ```gml
    custom_crouch() // run the custom crouch code

    // Defines always go at the bottom of the file.
    #define custom_crouch()
    // Crouch Animation Start/End Customization by @SupersonicNK
    if state == PS_CROUCH {
        crouch_spr = sprite_index; //this should technically account for skin handler in most cases lol
        if !ccrouch_playing {
            ccrouch_playing = true;
            ccrouch_phase = 0;
            ccrouch_timer = 0;
            ccrouch_percent = 0;
        }
    } else if state != PS_IDLE {
        ccrouch_playing = false;
    }

    if ccrouch_playing {
        var duration
        switch (ccrouch_phase) {
            case 0: 
                duration = crouch_start_time;
                ccrouch_percent = clamp(ccrouch_timer/duration,0,1)
                image_index = lerp(0,crouch_startup_frames,ccrouch_percent)
                if ccrouch_percent == 1 { // to loop
                    ccrouch_phase = 1;
                    ccrouch_timer = 0;
                }else if !down_down { // to uncrouch
                    ccrouch_timer = floor(crouch_end_time * (1-ccrouch_percent));
                    ccrouch_phase = 2;
                }
                break;
            case 1:
                image_index = crouch_startup_frames + ( (ccrouch_timer) * crouch_anim_speed % crouch_active_frames )
                if !down_down {
                    ccrouch_timer = 0;
                    ccrouch_phase = 2;
                }
                break;
            case 2: // uncrouch
                duration = crouch_end_time+1; // the + 1 is so the frame time is accurate due to how i stop it
                ccrouch_percent = clamp(ccrouch_timer/duration,0,1)
                if !down_down && ccrouch_percent == 1 { // finish crouching. interrupting it here 
                    ccrouch_playing = false;
                    break;
                }
                sprite_index = crouch_spr; // this is the only part of crouch that needs the sprite to be set to crouch lol
                var start = crouch_startup_frames+crouch_active_frames;
                image_index = lerp(start, start+crouch_recovery_frames, ccrouch_percent)
                if down_down { // recrouch
                    ccrouch_timer = floor(crouch_start_time * (1-ccrouch_percent))
                    ccrouch_phase = 0;
                }
                break;
        }
        ccrouch_timer++;
    }
    ```

3. In `init.gml`, tweak the `crouch_start_time` and `crouch_end_time` until the crouch/uncrouch animations play at the speed you desire.
