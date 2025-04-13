---@class screenkeyboard.Keyboard
local keyboard = {
    label = {
        default = '',
        selected = ''
    },
    ---@type {[number]: {[number]: {text: string, enabled: boolean, replacement: string?}}}
    grid = {},
    text_entry_function = nil
}

---@return screenkeyboard.Keyboard
return function (label, selectedLabel, lines)
    local o = {
        label = {
            default = label,
            selected = selectedLabel or ('[color=#00aaff]'.. label)
        },
        grid = {}
    }
    local x,y,lineEntry, char = 0,0,nil,nil;
    if type(lines) == 'table' then
        for line = 1, #lines do
            lineEntry = lines[line];
            o.grid[y] = {};
            char = 1;
            for _, code in utf8.codes(lineEntry) do
                o.grid[y][x] = {text = utf8.char(code), enabled = true, replacement = nil};
                char = char + 1;
                x = x + 1;
            end
            if x < 15 then
                while x < 15 do o.grid[y][x] = {text = '', enabled = false, replacement = nil}; x=x+1; end
            end
            x = 0; y = y + 1;
        end
    else
        lineEntry = lines;
        char = 1;
        o.grid[0] = {};
        for _, code in utf8.codes(lineEntry) do
            if x == 15 then x = 0; y = y + 1; o.grid[y] = {}; end
            o.grid[y][x] = {text = utf8.char(code), enabled = true, replacement = nil};
            char = char + 1;
            x = x + 1;
        end
    end

    setmetatable(o, keyboard)
    return o;
end