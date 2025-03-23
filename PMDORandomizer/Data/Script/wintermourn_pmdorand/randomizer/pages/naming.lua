local CONST = require 'wintermourn_pmdorand.lib.constants'

local options_menu = require 'mentoolkit.menus.reflowing_options'
local naming_menu;

return function()
    if naming_menu == nil then
        naming_menu = options_menu(16,40,220,102);
        naming_menu.title = "Naming"

        naming_menu:AddButton("Randomization", CONST.FUNCTION_EMPTY).labels.right = STRINGS:FormatKey("pmdorand:option.disabled");
        naming_menu:AddSubmenuButton("Pokemon", CONST.FUNCTION_EMPTY);
        naming_menu:AddSubmenuButton("Items", CONST.FUNCTION_EMPTY);
        naming_menu:AddSubmenuButton("Moves", CONST.FUNCTION_EMPTY);
        naming_menu:AddSubmenuButton("Dungeons", CONST.FUNCTION_EMPTY);
    end
    naming_menu:Open(true);
end