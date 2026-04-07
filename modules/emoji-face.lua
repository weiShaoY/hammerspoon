---@diagnostic disable: lowercase-global
-- 表情包搜索

local M = {}

local page = 1
local choices = {}
local chooser_raw_len = 0
local base_url = "https://www.doutub.com"
local temp_dir = os.getenv("HOME") .. "/.hammerspoon/.emoji-temp/"
local emoji_canvas
local chooser
local select_key

-- 简单的 trim 函数
local function trim(s)
    return s:match("^%s*(.-)%s*$")
end

-- 模拟 htmlparser 功能（简化版）
local function parse_html(body)
    local response_data = {}

    -- 简单的正则匹配获取图片
    for alt, src in body:gmatch('alt="([^"]+)"[^>]*data%-src="([^"]+)"') do
        if alt and src then
            table.insert(response_data, { alt, src })
        end
    end

    return response_data
end

local function render_chooser(file_path)
    local image = hs.image.imageFromPath(file_path)
    if (#choices >= 10) or not image then
        return
    end
    local filename_ext = file_path:match("^.+%.([^%.]+)$")
    local title = file_path:gsub(temp_dir, ""):gsub("." .. filename_ext, "")
    if (#choices > 0) and (title == choices[#choices]["text"]) then
        return
    end
    table.insert(choices, {
        text = title,
        subText = "来源: 网络",
        path = file_path,
        image = image,
    })
    chooser:choices(choices)
end

local function download_file(url, file_path)
    -- 异步方式下载
    local down_emoji_task = hs.task.new(
        "/usr/bin/curl",
        function() render_chooser(file_path) end,
        {
            "--header",
            "Referer: " .. base_url,
            "--connect-timeout",
            "3",
            "-L",
            url,
            "--create-dirs",
            "-o",
            file_path,
        }
    )
    down_emoji_task:start()
end

local function preview(path)
    if not path then
        return
    end
    emoji_canvas[1] = {
        type = "image",
        image = hs.image.imageFromPath(path),
        imageScaling = "scaleProportionally",
        imageAnimates = true,
    }
    emoji_canvas:show()
end

local function request(query_kw)
    local req_url = base_url .. "/search/"
    local request_headers = { Referer = base_url }

    query_kw = trim(query_kw)

    if query_kw == "" then
        return
    end

    local url = req_url .. hs.http.encodeForQuery(query_kw) .. "/" .. page

    hs.http.doAsyncRequest(url, "GET", nil, request_headers, function(code, body, response_headers)
        local response_data = parse_html(body)
        if code == 200 and response_data then
            chooser_raw_len = #response_data
            for _, v in ipairs(response_data) do
                local title = v[1]:gsub(" ", "")
                local img_url = v[2]
                local filename_ext = hs.http.urlParts(img_url).pathExtension
                local file_path = temp_dir .. title .. "." .. filename_ext
                -- 下载图片
                download_file(img_url, file_path)
            end
        end
    end)
end

function M.start()
    -- 创建临时目录
    if not hs.fs.pathToAbsolute(temp_dir) then
        hs.fs.mkdir(temp_dir)
    end

    -- 每小时自动清理临时文件夹
    hs.timer.doEvery(3600, function()
        clean_temp_dir()
    end)

    -- 获取屏幕信息
    local focusedWindow = hs.window.focusedWindow()
    local screen = { w = 1920, h = 1080 } -- 默认值
    if focusedWindow then
        screen = focusedWindow:screen():frame()
    end

    -- 占屏幕宽度的 20%（居中）
    local WIDTH = 300
    local HEIGHT = 300
    local CHOOSER_WIDTH = screen.w * 0.2
    local COORIDNATE_X = screen.w / 2 + CHOOSER_WIDTH / 2 + 5
    local COORIDNATE_Y = screen.h / 2 - 300
    emoji_canvas = hs.canvas.new({
        x = COORIDNATE_X,
        y = COORIDNATE_Y - HEIGHT / 2,
        w = WIDTH,
        h = HEIGHT,
    })

    -- 创建 chooser
    chooser = hs.chooser.new(function(selected)
        if selected then
            local image = hs.image.imageFromPath(selected.path)
            if not image then
                return
            end
            hs.pasteboard.writeObjects(image)
            hs.eventtap.keyStroke({ "cmd" }, "v")
        end
    end)
    chooser:width(30)
    chooser:rows(10)
    chooser:bgDark(false)
    chooser:fgColor({ hex = "#000000" })
    chooser:placeholderText("输入关键词搜索表情包")

    -- 上下键选择表情包预览
    select_key = hs.eventtap
        .new({ hs.eventtap.event.types.keyDown }, function(event)
            -- 只在 chooser 显示时，才监听键盘按下
            if not chooser:isVisible() then
                return
            end
            local keycode = event:getKeyCode()
            local key = hs.keycodes.map[keycode]
            if "right" == key then
                page = page + 1
                choices = {}
                request(chooser:query())
                return
            end
            if "left" == key then
                if page <= 1 then
                    page = 1
                    return
                end
                page = page - 1
                choices = {}
                request(chooser:query())
                return
            end

            if "down" ~= key and "up" ~= key then
                return
            end
            local number = chooser:selectedRow()
            if "down" == key then
                if number < chooser_raw_len then
                    number = number + 1
                else
                    number = 1
                end
            end
            if "up" == key then
                if number > 1 then
                    number = number - 1
                else
                    number = chooser_raw_len
                end
            end
            local selrowcontent = chooser:selectedRowContents(number)
            if selrowcontent then
                preview(selrowcontent.path)
            end
        end)
        :start()

    -- 搜索回调
    chooser:queryChangedCallback(function()
        hs.timer.doAfter(0.3, function()
            local query = chooser:query()
            page = 1
            choices = {}
            request(query)
        end)
    end)

    -- 隐藏回调
    chooser:hideCallback(function()
        if emoji_canvas then
            emoji_canvas:hide(0.3)
        end
    end)
end

function M.show()
    if chooser then
        chooser:show()
        chooser:query("")
    end
end

return M
