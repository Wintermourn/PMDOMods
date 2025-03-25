local rand = require 'wintermourn_pmdorand.lib.pseudorandom'
local CONST = require 'wintermourn_pmdorand.lib.constants'
local logger = require 'mentoolkit.lib.logger' ('wintermourn.pmdorand', 'PMDORAND')

local data = {
    version = "v0.1.0",
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
                }
            },
            intrinsics = {
                enabled = true,
                randomizationChance = 1,
                --- Chance for an already blank ability slot to be filled (pokemon with less than three abilities can get up to three)
                -- * not implemented
                slotFillChance = 0
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
                randomizationChance = 1
            }
        },
        -- * not implemented
        abilities = {
            enabled = true,
            randomizationChance = 1,
            additionalRules = {} -- *
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
    randomGenerators.shared = rand.twister(hash(data.seeding.shared_seed or os.time()));
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

return data;