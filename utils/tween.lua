-- 缓动函数模块
local Tween = {}

-- 指数缓出函数
-- 功能：创建一个从快速到缓慢的动画效果
-- @param t 时间进度，范围 0-1
-- @return 缓动后的进度值
function Tween.easeOutExpo(t)
  -- 当 t 为 1 时直接返回 1，否则计算指数缓动值
  return t == 1 and 1 or 1 - math.pow(2, -10 * t)
end

-- 导出 Tween 模块
return Tween