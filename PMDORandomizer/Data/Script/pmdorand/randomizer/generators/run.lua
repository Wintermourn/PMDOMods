local data = require 'pmdorand.randomizer.data'
local CONST = require 'pmdorand.lib.constants'
    local __Directory = CONST.Classes.System.IO.Directory;
    local __Type = CONST.Classes.System.Type;
local logger = require 'mentoolkit.lib.logger' ('wintermourn.pmdorand', 'PMDORAND');
local DataType = RogueEssence.Data.DataManager.DataType;

local function DisplayString(var)
    return var ~= '' and '`'.. var ..'`' or '<none>'
end

local function LogChangeMessage(message, first, second, firstName, secondName)
    if first ~= second then
        data.spoilerLog:write(string.format("%s: %s -> %s\n", message, firstName or first, secondName or second));
    else
        data.spoilerLog:write(string.format("%s: %s (UNCHANGED)\n", message, firstName or first));
    end
end

local __DataManager_LoadModData = luanet.ctype(RogueEssence.Data.DataManager):GetMethod("LoadModData"):MakeGenericMethod(
    luanet.make_array(CONST.Classes.System.Type, {__Type.GetType 'RogueEssence.Data.IEntryData, RogueEssence'})
);
local indexArgs = luanet.make_array(CONST.Classes.System.Object, {
    data.mod.header, '', '', RogueEssence.Data.DataManager.DATA_EXT
});

--- Aggressively strangling pmdo to give me my index files.
local function CreateIndex(type)
    local stream = CONST.Classes.System.IO.FileStream(
        data.mod.path ..'/Data/'.. type:ToString() ..'/index.idx',
        CONST.Classes.System.IO.FileMode.Create,
        CONST.Classes.System.IO.FileAccess.Write,
        CONST.Classes.System.IO.FileShare.None
    );

    --local index = _DATA.DataIndices[type]:GetModIndex(data.mod.header.UUID);
    local entries = LUA_ENGINE:MakeGenericType(
        CONST.Classes.System.Dictionary,
        {
            CONST.Classes.System.String,
            RogueEssence.Data.EntrySummary
        },
        {}
    );

    local files = __Directory.GetFiles(data.mod.path ..'/Data/'.. type:ToString(), '*');
    local dir, filename, testext, dat;

    indexArgs[1] = 'Data/'.. type:ToString() ..'/';
    for i = 0, files.Length - 1 do
        dir = files[i];
        filename = CONST.Classes.System.IO.Path.GetFileNameWithoutExtension(dir);
        testext = CONST.Classes.System.IO.Path.GetExtension(dir);

        if testext == RogueEssence.Data.DataManager.DATA_EXT or testext == RogueEssence.Data.DataManager.PATCH_EXT then
            indexArgs[2] = filename;
            logger:debug(tostring(indexArgs[0]),tostring(indexArgs[1]),tostring(indexArgs[2]),tostring(indexArgs[3]))
            dat = __DataManager_LoadModData:Invoke(nil, indexArgs);
            if dat then
                logger:debug("data exists, a summary can happen");
                entries[filename] = dat:GenerateEntrySummary();
            end
        end
    end

    if entries.Count > 0 then
        RogueEssence.Data.Serializer.SerializeData(stream, entries);
        stream:Flush();
        stream:Close();
    else
        stream:Close();
        CONST.Classes.System.IO.File.Delete(data.mod.path ..'/Data/'.. type:ToString() ..'/index.idx');
    end
end

---@param randomLabel mentoolkit.PaginatedOptions.Labelled
return function(randomLabel, menu)
    data.lockRandomizerButton = true;

    --- Clear any existing randomization data.
    require 'pmdorand.randomizer.clear' (true);
    --- Precautionary cache initialization. We don't want ANY leftover data from previous generations.
    _DATA:InitDataIndices();
    randomLabel:SetLabel('right', "[color=#aaaaaa][ Caching ]");
    coroutine.yield();
    --- Generate utility cache: data ids and groupings if necessary.
    require 'pmdorand.randomizer.utilitycache' .Cache();
    --- Set up number generators according to user specified seeds
    data.InitRNG()
    data.FireEvent('initrng');

    local anythingRandomized = false;

    --- Spoiler log generation
    if data.options.generateSpoilerLog then
        data.spoilerLog = io.open(data.mod.path ..'/SpoilerLog.md', 'w+');
        data.spoilers = {};
        data.updateRoutineUtils = {menu = menu, menuOption = randomLabel};
    
        data.spoilerLog:write("# PMDORandomizer Spoiler Log\n");
        data.spoilerLog:write("\n**Randomizer Version:** ".. data.version .." (".. data.lastModified ..")\n");
        data.spoilerLog:write("**Game Version:** ".. RogueEssence.Versioning.GetVersion():ToString() ..'\n\n');
        data.FireEvent('spoiler:seeds/pre');
        data.spoilerLog:write("## Seeds\n\n")
        data.spoilerLog:write("* **Fallback (Shared) Seed:** ".. DisplayString(data.seeding.shared_seed) ..'\n');
        data.spoilerLog:write("* Naming Seed: ".. DisplayString(data.seeding.seeds.naming) ..'\n');
        data.spoilerLog:write("* Items Seed: ".. DisplayString(data.seeding.seeds.items) ..'\n');
        data.spoilerLog:write("* Status Effect Seed: ".. DisplayString(data.seeding.seeds.statuses) ..'\n');
        data.spoilerLog:write("* **Pokemon Seeds:**\n  * Stats:     ".. DisplayString(data.seeding.seeds.pokemon.stats) ..'\n');
        data.spoilerLog:write("  * Moves:     ".. DisplayString(data.seeding.seeds.pokemon.moves) ..'\n');
        data.spoilerLog:write("  * Intrinsics:   ".. DisplayString(data.seeding.seeds.pokemon.abilities) ..'\n');
        data.spoilerLog:write("* **Move Seeds:**\n  * Values:    ".. DisplayString(data.seeding.seeds.moves.values) ..'\n');
        data.spoilerLog:write("  * Ranges:    ".. DisplayString(data.seeding.seeds.moves.ranges) ..'\n');
        data.spoilerLog:write('\n');
        data.FireEvent('spoiler:seeds/post');
    
        data.spoilerLog:flush();
    end

    logger:debug("moves");
    if data.options.moves.enabled then
        anythingRandomized = true;
        __Directory.CreateDirectory(data.mod.path .. '/Data/Skill/');
        data.FireEvent('randomizing:moves/pre');
        require 'pmdorand.randomizer.generators.moves' .Randomize();
        data.FireEvent('randomizing:moves/post');
    end

    logger:debug("pokemon");
    if data.options.pokemon.enabled then
        anythingRandomized = true;
        __Directory.CreateDirectory(data.mod.path .. '/Data/Monster/');
        data.FireEvent('randomizing:pokemon/pre');
        require 'pmdorand.randomizer.generators.pokemon' .Randomize();
        data.FireEvent('randomizing:pokemon/post');
    end

    logger:debug("items");
    if data.options.items.enabled then
        anythingRandomized = true;
        __Directory.CreateDirectory(data.mod.path .. '/Data/Item/');
        data.FireEvent('randomizing:items/pre');
        require 'pmdorand.randomizer.generators.items' .Randomize();
        data.FireEvent('randomizing:items/post');
    end

    logger:debug("index");
    randomLabel:SetLabel('right', "[color=#aaaaaa][ Indexing ]");
    CreateIndex(DataType.Item);
    CreateIndex(DataType.Skill);
    CreateIndex(DataType.Monster);
    --[[ local modFolder = CONST.Methods.System.Regex.Match(data.mod.path, ".*\\/(MODS\\/.*)");
    if modFolder.Success then
        Dev.DevHelper.IndexNamedData(modFolder.Groups[1].Captures[0].Value .. '/Data/Skill/');
    end ]]

    if data.options.generateSpoilerLog then
        logger:debug("spoiler log output");
        data.FireEvent('spoiler:postrandom');
        if data.spoilers.pokemon then
            data.FireEvent('spoiler:pokemon/pre');
            data.spoilerLog:write("## Pokemon Randomization\n");
            for i,k in pairs(data.spoilers.pokemon) do
                if k.skipped then
                    data.spoilerLog:write(string.format("* No. %04d | %s (SKIPPED)\n", k.id, k.name:ToLocal()));
                    goto SKIP_POKEMON_LOG;
                end
    
                data.spoilerLog:write(string.format("* No. %04d | %s\n", k.id, k.name:ToLocal()));
                for c,f in pairs(k.forms) do
                    data.spoilerLog:write(string.format("\t* Form %02d: %s\n", c, f.name:ToLocal()));
    
                    if f.Element1 and f.Element1.from ~= f.Element1.to then
                        LogChangeMessage("\t\t* type 1", f.Element1.from, f.Element1.to);
                    end
                    if f.Element2 and f.Element2.from ~= f.Element2.to then
                        LogChangeMessage("\t\t* type 2", f.Element2.from, f.Element2.to);
                    end
                    if f.Intrinsics then
                        data.spoilerLog:write("\t\t* Abilities:\n");
                        LogChangeMessage("\t\t\t* ability 1", f.Intrinsics.From1, f.Intrinsics.To1);
                        LogChangeMessage("\t\t\t* ability 2", f.Intrinsics.From2, f.Intrinsics.To2);
                        LogChangeMessage("\t\t\t* ability 3", f.Intrinsics.From3, f.Intrinsics.To3);
                    end
                end
    
                ::SKIP_POKEMON_LOG::
            end
            data.FireEvent('spoiler:pokemon/post');
        end
    
        if data.spoilers.moves then
            data.FireEvent('spoiler:moves/pre');
            data.spoilerLog:write("\n## Move Randomization\n");
            for i,k in pairs(data.spoilers.moves) do
                if k.skipped then
                    data.spoilerLog:write(string.format("* M%03d | %s (SKIPPED)\n", k.id, k.name:ToLocal()));
                    goto SKIP_MOVE_LOG;
                end
    
                data.spoilerLog:write(string.format("* M%04d | %s\n", k.id, k.name:ToLocal()));
                if k.Element then
                    LogChangeMessage("\t* Element", k.Element.from, k.Element.to);
                end
                if k.Power then
                    LogChangeMessage("\t* Base Power", k.Power.from, k.Power.to);
                end
    
                ::SKIP_MOVE_LOG::
            end
            data.FireEvent('spoiler:moves/post');
        end
    
        data.FireEvent('spoiler:end');
        data.spoilerLog:flush();
        data.spoilerLog:close();
    end
    _DATA:InitDataIndices();


    if anythingRandomized == false then
        randomLabel:SetLabel('right', "[color=#aaaaaa][ nothing happened ]");
    else
        randomLabel:SetLabel('right', ' ');
    end

    data.lockRandomizerButton = false;
end