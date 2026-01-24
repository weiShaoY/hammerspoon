-- Hammerspoon: 切换音频输出设备（Headsets <-> Yamaha YVC-330）
-- 将本文件保存为 ~/.hammerspoon/init.lua，Reload Config 后按 F12 切换

-- 定义要切换的两个设备
local DEVICES = {
    {name = "Headsets", icon = "🎧"},           -- 耳机
    {name = "Yamaha YVC-330", icon = "🔈"}     -- 雅马哈设备
}

-- 获取所有音频设备
local function getAllAudioDevices()
    local devices = {}
    for _, dev in ipairs(hs.audiodevice.allOutputDevices()) do
        devices[dev:name()] = dev
    end
    return devices
end

-- 切换音频设备
local function toggleAudioOutput()
    local allDevices = getAllAudioDevices()

    -- 检查两个设备是否都存在
    local device1 = allDevices[DEVICES[1].name]
    local device2 = allDevices[DEVICES[2].name]

    if not device1 or not device2 then
        hs.alert.show("❌ 找不到音频设备")
        return
    end

    -- 获取当前设备
    local current = hs.audiodevice.defaultOutputDevice()

    -- 决定切换到哪个设备
    local target = nil
    local targetIcon = ""

    if current and current:name() == DEVICES[1].name then
        target = device2
        targetIcon = DEVICES[2].icon
    else
        target = device1
        targetIcon = DEVICES[1].icon
    end

    -- 执行切换
    if target:setDefaultOutputDevice() then
        hs.alert.show(targetIcon .. " 已切换至: " .. target:name())
    else
        hs.alert.show("❌ 切换失败")
    end
end




-- hs.hotkey.bind({"ctrl"}, "f1", toggleAudioOutput)

-- 绑定热键 F12（没有修饰键）
hs.hotkey.bind({}, "f13", toggleAudioOutput)

-- 加载提示
print("🎧 音频切换脚本已加载")
print("📢 按 F12 切换设备:")
for i, device in ipairs(DEVICES) do
    print("  " .. i .. ". " .. device.icon .. " " .. device.name)
end