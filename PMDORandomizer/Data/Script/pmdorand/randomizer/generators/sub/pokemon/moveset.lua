local ucache = require 'pmdorand.randomizer.utilitycache'
local data = require 'pmdorand.randomizer.data'

local movesOptions = data.options.pokemon.moves;
local guaranteedAttackStartingMoves = math.min(movesOptions.guaranteedStartingMoves, movesOptions.ensuredAttackingMoves);
local guaranteedAnyStartingMoves = movesOptions.guaranteedStartingMoves - guaranteedAttackStartingMoves;

local move, currentMoveset;

local moveset = {};
moveset.Randomize = function (form, formSpoilers)

    currentMoveset = {};

    formSpoilers.LevelSkills = {};
    form.LevelSkills:Clear();
    if movesOptions.typeMatching.allowed then
        
    else
        if guaranteedAnyStartingMoves > 0 then
            for _ = 1, guaranteedAnyStartingMoves do
                move = ucache.moves.all[data.random('pokemon.moves',1,#ucache.moves.all)];
                if currentMoveset[move.id] then
                    repeat
                        move = ucache.moves.all[data.random('pokemon.moves',1,#ucache.moves.all)];
                    until not currentMoveset[move.id]
                end
                formSpoilers.LevelSkills[#formSpoilers.LevelSkills+1] = {level = 1, move = move};
                form.LevelSkills:Add(RogueEssence.Data.LevelUpSkill(move.id, 1));
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
                form.LevelSkills:Add(RogueEssence.Data.LevelUpSkill(move.id, 1));
                currentMoveset[move.id] = true;
            end
        end
    end

end
moveset.InitializeVariables = function ()
    movesOptions = data.options.pokemon.moves;
    guaranteedAttackStartingMoves = math.min(movesOptions.guaranteedStartingMoves, movesOptions.ensuredAttackingMoves);
    guaranteedAnyStartingMoves = movesOptions.guaranteedStartingMoves - guaranteedAttackStartingMoves;
end
return moveset;