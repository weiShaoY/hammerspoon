-- Hammerspoon 配置初始化文件

local log = hs.logger.new("init", "info")

-- 加载文件夹中所有 Lua 文件（确定性顺序 + 容错）
-- @param folder 文件夹名称（相对于 ~/.hammerspoon/）
local function loadFolderFiles(folder)
    local absPath = hs.configdir .. "/" .. folder

    local iter, dirObj = hs.fs.dir(absPath)
    if not iter then
        log.w("Directory not found or not readable: %s", absPath)
        return
    end

    local moduleNames = {}
    for file in iter, dirObj do
        if file:match("%.lua$") and not file:match("^%.") then
            moduleNames[#moduleNames + 1] = file:sub(1, -5)
        end
    end

    table.sort(moduleNames)
    for _, fileName in ipairs(moduleNames) do
        local modulePath = folder .. "." .. fileName
        local ok, err = pcall(require, modulePath)
        if ok then
            log.i("Loaded: %s", modulePath)
        else
            log.e("Failed to load %s: %s", modulePath, err)
        end
    end
end

-- 加载各个目录下的模块
-- 注意：require 加载是以 ~/.hammerspoon/ 为根目录的
loadFolderFiles('configs')  -- 加载 configs 目录下的模块
loadFolderFiles('modules')  -- 加载 modules 目录下的模块

-- 快捷键统一在 init.lua 里绑定（去掉 hotkeys.lua）

local notify = require("utils.notify")

-- F13：音频输出设备切换
local audioSwitch = require("modules.switch-audio")
hs.hotkey.bind({}, "F13", function()
    audioSwitch.toggleAudioOutput()
end)

-- F14：打开微信
local wechat = require("modules.open-wechat")
hs.hotkey.bind({}, "F14", function()
    wechat.openWeChat()
end)

-- 自动重载配置函数
-- @param files 变化的文件列表
local function reloadConfig(files)
    if type(files) ~= "table" then return end

    log.d("Pathwatcher event: %s", table.concat(files, ", "))
    for _, file in ipairs(files) do
        if type(file) == "string" and file:match("%.lua$") then
            log.i("Config change detected: %s", file)
            notify.show("检测到配置变化，正在重载…", 0.6)
            hs._codex.reloadTimer:start()
            return
        end
    end
end

-- 创建文件系统监听器，监听 ~/.hammerspoon/ 目录的变化
-- 当文件发生变化时，调用 reloadConfig 函数
-- 注意：watcher/timer 需要持久引用，否则可能被 GC 回收而失效
hs._codex = hs._codex or {}

if hs._codex.configWatcher then hs._codex.configWatcher:stop() end
if hs._codex.reloadTimer then hs._codex.reloadTimer:stop() end

hs._codex.reloadTimer = hs.timer.delayed.new(0.25, hs.reload)
hs._codex.configWatcher = hs.pathwatcher.new(hs.configdir, reloadConfig)
hs._codex.configWatcher:start()
log.i("Config watcher started on: %s", hs.configdir)

-- 显示配置就绪的提示信息
notify.show("Hammerspoon 配置已就绪 🔥")
