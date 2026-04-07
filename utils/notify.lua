-- 通知/提示工具：统一封装 hs.alert.show

local M = {}

-- 显示提示
-- @param text string 提示内容
-- @param opts table|number|nil 可选：数字表示 seconds；或 {style=..., screen=..., seconds=...}
function M.show(text, opts)
    if type(opts) == "number" then
        return hs.alert.show(text, nil, nil, opts)
    end
    if type(opts) == "table" then
        return hs.alert.show(text, opts.style, opts.screen, opts.seconds)
    end
    return hs.alert.show(text)
end

return M

