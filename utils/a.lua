-- 工具函数模块
local Utils = {}

-- 空函数，用于默认回调
function noop() end

-- 防抖函数
-- 功能：在指定时间内多次调用函数时，只执行最后一次
-- @param func 要执行的函数
-- @param delay 延迟时间（秒）
-- @return 防抖处理后的函数
function Utils.debounce(func, delay)
  local timer = nil  -- 定时器

  -- 返回一个新函数
  return function(...)
    -- 保存函数参数
    local args = { ... }

    -- 如果定时器存在，停止它
    if timer then
      timer:stop()
      timer = nil
    end

    -- 创建新的定时器，延迟执行函数
    timer = hs.timer.doAfter(delay, function()
      func(table.unpack(args))
    end)
  end
end

-- 节流函数
-- 功能：限制函数的执行频率，在指定时间内最多执行一次
-- @param func 要执行的函数
-- @param delay 时间间隔（秒）
-- @return 节流处理后的函数
function Utils.throttle(func, delay)
  local wait = false       -- 是否处于等待状态
  local storedArgs = nil   -- 存储的函数参数
  local timer = nil        -- 定时器

  -- 检查是否有存储的参数需要执行
  local function checkStoredArgs()
    if storedArgs == nil then
      -- 没有存储的参数，解除等待状态
      wait = false
    else
      -- 执行存储的参数
      func(table.unpack(storedArgs))
      -- 清空存储的参数
      storedArgs = nil
      -- 重新设置定时器
      timer = hs.timer.doAfter(delay, checkStoredArgs)
    end
  end

  -- 返回一个新函数
  return function(...)
    -- 保存函数参数
    local args = { ... }

    -- 如果处于等待状态，存储参数并返回
    if wait then
      storedArgs = args
      return
    end

    -- 执行函数
    func(table.unpack(args))
    -- 设置等待状态
    wait = true
    -- 设置定时器，延迟后检查是否有存储的参数
    timer = hs.timer.doAfter(delay, checkStoredArgs)
  end
end

-- 限制值在指定范围内
-- @param value 要限制的值
-- @param min 最小值
-- @param max 最大值
-- @return 限制后的值
function Utils.clamp(value, min, max)
  return math.max(math.min(value, max), min)
end

--- 过渡效果工具函数
-- @param options 参数配置
--   @field duration 过渡时长（秒）
--   @field easing 缓动函数，函数接受一个真实进度并返回缓动后的进度
--   @field onProgress 过渡时触发的回调函数
--   @field onEnd 过渡结束后触发的回调函数
-- @return 用于取消过渡的函数
function Utils.animate(options)
  local duration = options.duration     -- 过渡时长
  local easing = options.easing         -- 缓动函数
  local onProgress = options.onProgress -- 进度回调
  local onEnd = options.onEnd or noop   -- 结束回调

  local st = hs.timer.absoluteTime()    -- 开始时间
  local timer = nil                     -- 定时器

  -- 进度处理函数
  local function progress()
    local now = hs.timer.absoluteTime()  -- 当前时间
    local diffSec = (now - st) / 1000000000  -- 经过的时间（秒）

    if diffSec <= duration then
      -- 计算进度并应用缓动函数
      onProgress(easing(diffSec / duration))
      -- 设置下一帧的定时器
      timer = hs.timer.doAfter(1 / 60, function() progress() end)
    else
      -- 过渡结束
      timer = nil
      -- 调用进度回调，进度为 1
      onProgress(1)
      -- 调用结束回调
      onEnd()
    end
  end

  -- 初始执行
  progress()

  -- 返回取消过渡的函数
  return function()
    if timer then
      timer:stop()
      timer = nil
    end
  end
end

-- 导出 Utils 模块
return Utils