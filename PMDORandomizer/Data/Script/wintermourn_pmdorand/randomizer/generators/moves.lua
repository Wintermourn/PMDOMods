local CONST = require 'wintermourn_pmdorand.lib.constants';

local data = require 'wintermourn_pmdorand.randomizer.data'
local logger = require 'mentoolkit.lib.logger' ('wintermourn.pmdorand', 'PMDORAND');

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

    local moveNames = {};

    for i, move in pairs(ucache.moves.all) do
        currentEntry = _DATA:GetSkill(move.id);

        moveNames[#moveNames+1] = {
            originalID = move.id,
            name = currentEntry.Name
        };

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
            if basePowerState == nil or basePowerState.Power == 0 then goto skip_power end
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
            data.updateRoutineUtils.menuOption:SetLabel('right', string.format("[color=#aaaaaa]M".. digitTag .."/%s", i, max));
            coroutine.yield(); rep = 0;
        end
    end

    if data.options.naming.moves.enabled then
        local nameRandomizer = data.createNamer(data.options.naming.moves.customNames, data.options.naming.moves, moveNames);
        local mnameChance, nameChance = data.options.naming.moves.randomizationChance, data.options.naming.randomizationChance;
        local nameDat;
        for i, move in pairs(ucache.moves.all) do
            currentEntry = _DATA:GetSkill(move.id);
    
            if data.randomizationChance(mnameChance, 'naming') and data.randomizationChance(nameChance, 'naming') then
                nameDat = nameRandomizer.GetName({
                    Element = currentEntry.Data.Element
                }, move.id);

                if CONST.Methods.IsLocalText(nameDat) then
                    currentEntry.Name = nameDat;
                else
                    currentEntry.Name = RogueEssence.LocalText(nameDat);
                end
            end

            RogueEssence.Data.Serializer.SerializeDataAsDiff(skillfolder .. move.id ..'.jsonpatch', originalSkillFolder .. move.id ..'.json', currentEntry);
            
            rep = rep + 1;
            if rep > 20 then
                data.updateRoutineUtils.menuOption:SetLabel('right', string.format("[color=#aaaaaa]NM".. digitTag .."/%s", i, max));
                coroutine.yield(); rep = 0;
            end
        end
    end
end

return moves_randomizer;