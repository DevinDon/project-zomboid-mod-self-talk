-- 导入工具模块
local utils = require('utils')

-- 配置项文档见 <https://pzwiki.net/wiki/ModOptions>
local createOptions = function()
  -- 创建配置项
  local options = PZAPI.ModOptions:create('SelfTalk', 'UI_Options_Title')
  -- 角色配置
  options:addTitle('UI_Options_Character')
  -- 角色性格，会影响角色说话的频率以及台词风格，默认为泰然自若
  local personality = options:addComboBox(
    'Personality',
    'UI_Options_Personality',
    'UI_Options_Personality_Tooltip'
  )
  -- 喋喋不休
  personality:addItem('UI_Options_Personality_Talkative', false)
  -- 泰然自若
  personality:addItem('UI_Options_Personality_Composed', true)
  -- 沉默寡言
  personality:addItem('UI_Options_Personality_Reticent', false)
  -- 台词使用规则，仅内置、仅额外或两者都使用
  local rule = options:addComboBox('Rule', 'UI_Options_Rule', 'UI_Options_Rule_Tooltip')
  -- 只使用内置台词
  rule:addItem('UI_Options_Rule_Only_BuiltIn', false)
  -- 只使用额外台词
  rule:addItem('UI_Options_Rule_Only_Extra', false)
  -- 两者都使用
  rule:addItem('UI_Options_Rule_Both', true)
  -- 台词启用等级，只在恶化到指定等级时生效，比如默认从饥饿 0 到饥饿 1 不会触发，但饥饿 2 到 饥饿 1 会触发
  local levels = options:addMultipleTickBox(
    'Levels',
    'UI_Options_Levels',
    'UI_Options_Levels_Tooltip'
  )
  levels:addTickBox('UI_Options_Levels_1', false)
  levels:addTickBox('UI_Options_Levels_2', true)
  levels:addTickBox('UI_Options_Levels_3', true)
  levels:addTickBox('UI_Options_Levels_4', true)
end

-- 执行配置项创建
createOptions()

-- 可用状态映射
local Moodles = {
  { enum = MoodleType.ENDURANCE,     name = 'Endurance' },
  { enum = MoodleType.HEAVY_LOAD,    name = 'HeavyLoad' },
  { enum = MoodleType.ANGRY,         name = 'Angry' },
  { enum = MoodleType.STRESS,        name = 'Stress' },
  { enum = MoodleType.THIRST,        name = 'Thirst' },
  { enum = MoodleType.TIRED,         name = 'Tired' },
  { enum = MoodleType.HUNGRY,        name = 'Hunger' },
  { enum = MoodleType.PANIC,         name = 'Panic' },
  { enum = MoodleType.SICK,          name = 'Sick' },
  { enum = MoodleType.BORED,         name = 'Bored' },
  { enum = MoodleType.UNHAPPY,       name = 'Unhappy' },
  { enum = MoodleType.BLEEDING,      name = 'Bleeding' },
  { enum = MoodleType.WET,           name = 'Wet' },
  { enum = MoodleType.HAS_A_COLD,    name = 'HasACold' },
  { enum = MoodleType.INJURED,       name = 'Injured' },
  { enum = MoodleType.PAIN,          name = 'Pain' },
  { enum = MoodleType.DRUNK,         name = 'Drunk' },
  { enum = MoodleType.FOOD_EATEN,    name = 'FoodEaten' },
  { enum = MoodleType.HYPERTHERMIA,  name = 'Hyperthermia' },
  { enum = MoodleType.HYPOTHERMIA,   name = 'Hypothermia' },
  { enum = MoodleType.WINDCHILL,     name = 'Windchill' },
  { enum = MoodleType.UNCOMFORTABLE, name = 'Uncomfortable' },
  { enum = MoodleType.NOXIOUS_SMELL, name = 'NoxiousSmell' }
}

-- 模组全局配置
local Configs = {
  -- 台词启用等级，键表示等级，值表示是否启用
  levels = {},
  -- 角色性格，1 为喋喋不休、2 为泰然自若、3 为沉默寡言
  personality = 2,
  -- 发言间隔，单位游戏内分钟，最低 1 分钟
  interval = 1,
  -- 单次发言条数，最少 1 条
  size = 1,
  -- 台词表，解析 `IGUI.json` 文件，保持键名不变，值以 / 分隔解析为列表
  lines = {},
}

-- 获取配置
Events.OnInitWorld.Add(
  function()
    -- 模组全局配置
    local Options = PZAPI.ModOptions:getOptions('SelfTalk')
    -- 获取配置中的台词启用等级，获取最后一个字符作为等级
    for index, item in ipairs(Options:getOption('Levels').values) do
      Configs.levels[tonumber(string.sub(item.name, -1))] = item.value
    end
    -- 获取配置中的角色性格以确定台词风格、多次发言间隔和单次发言数量
    Configs.personality = Options:getOption('Personality').selected
    -- 喋喋不休间隔游戏内 1 分钟，以此类推
    Configs.interval = math.max(1, Configs.personality - 1)
    -- 喋喋不休每次最多发言 3 - 1 = 2 句台词，以此类推
    Configs.size = math.max(1, 3 - Configs.personality)
    -- 解析台词表
    for index, item in ipairs(Moodles) do
      -- 获取状态名称
      local name = item.name
      -- 遍历性格
      for personality = 1, 3 do
        -- 遍历好转和恶化
        for improvement = 1, 2 do
          -- 遍历等级
          for level = 0, 4 do
            -- 拼接键名
            local key = 'IGUI_SelfTalk_Moodle_Personality_' .. personality .. '_' .. name .. '_' .. (improvement == 1 and 'Improve' or 'Worsen') .. '_To_' .. level
            -- 获取台词
            local text = getText(key)
            -- 如果台词不为空
            if text ~= nil and text ~= '' then
              -- 拆分台词列表并将添加到配置中
              Configs.lines[key] = utils.split(text)
            end
          end
        end
      end
    end
  end
)

-- 导出配置
return {
  Moodles = Moodles,
  Configs = Configs,
}
