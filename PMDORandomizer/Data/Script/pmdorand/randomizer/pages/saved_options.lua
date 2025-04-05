local CONST = require 'pmdorand.lib.constants'
    local __Directory = CONST.Classes.System.IO.Directory;
    local __Path = CONST.Classes.System.IO.Path;
    local __File = CONST.Classes.System.IO.File;
local json = require 'pmdorand.lib.json'
local data = require 'pmdorand.randomizer.data'
local invokeWith = CONST.INVOKE_WITH;

local CONFIGFOLDER = data.mod.path ..'/Configs/';
local CONFIGFOLDER_LOCAL = data.mod.path ..'/Configs/Local/';
local CONFIGFOLDER_SHARED = data.mod.path ..'/Configs/Shared/';

local logger = require 'mentoolkit.lib.logger' ('wintermourn.pmdorand', 'PMDORAND')

local options_menu = require 'mentoolkit.menus.reflowing_options'
local paginated_menu = require 'mentoolkit.menus.paginated_options'
---@type mentoolkit.PaginatedOptions, mentoolkit.PaginatedOptions;
local context, saves;
local ctx_Data = {
    filename = nil,
    local_save = true
};

local m = {
    fill_save_menu = nil
}

local function save_local(filename, savename)
    local savedata = {
        seeding = data.seeding,
        configs = data.options
    };

    local file = io.open(data.mod.path ..'/Configs/Local/'.. filename ..'.json', 'w+');
    if file then
        file:write(string.format("name = \"%s\"\nversion = \"%s\"\n", savename, data.version) .. json.encode(savedata));
        file:close();
        return true;
    end
    return false;
end

local invalidChars = CONST.Classes.System.String(__Path.GetInvalidFileNameChars());
local function create_local_save()
    local menu = RogueEssence.Menu.TeamNameMenu(
        STRINGS:FormatKey("pmdorand:save.name.title"),
        STRINGS:FormatKey("INPUT_CAN_PASTE"),
        130, os.date("%Y-%m-%d"), function (name)
            local finame = CONST.Methods.System.Regex.Replace(name, invalidChars, '_');

            if __File.Exists(CONFIGFOLDER_LOCAL .. finame ..'.json') then
                local copName = 0;
                repeat
                    copName = copName + 1;
                until not __File.Exists(string.format("%s%s (%d).json", CONFIGFOLDER_LOCAL, finame, copName));
                finame = finame .. ' ('.. copName ..')';
            end
            save_local(finame, name);
            m.fill_save_menu();
            saves:Rebuild();
            saves:CursorTo(1, 2);
        end);

    _MENU:AddMenu(menu, true);
end
local function update_local_save(file)
    local oname;
    for line in io.lines(file, 'l') do
        if string.sub(line, 1,7) == "name = " then
            oname = string.sub(line, 9, -2);
            break;
        end
    end
    local menu = RogueEssence.Menu.TeamNameMenu(
        STRINGS:FormatKey("pmdorand:save.name.title"),
        STRINGS:FormatKey("INPUT_CAN_PASTE"),
        130, oname, function (name)
            save_local(string.sub(__Path.GetFileName(file), 1, -6), name);
            m.fill_save_menu();
            saves:Rebuild();
            saves:CursorTo(1, 2);
            _MENU:RemoveMenu();
        end);

    _MENU:AddMenu(menu, true);
end

local function fill_save_menu()

    saves.pages = {};

    if not __Directory.Exists(CONFIGFOLDER_LOCAL) then
        __Directory.CreateDirectory(CONFIGFOLDER_LOCAL);
    end
    if not __Directory.Exists(CONFIGFOLDER_SHARED) then
        __Directory.CreateDirectory(CONFIGFOLDER_SHARED);
    end

    local files = __Directory.GetFiles(CONFIGFOLDER_LOCAL);
    local sortedFiles = {};
    for i = 0, files.Length - 1 do
        sortedFiles[#sortedFiles+1] = {path = files[i], lastModified = __File.GetLastWriteTime(files[i])};
    end
    table.sort(sortedFiles, function (a, b)
        return a.lastModified:CompareTo(b.lastModified) > 0;
    end)

    local page = saves:AddPage();
    page:AddHeader("[color=#aaaaaa]Local Sets");
    local f = 1;
    local lineCount, name, version;
    while (f <= #sortedFiles) do
        local path = sortedFiles[f].path;

        page = saves.pages[#saves.pages];
        if #page.contents > 11 then
            page = saves:AddPage();
            page:AddHeader("[color=#aaaaaa]Local Sets");
        end

        lineCount = 0;
        name, version = "- unnamed -", "???";
        for line in io.lines(path, 'l') do
            if string.sub(line, 1,7) == "name = " then
                name = string.sub(line, 9, -2);
            end
            if string.sub(line, 1,10) == "version = " then
                version = string.sub(line, 12, -2);
            end

            lineCount = lineCount + 1;
            if lineCount == 2 then break end
        end
        if path:sub(-5) ~= '.json' then name = '[color=#ffaaaa]' .. name; end
        page:AddButton(name, function ()
            ctx_Data.filename = path;
            ctx_Data.local_save = true;
            context:Open(false);
        end):SetLabel('right', version or '[color=#aaaaaa]Invalid Ver.');
        f = f + 1;
    end
    if #page.contents > 11 then
        page = saves:AddPage();
        page:AddHeader("[color=#aaaaaa]Local Sets");
    end
    page:AddButton("[color=#aaaaaa]-[color] Create New Set", create_local_save);

    if #page.contents > 11 then
        page = saves:AddPage();
    end
    page:AddHeader("[color=#aaaaaa]Shared Sets");

    files = __Directory.GetFiles(CONFIGFOLDER_SHARED);
    sortedFiles = {};
    for i = 0, files.Length - 1 do
        sortedFiles[#sortedFiles+1] = {path = files[i], lastModified = __File.GetLastWriteTime(files[i])};
    end
    table.sort(sortedFiles, function (a, b)
        return a.lastModified:CompareTo(b.lastModified) > 0;
    end)
end

m.fill_save_menu = fill_save_menu;

return function()
    if context == nil then
        context = paginated_menu(224,103, 96, 92);
        local page = context:AddPage();
        page:AddButton("Load", function ()
            local file = io.open(ctx_Data.filename, 'r');

            if file then
                --- skip first two lines
                _ = file:read('l');
                _ = file:read('l');

                local dat = json.decode(file:read('a'));
                file:close();
                data.loadConfig(dat.configs);
                data.seeding = dat.seeding;
                _MENU:RemoveMenu();
                _MENU:RemoveMenu();
            end
            
        end);
        page:AddButton("Overwrite", function ()
            if not ctx_Data.local_save then return end
            update_local_save(ctx_Data.filename);
        end);
        page:AddButton("Rename", CONST.FUNCTION_EMPTY);
        page:AddButton("Delete", function ()
            if ctx_Data.filename ~= nil and __File.Exists(ctx_Data.filename) and string.sub(ctx_Data.filename,-5) == '.json' then
                os.remove(ctx_Data.filename);
                if saves.currentSelection > 1 and saves.pages[saves.currentPage].contents[saves.currentSelection - 1].selectable then
                    saves:Input('up');
                end
            end
            _MENU:RemoveMenu();
            fill_save_menu();
            saves:Rebuild();
        end);
        page:AddButton("Export", CONST.FUNCTION_EMPTY);
        page:AddButton("Cancel", function ()
            _MENU:RemoveMenu();
        end);

        saves = paginated_menu(0,0,255,188);
        saves.title = "Saved Configurations";
        page = saves:AddPage();
    end

    context:Rebuild();
    fill_save_menu();
    saves:Open(true);
end