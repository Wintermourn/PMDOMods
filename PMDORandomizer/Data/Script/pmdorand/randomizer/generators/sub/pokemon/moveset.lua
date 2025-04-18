local ucache = require 'pmdorand.randomizer.utilitycache'
local data = require 'pmdorand.randomizer.data'

local movesOptions = data.options.pokemon.moves;
local guaranteedAttackStartingMoves = math.min(movesOptions.guaranteedStartingMoves, movesOptions.ensuredAttackingMoves);
local guaranteedAnyStartingMoves = movesOptions.guaranteedStartingMoves - guaranteedAttackStartingMoves;

local move, currentMoveset;

local function AddLevelUpSkill(list, level, skill)
    local id = 0;
    while list.Count > id and list[id].Level < level do
        id = id + 1;
    end
    list:Insert(id, RogueEssence.Data.LevelUpSkill(move.id, level));
end

local moveset = {};
moveset.Randomize = function (form, formSpoilers)

    currentMoveset = {};

    formSpoilers.LevelSkills = {};
    if movesOptions.learnset.shuffleExisting then
        for i = form.LevelSkills.Count - 1, 0, -1 do
            if form.LevelSkills[i].Level == 1 then
                form.LevelSkills:RemoveAt(i)
            end
        end
    else
        form.LevelSkills:Clear();
    end
    if guaranteedAnyStartingMoves > 0 then
        for _ = 1, guaranteedAnyStartingMoves do
            move = ucache.moves.all[data.random('pokemon.moves',1,#ucache.moves.all)];
            if currentMoveset[move.id] then
                repeat
                    move = ucache.moves.all[data.random('pokemon.moves',1,#ucache.moves.all)];
                until not currentMoveset[move.id]
            end
            formSpoilers.LevelSkills[#formSpoilers.LevelSkills+1] = {level = 1, move = move};
            --form.LevelSkills:Add(RogueEssence.Data.LevelUpSkill(move.id, 1));
            AddLevelUpSkill(form.LevelSkills, 1, move.id);
            currentMoveset[move.id] = true;
        end
    end
    if guaranteedAttackStartingMoves > 0 then
        for _ = 1, guaranteedAttackStartingMoves do
            move = ucache.moves.attacking[data.random('pokemon.moves',1,#ucache.moves.attacking)];
            if currentMoveset[move.id] then
                repeat
                    move = ucache.moves.all[data.random('pokemon.moves',1,#ucache.moves.attacking)];
                until not currentMoveset[move.id]
            end
            formSpoilers.LevelSkills[#formSpoilers.LevelSkills+1] = {level = 1, move = move};
            --form.LevelSkills:Add(RogueEssence.Data.LevelUpSkill(move.id, 1));
            AddLevelUpSkill(form.LevelSkills, 1, move.id);
            currentMoveset[move.id] = true;
        end
    end

    --[[ if movesOptions.typeMatching.allowed then
        
    else
    end ]]

end
moveset.InitializeVariables = function ()
    movesOptions = data.options.pokemon.moves;
    guaranteedAttackStartingMoves = math.min(movesOptions.guaranteedStartingMoves, movesOptions.ensuredAttackingMoves);
    guaranteedAnyStartingMoves = movesOptions.guaranteedStartingMoves - guaranteedAttackStartingMoves;
end
return moveset;