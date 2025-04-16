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
        ---@type PMDOR.ConfigTemplate.Percentage
        {
            id = 'baseTypeRequirementRate',
            type = 'percent',
            default = 0.00,
            stepSize = 0.01
        },
        ---@type PMDOR.ConfigTemplate.Percentage
        {
            id = 'fullEffectRate',
            type = 'percent',
            default = 0.00,
            stepSize = 0.01
        }
    }
)