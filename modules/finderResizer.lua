-- 陌生 Finder 窗口大小调整
local RESIZE_MIN_WIDTH = 1400  -- 最小宽度
local RESIZE_MIN_HEIGHT = 1000 -- 最小高度
local RESIZE_TARGET_APP = "访达" -- 目标应用程序名称

-- 定义调整窗口大小的函数
local function resizeTargetWindow(window)
    -- 检查窗口是否为 nil 或不可见
    if not window or not window:isVisible() then return end

    -- 获取窗口所属的应用程序
    local app = window:application()
    -- 检查应用程序名称是否匹配目标应用程序
    if not (app and app:name() == RESIZE_TARGET_APP) then
        return
    end

    -- 获取窗口的当前框架
    local frame = window:frame()
    -- 标记是否需要调整大小
    local needsResize = false

    -- 如果宽度小于最小宽度，进行调整
    if frame.w < RESIZE_MIN_WIDTH then
        frame.w = RESIZE_MIN_WIDTH
        needsResize = true
    end

    -- 如果高度小于最小高度，进行调整
    if frame.h < RESIZE_MIN_HEIGHT then
        frame.h = RESIZE_MIN_HEIGHT
        needsResize = true
    end

    -- 如果需要调整大小，显示通知并调整窗口大小
    if needsResize then
        hs.alert.show("正在调整 '" .. RESIZE_TARGET_APP .. "' 窗口...")
        window:setFrame(frame)
    end
end

-- 创建过滤器，订阅窗口创建和焦点事件
local finderResizeFilter = hs.window.filter.new(RESIZE_TARGET_APP)
finderResizeFilter:subscribe({
    hs.window.filter.windowCreated,  -- 窗口创建事件
    hs.window.filter.windowFocused  -- 窗口获取焦点事件
}, resizeTargetWindow)
