--- Emulates a switch case system. Call this like a function with the arguments (case, ...) to run it.
---@class Switch
---@overload fun(self: table, case: any, ...): ...

---@param table {[any]: fun(...): ...}
---@param default fun(...)? fallback function if a requested case isn't found
---@return Switch
return function (table, default)
    ---@overload fun(self: table, case: any, ...): ...
    return setmetatable(table, {
        __call = function (t, case, ...)
            if t[case] then
                return t[case](...);
            elseif default then
                return default(...);
            end
        end
    });
end