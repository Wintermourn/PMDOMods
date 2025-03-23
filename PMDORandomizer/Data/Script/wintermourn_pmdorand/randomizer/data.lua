local rand = require 'wintermourn_pmdorand.lib.pseudorandom'
local CONST = require 'wintermourn_pmdorand.lib.constants'
local logger = require 'mentoolkit.lib.logger' ('wintermourn.pmdorand', 'PMDORAND')

local data = {
    version = "v0.0.0",
    lastModified = "2025-03-09",
    ---@type file*?
    spoilerLog = nil,
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
    updateCoroutine = nil,
    updateRoutineUtils = {
        ---@type table
        menuOption = nil,
        ---@type mentoolkit.Options
        menu = nil
    },
    mod = {},
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
                --- Keep the second type as the pokemon's original second type.
                naturalDualTyping = false,
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
                guaranteedStartingMoves = 4,
                enforceStartingAttackingMove = true,
                --- todo: not implemented yet
                ensuredAttackingMoves = 2,
                learnset = {
                    shuffleExisting = false,
                }
            },
            intrinsics = {
                enabled = true,
                randomizationChance = 1,
                --- Chance for an already blank ability slot to be filled (pokemon with less than three abilities can get up to three)
                --- todo: not implemented yet
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
                powerRandomizationRange = 0.4,
                minimumPower = 1,
                maximumPower = 120,
                weightedPower = {
                    enabled = true,
                    originalPowerWeight = 0.5
                }
            },
            category = {
                enabled = true,
                randomizationChance = 1
            }
        },
        abilities = {
            enabled = true,
            randomizationChance = 1,
            additionalRules = {} -- *
        }
    }
};
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
    return bool and STRINGS:FormatKey("RANDOMIZER_OPTION_ENABLED") or STRINGS:FormatKey("RANDOMIZER_OPTION_DISABLED");
end

return data;