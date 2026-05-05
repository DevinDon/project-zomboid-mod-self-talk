-- 以 / 为分隔符的分割函数
local split = function(text)
  local list = {}
  for slice in string.gmatch(text, '[^/]+') do
    table.insert(list, slice)
  end
  return list
end

-- 随机数生成器
local randomer = newrandom()

-- 随机采样，从 1 到 n 中随机返回 k 个不重复的数字
local sample = function(n, k)
  -- 如果 n 小于 1 或 k 小于等于 0，返回空表
  if n < 1 or k <= 0 then return {} end
  -- 如果 k 大于等于 n，返回全部数字，并随机打乱顺序
  if k >= n then
    local result = {}
    for i = 1, n do result[i] = i end
    for i = n, 2, -1 do
      local j = randomer:random(i)
      result[i], result[j] = result[j], result[i]
    end
    return result
  end
  -- 部分洗牌法，只随机交换前 k 个位置
  local pool = {}
  for i = 1, n do pool[i] = i end
  for i = 1, k do
    local j = randomer:random(i, n)
    pool[i], pool[j] = pool[j], pool[i]
  end
  local result = {}
  for i = 1, k do result[i] = pool[i] end
  return result
end

-- 获取当前时间戳，毫秒
-- 如果缓存 `Calendar.getInstance()` 则会导致时间不变，所以必须每次获取新的实例
local now = function()
  return Calendar.getInstance():getTimeInMillis()
end

-- 导出模块
return {
  split = split,
  sample = sample,
  now = now,
}
