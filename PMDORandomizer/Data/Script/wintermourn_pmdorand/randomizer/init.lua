---@diagnostic disable: undefined-global
local logger = require 'mentoolkit.lib.logger' ('wintermourn.pmdorand', 'PMDORAND')
local CONST = require 'wintermourn_pmdorand.lib.constants'
    local perform = CONST.PERFORM_LATER;
    local performwith = CONST.PERFORM_INSIDE_LATER;

local options_menu = require 'mentoolkit.menus.reflowing_options'

local randomizer = {
    Data = require 'wintermourn_pmdorand.randomizer.data',
    Menus = {
        ---@type mentoolkit.Options?
        Top_Menu = nil
    }
}
local menus = {}
local topMenu = {}


randomizer.OpenMenu = function ()
    local menu;
    if randomizer.Menus.Top_Menu == nil then
        randomizer.Menus.Top_Menu = options_menu(8,8,220,131);
        menu = randomizer.Menus.Top_Menu;
        ---@cast menu mentoolkit.Options
        menu.title = "PMDO Randomizer v0.0";
        menu.allowVerticalPageSwitch = false;

        menu:AddButton("\n\n", require 'wintermourn_pmdorand.randomizer.pages.changelog').labels = {
            left = "Version\n Heavily in-development,\n problems may arise.",
            center = randomizer.Data.lastModified,
            right = randomizer.Data.version
        };
        menu:AddSpacer(6)
        menu:AddText("[color=#a0a0a0]Currently Randomized?").labels.right = "[color=#ff3030]Not Tracked[color]";
        --[[ menu:AddButton("\n", CONST.FUNCTION_EMPTY).labels = {
            left = "Enabled\n - no functionality",
            center = "test",
            right = "[color=#ffbebe]No[color]"
        }; ]]
        local randomize = menu:AddButton("Randomize", CONST.FUNCTION_EMPTY);
        randomize.labels.right = '';
        randomize.onSelected = function ()
            randomize.menuElements.right:SetText('[color=#aaaaaa]working...');
            --- Run the randomizer as a coroutine. We don't want the game sitting there completely locked up.
            local c = coroutine.create(require 'wintermourn_pmdorand.randomizer.generators.run');
            randomizer.Data.updateCoroutine = c;
            --- Start generation coroutine and check for starting errors
            local output, error = coroutine.resume(c, randomize, menu);
            if not output and error then logger:err(error); end
        end

        menu:AddButton("Clear Randomization", function ()
            local confirmation = _MENU:CreateQuestion(
                STRINGS:FormatKey("pmdorand:top.clear"),
                perform 'wintermourn_pmdorand.randomizer.clear',
                CONST.FUNCTION_EMPTY
            );
            _MENU:AddMenu(confirmation, false);
        end);
        menu:PageBreak();

        menu:AddHeader("[color=#aaaaaa]Generation");
        menu:AddSubmenuButton(STRINGS:FormatKey("pmdorand:top.seeding"), perform 'wintermourn_pmdorand.randomizer.pages.seeding');
        menu:PageBreak();

        menu:AddHeader("[color=#aaaaaa]Randomization Options");
        menu:AddSubmenuButton(STRINGS:FormatKey("pmdorand:top.pokemon"), perform 'wintermourn_pmdorand.randomizer.pages.pokemon');
        menu:AddSubmenuButton(STRINGS:FormatKey("pmdorand:top.moves"), perform 'wintermourn_pmdorand.randomizer.pages.moves');
        menu:AddSubmenuButton(STRINGS:FormatKey("pmdorand:top.items"), perform 'wintermourn_pmdorand.randomizer.pages.items');
        menu:AddSubmenuButton(STRINGS:FormatKey("pmdorand:top.dungeons"), CONST.FUNCTION_EMPTY);
        menu:AddSubmenuButton(STRINGS:FormatKey("pmdorand:top.naming"), perform 'wintermourn_pmdorand.randomizer.pages.naming');
        menu:AddSubmenuButton(STRINGS:FormatKey("pmdorand:top.statuses"), perform 'wintermourn_pmdorand.randomizer.pages.statuses');

        logger:debug("Mods path", randomizer.Data.mod.path);
    else
        menu = randomizer.Menus.Top_Menu;
    end
    ---@cast menu mentoolkit.Options

    menu:Open(true);
end

randomizer.Randomize = function ()
    if not randomizer.Data.enabled and not randomizer.State.isRandomized then return end

    if not randomizer.Data.enabled then
        randomizer.UndoRandomization();
    end
end

randomizer.UndoRandomization = function ()
    -- TODO
end

return randomizer