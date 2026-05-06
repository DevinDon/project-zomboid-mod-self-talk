-- 导入工具
local Utils = require('utils')
-- 获取配置
local Configs = require('options').Configs

-- 角色即将发言的台词队列
local Queue = {}

-- 发言时间戳
local last = 0

-- 每次累加游戏内的分钟数，并检测是否需要发言消费台词
local onQueueConsume = function()
  -- 获取当前角色
  local player = getPlayer()
  -- 如果获取不到角色、队列为空或发言间隔过短则不发言
  -- 支持配置项中的发言频率，包含多次发言间隔和单次发言数量
  if player == nil or #Queue == 0 or Utils.now() - last < Configs.interval then
    return
  end
  -- 更新发言时间戳
  last = Utils.now()
  -- 获取下一句台词
  local line = table.remove(Queue, 1)
  -- 发言
  player:Say(line)
end

-- 添加台词到队列，过滤无效输入、空字符串输入和非字符串输入
local push = function(text)
  if type(text) ~= 'string' or text == '' then return end
  table.insert(Queue, text)
end

-- 导出接口
return {
  push = push,
  onQueueConsume = onQueueConsume,
}
