---@diagnostic disable: undefined-global
local logger = require 'mentoolkit.lib.logger' ('wintermourn.pmdorand', 'PMDORAND')
local CONST = require 'wintermourn_pmdorand.lib.constants'
    local perform = CONST.PERFORM_LATER;
local data = require 'wintermourn_pmdorand.randomizer.data';

local options_menu = require 'mentoolkit.menus.reflowing_options'
local paginated_menu = require 'mentoolkit.menus.paginated_options'

local randomizer = {
    menu = {},
    Data = data
}

local topMenu;
randomizer.OpenMenu = function ()
    local menu;
    if topMenu == nil then
        topMenu = paginated_menu(8,8,220,131);
        menu = topMenu;
        ---@cast menu mentoolkit.PaginatedOptions
        menu.title = "PMDO Randomizer v0.0";
        --menu.allowVerticalPageSwitch = false;

        local frontPage = menu:AddPage();

        frontPage:AddButton(STRINGS:FormatKey("pmdorand:wip"), require 'wintermourn_pmdorand.randomizer.pages.changelog')
            :SetLabel('center', data.lastModified)
            :SetLabel('right', data.version);
        frontPage:AddSpacer(6)
        frontPage:AddText("[color=#a0a0a0]Currently Randomized?"):SetLabel('right', "[color=#ff3030]Not Tracked[color]");
        --[[ menu:AddButton("\n", CONST.FUNCTION_EMPTY).labels = {
            left = "Enabled\n - no functionality",
            center = "test",
            right = "[color=#ffbebe]No[color]"
        }; ]]
        local randomize = frontPage:AddButton("Randomize", CONST.FUNCTION_EMPTY):SetLabel('right', '');
        randomize.labels.right = '';
        randomize.actions.onSelected = function ()
            randomize:SetLabel('right', '[color=#aaaaaa]working...');
            --- Run the randomizer as a coroutine. We don't want the game sitting there completely locked up.
            local c = coroutine.create(require 'wintermourn_pmdorand.randomizer.generators.run');
            data.updateCoroutine = c;
            --- Start generation coroutine and check for starting errors
            local output, error = coroutine.resume(c, randomize, menu);
            if not output and error then logger:err(error); end
        end

        frontPage:AddButton("Clear Randomization", function ()
            local confirmation = _MENU:CreateQuestion(
                STRINGS:FormatKey("pmdorand:top.clear"),
                perform 'wintermourn_pmdorand.randomizer.clear',
                CONST.FUNCTION_EMPTY
            );
            _MENU:AddMenu(confirmation, false);
        end);

        local generationPage = topMenu:AddPage();
        generationPage:AddHeader("[color=#aaaaaa]Generation");
        generationPage:AddSubmenuButton(STRINGS:FormatKey("pmdorand:top.seeding"), perform 'wintermourn_pmdorand.randomizer.pages.seeding');
        generationPage:AddSubmenuButton(STRINGS:FormatKey("pmdorand:top.save"), perform 'wintermourn_pmdorand.randomizer.pages.saved_options');

        local optionsPage = topMenu:AddPage();
        optionsPage:AddHeader("[color=#aaaaaa]Randomization Options");
        optionsPage:AddSubmenuButton(STRINGS:FormatKey("pmdorand:top.pokemon"), perform 'wintermourn_pmdorand.randomizer.pages.pokemon');
        optionsPage:AddSubmenuButton(STRINGS:FormatKey("pmdorand:top.moves"), perform 'wintermourn_pmdorand.randomizer.pages.moves');
        optionsPage:AddSubmenuButton(STRINGS:FormatKey("pmdorand:top.items"), perform 'wintermourn_pmdorand.randomizer.pages.items');
        optionsPage:AddSubmenuButton(STRINGS:FormatKey("pmdorand:top.dungeons"), CONST.FUNCTION_EMPTY);
        optionsPage:AddSubmenuButton(STRINGS:FormatKey("pmdorand:top.naming"), perform 'wintermourn_pmdorand.randomizer.pages.naming');
        optionsPage:AddSubmenuButton(STRINGS:FormatKey("pmdorand:top.statuses"), perform 'wintermourn_pmdorand.randomizer.pages.statuses');

        randomizer.menu.top = topMenu;
    else
        menu = topMenu;
    end
    ---@cast menu mentoolkit.Options

    menu:Open(true);
end

randomizer.Randomize = function ()
    -- TODO
end

randomizer.UndoRandomization = function ()
    -- TODO
end

return randomizer