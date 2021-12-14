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
end

function Hand:addCard(card)
    if not Card.holding then
        if #self.cards < self.maxCards then
            card = card or Card(self.pos, self.board)
            if not card.board then card.board = self.board end
            card:setText(N)
            self.cards[#self.cards+1] = card
            card:setPosition(#self.cards)
            
            N = N + 1
        end
    end
end

---comment
---@param card nil or Card or number
function Hand:removeCard(card)
    if not Card.holding then
        if card == nil then
            for i, v in ipairs(self.cards) do
                local mx, my = love.mouse.getPosition()
                if (v:isPointInside({mx, my})) then
                    self:removeCard(v.position)
                    return
                end
            end
        elseif type(card) == "table" then
            self:removeCard(card.position)
        elseif type(card) == "number" then
            self.cards[card]:remove()
            for i = card, #self.cards-1 do
                self.cards[i] = self.cards[i+1]
                self.cards[i]:setPosition(i)
            end
            self.cards[#self.cards] = nil
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
                    v:release(x, y)
                end
            end
        else
            for i, v in ipairs(self.cards) do
                if (v:isPointInside({x, y})) then
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
                    v:release(x, y)
                end
            end
        end
    end
end

return Hand