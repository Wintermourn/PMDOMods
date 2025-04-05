local CONST = require 'mentoolkit.lib.constants'
    local DirH = CONST.Enums.DirH
local textile_menu = require 'mentoolkit.menus.textile'

local changelog_menu;

local CHANGELOG = {
    { "2025-03-23", "PMDOR_CHANGELOG_2025-03-23" }
}

return function()
    if changelog_menu == nil then
        changelog_menu = textile_menu(32,96,256,127);
        changelog_menu.title = "Changelog"

        for _,k in pairs(CHANGELOG) do
            local page = changelog_menu:CreatePage();
            page:TextAt(127, 8, "[color=#999999]".. k[1] .."[color]", DirH.NONE);
            page:Append(STRINGS:FormatKey(k[2]):match("^%s*(.-)%s*$"));
        end
    end
    changelog_menu:OpenToPage(1,true);
end