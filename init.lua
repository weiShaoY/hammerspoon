-- Hammerspoon 配置初始化文件

-- 加载文件夹中所有 Lua 文件的函数
-- @param folder 文件夹名称（相对于 ~/.hammerspoon/）
function loadFolderFiles(folder)
    -- 将文件夹路径转换为绝对路径，确保 fs 能够找到目录
    local absPath = hs.fs.pathToAbsolute(folder)
    -- 如果目录不存在，输出警告信息并返回
    if not absPath then
        print("Warning: Directory not found: " .. folder)
        return
    end

    -- hs.fs.dir 返回一个迭代器函数，用于遍历目录中的文件
    local iter, dir_obj = hs.fs.dir(absPath)
    -- 如果迭代器创建失败，直接返回
    if not iter then return end

    -- 遍历目录中的所有文件
    for file in iter, dir_obj do
        -- 过滤掉隐藏文件（以 . 开头）和非 Lua 文件（不以 .lua 结尾）
        if file:match("%.lua$") and not file:match("^%.") then
            -- 提取文件名（去掉 .lua 后缀）
            local fileName = file:sub(1, -5)

            -- 构建模块路径，格式为 folder.fileName
            -- require 的路径是相对于 ~/.hammerspoon/ 的逻辑路径
            local modulePath = folder .. "." .. fileName

            -- 输出加载信息
            print("Loading module: " .. modulePath)
            -- 加载模块
            require(modulePath)
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
function reloadConfig(files)
    -- 标记是否需要重载
    local doReload = false
    -- 遍历所有变化的文件
    for _,file in ipairs(files) do
        -- 如果有 Lua 文件发生变化，标记需要重载
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    -- 如果需要重载，执行重载操作
    if doReload then
        hs.reload()
    end
end

-- 创建文件系统监听器，监听 ~/.hammerspoon/ 目录的变化
-- 当文件发生变化时，调用 reloadConfig 函数
local myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

-- 显示配置就绪的提示信息
hs.alert.show("Hammerspoon 配置已就绪 🔥")