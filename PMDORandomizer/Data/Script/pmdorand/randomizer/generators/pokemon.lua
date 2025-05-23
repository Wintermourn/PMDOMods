local CONST = require 'pmdorand.lib.constants'
    local Environment = CONST.Classes.System.Environment;
local data = require 'pmdorand.randomizer.data'

local ucache = require 'pmdorand.randomizer.utilitycache'

local pokemon_randomizer = {}
local monsterfolder = data.mod.path .. '/Data/Monster/';

pokemon_randomizer.Randomize = function ()
    local originalMonsterFolder = RogueEssence.Data.DataManager.DATA_PATH ..'/Monster/'

    data.spoilers.pokemon = {};
    ucache.randomized.pokemon_by_type = {};

    local currentEntry, currentForm, form, move, localSpoiler;
    
    local max = #ucache.pokemon;
    local maxlen = tostring(max):len();
    local digitTag = '%0'.. maxlen ..'d';
    local nextBreak = Environment.TickCount64+100;

    local options = data.options.pokemon;

    local elementByType1, elementByType2;

    local pokemonNames = {};

    local typeList = data.typeBlacklist(ucache.elements, data.options.pokemon.typing.bannedTypes);

    local sub_moveset = require 'pmdorand.randomizer.generators.sub.pokemon.moveset';
    sub_moveset.InitializeVariables();

    --- PASS 1
    for i, key in ipairs(ucache.pokemon) do
        currentEntry = _DATA:GetMonster(key);

        if not data.randomizationChance(options.randomizationChance, 'shared') then
            data.spoilers.pokemon[#data.spoilers.pokemon+1] = {id = currentEntry.IndexNum, name = currentEntry.Name, skipped = true};
            --data.spoilerLog:write(string.format("* No. %04d | %s\n\tSKIPPED\n", currentEntry.IndexNum, currentEntry.Name:ToLocal()));
            goto skip_pokemon
        end

        if data.options.naming.pokemon.includeExistingNames then
            pokemonNames[#pokemonNames+1] = {
                originalID = key,
                name = currentEntry.Name
            };
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

            if data.options.naming.enabled and data.options.naming.pokemon.includeExistingNames then
                pokemonNames[#pokemonNames+1] = {
                    originalID = key,
                    formID = f,
                    name = currentForm.FormName
                };
            end

            --- Pokemon Types
            -- Shuffles pokemon typing (1&2)
            if data.options.pokemon.typing.enabled and data.randomizationChance(options.typing.randomizationChance, 'pokemon.stats') then
                local firstTypeId = data.random('pokemon.stats', 1, #typeList);

                if options.typing.typeRetainment ~= 1 then
                    form.Element1 = {from = currentForm.Element1};
                    currentForm.Element1 = typeList[firstTypeId];
                    form.Element1.to = currentForm.Element1;
                end
                ucache.randomized.pokemon_by_type[currentForm.Element1] = ucache.randomized.pokemon_by_type[currentForm.Element1] or {};
                elementByType1 = ucache.randomized.pokemon_by_type[currentForm.Element1];
                elementByType1[#elementByType1+1] = {pokemon = key, form = f};

                if options.typing.typeRetainment ~= 2 then
                    if options.typing.typeRetainment ~= 1 and not data.options.pokemon.typing.allowDuplicateTyping then
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
                    if options.typing.typeRetainment ~= 1 and not data.options.pokemon.typing.allowDuplicateTyping then
                        table.insert(typeList, firstTypeId, currentForm.Element1);
                    end
                end

                if form.Element2 ~= 'none' then
                    ucache.randomized.pokemon_by_type[currentForm.Element2] = ucache.randomized.pokemon_by_type[currentForm.Element2] or {};
                    elementByType2 = ucache.randomized.pokemon_by_type[currentForm.Element2];
                    elementByType2[#elementByType2+1] = {pokemon = key, form = f};
                end
            end

            --- Movesets
            if data.options.pokemon.moves.enabled and data.randomizationChance(options.moves.randomizationChance, 'pokemon.moves') then
                sub_moveset.Randomize(currentForm, form);
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

        if Environment.TickCount64 > nextBreak then
            data.updateRoutineUtils.menuOption:SetLabel('right', string.format("[color=#aaaaaa]P".. digitTag .."/%s|1", i, max));
            coroutine.yield(); nextBreak = Environment.TickCount64+100;
        end
    end

    --- PASS 2: Base Stats
    if options.baseStats.enabled then
        for i, key in pairs(ucache.pokemon) do
            currentEntry = _DATA:GetMonster(key);
            if data.spoilers.pokemon[i].skipped then goto skip_pass2; end

            for f = 0, currentEntry.Forms.Count - 1 do
                currentForm = currentEntry.Forms[f];

                if options.baseStats.enabled and data.randomizationChance(options.baseStats.randomizationChance, 'pokemon.stats') then
                    for stat, config in pairs{
                        BaseHP = options.baseStats.health,
                        BaseAtk = options.baseStats.attack,
                        BaseDef = options.baseStats.defense,
                        BaseMAtk = options.baseStats.spAttack,
                        BaseMDef = options.baseStats.spDefense,
                        BaseSpeed = options.baseStats.speed,
                    } do
                        if config.enabled and data.randomizationChance(config.randomizationChance, 'pokemon.stats') then
                            currentForm[stat] = data.randomPower(
                                'pokemon.stats',
                                math.max(config.minimum, currentForm[stat] * (1- config.maximumDifference)),
                                math.min(config.maximum, currentForm[stat] * (1+ config.maximumDifference)),
                                currentForm[stat],
                                config.originalPullStrength
                            );

                            -- * TODO: spoiler log stat changes
                        end
                    end
                end
            end
    
            RogueEssence.Data.Serializer.SerializeDataAsDiff(monsterfolder .. key ..'.jsonpatch', originalMonsterFolder .. key ..'.json', currentEntry);
    
            if Environment.TickCount64 > nextBreak then
                data.updateRoutineUtils.menuOption:SetLabel('right', string.format("[color=#aaaaaa]P".. digitTag .."/%s|2", i, max));
                coroutine.yield(); nextBreak = Environment.TickCount64+100;
            end
    
            ::skip_pass2::
        end
    end

    if options.evolutions.enabled then
        data.updateRoutineUtils.menuOption:SetLabel('right', "[color=#aaaaaa]EP[...]");
        require 'pmdorand.randomizer.generators.EvolutionMethods' .Randomize();
    end

    if data.options.naming.enabled and data.options.naming.pokemon.enabled then
        local nameRandomizer = data.createNamer(data.options.naming.pokemon.customNames, data.options.naming.pokemon, pokemonNames);
        local pnameChance, nameChance = data.options.naming.pokemon.randomizationChance, data.options.naming.randomizationChance;
        local nameDat;
        for i, key in pairs(ucache.pokemon) do
            currentEntry = _DATA:GetMonster(key);
    
            currentForm = currentEntry.Forms[0];
            if data.randomizationChance(pnameChance, 'naming') and data.randomizationChance(nameChance, 'naming') then
                nameDat = nameRandomizer.GetName({
                    IsSpeciesName = true,
                    Element1 = currentForm.Element1,
                    Element2 = currentForm.Element2,
                    Species = key
                }, key);

                if CONST.Methods.IsLocalText(nameDat) then
                    currentEntry.Name = nameDat;
                else
                    currentEntry.Name = RogueEssence.LocalText(nameDat);
                end
            end
    
            for f = 0, currentEntry.Forms.Count - 1 do
                currentForm = currentEntry.Forms[f];
    
                if data.randomizationChance(pnameChance, 'naming') and data.randomizationChance(nameChance, 'naming') then
                    nameDat = nameRandomizer.GetName({
                        Element1 = currentForm.Element1,
                        Element2 = currentForm.Element2
                    }, key);
    
                    if CONST.Methods.IsLocalText(nameDat) then
                        currentForm.FormName = nameDat;
                    else
                        currentForm.FormName = RogueEssence.LocalText(nameDat);
                    end
                end
            end

            RogueEssence.Data.Serializer.SerializeDataAsDiff(monsterfolder .. key ..'.jsonpatch', originalMonsterFolder .. key ..'.json', currentEntry);
            
            if Environment.TickCount64 > nextBreak then
                data.updateRoutineUtils.menuOption:SetLabel('right', string.format("[color=#aaaaaa]NP".. digitTag .."/%s", i, max));
                coroutine.yield(); nextBreak = Environment.TickCount64+100;
            end
        end
    end
end

return pokemon_randomizer;