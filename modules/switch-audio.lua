-- Hammerspoon: 音频输出设备切换模块
-- 功能：在两个指定的音频设备之间切换（Headsets <-> Yamaha YVC-330）
-- 使用方法：按 F12 键切换音频设备

-- 定义要切换的两个音频设备
local DEVICES = {
    {name = "Headsets", icon = "🎧"},           -- 耳机设备
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
        hs.alert.show("❌ 找不到音频设备")
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

-- 绑定热键：按 F12 键（无修饰键）切换音频设备
hs.hotkey.bind({}, "f13", toggleAudioOutput)

-- 加载提示信息
print("🎧 音频切换脚本已加载")
print("📢 按 F13 切换设备:")
-- 遍历并打印所有可切换的设备
for i, device in ipairs(DEVICES) do
    print("  " .. i .. ". " .. device.icon .. " " .. device.name)
end