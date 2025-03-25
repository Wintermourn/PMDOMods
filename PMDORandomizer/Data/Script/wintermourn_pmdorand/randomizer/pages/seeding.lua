---@diagnostic disable: inject-field, undefined-field
local logger = require 'mentoolkit.lib.logger' ('wintermourn.pmdorand', 'PMDORAND');

local CONST = require 'wintermourn_pmdorand.lib.constants'
local Data = require 'wintermourn_pmdorand.randomizer.data'

local options_menu = require 'mentoolkit.menus.reflowing_options'
local paginated_menu = require 'mentoolkit.menus.paginated_options'
---@type mentoolkit.PaginatedOptions, mentoolkit.PaginatedOptions.Page;
local seeding_menu, loose_seed_page;

local function DisplayStringShared(var)
    return var ~= '' and '\''.. var ..'\'' or '[color=#aaaaaa]- Random -[color]'
end

local function DisplayString(var)
    return var ~= '' and '\''.. var ..'\'' or '[color=#aaaaaa]---[color]'
end

-- https://stackoverflow.com/a/1647577
local function split(self)
    local st, g = 1, self:gmatch("()(%.)")
    local function getter(segs, seps, sep, cap1, ...)
      st = sep and seps + #sep
      return self:sub(segs, (seps or 0) - 1), cap1 or sep, ...
    end
    return function() if st then return getter(st, g()) end end
  end

local function SeedMenuCallback(seed, callback)
    local menu = RogueEssence.Menu.TeamNameMenu(
        STRINGS:FormatKey("INPUT_SEED_TITLE"),
        STRINGS:FormatKey("INPUT_CAN_PASTE"),
        130, seed, callback);

    _MENU:AddMenu(menu, true);
end

local function SeedMenu(button, path)
    return function ()
        ---@type string|table
        local target, lastSeg = Data.seeding, '';
        for seg in split(path) do
            if type(target[seg]) ~= "table" then lastSeg = seg; break end
            target = target[seg];
        end

        SeedMenuCallback(target[lastSeg], function (seed)
            target[lastSeg] = seed;
            button:SetLabel('right', DisplayString(seed));
        end);
    end
end

local function SharedSeedMenu(button, path)
    return function ()
        ---@type string|table
        local target, lastSeg = Data.seeding, '';
        for seg in split(path) do
            if type(target[seg]) ~= "table" then lastSeg = seg; break end
            target = target[seg];
        end

        SeedMenuCallback(target[lastSeg], function (seed)
            target[lastSeg] = seed;
            button:SetLabel('right', DisplayString(seed));
        end);
    end
end

local function createButton(label, path)
    local button = loose_seed_page:AddButton(label, CONST.FUNCTION_EMPTY);
    button.actions.onSelected = SeedMenu(button, path);
    button:SetCallback('onRefresh', function (self)
        ---@type string|table
        local target, lastSeg = Data.seeding, '';
        for seg in split(path) do
            logger:debug(seg);
            if type(target[seg]) ~= "table" then lastSeg = seg; break end
            target = target[seg];
        end

        self:SetLabel('right', DisplayString(target[lastSeg]));
    end)
    button.__seed = {path = path};
end

local function createSharedButton()
    local button = loose_seed_page:AddButton("Shared Seed", CONST.FUNCTION_EMPTY);
    button.actions.onSelected = SharedSeedMenu(button, 'shared_seed');
    button:SetCallback('onRefresh', function (self)
        self:SetLabel('right', DisplayStringShared(Data.seeding.shared_seed));
    end)
    button.__seed = {path = 'shared_seed', shared = true};
end

logger:debug(tostring(CONST.Classes.Xna.Keys.Delete));

---@param self mentoolkit.PaginatedOptions
---@param input any
---@return boolean
local function menu_input (self, input)
    if input:BaseKeyPressed(CONST.Classes.Xna.Keys.Delete) then
        local currentOption = self.pages[self.currentPage].contents[self.currentSelection];
        if currentOption.__seed ~= nil then
            _GAME:SE("Menu/Cancel");
            ---@type string|table
            local target, lastSeg = Data.seeding, '';
            for seg in split(currentOption.__seed.path) do
                logger:debug(seg);
                if type(target[seg]) ~= "table" then lastSeg = seg; break end
                target = target[seg];
            end
    
            target[lastSeg] = '';
            currentOption:SetLabel('right', (currentOption.__seed.shared and DisplayStringShared or DisplayString)
            ( target[lastSeg] ));
            --seeding_menu:Rebuild();
            return true;
        end
    end
    return false;
end

return function()
    if seeding_menu == nil then
        seeding_menu = paginated_menu(32,96,256,127);
        seeding_menu.title = "Seeding"
        seeding_menu.onInput = menu_input;

        loose_seed_page = seeding_menu:AddPage();

        loose_seed_page:AddHeader(STRINGS:FormatKey("pmdorand:seed.clear"))
        createSharedButton();

        loose_seed_page:AddSpacer(4);

        createButton("Naming", 'seeds.naming');
        createButton("Items", 'seeds.items');
        createButton("Statuses", 'seeds.statuses');

        local second_page = seeding_menu:AddPage();

        second_page:AddHeader("[color=#aaaaaa]Submenus");
        second_page:AddSubmenuButton("Pokemon", CONST.FUNCTION_EMPTY);
        second_page:AddSubmenuButton("Dungeon", CONST.FUNCTION_EMPTY);
        second_page:AddSubmenuButton("Moves", CONST.FUNCTION_EMPTY);
    end
    seeding_menu:Open(true);
end