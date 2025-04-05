local CONST = require 'wintermourn_pmdorand.lib.constants'
local data = require 'wintermourn_pmdorand.randomizer.data'

local options_menu = require 'mentoolkit.menus.reflowing_options'
local items_menu;

return function()
    if items_menu == nil then
        items_menu = options_menu(16,40,220,89);
        items_menu.title = "Items"

        items_menu:AddButton("Randomization", function (self)
            data.options.items.enabled = not data.options.items.enabled;
            self.labels.right = data.language.toggle(data.options.items.enabled);
            self.menuElements.right:SetText(self.labels.right);
        end).labels.right = data.language.toggle(data.options.items.enabled);
        items_menu:AddSubmenuButton("Sprites", CONST.FUNCTION_EMPTY);
        items_menu:AddSubmenuButton("Prices & Stacks", CONST.FUNCTION_EMPTY);
        items_menu:AddSubmenuButton("Item Effects", CONST.FUNCTION_EMPTY);
    end
    items_menu:Open(true);
end