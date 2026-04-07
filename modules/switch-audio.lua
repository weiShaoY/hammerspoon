-- Hammerspoon: 音频输出设备切换模块
-- 功能：在两个指定的音频设备之间切换（Headsets <-> Yamaha YVC-330）
-- 使用方法：在 init.lua 里绑定热键（默认 F13）

-- 定义要切换的两个音频设备
local DEVICES = {
    {name = "EarPods", icon = "🎧"},           -- 耳机设备
    {name = "Yamaha YVC-330", icon = "🔈"}     -- 雅马哈设备
}

-- 获取所有音频输出设备的函数
-- @return table 设备名称到设备对象的映射
local function getAllAudioDevices()
    local devices = {}  -- 存储设备的表
    -- 遍历所有音频输出设备
    for _, dev in ipairs(hs.audiodevice.allOutputDevices()) do
        -- 以设备名称为键，设备对象为值存储
        devices[dev:name()] = dev
    end
    return devices
end

-- 切换音频输出设备的函数
local function toggleAudioOutput()
    -- 获取所有音频设备
    local allDevices = getAllAudioDevices()

    -- 检查两个目标设备是否都存在
    local device1 = allDevices[DEVICES[1].name]
    local device2 = allDevices[DEVICES[2].name]

    -- 如果任一设备不存在，显示错误提示
    if not device1 or not device2 then
        local missing = {}
        if not device1 then missing[#missing + 1] = DEVICES[1].name end
        if not device2 then missing[#missing + 1] = DEVICES[2].name end

        local available = {}
        for name, _ in pairs(allDevices) do
            available[#available + 1] = name
        end
        table.sort(available)

        hs.alert.show("❌ 找不到音频设备: " .. table.concat(missing, ", "))
        if #available > 0 then
            print("可用输出设备: " .. table.concat(available, " | "))
        end
        return
    end

    -- 获取当前默认的音频输出设备
    local current = hs.audiodevice.defaultOutputDevice()

    -- 决定切换到哪个设备
    local target = nil      -- 目标设备
    local targetIcon = ""   -- 目标设备的图标

    -- 如果当前设备是第一个设备，则切换到第二个设备
    if current and current:name() == DEVICES[1].name then
        target = device2
        targetIcon = DEVICES[2].icon
    else
        -- 否则切换到第一个设备
        target = device1
        targetIcon = DEVICES[1].icon
    end

    -- 执行设备切换
    if target:setDefaultOutputDevice() then
        -- 切换成功，显示成功提示
        hs.alert.show(targetIcon .. " 已切换至: " .. target:name())
    else
        -- 切换失败，显示错误提示
        hs.alert.show("❌ 切换失败")
    end
end

local M = {
    devices = DEVICES,
    toggleAudioOutput = toggleAudioOutput,
}

return M
