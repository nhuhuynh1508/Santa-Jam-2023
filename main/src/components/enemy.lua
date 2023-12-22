local Component = require 'src.components.component'

local Enemy = Class('Enemy', Component)

function Enemy:initialize(name, speed, stats)
    Component.initialize(self)

    self.name = name
    -- speed (slow = 10, medium = 25, fast = 40)
    self.speed = speed
    self.stats = stats or Enemy.Stats()
end

Enemy.Stats = Class('Enemy Stats')

function Enemy.Stats:initialize(maxHP, physicalArmor, psychicArmor)
    self.HP = maxHP
    self.maxHP = maxHP
    self.physicalArmor = physicalArmor
    self.psychicArmor = psychicArmor
end

function Enemy.Stats:getValues()
    return {
        HP = self.maxHP,
        maxHP = self.maxHP,
        physicalArmor = self.physicalArmor,
        psychicArmor = self.psychicArmor
    }
end

function Enemy:takeDamage(damage)
    local damage = damage or 0
    self.stats.HP = self.stats.HP - damage
end

return Enemy
