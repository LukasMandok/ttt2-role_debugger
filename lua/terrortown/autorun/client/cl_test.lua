--[[ Test = {}
Test.__index = Test

setmetatable(Test, {
    __call = function (cls)
        local obj = setmetatable({}, Test)
        return obj
    end,
}) ]]

