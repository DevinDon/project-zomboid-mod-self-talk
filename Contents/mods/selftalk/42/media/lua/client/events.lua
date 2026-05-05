-- 导入工具
local utils = require('utils')
-- 导入事件处理器
local onMoodleUpdate = require('moodle-change').onMoodleUpdate
local onQueueConsume = require('queue').onQueueConsume

-- 上次执行时间戳，毫秒
local last = 0

-- 注册检测事件，每 Tick 触发一次，但用于节省性能会进行节流，每 0.5 秒执行一次，见 <https://pzwiki.net/wiki/OnTick>
Events.OnTick.Add(
  function(tick)
    local timestamp = utils.now()
    -- 节流检测，执行间隔不足 0.5 秒时忽略本次 Tick
    if timestamp - last < 500 then
      return
    end
    -- 更新执行时间戳
    last = timestamp
    -- 处理角色状态并推入台词
    onMoodleUpdate()
    -- 触发发言检测
    onQueueConsume()
  end
)
