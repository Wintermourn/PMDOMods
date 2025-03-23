local logger = require 'mentoolkit.lib.logger' ('wintermourn.pmdorand', 'PMDORAND');

local CONST = require 'wintermourn_pmdorand.lib.constants'
local Data = require 'wintermourn_pmdorand.randomizer.data'

local options_menu = require 'mentoolkit.menus.reflowing_options'
local seeding_menu;

local function DisplayStringShared(var)
    return var ~= '' and '\''.. var ..'\'' or '[color=#aaaaaa]- Random -[color]'
end

local function DisplayString(var)
    return var ~= '' and '\''.. var ..'\'' or '[color=#aaaaaa]---[color]'
end

local function SeedMenuCallback(seed, callback)
    --local menu = RogueEssence.Menu.SeedInputMenu(callback, tonumber(seed, 16));
    local menu = RogueEssence.Menu.TeamNameMenu(
        STRINGS:FormatKey("INPUT_SEED_TITLE"),
        STRINGS:FormatKey("INPUT_CAN_PASTE"),
        130, seed, callback);

    _MENU:AddMenu(menu, true);
end

local function SeedMenu(button, table, key)
    return function ()
        SeedMenuCallback(table[key], function (seed)
            table[key] = seed;
            button.labels.right = DisplayString(seed);
            seeding_menu:Rebuild();
        end);
    end
end

local function SharedSeedMenu(button, table, key)
    return function ()
        SeedMenuCallback(table[key], function (seed)
            table[key] = seed;
            button.labels.right = DisplayStringShared(seed);
            seeding_menu:Rebuild();
        end);
    end
end

local function createButton(label, table, key)
    local button = seeding_menu:AddButton(label, CONST.FUNCTION_EMPTY);
    button.onSelected = SeedMenu(button, table, key);
    button.labels.right = DisplayString(table[key]);
    button.__seed = {table = table, key = key};
end

local function createSharedButton()
    local button = seeding_menu:AddButton("Shared Seed", CONST.FUNCTION_EMPTY);
    button.onSelected = SharedSeedMenu(button, Data.seeding, 'shared_seed');
    button.labels.right = DisplayStringShared(Data.seeding.shared_seed);
    button.__seed = {table = Data.seeding, key = 'shared_seed', shared = true};
end

logger:debug(tostring(CONST.Classes.Xna.Keys.Delete));

---@param self mentoolkit.Options
---@param input any
---@return boolean
local function menu_input (self, input)
    if input:BaseKeyPressed(CONST.Classes.Xna.Keys.Delete) then
        local currentOption = self.options[self.currentSelection];
        if currentOption.__seed ~= nil then
            _GAME:SE("Menu/Cancel");
            currentOption.__seed.table[currentOption.__seed.key] = '';
            currentOption.labels.right = (currentOption.__seed.shared and DisplayStringShared or DisplayString)
                ( currentOption.__seed.table[currentOption.__seed.key] );
            seeding_menu:Rebuild();
            return true;
        end
    end
    return false;
end

return function()
    if seeding_menu == nil then
        seeding_menu = options_menu(32,96,256,127);
        seeding_menu.title = "Seeding"
        seeding_menu.onInput = menu_input;

        seeding_menu:AddHeader(STRINGS:FormatKey("pmdorand:seed.clear"))
        createSharedButton();

        seeding_menu:AddSpacer(4);

        createButton("Naming", Data.seeding.seeds, 'naming');
        createButton("Items", Data.seeding.seeds, 'items');
        createButton("Statuses", Data.seeding.seeds, 'statuses');

        seeding_menu:PageBreak();

        seeding_menu:AddHeader("[color=#aaaaaa]Submenus");
        seeding_menu:AddSubmenuButton("Pokemon", CONST.FUNCTION_EMPTY);
        seeding_menu:AddSubmenuButton("Dungeon", CONST.FUNCTION_EMPTY);
        seeding_menu:AddSubmenuButton("Moves", CONST.FUNCTION_EMPTY);
    end
    seeding_menu:Open(true);
end