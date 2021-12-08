local Card = Class{}
Card.holding = false

local offset_x = 10

local width = 100
local height = 150

local riseHeight = 25
local riseSpeed = 200
local returnSpeed = 2000

local STATE = {
    IN_HAND = 1,
    HOLD = 2,
    ON_TABLE = 3,
    RETURNING = 4
}

function Card:init(hand_point)
    self.hand_point = hand_point

    self.pos = Vector(0, 0)
    self.offset = Vector(0, 0)
    self.hold_point = Vector(0, 0)
    self.width = width
    self.height = height
    self.mouseIn = false
    self.text = ''
    self.state = STATE.IN_HAND
end

function Card:setPosition(pos)
    if self.state == STATE.IN_HAND then
        self.position = pos

        local p = pos-1
        self.pos.x = self.hand_point.x + (width*p) + (offset_x*p)
        self.pos.y = self.hand_point.y - height
    end
end

function Card:setText(text)
    self.text = text
end

function Card:isHeld()
    return self.state == STATE.HOLD
end

function Card:hold(doHold)
    if doHold then
        local mx, my = love.mouse.getPosition()
        self.hold_point = self.pos - Vector(mx, my) + self.offset

        self.state = STATE.HOLD
    else
        self.offset = Vector(0, 0)
        self.state = STATE.IN_HAND
    end
    Card.holding = doHold
end

function Card:returnToHand()
    self.state = STATE.RETURNING
    Card.holding = false
end

function Card:isPointInside(point)
    local rect = { self.pos.x, self.pos.y, self.pos.x+self.width, self.pos.y+self.height }

    if self.state == STATE.IN_HAND then
        rect[2] = rect[2] + self.offset.y
    else
        rect[1] = rect[1] + self.offset.x
        rect[2] = rect[2] + self.offset.y
        rect[3] = rect[3] + self.offset.x
        rect[4] = rect[4] + self.offset.y
    end

    return IsPointInsideRect(rect, point)
end

function Card:update(dt)
    local mx, my = love.mouse.getPosition()
    local mouseOver = self:isPointInside({mx, my})

    if self.state == STATE.IN_HAND then
        if mouseOver and not Card.holding then
            self.offset.y = math.max(self.offset.y - dt*riseSpeed, -riseHeight)
        else
            self.offset.y = math.min(self.offset.y + dt*riseSpeed, 0)
        end
    elseif self.state == STATE.HOLD then
        self.offset = Vector(mx, my) + self.hold_point - self.pos
    elseif self.state == STATE.RETURNING then
        local return_pos = self.pos:clone()

        local vec = ((self.pos + self.offset) - return_pos):normalized() * returnSpeed * dt

        if ((self.pos + self.offset) - return_pos):len() < vec:len() then
            self.offset = Vector(0, 0)
            self.state = STATE.IN_HAND
        else
            self.offset = self.offset - vec
        end
    end
end

function Card:draw()
    local x, y = self.pos.x+self.offset.x, self.pos.y+self.offset.y
    local mx, my = love.mouse.getPosition()
    local mouseOver = self:isPointInside({mx, my})

    local color = { 1, 1, 1, 1 }
    if mouseOver and self.state == STATE.IN_HAND and not Card.holding then
        color = { 0.4, 0.4, 1, 1 }
    end

    love.graphics.setColor(color)
    love.graphics.rectangle('line', x, y, self.width, self.height)

    love.graphics.print(self.text, x+5, y+5)
end

return Card