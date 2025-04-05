local CONST = require 'pmdorand.lib.constants'
    local Environment = CONST.Classes.System.Environment;
local data = require 'pmdorand.randomizer.data'

local ucache = require 'pmdorand.randomizer.utilitycache'

local item_randomizer = {
}

item_randomizer.Randomize = function ()
    --- Check if item is consumable
    -- (PMDC.Dungeon.EdibleState)
    -- (PMDC.Dungeon.OrbState)
    local max = #ucache.items;
    local maxlen = tostring(max):len();
    local digitTag = '%0'.. maxlen ..'d';
    local nextBreak = Environment.TickCount64+100;

    local itemTraits = {
        consumable = false,
        equipable = false,
        beneficial = false,
        harmful = false
    }
    for i, key in pairs(ucache.items) do

        if Environment.TickCount64 > nextBreak then
            data.updateRoutineUtils.menuOption:SetLabel('right', string.format("[color=#aaaaaa]I".. digitTag .."/%s", i, max));
            coroutine.yield(); nextBreak = Environment.TickCount64+100;
        end
    end
end

return item_randomizer;