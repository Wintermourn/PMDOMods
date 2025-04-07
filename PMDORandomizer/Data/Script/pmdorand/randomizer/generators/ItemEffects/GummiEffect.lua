local CONST = require 'pmdorand.lib.constants'

require 'pmdorand.randomizer.data' .AddItemEffect(
    "GummiEffect",
    {
        PMDC.Dungeon.VitaGummiEvent
    },
    function (target, config, data)
        -- * TODO: Gummi Effect randomization
    end,
    {
        --- Chance for gummi effects to apply to base types only (denies effects that change a pokemon's typing!)
        baseTypeRequirementRate = 0.0,
        fullEffectRate = 0.0
    }
)

require 'pmdorand.randomizer.data' .SetEffectType(PMDC.Dungeon.VitaGummiEvent, CONST.Enums.ItemEventRule.BENEFICIAL);