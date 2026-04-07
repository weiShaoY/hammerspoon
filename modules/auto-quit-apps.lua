-- ===================== 配置区：只改这里 =====================
-- 要监控的软件名称（必须和应用名称完全一致，可在活动监视器看）
local TARGET_APPS = {
  'IINA'
}
-- ==========================================================

-- 创建窗口过滤器：只监听目标应用
local wf = hs.window.filter.new(TARGET_APPS)

-- 监听【窗口被销毁】（点 X 关闭）
wf:subscribe(hs.window.filter.windowDestroyed, function(win)
    if not win then return end

    local app = win:application()
    if not app then return end
    local appName = app:name()

    -- 延迟 0.2s 再判断，避免窗口还没完全销毁时判断错误
    hs.timer.doAfter(0.2, function()
        -- 检查该应用是否**已经没有任何窗口**
        local allWindows = app:allWindows()
        if not allWindows or #allWindows == 0 then
            -- 强制退出进程
            app:kill()
            -- 可选：通知中心提示（可删掉）
            hs.notify.new({
                title = "已强制退出",
                subTitle = appName,
                autoWithdraw = true
            }):send()
        end
    end)
end)

