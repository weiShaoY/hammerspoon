-- 修正后的 loadFolderFiles 函数
function loadFolderFiles(folder)
    -- 将 ~ 转换为绝对路径，否则 fs 可能找不到目录
    local absPath = hs.fs.pathToAbsolute(folder)
    if not absPath then
        print("Warning: Directory not found: " .. folder)
        return
    end

    -- hs.fs.dir 返回一个迭代器函数
    local iter, dir_obj = hs.fs.dir(absPath)
    if not iter then return end

    for file in iter, dir_obj do
        -- 过滤掉隐藏文件、当前目录(.)和上级目录(..)
        if file:match("%.lua$") and not file:match("^%.") then
            -- 提取文件名（去掉 .lua 后缀）
            local fileName = file:sub(1, -5)

            -- 注意：require 的路径通常是相对于 ~/.hammerspoon/ 的逻辑路径
            -- 如果你的文件夹在 ~/.hammerspoon/config，只需 require('config.filename')
            -- 这里假设你的 folder 参数类似于 'config' 或 'utils'
            local modulePath = folder .. "." .. fileName

            print("Loading module: " .. modulePath)
            require(modulePath)
        end
    end
end

-- 注意：require 加载是以 ~/.hammerspoon/ 为根目录的
-- 如果你的文件夹在 ~/.hammerspoon/config 下，请直接写文件夹名
loadFolderFiles('configs')
loadFolderFiles('utils')
loadFolderFiles('modules')

-- 加载热键配置
require('hotkeys')



-- 自动重载配置
-- 1. 先定义函数
function reloadConfig(files)
    local doReload = false
    for _,file in ipairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end

-- 2. 再创建监听器（传入刚才定义好的函数名）
local myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

-- 3. 最后提示成功
hs.alert.show("Hammerspoon 配置已就绪 🔥")