local CONST = require 'pmdorand.lib.constants'

require 'pmdorand.randomizer.data' .AddItemEffect(
    "HealthRestoration",
    function (target, config, data)
        
    end,
    {
        flatHealing = false,
        minHealed = 0.01,
        maxHealed = 0.4
    }
)

require 'pmdorand.randomizer.data' .SetEffectType(PMDC.Dungeon.RestoreHPEvent, CONST.Enums.ItemEventRule.RECOVERY);