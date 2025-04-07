local CONST = require 'pmdorand.lib.constants'
    local ItemEventRule = CONST.Enums.ItemEventRule;

require 'pmdorand.randomizer.data' .AddItemEffect(
    --- Effect Data name (this is stored in the save file)
    "HealthRestoration",
    --- Related Events - the function below is fired whenever one of these events is found inside of an item
    {
        PMDC.Dungeon.RestoreHPEvent
    },
    --- Item/Event modifying code
    function (target, config, data)
        -- This is only true once per item
        if target.isItem then
            if not data.randomizationChance(config.appearanceChance, 'items') then return end
            -- * TODO: Event Inserting Code
        -- This is only true if one of the above events are found on the item
        elseif target.isEvent then
            if data.randomizationChance(config.disappearanceChance, 'items') then
                return target.Destroy();
            end
            if not data.randomizationChance(config.modifyRate, 'items') then return end

            if config.settings.flatDifference then
                if (target.object.Numerator * config.settings.maxDifference) % 1 > 0 then
                    local mult = 1/((target.object.Numerator * config.settings.maxDifference) % 1);
                    target.object.Numerator = target.object.Numerator * mult;
                    target.object.Denominator = target.object.Denominator * mult;
                end
            else
                local factor = math.ceil(100/target.object.Denominator);
                target.object.Numerator = target.object.Numerator * factor;
                target.object.Denominator = target.object.Denominator * factor;

                target.object.Numerator = data.round(target.object.Numerator * (data.random('items') * .4 + .8));
            end
        end
    end,
    --- Effect config data (these are stored in the save file and can be accessed by the function above)
    {
        flatDifference = false,
        maxDifference = 0.2
    }
)

-- * Currently unused, will be for restricting effects to certain item types
require 'pmdorand.randomizer.data' .SetEffectType(PMDC.Dungeon.RestoreHPEvent, ItemEventRule.BENEFICIAL | ItemEventRule.HEALING);