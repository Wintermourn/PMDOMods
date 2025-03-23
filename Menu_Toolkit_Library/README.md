> [!Warning]
> This library is basically undocumented. And also poorly put together.
# Menu Toolkit Library
A library for scripted menus, made to split them from PMDOR's code.
## How to use
When the mod is loaded, require the scripts in `mentoolkit.menus` that match with the kind of menu that you want to use. This will return a function that will create the menu when called.
For example,
```lua
local options_menu = require 'mentoolkit.menus.reflowing_options`
-- Create a menu at 8,8 at the size 128x128
local menu = options_menu(8,8,128,128)
-- Add an option
menu:AddButton("My Button", function() end)
menu:Open(true)
```

## Todo
- [ ] Add function to insert options into top menu, options, ...
    - [ ] Generate option depending on how many additions are wanted (Create submenu if >1 insertions)
