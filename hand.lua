local Card = require 'card'
local Hand = Class{}

local N = 1
local holdTime = 0.1

---Hand of a cards
---@param x number right
---@param y number bottom
function Hand:init(x, y, board)
    self.pos = Vector(x, y)
    self.cards = {}
    self.maxCards = 10
    self.clickTime = 0
    self.board = board
    self.index = 0
end

function Hand:addCard(card)
    if not Card.holding then
        if self.index < self.maxCards then
            self.index = self.index + 1
            card = card or Card(self.pos, self.board)
            if not card.board then card.board = self.board end
            card:setText(N)
            self.cards[#self.cards+1] = card
            self.cards[card] = #self.cards
            card:setPosition(self.index)
            
            N = N + 1
        end
    end
end

function Hand:rearrange(n, remove)
    if remove then
        for i = n+1, #self.cards do
            local card = self.cards[i]
            self.cards[n] = card
            self.cards[card] = n
            n = n + 1
        end
        self.cards[n] = nil
    else
        local j = 1
        for i = 1, #self.cards do
            local card = self.cards[i]
            if not card:isOnBoard() then
                self.cards[i]:setPosition(j)
                j = j + 1
            end
        end
        self.index = self.index - 1
    end
end

---comment
---@param card nil or Card or number
function Hand:removeCard(card)
    if not Card.holding then
        if card == nil then
            for i, v in ipairs(self.cards) do
                if v:isOnBoard() then
                    local mx, my = love.mouse.getPosition()
                    if (v:isPointInside({mx, my})) then
                        self:removeCard(i)
                        return
                    end
                end
            end
        elseif type(card) == "table" then
            self:removeCard(card.position)
        elseif type(card) == "number" then
            self.cards[card]:remove()
            self:rearrange(card, true)
        end
    end
end

function Hand:update(dt)
    for i, v in ipairs(self.cards) do
        v:update(dt)
    end
    if Card.holding then
        self.clickTime = self.clickTime + dt
    end
end

function Hand:draw()
    for i, v in ipairs(self.cards) do
        v:draw()
    end
end

function Hand:keypressed(key)
    
end

function Hand:mousepressed( x, y, button, istouch, presses )
    if button == 1 then
        if Card.holding then
            for i, v in ipairs(self.cards) do
                if v:isHeld() then
                    if v:release(x, y) then
                        self:rearrange(v.position)
                    end
                end
            end
        else
            for i, v in ipairs(self.cards) do
                if (v:isPointInside({x, y})) and not v.locked then
                    v:hold(true)
                    self.clickTime = 0
                    return
                end
            end
        end
    end
end

function Hand:mousereleased( x, y, button, istouch, presses )
    if button == 1 then
        if Card.holding
        and self.clickTime > holdTime then
            for i, v in ipairs(self.cards) do
                if v:isHeld() then
                    if v:release(x, y) then
                        self:rearrange(v.position)
                    end
                end
            end
        end
    end
end

return Hand