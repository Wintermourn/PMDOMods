local ItemEventRule = require 'pmdorand.lib.constants' .Enums.ItemEventRule;
local data = require 'pmdorand.randomizer.data'

--#region Event Types
    -- Restoration / Recovery
    data.SetEffectType(PMDC.Dungeon.RestoreHPEvent, ItemEventRule.BENEFICIAL | ItemEventRule.HEALING);
    data.SetEffectType(PMDC.Dungeon.RestoreBellyEvent, ItemEventRule.BENEFICIAL | ItemEventRule.HEALING);
    data.SetEffectType(PMDC.Dungeon.RestorePPEvent, ItemEventRule.BENEFICIAL | ItemEventRule.HEALING);
    -- Stat Boosting
    data.SetEffectType(PMDC.Dungeon.VitaGummiEvent, ItemEventRule.BENEFICIAL);
    -- Situational
    data.SetEffectType(PMDC.Dungeon.RemoveStatusBattleEvent, ItemEventRule.SITUATIONAL);
    data.SetEffectType(PMDC.Dungeon.ChangeToElementEvent, ItemEventRule.SITUATIONAL);
--#endregion

return {
    --- Loads all internal ItemEffect definitions for the randomizer.
    LoadAll = function ()
        require 'pmdorand.randomizer.generators.ItemEffects.HealthRestoration'
        require 'pmdorand.randomizer.generators.ItemEffects.BellyRestoration'
        require 'pmdorand.randomizer.generators.ItemEffects.PPRestoration'
        require 'pmdorand.randomizer.generators.ItemEffects.GummiEffect'
        require 'pmdorand.randomizer.generators.ItemEffects.PerishSong'
    end
}