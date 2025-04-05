local paginated_options = require 'mentoolkit.menus.paginated_options'
local data = require 'pmdorand.randomizer.data'
local menu = paginated_options(24, 56, 220, 115);
menu.title = "Pokemon > Typing";
menu:AddDescriptionPanel(0,185,320,55);

local frontPage = menu:AddPage();

frontPage
    :AddButton("Randomization", function (self)
        data.options.pokemon.typing.enabled = not data.options.pokemon.typing.enabled;
        self:SetLabel('right', data.language.toggle(data.options.pokemon.typing.enabled));
    end)
    :SetCallback('onRefresh', function (self)
        self:SetLabel('right', data.language.toggle(data.options.pokemon.typing.enabled));
    end)
    :SetDescription(data.language.descriptionText("pmdorand:pkmn.typing.rand"));

frontPage:AddHeader("[color=#aaaaaa]Dual Typing");

frontPage
    :AddButton("Allow Duplicates", function (self)
        data.options.pokemon.typing.allowDuplicateTyping = not data.options.pokemon.typing.allowDuplicateTyping;
        self:SetLabel('right', data.language.toggle(data.options.pokemon.typing.allowDuplicateTyping));
    end)
    :SetCallback('onRefresh', function (self)
        self:SetLabel('right', data.language.toggle(data.options.pokemon.typing.allowDuplicateTyping));
    end)
    :SetDescription(data.language.descriptionText("pmdorand:pkmn.typing.duplicates"));

frontPage
    :AddButton("Keep Dual Typing", function (self)
        data.options.pokemon.typing.retainDualTyping = not data.options.pokemon.typing.retainDualTyping;
        self:SetLabel('right', data.language.toggle(data.options.pokemon.typing.retainDualTyping));
    end)
    :SetCallback('onRefresh', function (self)
        self:SetLabel('right', data.language.toggle(data.options.pokemon.typing.retainDualTyping));
    end)
    :SetDescription(data.language.descriptionText("pmdorand:pkmn.typing.retainDual"));

frontPage
    :AddButton("Type Retainment", function (self)
        local value = data.options.pokemon.typing.typeRetainment;
        if value == 1 then value = 2 elseif value == 2 then value = false else value = 1 end
        data.options.pokemon.typing.typeRetainment = value;
        self:SetLabel('right', STRINGS:FormatKey("pmdorand:option.".. (value == 1 and 'first' or (value == 2 and 'second') or 'disabled')));
    end)
    :SetCallback('onRefresh', function (self)
        local value = data.options.pokemon.typing.typeRetainment;
        self:SetLabel('right', STRINGS:FormatKey("pmdorand:option.".. (value == 1 and 'first' or (value == 2 and 'second') or 'disabled')));
    end)
    :SetDescription(data.language.descriptionText("pmdorand:pkmn.typing.retainment"));

return function ()
    menu:Open(true);
end;