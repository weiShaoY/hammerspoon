-- Hammerspoon: 打开/切换到微信（WeChat）

local log = hs.logger.new("wechat", "info")

local WECHAT_BUNDLE_ID = "com.tencent.xinWeChat"
local WECHAT_APP_NAMES = { "WeChat", "微信" }

local function openWeChat()
    if hs.application.launchOrFocusByBundleID(WECHAT_BUNDLE_ID) then
        return
    end

    for _, name in ipairs(WECHAT_APP_NAMES) do
        if hs.application.launchOrFocus(name) then
            return
        end
    end

    log.e("WeChat not found (bundleID=%s)", WECHAT_BUNDLE_ID)
    hs.alert.show("❌ 未找到微信（WeChat）")
end

return {
    openWeChat = openWeChat,
}

