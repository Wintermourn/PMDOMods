local logger = require 'mentoolkit.lib.logger' ('wintermourn.pmdorand', 'PMDORAND')

require 'pmdorand.randomizer.data' .AddItemEffect(
    --- Effect Data name (this is stored in the save file)
    "PerishSong",
    --- Related Events - the function below is fired whenever one of these events is found inside of an item
    {
    },
    --- Item/Event modifying code
    function (target, config, data)
        -- This is only true once per item
        if target.isItem then
            if not data.randomizationChance(config.appearanceChance, 'items') then return end

            local status = PMDC.Dungeon.StatusBattleEvent(
                "perish_song",
                true,
                false,
                false
            );
            target.object.UseEvent.OnHits:Add(1, status);

            --status.TriggerMsg = RogueEssence.StringKey("pmdorand:itemeffect/perishsong");
            status.Anims:Add(PMDC.Dungeon.BattleAnimEvent(
                RogueEssence.Content.BetweenEmitter(
                    RogueEssence.Content.AnimData("Perish_Song_Back", 1),
                    RogueEssence.Content.AnimData("Perish_Song_Front", 1)
                ),
                "DUN_Perish_Song",
                true
            ));
        end
    end,
    --- Effect config data (these are stored in the save file and can be accessed by the function above)
    {
    }
).sortPriority = require 'pmdorand.lib.constants' .Enums.ItemEffectPriority.INEVITABLE_DOOM;