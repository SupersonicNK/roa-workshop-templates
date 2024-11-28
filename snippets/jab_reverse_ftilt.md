# Whiff Jab -> Reverse FTilt

Did you know that in base cast, you can buffer a reverse FTilt out of Jab 1 or 2 endlag? In workshop, trying to do it gives you the next jab in the string without extra code.
That being said, here's some extra code. Add this to your jab in `attack_update.gml`.

```gml
if (right_down-left_down == -spr_dir && down_down-up_down == 0 && !has_hit && !has_hit_player) {
    var win_time = get_window_value(attack,window,AG_WINDOW_LENGTH);
    set_window_value(attack,window,AG_WINDOW_CANCEL_FRAME, win_time);
    if get_window_value(attack,window,AG_WINDOW_CANCEL_TYPE) != 0 && window_timer == win_time {
        set_state(PS_IDLE);
        // if you get ftilt frame-perfectly on parry you can carry the parry lag over
        // that doesn't happen in base cast so this fixes that
        was_parried = false; 
    }
} else {
    reset_window_value(attack,window,AG_WINDOW_CANCEL_FRAME);
}
```
