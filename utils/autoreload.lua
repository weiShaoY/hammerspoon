-- 自动重载工具：监听配置目录变更并触发 hs.reload()
--
-- 设计目标：
-- - 可复用：init.lua 只需要一行 start()
-- - 稳定：watcher/timer 挂到 hs._codex 上，避免被 GC 回收
-- - 防抖：短时间内多次文件变更只触发一次 reload
--
-- 用法：
-- local autoreload = require("utils.autoreload")
-- autoreload.start({ log = log, notify = notify })

local M = {}

local function isLuaFile(path)
    return type(path) == "string" and path:match("%.lua$")
end

local function ensureCodexNamespace()
    hs._codex = hs._codex or {}
    return hs._codex
end

function M.stop(key)
    local ns = ensureCodexNamespace()
    local k = key or "autoReload"
    local state = ns[k]
    if not state then return end

    if state.watcher then state.watcher:stop() end
    if state.timer then state.timer:stop() end
    ns[k] = nil
end

-- @param opts table|nil
-- opts.key string: 在 hs._codex 下存储状态的键名（默认 "autoReload"）
-- opts.path string: 监听路径（默认 hs.configdir）
-- opts.delay number: 防抖秒数（默认 0.25）
-- opts.notify table: utils.notify 模块（可选）
-- opts.notifyText string: 提示文案（默认 "检测到配置变化，正在重载…"）
-- opts.notifySeconds number: 提示显示秒数（默认 0.6）
-- opts.log userdata|table: hs.logger（可选，用于输出日志）
function M.start(opts)
    opts = opts or {}

    local ns = ensureCodexNamespace()
    local key = opts.key or "autoReload"
    local path = opts.path or hs.configdir
    local delay = opts.delay or 0.25

    -- 如果之前启动过，先停掉再重建（避免重复 watcher）
    M.stop(key)

    local log = opts.log
    local notify = opts.notify
    local notifyText = opts.notifyText or "检测到配置变化，正在重载…"
    local notifySeconds = opts.notifySeconds or 0.6

    local state = {}
    state.timer = hs.timer.delayed.new(delay, hs.reload)
    state.watcher = hs.pathwatcher.new(path, function(files)
        if type(files) ~= "table" then return end
        for _, file in ipairs(files) do
            if isLuaFile(file) then
                if log then log.i("Config change detected: %s", file) end
                if notify and type(notify.show) == "function" then
                    notify.show(notifyText, notifySeconds)
                end
                state.timer:start()
                return
            end
        end
    end)

    state.watcher:start()
    ns[key] = state

    if log then log.i("Config watcher started on: %s", path) end
    return state
end

return M

