local CurrentSkill = require 'src.components.skills.currentSkill'
local Phase = require 'src.components.phase'

local System = require 'src.systems.system'

local UpdateAreaSkill = Class('UpdateAreaSkill', System)

function UpdateAreaSkill:initialize()
  System.initialize(self, 'Transform', 'AreaSkill')

  self.currentSkillComponent = CurrentSkill()

  self.timer = Hump.Timer.new()

  self.cornerOffset = 2
  self.timer:every(0.66, function()
    self.cornerOffset = -self.cornerOffset
  end)
end

function UpdateAreaSkill:earlysystemupdate(dt)
  self.timer:update(dt)

  if Phase():current() ~= 'battle' then
    self.currentSkillComponent.currentSkill = nil
  end
end

function UpdateAreaSkill:update(transform, areaSkill, dt)
  if areaSkill.secondsUntilDetonate > 0 then
    areaSkill.secondsUntilDetonate = areaSkill.secondsUntilDetonate - dt

  else
    local continuousInfo = areaSkill.continuousInfo

    if continuousInfo == nil then
      local damageInfo = areaSkill.damageInfo
      self:damageEnemiesInArea(areaSkill.hero, damageInfo,
          areaSkill.targetInfo.x, areaSkill.targetInfo.y, areaSkill.w, areaSkil.h)

      Hump.Gamestate.current():removeEntity(transform:getEntity())

    else
      if continuousInfo.secondsUnitlNextTick > 0 then
        continuousInfo.secondsUnitlNextTick = continuousInfo.secondsUnitlNextTick - dt

      else
        local damageInfo = areaSkill.damageInfo
        self:damageEnemiesInArea(areaSkill.hero, damageInfo,
            areaSkill.targetInfo.x - areaSkill.w/2, areaSkill.targetInfo.y - areaSkill.h/2, areaSkill.w, areaSkill.h)
        
        continuousInfo.tickCount = continuousInfo.tickCount - 1
        if continuousInfo.tickCount <= 0 then 
          Hump.Gamestate.current():removeEntity(transform:getEntity())
        else
          continuousInfo.secondsUnitlNextTick = continuousInfo.secondsPerTick
        end
      end
    end
  end
end

function UpdateAreaSkill:damageEnemiesInArea(hero, damageInfo, areaX, areaY, areaW, areaH)
  local damage = hero:getDamageFromRatio(damageInfo.attackDamageRatio,
      damageInfo.realityPowerRatio, damageInfo.canCrit) 

  local enemyEntities = Hump.Gamestate.current():getEntitiesWithComponent('Enemy')
  enemyEntities = Lume.filter(enemyEntities, function(enemyEntity)
    local x, y = enemyEntity:getComponent('Transform'):getGlobalPosition()
    local w, h = enemyEntity:getComponent('Area'):getSize()
    return x < areaX + areaW and x + w > areaX and y < areaY + h and y + h > areaY
  end)
  for _, enemyEntity in ipairs(enemyEntities) do
    local enemy = enemyEntity:getComponent('Enemy')
    enemy:takeDamage(damage, damageInfo.damageType)
    for _, effect in ipairs(damageInfo.effects) do
      enemy:applyEffect(Lume.clone(effect))
    end
  end
end

function UpdateAreaSkill:earlysystemworlddraw()
  if self.currentSkillComponent.currentSkill then
    local w, h = self.currentSkillComponent.currentSkill.secondaryW, self.currentSkillComponent.currentSkill.secondaryH
    Deep.queue(17, function()
      local mx, my = love.mouse.getPosition()

      
      love.graphics.setColor(0.62, 0.6, 0.66, 0.15)
      love.graphics.rectangle('fill', mx - w/2 + 1, my - h/2 + 1, w, h, 2)

      love.graphics.setColor(0.62, 0.6, 0.66, 0.9)
      local signses = {{1, 1}, {-1, 1}, {1, -1}, {-1, -1}}
      for i = 1, 4 do
        love.graphics.rectangle('fill', mx + 6 * signses[i][1], my + 6 * signses[i][2], 2, 2)
        love.graphics.rectangle('fill', mx + 6 * signses[i][1], my + 4 * signses[i][2], 2, 2)
        love.graphics.rectangle('fill', mx + 4 * signses[i][1], my + 6 * signses[i][2], 2, 2)

        love.graphics.rectangle('fill', mx + (4 + w/2 + self.cornerOffset) * signses[i][1], my + (4 + h/2 + self.cornerOffset) * signses[i][2], 2, 2)
        love.graphics.rectangle('fill', mx + (4 + w/2 + self.cornerOffset) * signses[i][1], my + (2 + h/2 + self.cornerOffset) * signses[i][2], 2, 2)
        love.graphics.rectangle('fill', mx + (2 + w/2 + self.cornerOffset) * signses[i][1], my + (4 + h/2 + self.cornerOffset) * signses[i][2], 2, 2)
      end

      -- love.graphics.rectangle('line', mx - 6, my - 6, 12, 12)

      love.graphics.setLineWidth(1)
    end)
  end
end

function UpdateAreaSkill:earlysystemmousepressed(x, y, button)
  local currentSkill = self.currentSkillComponent.currentSkill
  if currentSkill ~= nil then
    if button == 1 then
      local hero = currentSkill.hero
      currentSkill._fn(hero, x, y)
      self.currentSkillComponent.currentSkill = nil
      if hero.overrides.onSkillCast then return hero.overrides.onSkillCast(self) end
      
    elseif button == 2 then
      self.currentSkillComponent.currentSkill = nil

    end
  end
end

return UpdateAreaSkill