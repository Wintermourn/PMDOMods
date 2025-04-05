local CONST = require 'wintermourn_pmdorand.lib.constants'

require 'wintermourn_pmdorand.randomizer.data' .AddItemEffect(
    "HealthRestoration",
    function (target, config, data)
        
    end,
    {
        flatHealing = false,
        minHealed = 0.01,
        maxHealed = 0.4
    }
)

require 'wintermourn_pmdorand.randomizer.data' .SetEffectType(PMDC.Dungeon.RestoreHPEvent, CONST.Enums.ItemEventRule.RECOVERY);