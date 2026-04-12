-- Hammerspoon 配置初始化文件

local log = hs.logger.new("init", "info")
local notify = require("utils.notify")

-- 参考结构：init.lua 负责
-- 1) 启动后台模块/服务（Spoon 或 modules/*）
-- 2) 统一绑定快捷键（hs.hotkey.bind）

-- 自动重载：监听 ~/.hammerspoon/ 目录变更并 hs.reload()
require("utils.autoreload").start({ log = log, notify = notify })

-- Spoons（可选）：存在就启动，不存在也不影响整体启动
-- Spoon 是 Hammerspoon 的“插件”机制，一般放在 `~/.hammerspoon/Spoons/<Name>.spoon/`。
-- 这里封装成函数的目的：
-- - 统一管理：所有 Spoon 的加载/启动入口都在 init.lua，方便开关和排错
-- - 容错隔离：用 pcall 包裹，某个 Spoon 报错不会导致整份配置加载失败
-- - 兼容差异：不是所有 Spoon 都实现了 `start()`，有的只提供函数/对象
local function loadAndStartSpoon(name)
    local ok, err = pcall(hs.loadSpoon, name)
    if not ok then
        log.w("Spoon 未加载：%s (%s)", name, err)
        return nil
    end

    -- hs.loadSpoon 成功后，会把 Spoon 实例挂到全局 `spoon[name]` 上
    local sp = spoon and spoon[name] or nil
    if sp and type(sp.start) == "function" then
        local okStart, startErr = pcall(sp.start, sp)
        if not okStart then
            log.e("Spoon 启动失败：%s (%s)", name, startErr)
        end
    end
    return sp
end

-- 示例（按需开启）
-- loadAndStartSpoon("FifineDisplay")

-- 启动 modules（显式启动，避免 require 时产生副作用）
-- modules/ 下建议遵循“无副作用 require”的约定：
-- - `require("modules.xxx")` 只返回一个 table（配置/函数）
-- - 真正注册 watcher/eventtap/订阅等动作放在 `start()` 中
-- 这样做的好处：
-- - 启动顺序清晰（init.lua 一眼可见）
-- - 自动重载更安全（避免 reload 后重复注册监听导致多份回调并存）
-- - 未来可控（可以实现 stop()，按需开关功能）
local function startModule(modulePath)
    local ok, modOrErr = pcall(require, modulePath)
    if not ok then
        log.e("模块加载失败：%s (%s)", modulePath, modOrErr)
        return nil
    end

    local mod = modOrErr
    if type(mod) == "table" and type(mod.start) == "function" then
        -- 约定：模块的 start() 尽量做到“幂等”，多次调用不会重复注册
        local okStart, err = pcall(mod.start, mod)
        if not okStart then
            log.e("模块启动失败：%s (%s)", modulePath, err)
        end
    end

    return mod
end

startModule("modules.finder-resizer")
-- startModule("modules.auto-quit-apps")
-- startModule("modules.emoji-face")

-- 快捷键统一在 init.lua 里绑定

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

-- F15：打开表情包搜索
-- local emojiFace = require("modules.emoji-face")
-- hs.hotkey.bind({}, "F15", function()
--     emojiFace.show()
-- end)

-- 显示配置就绪的提示信息
notify.show("Hammerspoon 配置已就绪 🔥")
