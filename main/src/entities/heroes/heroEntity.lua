local Transform = require 'src.components.transform'
local Sprite = require 'src.components.sprite'
local Animator = require 'src.components.animator'
local Hero = require 'src.components.hero'
local Draggable = require 'src.components.draggable'
local Area = require 'src.components.area'
local Inspectable = require 'src.components.inspectable'
local Entity = require 'src.entities.entity'

local HeroEntity = Class('HeroEntity', Entity)

function HeroEntity:initialize(slot, image, name, traits, baseStats, skill)
    Entity.initialize(self)

    self:addComponent(Transform(0, 0, 0, 2, 2))

    self:addComponent(Sprite(image, 10))

    self:addComponent(Animator())

    self:addComponent(Area(36, 36))

    self:addComponent(Inspectable(nil, 3, 1, 'hero', Hero(name, traits, baseStats, skill)))

    self:addComponent(Hero(name, traits, baseStats, skill))

    self:addComponent(Draggable(slot, 'hero'))
end

return HeroEntity