local data = require 'wintermourn_pmdorand.randomizer.data'
local logger = require 'mentoolkit.lib.logger' ('wintermourn.pmdorand', 'PMDORAND');

local ucache = require 'wintermourn_pmdorand.randomizer.utilitycache'

local pokemon_randomizer = {}
local monsterfolder = data.mod.path .. '/Data/Monster/';

pokemon_randomizer.Randomize = function ()
    local originalMonsterFolder = RogueEssence.Data.DataManager.DATA_PATH ..'/Monster/'

    data.spoilers.pokemon = {};

    local currentEntry, currentForm, form, move, localSpoiler;
    local rep, max = 0, #ucache.pokemon;
    local maxlen = tostring(max):len();
    local digitTag = '%0'.. maxlen ..'d';
    local options = data.options.pokemon;
    local movesOptions = data.options.pokemon.moves;
    local guaranteedAttackStartingMoves = math.min(movesOptions.guaranteedStartingMoves, movesOptions.ensuredAttackingMoves);
    local guaranteedAnyStartingMoves = movesOptions.guaranteedStartingMoves - guaranteedAttackStartingMoves;

    local typeList = data.typeBlacklist(ucache.elements, data.options.pokemon.typing.bannedTypes);

    for i, key in pairs(ucache.pokemon) do
        currentEntry = _DATA:GetMonster(key);

        if not data.randomizationChance(options.randomizationChance, 'shared') then
            data.spoilers.pokemon[#data.spoilers.pokemon+1] = {id = currentEntry.IndexNum, name = currentEntry.Name, skipped = true};
            --data.spoilerLog:write(string.format("* No. %04d | %s\n\tSKIPPED\n", currentEntry.IndexNum, currentEntry.Name:ToLocal()));
            goto skip_pokemon
        end

        localSpoiler = {
            id = currentEntry.IndexNum,
            name = currentEntry.Name
        };
        data.spoilers.pokemon[#data.spoilers.pokemon+1] = localSpoiler;

        localSpoiler.forms = {}
        for f = 0, currentEntry.Forms.Count - 1 do
            currentForm = currentEntry.Forms[f];
            form = {
                name = currentForm.FormName
            };
            localSpoiler.forms[f+1] = form;

            --- Pokemon Types
            -- Shuffles pokemon typing (1&2)
            if data.options.pokemon.typing.enabled and data.randomizationChance(options.typing.randomizationChance, 'pokemon.stats') then
                local firstTypeId = data.random('pokemon.stats', 1, #typeList);
                form.Element1 = {from = currentForm.Element1};
                
                currentForm.Element1 = typeList[firstTypeId];
                form.Element1.to = currentForm.Element1;

                if not data.options.pokemon.typing.naturalDualTyping then
                    if not data.options.pokemon.typing.allowDuplicateTyping then
                        table.remove(typeList, firstTypeId);
                    end
                    --- Randomize second type
                    if data.options.pokemon.typing.retainDualTyping then
                        if currentForm.Element2 ~= 'none' then
                            form.Element2 = {from = currentForm.Element2};
                            currentForm.Element2 = typeList[data.random('pokemon.stats', 1, #typeList)];
                            form.Element2.to = currentForm.Element2;
                        end
                    else
                        form.Element2 = {from = currentForm.Element2};
                        if data.random('pokemon.stats') < data.options.pokemon.typing.dualTypeChance then
                            currentForm.Element2 = typeList[data.random('pokemon.stats', 1, #typeList)];
                            form.Element2.to = currentForm.Element2;
                        else
                            currentForm.Element2 = 'none';
                            form.Element2.to = 'none';
                        end
                    end
                    if not data.options.pokemon.typing.allowDuplicateTyping then
                        table.insert(typeList, firstTypeId, currentForm.Element1);
                    end
                end
            end

            --- Movesets
            if data.options.pokemon.moves.enabled and data.randomizationChance(options.moves.randomizationChance, 'pokemon.moves') then
                form.LevelSkills = {};
                currentForm.LevelSkills:Clear();
                if guaranteedAnyStartingMoves > 0 then
                    for _ = 1, guaranteedAnyStartingMoves do
                        move = ucache.moves.all[data.random('pokemon.moves',1,#ucache.moves.all)];
                        form.LevelSkills[#form.LevelSkills+1] = {level = 1, move = move};
                        currentForm.LevelSkills:Add(RogueEssence.Data.LevelUpSkill(move.id, 1));
                    end
                end
                if guaranteedAttackStartingMoves > 0 then
                    for _ = 1, guaranteedAttackStartingMoves do
                        move = ucache.moves.attacking[data.random('pokemon.moves',1,#ucache.moves.attacking)];
                        form.LevelSkills[#form.LevelSkills+1] = {level = 1, move = move};
                        currentForm.LevelSkills:Add(RogueEssence.Data.LevelUpSkill(move.id, 1));
                    end
                end
            end

            --- Intrinsics
            if data.options.pokemon.intrinsics.enabled and data.randomizationChance(options.intrinsics.randomizationChance, 'pokemon.abilities') then
                form.Intrinsics = {From1 = currentForm.Intrinsic1, From2 = currentForm.Intrinsic2, From3 = currentForm.Intrinsic3};
                currentForm.Intrinsic1 = ucache.intrinsics[data.random('pokemon.abilities', 1, #ucache.intrinsics)];
                currentForm.Intrinsic2 = ucache.intrinsics[data.random('pokemon.abilities', 1, #ucache.intrinsics)];
                currentForm.Intrinsic3 = ucache.intrinsics[data.random('pokemon.abilities', 1, #ucache.intrinsics)];
                form.Intrinsics.To1 = currentForm.Intrinsic1;
                form.Intrinsics.To2 = currentForm.Intrinsic2;
                form.Intrinsics.To3 = currentForm.Intrinsic3;
            end
        end

        ::skip_pokemon::

        RogueEssence.Data.Serializer.SerializeDataAsDiff(monsterfolder .. key ..'.jsonpatch', originalMonsterFolder .. key ..'.json', currentEntry);

        rep = rep + 1;
        if rep > 50 then
            data.updateRoutineUtils.menuOption.menuElements.right:SetText(string.format("[color=#aaaaaa]P".. digitTag .."/%s", i, max));
            coroutine.yield(); rep = 0;
        end
    end
end

return pokemon_randomizer;