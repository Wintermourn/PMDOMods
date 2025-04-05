local CONST = require 'wintermourn_pmdorand.lib.constants'
    local Convert = CONST.Classes.System.Convert;

local DataType = RogueEssence.Data.DataManager.DataType;

local utilitycache = {
    elements = {},
    moves = {
        all = {},
        no_type = {},
        physical = {},
        special = {},
        status = {},
        attacking = {}
    },
    intrinsics = {},
    pokemon = {},
    statuses = {},
    items = {}
}

local cached = false;
utilitycache.Cache = function ()
    if cached then return end
    cached = true;
    
    --- Elements
    local list = _DATA.DataIndices[DataType.Element]:GetOrderedKeys(true);
    for i = 0, list.Count - 1 do
        utilitycache.elements[i + 1] = list[i];
    end

    --- Moves
    list = _DATA.DataIndices[DataType.Skill]:GetOrderedKeys(true);
    local move, category, response, entry;
    local responses = {
        [0] = "no_type",
        [1] = "physical",
        [2] = "special",
        [3] = "status"
    }
    for i = 0, list.Count - 1 do
        move = _DATA:GetSkill(list[i]);

        if move.Released then
            entry = {
                id = list[i],
                name = move.Name
            };
            utilitycache.moves.all[#utilitycache.moves.all + 1] = entry;
            response = responses[Convert.ToInt32(move.Data.Category)];
            category = utilitycache.moves[response];
            category[#category + 1] = entry;

            if response == 'physical' or response == 'special' then
                utilitycache.moves.attacking[#utilitycache.moves.attacking+1] = entry;
            end
        end
    end

    --- Pokemon
    list = _DATA.DataIndices[DataType.Monster]:GetOrderedKeys(true);
    for i = 0, list.Count - 1 do
        if _DATA.DataIndices[DataType.Monster]:Get(list[i]).Released then
            utilitycache.pokemon[#utilitycache.pokemon + 1] = list[i];
        end
    end

    --- Abilities
    list = _DATA.DataIndices[DataType.Intrinsic]:GetOrderedKeys(true);
    for i = 0, list.Count - 1 do
        if _DATA.DataIndices[DataType.Intrinsic]:Get(list[i]).Released then
            utilitycache.intrinsics[#utilitycache.intrinsics + 1] = list[i];
        end
    end

    --- Status Effects
    list = _DATA.DataIndices[DataType.Status]:GetOrderedKeys(true);
    for i = 0, list.Count - 1 do
        utilitycache.statuses[i + 1] = list[i];
    end

    --- Items
    list = _DATA.DataIndices[DataType.Item]:GetOrderedKeys(true);
    for i = 0, list.Count - 1 do
        if _DATA.DataIndices[DataType.Item]:Get(list[i]).Released then
            utilitycache.items[#utilitycache.items + 1] = list[i];
        end
    end
end

return utilitycache;