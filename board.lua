local Card = require 'card'
local Board = Class{}

local spaceWidth = 110
local spaceHeight = 160
local offset_x = 15

---comment
---@param x number center x
---@param y number top y
---@param spaces number number of spaces
function Board:init(x, y, spaces)
    self.pos = Vector(x, y)
    self.spaces = {}
    local width = spaces*spaceWidth + (spaces-1)*offset_x
    local start_x = x - width/2

    for i = 1, spaces do
        local sx = start_x + offset_x*(i-1) + spaceWidth*(i-1)
        local s = {
            pos = Vector(sx, y),
            width = spaceWidth,
            height = spaceHeight,
            free = true
        }
        self.spaces[i] = s
    end
end

function Board:isPointInside(point)
    for i, v in ipairs(self.spaces) do
        local rect = { v.pos.x, v.pos.y, v.pos.x+v.width, v.pos.y+v.height }
        if IsPointInsideRect(rect, point) then
            return v
        end
    end
    return false
end

function Board:update(dt)
    
end

function Board:draw()
    local mx, my = love.mouse.getPosition()
    for i, v in ipairs(self.spaces) do
        local x, y = v.pos:unpack()
        local color = { 1, 1, 1, 1 }

        if Card.holding and IsPointInsideRect({x, y, x+v.width, y+v.height}, {mx, my}) then
            color = { 0.5, 1, 0.5, 1 }
        end

        love.graphics.setColor(color)
        love.graphics.rectangle('line', x, y, v.width, v.height)
    end
end

return Board