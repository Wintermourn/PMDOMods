local CONST = require 'wintermourn_pmdorand.lib.constants'
local Data = require 'wintermourn_pmdorand.randomizer.data'

local options_menu = require 'mentoolkit.menus.reflowing_options'
local naming_menu;

local buttons = {};

return function()
    if naming_menu == nil then
        naming_menu = options_menu(16,40,220,102);
        naming_menu.title = "Naming"

        naming_menu:AddButton("Randomization", CONST.FUNCTION_EMPTY).labels.right = STRINGS:FormatKey("RANDOMIZER_OPTION_DISABLED");
        buttons.pokemon = naming_menu:AddSubmenuButton("Pokemon", CONST.FUNCTION_EMPTY);
        buttons.items = naming_menu:AddSubmenuButton("Items", CONST.FUNCTION_EMPTY);
        buttons.moves = naming_menu:AddSubmenuButton("Moves", CONST.FUNCTION_EMPTY);
        buttons.dungeons = naming_menu:AddSubmenuButton("Dungeons", CONST.FUNCTION_EMPTY);
    end
    naming_menu:Open(true);
end