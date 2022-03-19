local Card = require 'card'
local Board = Class{}

---comment
---@param x number center x
---@param y number top y
function Board:init(x, y, width, height)
    self.pos = Vector(x-width/2, y)
    self.spaces = {}
    self.width = width
    self.height = height
    self.card = false
    -- self.free = true
end

function Board:isPointInside(point)
    local rect = { self.pos.x, self.pos.y, self.pos.x+self.width, self.pos.y+self.height }
    return IsPointInsideRect(rect, point)
end

function Board:update(dt)
    
end

function Board:draw()
    local mx, my = love.mouse.getPosition()
    local x, y = self.pos:unpack()
    local color = { 1, 1, 1, 1 }

    if Card.holding and IsPointInsideRect({x, y, x+self.width, y+self.height}, {mx, my}) then
        color = { 0.5, 1, 0.5, 1 }
    end

    love.graphics.setColor(color)
    love.graphics.rectangle('line', x, y, self.width, self.height)
end

return Board