local CONST = require 'pmdorand.lib.constants'
local data = require 'pmdorand.randomizer.data'
local perform = CONST.PERFORM_LATER

local options_menu = require 'mentoolkit.menus.reflowing_options'
local pokemon_menu;


return function()
    if pokemon_menu == nil then
        pokemon_menu = options_menu(16,40,220,115);
        pokemon_menu.title = "Pokemon"

        pokemon_menu:AddButton("Randomization", function (self)
            data.options.pokemon.enabled = not data.options.pokemon.enabled;
            self.labels.right = data.language.toggle(data.options.pokemon.enabled);
            self.menuElements.right:SetText(self.labels.right);
        end).labels.right = data.language.toggle(data.options.pokemon.enabled);
        pokemon_menu:AddSubmenuButton("Typing", perform 'pmdorand.randomizer.pages.submenus.pokemon.typing');
        pokemon_menu:AddSubmenuButton("Evolutions", CONST.FUNCTION_EMPTY);
        pokemon_menu:AddSubmenuButton("Stats", CONST.FUNCTION_EMPTY);
        pokemon_menu:AddSubmenuButton("Movesets", perform 'pmdorand.randomizer.pages.submenus.pokemon.movesets');
        pokemon_menu:AddSubmenuButton("Intrinsics", CONST.FUNCTION_EMPTY);
    end
    pokemon_menu:Open(true);
end