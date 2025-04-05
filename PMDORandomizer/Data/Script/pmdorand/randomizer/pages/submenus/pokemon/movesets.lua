local paginated_options = require 'mentoolkit.menus.paginated_options'
local data = require 'pmdorand.randomizer.data'
local menu = paginated_options(24, 56, 220, 115);
menu.title = "Pokemon > Movesets";
menu:AddDescriptionPanel(0,185,320,55);

local frontPage = menu:AddPage();

frontPage
    :AddButton("Randomization", function (self)
        data.options.pokemon.moves.enabled = not data.options.pokemon.moves.enabled;
        self:SetLabel('right', data.language.toggle(data.options.pokemon.moves.enabled));
    end)
    :SetCallback('onRefresh', function (self)
        self:SetLabel('right', data.language.toggle(data.options.pokemon.moves.enabled));
    end)
    :SetDescription(data.language.descriptionText("pmdorand:pkmn.moves.rand"));

frontPage:AddHeader("[color=#aaaaaa]Starting Moves");

frontPage
    :AddButton("Total Starting Moves", function (self)
        data.options.pokemon.moves.guaranteedStartingMoves = (data.options.pokemon.moves.guaranteedStartingMoves % 12)+ 1;
        self:SetLabel('right', tostring(data.options.pokemon.moves.guaranteedStartingMoves));
    end)
    :SetCallback('onRefresh', function (self)
        self:SetLabel('right', tostring(data.options.pokemon.moves.guaranteedStartingMoves));
    end)
    :SetDescription(data.language.descriptionText("pmdorand:pkmn.moves.initialMoves"));

frontPage
    :AddButton("Guaranteed Attacks", function (self)
        data.options.pokemon.moves.ensuredAttackingMoves = (data.options.pokemon.moves.ensuredAttackingMoves % data.options.pokemon.moves.guaranteedStartingMoves)+ 1;
        self:SetLabel('right', tostring(data.options.pokemon.moves.ensuredAttackingMoves));
    end)
    :SetCallback('onRefresh', function (self)
        self:SetLabel('right', tostring(data.options.pokemon.moves.ensuredAttackingMoves));
    end)
    :SetDescription(data.language.descriptionText("pmdorand:pkmn.moves.initialAttacks"));

return function ()
    menu:Open(true);
end;