-- 微信输入法专用：按键模拟同步版
local HEIGHT = 6
local COLOR_CN = { green = 1, alpha = 0.8 }
local COLOR_EN = { red = 1, alpha = 0.8 }
local IME_WECHAT = "com.tencent.inputmethod.wetype.pinyin"

local canvas = nil
local isEnglish = false -- 内部状态记录

-- 初始化画布
local function initCanvas()
    local f = hs.screen.mainScreen():fullFrame()
    canvas = hs.canvas.new({x=0, y=0, w=f.w, h=HEIGHT})
    canvas:level(hs.canvas.windowLevels.status + 1)
    canvas:behavior({hs.canvas.windowBehaviors.canJoinAllSpaces, hs.canvas.windowBehaviors.ignoresMouseEvents})
    canvas[1] = {type="rectangle", action="fill", fillColor=COLOR_CN}
end

-- 刷新显示
local function refresh()
    if not canvas then initCanvas() end

    local source = hs.keycodes.currentSourceID()
    if source ~= IME_WECHAT then
        canvas:hide()
        return
    end

    canvas[1].fillColor = isEnglish and COLOR_EN or COLOR_CN
    canvas:show()
end

-- 【核心：监听 Shift 按键】
-- 微信输入法通常靠单压 Shift 切换，我们捕获这个动作
local shiftWatcher = hs.eventtap.new({hs.eventtap.eventtypes.flagsChanged}, function(event)
    local flags = event:getFlags()
    local keyCode = event:getKeyCode()

    -- 检查是否是左 Shift (56) 或 右 Shift (60)
    if keyCode == 56 or keyCode == 60 then
        -- 这里的逻辑是：当 Shift 被按下再松开时触发（微信切换逻辑）
        -- 为了简化，我们直接在按下时翻转
        isEnglish = not isEnglish
        refresh()
    end
    return false -- 不拦截事件，只做监听
end):start()

-- 监听输入法切换（切到别家输入法时隐藏）
hs.keycodes.inputSourceChanged(function()
    isEnglish = false -- 每次切回微信默认先设为中文模式（或根据你习惯调整）
    refresh()
end)



-- 初始运行
refresh()