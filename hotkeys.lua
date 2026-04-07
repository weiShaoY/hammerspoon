-- 热键统一放这里：模块只提供功能，这里负责绑定。

-- 预留：常用的 “Hyper” 组合键
-- local hyper = { "cmd", "alt", "ctrl" }

local log = hs.logger.new("hotkeys", "info")

-- 音频输出切换：F13
do
    local ok, audioSwitch = pcall(require, "modules.switch-audio")
    if ok and audioSwitch and type(audioSwitch.toggleAudioOutput) == "function" then
        hs.hotkey.bind({}, "F13", audioSwitch.toggleAudioOutput)
        log.i("已绑定热键：F13 -> 音频输出切换")
    else
        log.e("绑定失败：F13 音频输出切换（未找到模块 modules.switch-audio）")
    end
end

-- 打开微信：F14
do
    local ok, wechat = pcall(require, "modules.open-wechat")
    if ok and wechat and type(wechat.openWeChat) == "function" then
        hs.hotkey.bind({}, "F14", wechat.openWeChat)
        log.i("已绑定热键：F14 -> 打开微信")
    else
        log.e("绑定失败：F14 打开微信（未找到模块 modules.open-wechat）")
    end
end
