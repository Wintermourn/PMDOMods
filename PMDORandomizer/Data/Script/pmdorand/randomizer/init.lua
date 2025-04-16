---@diagnostic disable: undefined-global
local logger = require 'mentoolkit.lib.logger' ('wintermourn.pmdorand', 'PMDORAND')
local CONST = require 'pmdorand.lib.constants'
    local perform = CONST.PERFORM_LATER;
local data = require 'pmdorand.randomizer.data';

local paginated_menu = require 'mentoolkit.menus.paginated_options'

local randomizer = {
    menu = {},
    Data = data
}

local topMenu;
randomizer.OpenMenu = function ()
    local menu;
    if topMenu == nil then
        topMenu = paginated_menu.create(8,8,220,131);
        menu = topMenu;
        ---@cast menu mentoolkit.PaginatedOptions
        menu.title = "PMDO Randomizer ".. data.version;
        menu.showPageNumber = true;
        --menu.allowVerticalPageSwitch = false;

        local frontPage = menu:AddPage();

        frontPage:AddButton("[$pmdorand:wip]", require 'pmdorand.randomizer.pages.changelog')
            :SetLabel('center', data.lastModified)
            :SetLabel('right', data.version);
        frontPage:AddSpacer(6)
        frontPage:AddText("[^gray]Currently Randomized?"):SetLabel('right', "[color=#ff3030]Not Tracked[color]");
        --[[ menu:AddButton("\n", CONST.FUNCTION_EMPTY).labels = {
            left = "Enabled\n - no functionality",
            center = "test",
            right = "[color=#ffbebe]No[color]"
        }; ]]
        local randomize = frontPage:AddButton("Randomize", CONST.FUNCTION_EMPTY):SetLabel('right', '');
        randomize.labels.right = '';
        randomize.actions.onSelected = function ()
            if data.lockRandomizerButton then return end
            randomize:SetLabel('right', '[^gray]working...');
            --- Run the randomizer as a coroutine. We don't want the game sitting there completely locked up.
            local c = coroutine.create(require 'pmdorand.randomizer.generators.run');
            data.updateCoroutine = c;
            --- Start generation coroutine and check for starting errors
            local output, error = coroutine.resume(c, randomize, menu);
            if not output and error then logger:err(error); end
        end

        frontPage:AddButton("Clear Randomization", function ()
            local confirmation = _MENU:CreateQuestion(
                STRINGS:FormatKey("pmdorand:top.clear"),
                perform 'pmdorand.randomizer.clear',
                CONST.FUNCTION_EMPTY
            );
            _MENU:AddMenu(confirmation, false);
        end);

        local generationPage = topMenu:AddPage();
        generationPage:AddHeader("[^gray]Generation");
        generationPage:AddSubmenuButton("[$pmdorand:top.seeding]", perform 'pmdorand.randomizer.pages.seeding');
        generationPage:AddSubmenuButton("[$pmdorand:top.save]", perform 'pmdorand.randomizer.pages.saved_options');

        local optionsPage = topMenu:AddPage();
        optionsPage:AddHeader("[^gray]Randomization Options");
        optionsPage:AddSubmenuButton("[$pmdorand:top.pokemon]", perform 'pmdorand.randomizer.pages.pokemon');
        optionsPage:AddSubmenuButton("[$pmdorand:top.moves]", perform 'pmdorand.randomizer.pages.moves');
        optionsPage:AddSubmenuButton("[$pmdorand:top.items]", perform 'pmdorand.randomizer.pages.items');
        optionsPage:AddSubmenuButton("[$pmdorand:top.dungeons]", CONST.FUNCTION_EMPTY);
        optionsPage:AddSubmenuButton("[$pmdorand:top.naming]", perform 'pmdorand.randomizer.pages.naming');
        optionsPage:AddSubmenuButton("[$pmdorand:top.statuses]", perform 'pmdorand.randomizer.pages.statuses');

        randomizer.menu.top = topMenu;
    else
        menu = topMenu;
    end
    ---@cast menu mentoolkit.Options

    require 'pmdorand.randomizer.generators.ItemEffects' .LoadAll();
    menu:Open(true);
end

randomizer.Randomize = function ()
    -- TODO
end

randomizer.UndoRandomization = function ()
    -- TODO
end

return randomizer