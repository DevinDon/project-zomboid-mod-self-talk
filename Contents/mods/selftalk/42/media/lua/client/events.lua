-- 导入事件处理器
local onMoodleUpdate = require('moodle-change').onMoodleUpdate
local onQueueConsume = require('queue').onQueueConsume

-- 注册检测事件，每分钟触发一次，见 <https://pzwiki.net/wiki/EveryOneMinute>
Events.EveryOneMinute.Add(
  function()
    -- 先推入台词
    onMoodleUpdate()
    -- 再检测发言
    onQueueConsume()
  end
)
