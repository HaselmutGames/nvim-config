require("haselmut")

local uname = vim.loop.os_uname()
local is_windows = uname.version:match('Windows')
if is_windows then
    require('platform.windows')
else
    require('platform.linux')
end
