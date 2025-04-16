local logger = require 'mentoolkit.lib.logger' ('wintermourn.pmdorand', 'PMDORAND')

require 'pmdorand.randomizer.data' .AddItemEffect(
    --- Effect Data name (this is stored in the save file)
    "BellyRestoration",
    --- Related Events - the function below is fired whenever one of these events is found inside of an item
    {
    },
    --- Item/Event modifying code
    function (target, config, data)
    end,
    --- Effect config data (these are stored in the save file and can be accessed by the function above)
    {
    }
).sortPriority = require 'pmdorand.lib.constants' .Enums.ItemEffectPriority.RECOVERY;