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
loadFolderFiles('utils')    -- 加载 utils 目录下的模块
loadFolderFiles('modules')  -- 加载 modules 目录下的模块

-- 加载热键配置
require('hotkeys')

-- 自动重载配置函数
-- @param files 变化的文件列表
local function reloadConfig(files)
    for _, file in ipairs(files) do
        if file:sub(-4) == ".lua" then
            hs.reload()
            return
        end
    end
end

-- 创建文件系统监听器，监听 ~/.hammerspoon/ 目录的变化
-- 当文件发生变化时，调用 reloadConfig 函数
local myWatcher = hs.pathwatcher.new(hs.configdir .. "/", reloadConfig):start()

-- 显示配置就绪的提示信息
hs.alert.show("Hammerspoon 配置已就绪 🔥")
