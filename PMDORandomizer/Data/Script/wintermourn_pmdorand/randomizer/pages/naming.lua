local CONST = require 'wintermourn_pmdorand.lib.constants'
local data = require 'wintermourn_pmdorand.randomizer.data'

local options_menu = require 'mentoolkit.menus.reflowing_options'
local naming_menu;

return function()
    if naming_menu == nil then
        naming_menu = options_menu(16,40,220,115);
        naming_menu.title = "Naming"

        naming_menu:AddButton("Randomization", function (self)
            data.options.naming.enabled = not data.options.naming.enabled;
            self.labels.right = data.language.toggle(data.options.naming.enabled);
            self.menuElements.right:SetText(self.labels.right);
        end).labels.right = data.language.toggle(data.options.naming.enabled);
        naming_menu:AddSubmenuButton("Shared", CONST.FUNCTION_EMPTY);
        naming_menu:AddSubmenuButton("Pokemon", CONST.FUNCTION_EMPTY);
        naming_menu:AddSubmenuButton("Items", CONST.FUNCTION_EMPTY);
        naming_menu:AddSubmenuButton("Moves", CONST.FUNCTION_EMPTY);
        naming_menu:AddSubmenuButton("Dungeons", CONST.FUNCTION_EMPTY);
    end
    naming_menu:Open(true);
end