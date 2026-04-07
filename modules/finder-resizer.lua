-- Finder 窗口大小调整模块

-- 配置参数
local RESIZE_MIN_WIDTH = 1400  -- 窗口最小宽度
local RESIZE_MIN_HEIGHT = 1000 -- 窗口最小高度
local RESIZE_TARGET_BUNDLE_ID = "com.apple.finder"
local RESIZE_TARGET_APP_NAMES = { ["Finder"] = true, ["访达"] = true }

local M = {}

-- 调整目标窗口大小的函数
-- @param window 窗口对象
local function resizeTargetWindow(window)
    -- 检查窗口是否存在且可见
    if not window or not window:isVisible() then return end

    -- 获取窗口所属的应用程序
    local app = window:application()
    if not app then return end

    local bundleID = app:bundleID()
    local appName = app:name()
    local isFinder = (bundleID == RESIZE_TARGET_BUNDLE_ID) or (appName and RESIZE_TARGET_APP_NAMES[appName])
    if not isFinder then
        return
    end

    -- 获取窗口的当前框架信息（位置和大小）
    local frame = window:frame()
    -- 标记是否需要调整大小
    local needsResize = false

    local screen = window:screen()
    local screenFrame = screen and screen:frame() or nil

    local targetW = math.max(frame.w, RESIZE_MIN_WIDTH)
    local targetH = math.max(frame.h, RESIZE_MIN_HEIGHT)
    if screenFrame then
        targetW = math.min(targetW, screenFrame.w)
        targetH = math.min(targetH, screenFrame.h)
    end

    if frame.w ~= targetW then
        frame.w = targetW
        needsResize = true
    end
    if frame.h ~= targetH then
        frame.h = targetH
        needsResize = true
    end

    if screenFrame then
        local maxX = screenFrame.x + screenFrame.w - frame.w
        local maxY = screenFrame.y + screenFrame.h - frame.h

        local newX = math.max(screenFrame.x, math.min(frame.x, maxX))
        local newY = math.max(screenFrame.y, math.min(frame.y, maxY))
        if frame.x ~= newX then
            frame.x = newX
            needsResize = true
        end
        if frame.y ~= newY then
            frame.y = newY
            needsResize = true
        end
    end

    -- 如果需要调整大小，显示通知并应用新的窗口大小
    if needsResize then
        hs.alert.show("正在调整 Finder 窗口...")
        window:setFrame(frame)
    end
end

function M.start()
    if M._filter then return M end
    -- 创建窗口过滤器，用于监听目标应用程序的窗口事件
    M._filter = hs.window.filter.new({ "Finder", "访达" })
    -- 订阅窗口创建和窗口获取焦点事件，当事件触发时调用 resizeTargetWindow 函数
    M._filter:subscribe({
        hs.window.filter.windowCreated,  -- 窗口创建事件
        hs.window.filter.windowFocused  -- 窗口获取焦点事件
    }, resizeTargetWindow)
    return M
end

function M.stop()
    if not M._filter then return M end
    if type(M._filter.unsubscribeAll) == "function" then
        M._filter:unsubscribeAll()
    end
    M._filter = nil
    return M
end

return M
