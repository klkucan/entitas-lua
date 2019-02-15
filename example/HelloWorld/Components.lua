local MakeComponent = require('entitas.MakeComponent')

local M = {
    -- 这里DebugMessage是个table，可以理解为定义了一个DebugMessage Class，里面有一个message变量。
    DebugMessage = MakeComponent("DebugMessage","message")
}

return M