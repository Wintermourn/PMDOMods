local data = require 'pmdorand.randomizer.data'
local CONST = require 'pmdorand.lib.constants'

local jpatch = '.jsonpatch';
local __Array = luanet.import_type('System.Array');
local __Type = CONST.Classes.System.Type;
local __Directory = CONST.Classes.System.IO.Directory;
local type_String = __Type.GetType('System.String');
local type_Type = __Type.GetType('System.Type');

local tA = __Array.CreateInstance(type_Type, 1);
tA[0] = type_String
local EndsWith = type_String:GetMethod("EndsWith", tA);

local argumentsArray = __Array.CreateInstance(type_String, 1);
argumentsArray[0] = jpatch;

local function ClearFolderPatches(folder, locals, labelWorking, labelSkip)
    local files, filename;
    local notice, t = locals.notice, locals.text;

    if __Directory.Exists(folder) then
        t = t .. '\n' .. labelWorking
        notice.Info:SetAndFormatText(t);
        files = __Directory.GetFiles(folder);

        for i = 0, files.Length - 1 do
            filename = files[i];

            -- if (string.EndsWith([".jsonpatch"]))
            if EndsWith:Invoke(filename, argumentsArray) then
                os.remove(filename);
            end
        end
    else
        t = t .. '\n' .. labelSkip
        notice.Info:SetAndFormatText(t);
    end

    locals.text = t;
end

local function ClearFolderPatchesWithoutMessage(folder)
    local files, filename;

    if __Directory.Exists(folder) then
        files = __Directory.GetFiles(folder);

        for i = 0, files.Length - 1 do
            filename = files[i];

            -- if (string.EndsWith([".jsonpatch"]))
            if EndsWith:Invoke(filename, argumentsArray) then
                os.remove(filename);
            end
        end
    end
end

return function (withoutMessage)
    if withoutMessage then
        ClearFolderPatchesWithoutMessage(data.mod.path .. '/Data/Element/');
        ClearFolderPatchesWithoutMessage(data.mod.path .. '/Data/Monster/');
        ClearFolderPatchesWithoutMessage(data.mod.path .. '/Data/Skill/');
        ClearFolderPatchesWithoutMessage(data.mod.path .. '/Data/Item/');
        ClearFolderPatchesWithoutMessage(data.mod.path .. '/Data/Status/');
        return;
    end
    local locals = {
        text = 'This might take a few moments...\n - Clearing .jsonpatch files'
    }
    locals.notice = _MENU:CreateNotice('PMDOR '.. data.version, locals.text);
    _MENU:AddMenu(locals.notice, false);

    ClearFolderPatches(data.mod.path .. '/Data/Element/', locals, '. - Elements', '. - No Elements folder, skipping');
    ClearFolderPatches(data.mod.path .. '/Data/Monster/', locals, '. - Monsters', '. - No Monsters folder, skipping');
    ClearFolderPatches(data.mod.path .. '/Data/Skill/', locals, '. - Skills', '. - No Skills folder, skipping');
    ClearFolderPatches(data.mod.path .. '/Data/Item/', locals, '. - Items', '. - No Items folder, skipping');
    ClearFolderPatches(data.mod.path .. '/Data/Status/', locals, '. - Statuses', '. - No Statuses folder, skipping');

    --notice.Info:SetAndFormatText("Randomizer clear complete.");
end