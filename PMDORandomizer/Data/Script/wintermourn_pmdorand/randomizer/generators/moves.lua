local CONST = require 'wintermourn_pmdorand.lib.constants';
    local System = CONST.Classes.System;
    local BindingFlags = CONST.Enums.BindingFlags;
    local Enumerable_ToArray = CONST.Methods.System.Linq.Enumerable.ToArray;

local data = require 'wintermourn_pmdorand.randomizer.data'
local logger = require 'mentoolkit.lib.logger' ('wintermourn.pmdorand', 'PMDORAND');
local json = require 'wintermourn_pmdorand.lib.json'

local __Type = CONST.Classes.System.Type;
local type_BasePowerState = __Type.GetType('RogueEssence.Dungeon.BasePowerState, RogueEssence');
logger:debug(type_BasePowerState.Name);

local ucache = require 'wintermourn_pmdorand.randomizer.utilitycache'

local moves_randomizer = {}
local skillfolder = data.mod.path .. '/Data/Skill/';

moves_randomizer.Randomize = function ()
    local originalSkillFolder = RogueEssence.Data.DataManager.DATA_PATH ..'/Skill/'

    local basePowerOptions = data.options.moves.basePower;
    local powerPointOptions = data.options.moves.powerPoints;

    data.spoilers.moves = {};

    local currentEntry, localSpoiler, basePowerState;
    local rep, max = 0, #ucache.moves.all;
    local maxlen = tostring(max):len();
    local digitTag = '%0'.. maxlen ..'d';

    for i, move in pairs(ucache.moves.all) do
        currentEntry = _DATA:GetSkill(move.id);


        if not data.randomizationChance(data.options.moves.randomizationChance, 'shared') then
            data.spoilers.moves[#data.spoilers.moves+1] = {id = currentEntry.IndexNum, name = currentEntry.Name, skipped = true};
            goto skip_move;
        end

        localSpoiler = {
            id = currentEntry.IndexNum,
            name = currentEntry.Name
        };
        data.spoilers.moves[#data.spoilers.moves+1] = localSpoiler;

        --data.spoilerLog:write(string.format("* M%04d | %s\n", currentEntry.IndexNum, currentEntry.Name:ToLocal()));
        --totalInfo = '';

        --- Move type
        if data.options.moves.typing.enabled and data.randomizationChance(data.options.moves.typing.randomizationChance, 'moves.values') then
            --totalInfo = totalInfo .."\t* Type: ".. currentEntry.Data.Element .." -> ";
            localSpoiler.Element = {from = currentEntry.Data.Element};
            currentEntry.Data.Element = ucache.elements[data.random('moves.values', 1, #ucache.elements)];
            localSpoiler.Element.to = currentEntry.Data.Element;
        end

        --- Base Power
        if basePowerOptions.enabled and data.randomizationChance(basePowerOptions.randomizationChance, 'moves.values') then
            basePowerState = currentEntry.Data.SkillStates:GetWithDefault(type_BasePowerState);
            if basePowerState == nil then goto skip_power end
            localSpoiler.Power = {from = basePowerState.Power};
            if basePowerOptions.weightedPower.enabled then
                local maxOffset = basePowerState.Power * basePowerOptions.powerRandomizationRange;
                basePowerState.Power = math.floor(
                    math.max(math.min(
                        data.randomPower(
                            'moves.values',
                            basePowerState.Power - maxOffset, basePowerState.Power + maxOffset,
                            basePowerState.Power,
                            basePowerOptions.weightedPower.originalPowerWeight
                        )
                    ,basePowerOptions.maximumPower),basePowerOptions.minimumPower)
                )
            else
                basePowerState.Power = math.floor(math.max(math.min(
                    basePowerState.Power + basePowerState.Power * ((data.random('moves.values')*2-1) * basePowerOptions.powerRandomizationRange),
                    basePowerOptions.maximumPower
                ),basePowerOptions.minimumPower) + 0.5);
            end
            localSpoiler.Power.to = basePowerState.Power;
        end
        ::skip_power::

        if powerPointOptions.enabled and data.randomizationChance(powerPointOptions.randomizationChance, 'moves.values') then
            
        end

        ::skip_move::

        RogueEssence.Data.Serializer.SerializeDataAsDiff(skillfolder .. move.id ..'.jsonpatch', originalSkillFolder .. move.id ..'.json', currentEntry);

        rep = rep + 1;
        if rep > 50 then
            data.updateRoutineUtils.menuOption.menuElements.right:SetText(string.format("[color=#aaaaaa]M".. digitTag .."/%s", i, max));
            coroutine.yield(); rep = 0;
        end
    end
end

return moves_randomizer;