local CONST = require 'wintermourn_pmdorand.lib.constants'
local data = require 'wintermourn_pmdorand.randomizer.data'

local options_menu = require 'mentoolkit.menus.reflowing_options'
local moves_menu;

return function()
    if moves_menu == nil then
        moves_menu = options_menu(16,40,220,89);
        moves_menu.title = "Moves"

        moves_menu:AddButton("Randomization", function (self)
            data.options.moves.enabled = not data.options.moves.enabled;
            self.labels.right = data.language.toggle(data.options.moves.enabled);
            self.menuElements.right:SetText(self.labels.right);
        end).labels.right = data.language.toggle(data.options.moves.enabled);
        moves_menu:AddSubmenuButton("Typing", CONST.FUNCTION_EMPTY);
        moves_menu:AddSubmenuButton("Stats", CONST.FUNCTION_EMPTY);
        moves_menu:AddSubmenuButton("Effective Range", CONST.FUNCTION_EMPTY);
    end
    moves_menu:Open(true);
end