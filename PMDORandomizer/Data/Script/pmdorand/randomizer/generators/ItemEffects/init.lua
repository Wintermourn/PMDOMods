return {
    --- Loads all internal ItemEffect definitions for the randomizer.
    LoadAll = function ()
        require 'pmdorand.randomizer.generators.ItemEffects.HealthRestoration'
        require 'pmdorand.randomizer.generators.ItemEffects.BellyRestoration'
        require 'pmdorand.randomizer.generators.ItemEffects.GummiEffect'
    end
}