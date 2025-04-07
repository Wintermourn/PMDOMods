local CONST = require 'pmdorand.lib.constants'
    local ItemEventRule = CONST.Enums.ItemEventRule;

require 'pmdorand.randomizer.data' .SetEffectType(PMDC.Dungeon.RestoreBellyEvent, ItemEventRule.BENEFICIAL | ItemEventRule.HEALING);