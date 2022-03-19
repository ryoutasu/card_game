local Card = Class{}
Card.holding = false

local offset_x = 10

local width = 100
local height = 150

local riseHeight = 30

local STATE = {
    IN_HAND = 1,
    HOLD = 2,
    ON_BOARD = 3,
    MOVING = 4
}

function Card:init(hand_point, board)
    self.hand_point = hand_point

    self.pos = Vector(0, 0)
    self.offset = Vector(0, 0)
    self.hold_point = Vector(0, 0)
    self.width = width
    self.height = height
    self.board = board
    self.text = ''
    self.state = STATE.IN_HAND
    self.space = nil
    self.locked = false
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

function Card:release(x, y)
    local board = self.board
    local space = board:isPointInside({x, y})
    if space and space.free then
        self.state = STATE.MOVING
        self.nextState = STATE.ON_BOARD

        local pos = self.pos + self.offset
        -- self.pos = space.pos:clone()
        self.pos = CenterOf(space)-Vector(self.width/2,self.height/2)
        self.offset = pos - self.pos
        Card.holding = false

        space.free = false
        self.space = space
        self.locked = true
        return true
    else
        self:returnToHand()
        return false
    end
end

function Card:returnToHand()
    self.state = STATE.MOVING
    self.nextState = STATE.IN_HAND
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

function Card:remove()
    if self.space then
        self.space.free = true
        self.space = nil
    end
end

function Card:isOnBoard()
    return self.state == STATE.ON_BOARD or self.nextState == STATE.ON_BOARD
end

function Card:update(dt)
    local mx, my = love.mouse.getPosition()
    local mouseOver = self:isPointInside({mx, my})

    if self.state == STATE.IN_HAND then
        if mouseOver and not Card.holding then
            self.offset.y = math.lerp(self.offset.y, -riseHeight, 0.1)
        else
            self.offset.y = math.lerp(self.offset.y, 0, 0.1)
        end
    elseif self.state == STATE.HOLD then
        self.offset = Vector(mx, my) + self.hold_point - self.pos
    elseif self.state == STATE.MOVING then
        self.offset.x = math.lerp(self.offset.x, 0, 0.1)
        self.offset.y = math.lerp(self.offset.y, 0, 0.1)

        if self.offset:len() < 1 then
            self.offset = Vector(0, 0)
            self.state = self.nextState
        end
    end
end

function Card:draw()
    local x, y = (self.pos+self.offset):unpack()
    local mx, my = love.mouse.getPosition()
    local mouseOver = self:isPointInside({mx, my})

    local color = { 1, 1, 1, 1 }
    if (mouseOver and self.state == STATE.IN_HAND and not Card.holding) then
        color = { 0.2, 0.2, 1, 1 }
    elseif self.state == STATE.HOLD then
        color = { 0.6, 0.6, 1, 1 }
    end

    love.graphics.setColor(color)
    love.graphics.rectangle('line', x, y, self.width, self.height)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(self.text, x+5, y+5)
    love.graphics.print(self.state, x+5, y+20)
    if self.state == STATE.IN_HAND then
        love.graphics.print(self.position, x+5, y+35)
    end
end

return Card