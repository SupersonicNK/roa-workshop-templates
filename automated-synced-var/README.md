# Automated Synced Variable

Well... MOSTLY automated.

## Features

- Error detection
- Ease of use
  - Synced variables can be accessed as easily as calling `synced_var.my_variable`.
- No longer requires any bitwise on your end.

## Installation

1. Put the [user event](https://raw.githubusercontent.com/SupersonicNK/roa-workshop-templates/master/automated-synced-var/scr/user_event5.gml) into your `scripts/` folder.
2. In `css_update.gml`, near the bottom of the file but above any `#defines`, call the user event.  
    ( By default, this would be `user_event(5)` ).
3. In `init.gml`, near the top of the file, call the user event again.

## Usage

After installing the user event, the first thing you should do is **define your variables in the user event**.  
On line 21 of the user event, you should see the following:

```gml
#define define_vars()

// Define your synced variables here!
// Example:
//    add_var( "my_variable", 4 );
// In this example, I'm adding a variable named my_variable, with a maximum value of 4.
// Synced variables can only be integers.
// After defining them here, you can then access these variables as synced_var.my_variable

add_var( "my_variable", 4 );
```

You can add variables below this block using the syntax shown, `add_var( "variable_name", maximum_value );`  
By default, there is a variable named `my_variable` with a max value of `4` as an example, which can be removed.

After your variable is defined, in `css_update.gml` you can now simply do something like `synced_var.my_variable = 2;` to write to the synced variable.

It is then also available in match as `synced_var.my_variable`.

## Extra notes

You can also call the user event from the results screen, but reading the synced variable from the results screen is slightly different.  
Instead of `synced_var.my_variable`, you **must** use `synced_var[player].my_variable`.  
This is because the results screen object is shared between any player that wins the match.
