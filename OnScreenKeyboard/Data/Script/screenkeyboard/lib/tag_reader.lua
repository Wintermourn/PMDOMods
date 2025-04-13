local __Type = luanet.import_type 'System.Type';
local __Regex = __Type.GetType "System.Text.RegularExpressions.Regex, System.Text.RegularExpressions";
local __Regex_constructor = __Regex:GetConstructor(luanet.make_array(__Type, {__Type.GetType 'System.String'}));
local tagRegex = __Regex_constructor:Invoke(luanet.make_array(
    luanet.import_type 'System.Object',
    {"(?<cancel>\\\\)?\\[(?<tag>[\\$^])(?<target>[^\\[\\]]+)\\]"}
));
local switch = require 'screenkeyboard.lib.switchcaser';

local colors = {
    ['white'] = "[color=#ffffff]",
    ['red'] = "[color=#ff0000]",
    ['orange'] = "[color=#ffaa00]",
    ['yellow'] = "[color=#ffff00]",
    ['green'] = "[color=#00ff00]",
    ['cyan'] = '[color=#00ffff]',
    ['blue'] = "[color=#0000ff]",
    ['purple'] = "[color=#aa00ff]",
    ['gray'] = "[color=#a0a0a0]"
}
local tags = switch {
    ['$'] = function (content)
        return STRINGS:FormatKey(content);
    end,
    ['^'] = function (content)
        return colors[content] or '';
    end
}

return {
    ---@param input string
    parse = function (input)
        local matches = tagRegex:Matches(input);
    
        local output = {}
    
        local match, matchStart;
        local currentOffset = 1;
        for i = 0, matches.Count - 1 do
            match = matches[i];
            matchStart = match.Index + 1;
    
            if currentOffset < matchStart then
                output[#output+1] = input:sub(currentOffset, match.Index);
            end
    
            if match.Groups.cancel.Success then
                output[#output+1] = match.Value;
            else
                output[#output+1] = tags(match.Groups.tag.Value, match.Groups.target.Value);
            end
    
            currentOffset = matchStart + match.Length;
        end
    
        if currentOffset <= #input then
            output[#output+1] = input:sub(currentOffset);
        end
    
        return table.concat(output)
    end,
    setColorCode = function (name, color)
        colors[name] = string.format("[color=%s]", color);
    end
}