local evorand = {}
local data = require 'pmdorand.randomizer.data'
local CONST = require 'pmdorand.lib.constants'

evorand.Randomize = function ()
    local options = data.options.pokemon.evolutions;
    local ucache = require 'pmdorand.randomizer.utilitycache'

    if not options.enabled then return end
    if options.shuffleExistingEvolutions then
        for type in CONST.Methods.ivalues(ucache.elements) do
            
        end
    end
end

return evorand;