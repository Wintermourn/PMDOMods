local CONST = require 'pmdorand.lib.constants'
    local Environment = CONST.Classes.System.Environment;
local data = require 'pmdorand.randomizer.data'
local switch = require 'pmdorand.lib.switchcaser'
local logger = require 'mentoolkit.lib.logger' ('wintermourn.pmdorand', 'PMDORAND')

local ucache = require 'pmdorand.randomizer.utilitycache'

--- private `dict` dictionary field from the PriorityList<BattleEvent> type. Used because NLua seems to struggle with IEnumerable?
local __PriorityList_dict = CONST.Classes.System.Type.GetType
    'RogueElements.PriorityList`1[[RogueEssence.Dungeon.BattleEvent, RogueEssence]], RogueElements' :GetField('dict', CONST.Enums.BindingFlags.Convert(52));
local itemFolder = data.mod.path .. '/Data/Item/';
local originalItemFolder = RogueEssence.Data.DataManager.DATA_PATH ..'/Item/';

local item_randomizer = {
}

local knownTypesWithBaseEventField = {}

local priceMode = switch{
    [CONST.Enums.PriceMode.RAWRANDOM] = function (entry)
        -- *
    end,
    [CONST.Enums.PriceMode.RANDOMOFFSET] = function (entry)
        -- *
    end,
    [CONST.Enums.PriceMode.EVENTBASED] = function (entry)
        -- *
    end
}

local function scanEvent (flags, event, destroyer)
    local eventType = event:GetType();
    if not knownTypesWithBaseEventField then
        local baseEventField = eventType:GetField(
        "BaseEvent", CONST.Enums.BindingFlags.Convert(CONST.Enums.BindingFlags.Public | CONST.Enums.BindingFlags.Instance));
        knownTypesWithBaseEventField[eventType] = baseEventField ~= nil;
    end

    if knownTypesWithBaseEventField[eventType] then
        scanEvent(flags, event.BaseEvent, destroyer);
    else
        logger:debug(tostring(eventType))
        for i, k in pairs(data.external.items.itemEffects) do
            if k.types[eventType] then
                k.onItemRandomized(
                    ---@type PMDOR.ItemEvent.Target
                    {
                        isItem = false,
                        isEvent = true,
                        object = event,
                        Destroy = destroyer
                    },
                    data.options.items.effects[i],
                    data
                );
            end
        end
    end
end

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
    local currentEntry;
    local config = data.options.items;

    for i, key in pairs(ucache.items) do
        currentEntry = _DATA:GetItem(key);

        if config.pricing.enabled then
            priceMode(config.pricing.priceMode);
        end

        if config.effects.enabled then
            itemTraits.beneficial = false;
            itemTraits.harmful = false;
            itemTraits.consumable = false;

            local itemStateEnumerator = currentEntry.ItemStates:GetEnumerator();

            while itemStateEnumerator:MoveNext() do
                local entry = itemStateEnumerator.Current;
                if entry:GetType().Name == 'EdibleState' then
                    itemTraits.consumable = true;
                end
                if data.external.items.itemEffectTypes[entry:GetType()] then
                    local rule = data.external.items.itemEffectTypes[entry:GetType()];
                    if rule & CONST.Enums.ItemEventRule.BENEFICIAL then
                        itemTraits.beneficial = true;
                    elseif rule & CONST.Enums.ItemEventRule.HARMFUL then
                        itemTraits.harmful = true;
                    end
                end
            end

            local dictEnumerator, dictEntry, eventCount;
            for _, evs in pairs({
                currentEntry.UseEvent.OnHits
            }) do
                dictEnumerator = __PriorityList_dict:GetValue(evs):GetEnumerator();

                while dictEnumerator:MoveNext() do
                    dictEntry = dictEnumerator.Current;
                    eventCount = dictEntry.Value.Count;
                    for id = eventCount - 1, 0, -1 do
                        scanEvent(itemTraits, dictEntry.Value[id], function ()
                            dictEntry.Value:RemoveAt(id);
                        end)
                    end
                end
            end
        end

        RogueEssence.Data.Serializer.SerializeDataAsDiff(itemFolder .. key ..'.jsonpatch', originalItemFolder .. key ..'.json', currentEntry);

        if Environment.TickCount64 > nextBreak then
            data.updateRoutineUtils.menuOption:SetLabel('right', string.format("[color=#aaaaaa]I".. digitTag .."/%s", i, max));
            coroutine.yield(); nextBreak = Environment.TickCount64+100;
        end
    end
end

return item_randomizer;