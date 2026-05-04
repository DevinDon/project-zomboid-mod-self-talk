-- 获取配置
local Options = require('options')
local Configs = Options.Configs
local Moodles = Options.Moodles

-- 导入工具模块
local utils = require('utils')

-- 导入发言队列模块
local Queue = require('queue')

-- 角色当前状态表
local Status = {}

-- 将状态名称和状态变化转换为台词并推入发言队列
-- personality 即角色性格，等价于台词风格，同时会根据性格决定一次推入的台词数量
-- name 即 Moodles.name
-- level 为 0 到 4
-- improvement 表示是否向好转，比如角色从饥饿 4 级到饥饿 3 级，等级降低即为好转
local push = function(name, level, improvement)
  local key = 'IGUI_SelfTalk_Moodle_Personality_' .. Configs.personality .. '_' .. name .. '_' .. (improvement and 'Improve' or 'Worsen') .. '_To_' .. level
  print('[debug - push]: ' .. key)
  local list = Configs.lines[key]
  for none, index in ipairs(utils.sample(#list, Configs.size)) do
    Queue.push(list[index])
  end
end

-- 触发角色状态更新，检测当前角色状态变化
-- 事件回调参数见 <https://projectzomboid.com/modding/zombie/characters/IsoPlayer.html>
local onMoodleUpdate = function()
  local player = getPlayer()
  for index, moodle in pairs(Moodles) do
    -- 获取角色当前状态等级，值为 0 到 4
    local level = player:getMoodleLevel(moodle.enum)
    -- 检测状态好转（等级下降）或恶化（等级上升）
    -- 如果没有初始化则进行初始赋值，不执行其他操作
    if Status[moodle.name] == nil then
      Status[moodle.name] = level
      -- 如果角色状态恶化（等级上升）
    elseif level > Status[moodle.name] then
      print('[debug - onMoodleUpdate - Worsen]: ' .. moodle.name .. ' - ' .. Status[moodle.name] .. ' - ' .. level)
      print('[debug - onMoodleUpdate - Worsen]: ' .. tostring(Configs.levels[level]))
      -- 在恶化时判断目标等级是否为已启用等级，如果未启用则忽略
      if Configs.levels[level] == true then
        push(moodle.name, level, false)
      end
      Status[moodle.name] = level
      -- 如果角色状态好转（等级下降）
    elseif level < Status[moodle.name] then
      print('[debug - onMoodleUpdate - Improve]: ' .. moodle.name .. ' - ' .. Status[moodle.name] .. ' - ' .. level)
      push(moodle.name, level, true)
      Status[moodle.name] = level
      -- 状态不变则忽略
    end
  end
end

-- 导出模块
return {
  onMoodleUpdate = onMoodleUpdate,
}
