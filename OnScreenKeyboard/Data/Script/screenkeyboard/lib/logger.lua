---@diagnostic disable: undefined-global, duplicate-set-field
local cachedLoggers = {}
---@class wintermourn.logger
local logger = {}
logger.__name = ''
logger.__index = logger

local function stringjoin(...)
    local s = ""
    local a = {...}
    s = tostring(a[1] .. a[2])
    table.remove(a, 1)
    table.remove(a, 1)

    for _,k in pairs(a) do
        s = s .. '\t'.. tostring(k)
    end
    return s
end

local function logMessage(name, first, ...)
    local s = name ..' : '.. first;
    local a = {...}

    for _,k in pairs(a) do
        s = s .. '\t'.. tostring(k);
    end

    if DiagManager then
        DiagManager.Instance:LogInfo(s);
    else
        print(s);
    end
end

function logger:print(...)
    print(stringjoin(self.__name .." : ", ...))
end
function logger:info(...)
    logMessage('[\x1b[38;2;50;249;249mINFO\x1b[0m] '.. self.__name, ...)
end
function logger:warn(...)
    logMessage('[\x1b[38;2;250;249;50mWARN\x1b[0m] '.. self.__name, ...)
end
function logger:err(...)
    logMessage('[\x1b[38;2;250;70;70mERR \x1b[0m] '.. self.__name, ...)
end
function logger:debug(...)
    logMessage('[\x1b[38;2;70;255;70mDBG \x1b[0m] '.. self.__name, ...)
end
function logger:fatal(...)
    logMessage('[\x1b[38;2;250;100;250mFATL\x1b[0m] '.. self.__name, ...)
    error(stringjoin('[\x1b[38;2;250;100;250mFATL\x1b[0m] '.. self.__name ..' : ', ...))
end

---@param namespace string
---@param label string leading name to include in log messages
---@return wintermourn.logger
return function (namespace, label)
    if cachedLoggers[namespace] ~= nil then return cachedLoggers[namespace] end
    local o = {__name = label}
    setmetatable(o, logger)
    cachedLoggers[namespace] = o
    return o
end