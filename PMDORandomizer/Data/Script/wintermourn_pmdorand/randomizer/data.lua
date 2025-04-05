local rand = require 'wintermourn_pmdorand.lib.pseudorandom'
local CONST = require 'wintermourn_pmdorand.lib.constants'
    local ItemEventRule = CONST.Enums.ItemEventRule;
local logger = require 'mentoolkit.lib.logger' ('wintermourn.pmdorand', 'PMDORAND')

---@class PMDOR.Data
local data = {
    version = "v0.2.0",
    lastModified = "DEV",
    seeding = {
        shared_seed         = '',
        seeds = {
            naming = '',
            dungeon = {
                encounters  = '',
                backgrounds = '',
                music       = '',
                loot        = ''
            },
            pokemon = {
                moves       = '',
                stats       = '',
                abilities   = ''
            },
            items = '',
            statuses = '',
            moves = {
                values      = '',
                ranges      = ''
            },
            abilities = ''
        }
    },
    options = {
        generateSpoilerLog = true,
        pokemon = {
            enabled = true,
            randomizationChance = 1,
            typing = {
                enabled = true,
                randomizationChance = 1,
                --- Only allow pokemon to be dual-typed if they already have a second type.
                retainDualTyping = false,
                --- Controls whether a Pokemon keeps its first type, second type, or neither.
                ---@type false|1|2
                typeRetainment = false,
                --- Allow same first and second types.
                allowDuplicateTyping = false,
                --- Random chance to change the second type.<br>
                --- ⚠️ Only if `naturalDualTyping` and `retainDualTyping` are disabled.
                dualTypeChance = 0.2,
                --- types to be excluded from pokemon typing randomization.
                bannedTypes = {'none'}
            },
            moves = {
                enabled = true,
                randomizationChance = 1,
                --- How many moves should a Pokemon start with (at level 1)?
                guaranteedStartingMoves = 4,
                --- How many of the starting moves should be attacks (physical/special)?
                ensuredAttackingMoves = 2,
                -- * not implemented
                learnset = {
                    shuffleExisting = false,
                },
                -- * not implemented
                typeMismatch = {
                    allowed = true,
                    rate =  0.20,
                    limit = 0.90
                }
            },
            intrinsics = {
                enabled = true,
                randomizationChance = 1,
                --- Chance for an already blank ability slot to be filled (pokemon with less than three abilities can get up to three)
                -- * not implemented
                slotFillChance  = 0.50,
                -- * not implemented
                slotFillLimit   = 3
            }
        },
        moves = {
            enabled = true,
            randomizationChance = 1,
            typing = {
                enabled = true,
                randomizationChance = 1,
                bannedTypes = {'none'}
            },
            -- * not implemented
            powerPoints = {
                enabled = true,
                randomizationChance = 1,
                minimumPP = 1,
                averagePP = 10,
                maximumPP = 35
            },
            basePower = {
                enabled = true,
                randomizationChance = 1,
                --- The maximum change in a move's base power. For example, `0.4` means that a move can lose up to 40% power or gain up to 40% power.
                powerRandomizationRange = 0.4,
                minimumPower = 1,
                --- The absolute limit of power a move can have.
                maximumPower = 120,
                weightedPower = {
                    enabled = true,
                    --- Controls how strongly weighted power pulls towards the center.
                    -- Values between 0 and 1 pull towards the original move's power, while values over 1 will pull away from it.
                    originalPowerWeight = 0.5
                }
            },
            -- * not implemented
            category = {
                enabled = true,
                randomizationChance = 1,
                --- When deciding a move's category, the randomizer chooses a number between 0 and 1.
                -- If it's below this threshold, the move will be physical. Otherwise, it's special.
                leaning = 0.5
            }
        },
        items = {
            enabled = true,
            randomizationChance = 1,
            pricing = {
                enabled = true,
                priceMode = CONST.Enums.PriceMode.RANDOMOFFSET
            },
            effects = {
                enabled = true,
                ---@type PMDOR.Conf.HealthRestoration
                HealthRestoration = {
                    enabled = true,
                    appearanceChance = 0.1,
                    disappearanceChance = 0,
                    appearanceRules = ItemEventRule.RECOVERY | ItemEventRule.USABLE_ONLY,
                    flatHealing = false,
                    minHealed = 0.01,
                    maxHealed = 0.4
                },
                ---@type PMDOR.Conf.ItemEffect
                PPRestoration = {
                    enabled = true,
                    appearanceChance = 0,
                    disappearanceChance = 0,
                    appearanceRules = ItemEventRule.RECOVERY | ItemEventRule.USABLE_ONLY
                },
                ---@type PMDOR.Conf.ItemEffect
                StatBuffing = {
                    enabled = true,
                    appearanceChance = 0,
                    disappearanceChance = 0,
                    appearanceRules = ItemEventRule.RECOVERY | ItemEventRule.USABLE_ONLY
                }
            }
        },
        -- * not implemented
        abilities = {
            enabled = true,
            randomizationChance = 1,
            additionalRules = {} -- *
        },
        naming = {
            enabled = true,
            randomizationChance = 1,
            global = {
                enabled = nil,
                -- * not implemented
                randomizationChance = nil,
                -- * not implemented
                includeExistingNames = nil,
                -- * not implemented
                noDuplicateNames = nil,
                customNames = {}
            },
            pokemon = {
                enabled = true,
                randomizationChance = 1,
                includeExistingNames = true,
                noDuplicateNames = true,
                customNames = {
                    unconditional = {
                    },
                    conditional = {
                        {
                            conditions = {
                                Element1 = "fire"
                            },
                            names = {
                                "fred"
                            }
                        },
                        {
                            conditions = {
                                Element1 = "water"
                            },
                            names = {
                                "blue"
                            }
                        }
                    }
                }
            },
            -- * not implemented
            items = {
                enabled = true,
                randomizationChance = 1,
                includeExistingNames = false,
                noDuplicateNames = true,
                customNames = {
                    unconditional = {},
                    conditional = {}
                }
            },
            moves = {
                enabled = true,
                randomizationChance = 1,
                includeExistingNames = true,
                noDuplicateNames = true,
                customNames = {
                    unconditional = {},
                    conditional = {}
                }
            },
            -- * not implemented
            abilities = {
                enabled = true,
                randomizationChance = 1,
                includeExistingNames = false,
                noDuplicateNames = true,
                customNames = {
                    unconditional = {},
                    conditional = {}
                }
            }
        }
    },
    ---@type file*?
    spoilerLog = nil,
    updateCoroutine = nil,
    updateRoutineUtils = {
        ---@type mentoolkit.PaginatedOptions.Labelled
        menuOption = nil,
        ---@type mentoolkit.PaginatedOptions
        menu = nil
    },
    mod = {}
};
local backup = require 'wintermourn_pmdorand.lib.deepcopy' .deepcopy(data.options);
data.mod.header = RogueEssence.PathMod.GetModFromNamespace("wintermourn_pmdorand");
data.mod.path = CONST.Classes.System.IO.Path.Combine(RogueEssence.PathMod.APP_PATH, data.mod.header.Path);


local function hash(word)
    local result = 5381
    for i=1, #word do
        result = (result << 5) + result + word:byte(i)
    end
    return result
end

local randomGenerators = {
    shared = nil,
    naming = nil,
    pokemon = {},
    items = nil,
    statuses = nil,
    dungeon = {},
    moves = {},
    flattened = {}
};

local function setupGenerator (table, key, seed)
    local rng = seed == '' and randomGenerators.shared or rand.mwc(hash(seed));
    if seed == '' then table[key] = rng; return rng; end
    table[key] = rng;
    return rng;
end

data.InitRNG = function ()
    randomGenerators.shared = rand.twister(data.seeding.shared_seed ~= '' and hash(data.seeding.shared_seed) or os.time());
    randomGenerators.flattened['shared'] = randomGenerators.shared;

    randomGenerators.flattened['pokemon.moves'] = setupGenerator(randomGenerators.pokemon, 'moves', data.seeding.seeds.pokemon.moves);
    randomGenerators.flattened['pokemon.stats'] = setupGenerator(randomGenerators.pokemon, 'stats', data.seeding.seeds.pokemon.stats);
    randomGenerators.flattened['pokemon.abilities'] = setupGenerator(randomGenerators.pokemon, 'abilities', data.seeding.seeds.pokemon.abilities);

    randomGenerators.flattened['naming'] = setupGenerator(randomGenerators, 'naming', data.seeding.seeds.naming);
    randomGenerators.flattened['icons'] = setupGenerator(randomGenerators, 'icons', data.seeding.seeds.items);
    randomGenerators.flattened['statuses'] = setupGenerator(randomGenerators, 'statuses', data.seeding.seeds.statuses);

    randomGenerators.flattened['moves.values'] = setupGenerator(randomGenerators.moves, 'values', data.seeding.seeds.moves.values);
    randomGenerators.flattened['moves.ranges'] = setupGenerator(randomGenerators.moves, 'ranges', data.seeding.seeds.moves.ranges);
end

data.loadConfig = function (config)
    data.options = require 'wintermourn_pmdorand.lib.table_merge' (require 'wintermourn_pmdorand.lib.deepcopy' .deepcopy(backup), config);
end

data.random = function (generator_index, min, max)
    local gen = randomGenerators.flattened[generator_index];
    if gen then
        return gen:random(min, max);
    end
    return 0;
end

data.randomPower = function (generator_index, min, max, center, power)
    local gen = randomGenerators.flattened[generator_index];
    if gen then
        local range = max - min;
        local normalCenter = (center - min)/range;
        local rng = gen:random();

        local skewed = rng^power;

        local mapped = skewed < normalCenter and (skewed / normalCenter) or ((skewed - normalCenter)/ (1-normalCenter));

        return mapped * range + min;
    end
    return 0;
end

data.randomizationChance = function (chance, randomizer)
    if chance >= 1 then return true end
    if chance <= 0 then return false end
    return data.random(randomizer) < chance;
end

data.typeBlacklist = function (cache, blacklist)
    local output = {};
    local realBlacklist = {};
    for _,k in pairs(blacklist) do realBlacklist[k] = true end

    for _,k in pairs(cache) do
        if not realBlacklist[k] then
            table.insert(output, k);
        end
    end

    return output;
end

data.language = {};
data.language.toggle = function (bool)
    return bool and STRINGS:FormatKey("pmdorand:option.enabled") or STRINGS:FormatKey("pmdorand:option.disabled");
end
data.language.descriptionText = function (key)
    return STRINGS:FormatKey(key ..".title"), (STRINGS:FormatKey(key ..".description"):gsub("%[br%]",'\n'))
end

---@param conditions table
---@param conditionals table
---@return {table: table, name: string}[]
local getConditionalNames = function (conditions, conditionals)
    local names = {};
    local passed = true;
    for _, set in pairs(conditionals) do
        passed = true;
        for name, condition in pairs(set.conditions) do
            if type(condition) == 'table' then
                passed = false;
                for _, entry in pairs(condition) do
                    if entry == conditions[name] then
                        passed = true;
                    end
                end
                if not passed then break end
            else
                if condition ~= conditions[name] then
                    passed = false;
                    break;
                end
            end
        end
        if passed then
            for _, entry in pairs(set.nameIndexes) do
                names[#names+1] = entry;
            end
        end
    end
    return names;
end

---@param existingNames {originalID: string, localization: table}[]
data.createNamer = function (entries, options, existingNames)
    local o = {
        --- unconditional names
        any = {},
        --- conditional names
        conditional = {},
        --- preexisting names
        existing = {},
        --- list of existing ids whose names are already used, for `noDuplicateNames`
        usedEntries = {}
    }

    for _, name in pairs(data.options.naming.global.customNames) do
        o.any[#o.any+1] = name;
    end
    for _, name in pairs(entries.unconditional) do
        o.any[#o.any+1] = name;
    end

    local cond;
    for _, set in pairs(entries.conditional) do
        cond = {
            conditions = set.conditions,
            names = set.names,
            nameIndexes = {}
        };
        for _, name in pairs(cond.names) do
            cond.nameIndexes[#cond.nameIndexes+1] = {
                table = cond,
                name = name
            }
        end

        o.conditional[#o.conditional+1] = cond;
    end

    if options.includeExistingNames then
        for _, entry in pairs(existingNames) do
            o.existing[#o.existing+1] = entry;
        end
    end

    local selection, availableConditionalNames;
    if options.noDuplicateNames then
        o.replacedNames = {};
        local entry;
        o.GetName = function (conditions, id)
            availableConditionalNames = getConditionalNames(conditions, o.conditional);

            if #o.any == 0 and #availableConditionalNames == 0 and #o.existing == 0 then return "<no name>" end
            selection = data.random('naming', 1, #o.any + #availableConditionalNames + #o.existing);
            o.replacedNames[id] = true;

            if selection > #o.any + #availableConditionalNames then
                selection = selection - #o.any - #availableConditionalNames;
                entry = o.existing[selection];
                o.usedEntries[entry.originalID] = true;
                table.remove(o.existing, selection);
                return entry.name;
            elseif selection > #o.any then
                selection = selection - #o.any;
                entry = availableConditionalNames[selection];
                for i, k in pairs(entry.table.nameIndexes) do
                    if k == entry then
                        table.remove(entry.table.nameIndexes, i);
                        break;
                    end
                end
                return entry.name;
            else
                entry = o.any[selection];
                table.remove(o.any, selection);
                return entry;
            end
        end
    else
        o.GetName = function (conditions)
            availableConditionalNames = getConditionalNames(conditions, o.conditional);
            selection = data.random('naming', 1, #o.any + #availableConditionalNames + #o.existing);

            if selection > #o.any + #availableConditionalNames then
                return o.existing[selection - #o.any - #availableConditionalNames];
            elseif selection > #o.any then
                return availableConditionalNames[selection - #o.any].name;
            else
                return o.any[selection];
            end
        end
    end

    return o;
end

return data;