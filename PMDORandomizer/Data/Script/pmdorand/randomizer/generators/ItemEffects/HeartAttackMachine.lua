local logger = require 'mentoolkit.lib.logger' ('wintermourn.pmdorand', 'PMDORAND')

require 'pmdorand.randomizer.data' .AddItemEffect(
    --- Effect Data name (this is stored in the save file)
    "HeartAttackMachine",
    --- Related Events - the function below is fired whenever one of these events is found inside of an item
    {
    },
    --- Item/Event modifying code
    function (target, config, data)
        -- This is only true once per item
        if target.isItem then
            if not data.randomizationChance(config.appearanceChance, 'items') then return end
            target.object.UseEvent.OnHits:Add(1, PMDC.Dungeon.OHKODamageEvent());
        end
    end,
    --- Effect config data (these are stored in the save file and can be accessed by the function above)
    {
    }
).sortPriority = require 'pmdorand.lib.constants' .Enums.ItemEffectPriority.INEVITABLE_DOOM;