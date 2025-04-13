--- Emulates a switch case system. Call this like a function with the arguments (case, ...) to run it.
---@class Switch
---@overload fun(self: table, case: any, ...): ...

---@param table {[any]: fun(...): ...}
---@return Switch
return function (table)
    ---@overload fun(self: table, case: any, ...): ...
    return setmetatable(table, {
        __index = function (t, k)
            return nil;
        end,
        __call = function (t, case, ...)
            if t[case] then
                return t[case](...);
            end
        end
    });
end