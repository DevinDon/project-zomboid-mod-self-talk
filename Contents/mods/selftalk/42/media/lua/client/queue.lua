-- 获取配置
local Configs = require('options').Configs

-- 角色即将发言的台词队列
local Queue = {}

-- 游戏内的分钟数
local Minutes = {
  -- 游戏中已经历的分钟数
  total = 0,
  -- 上次发言的分钟数
  last = 0,
}

-- 每次累加游戏内的分钟数，并检测是否需要发言消费台词
-- 参数表示是否为手动触发，如果是手动触发则不会更新 `Minutes.total`
local onQueueConsume = function(manual)
  if manual ~= true then
    Minutes.total = Minutes.total + 1
  end
  -- 获取当前角色
  local player = getPlayer()
  -- 如果获取不到角色、队列为空或发言间隔过短则不发言
  -- 支持配置项中的发言频率，包含多次发言间隔和单次发言数量
  print('[debug - onQueueConsume - status]: ' .. #Queue .. ' - ' .. Minutes.total .. ' - ' .. Minutes.last .. ' - ' .. Configs.interval)
  if player == nil or #Queue == 0 or Minutes.total - Minutes.last < Configs.interval then
    return
  end
  -- 单次发言条数
  for index = 1, Configs.size do
    local line = table.remove(Queue, 1)
    -- 如果已经没有台词则跳出
    if line == nil then break end
    print('[debug - onQueueConsume - Say]: ' .. index .. line)
    player:Say(line)
  end
  Minutes.last = Minutes.total
end

-- 添加台词到队列
local push = function(text)
  if type(text) ~= 'string' or text == '' then return end
  table.insert(Queue, text)
  print('[debug - push]: ' .. text)
  -- 立即手动触发一次发言检测
  onQueueConsume(true)
end

-- 导出接口
return {
  push = push,
  onQueueConsume = onQueueConsume,
}
