local CONST = require 'pmdorand.lib.constants'

local options_menu = require 'mentoolkit.menus.reflowing_options'
local statuses_menu;

return function()
    if statuses_menu == nil then
        statuses_menu = options_menu(16,40,220,76);
        statuses_menu.title = "Statuses"

        statuses_menu:AddButton("Randomization", CONST.FUNCTION_EMPTY).labels.right = STRINGS:FormatKey("pmdorand:option.disabled");
        statuses_menu:AddSubmenuButton("Duration", CONST.FUNCTION_EMPTY);
        statuses_menu:AddSubmenuButton("Potency", CONST.FUNCTION_EMPTY);
    end
    statuses_menu:Open(true);
end