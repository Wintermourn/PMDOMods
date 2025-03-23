local CONST = require 'wintermourn_pmdorand.lib.constants'
local data = require 'wintermourn_pmdorand.randomizer.data'

local options_menu = require 'mentoolkit.menus.reflowing_options'
local pokemon_menu;

local buttons = {};

return function()
    if pokemon_menu == nil then
        pokemon_menu = options_menu(16,40,220,115);
        pokemon_menu.title = "Pokemon"

        pokemon_menu:AddButton("Randomization", function (self)
            data.options.pokemon.enabled = not data.options.pokemon.enabled;
            self.labels.right = data.language.toggle(data.options.pokemon.enabled);
            self.menuElements.right:SetText(self.labels.right);
        end).labels.right = data.language.toggle(data.options.pokemon.enabled);
        buttons.typing = pokemon_menu:AddSubmenuButton("Typing", CONST.FUNCTION_EMPTY);
        buttons.evolution = pokemon_menu:AddSubmenuButton("Evolutions", CONST.FUNCTION_EMPTY);
        buttons.stats = pokemon_menu:AddSubmenuButton("Stats", CONST.FUNCTION_EMPTY);
        buttons.moves = pokemon_menu:AddSubmenuButton("Movesets", CONST.FUNCTION_EMPTY);
        buttons.intrinsics = pokemon_menu:AddSubmenuButton("Intrinsics", CONST.FUNCTION_EMPTY);
    end
    pokemon_menu:Open(true);
end