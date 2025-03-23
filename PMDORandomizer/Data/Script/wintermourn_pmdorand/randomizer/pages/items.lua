local CONST = require 'wintermourn_pmdorand.lib.constants'
local Data = require 'wintermourn_pmdorand.randomizer.data'

local options_menu = require 'mentoolkit.menus.reflowing_options'
local items_menu;

local buttons = {};

return function()
    if items_menu == nil then
        items_menu = options_menu(16,40,220,89);
        items_menu.title = "Items"

        items_menu:AddButton("Randomization", CONST.FUNCTION_EMPTY).labels.right = STRINGS:FormatKey("RANDOMIZER_OPTION_DISABLED");
        buttons.sprites = items_menu:AddSubmenuButton("Sprites", CONST.FUNCTION_EMPTY);
        buttons.prices = items_menu:AddSubmenuButton("Prices & Stacks", CONST.FUNCTION_EMPTY);
        buttons.uses = items_menu:AddSubmenuButton("Item Uses", CONST.FUNCTION_EMPTY);
    end
    items_menu:Open(true);
end